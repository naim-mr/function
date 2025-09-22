(***************************************************)
(*                                                 *)
(*      Forward/Backward Termination Iterator      *)
(*                                                 *)
(*                  Caterina Urban                 *)
(*     École Normale Supérieure, Paris, France     *)
(*                   2012 - 2015                   *)
(*                                                 *)
(***************************************************)

open AbstractSyntax
open InvMap
open Config
open Apron
open Domain
open Functions
open Semantics
open DecisionTree
open ForwardIterator
open AbstractSyntax
open VarSet
open Taint

module TerminationIterator (D : RANKING_FUNCTION) : SEMANTIC = struct
  type r = D.t * D.t * bool

  module D = D
  module B = D.B
  module ForwardIteratorB = ForwardIterator (B)

  let dummy_prop = Exp StringMap.empty
  let fwdInvMap = ref InvMap.empty
  let fwdTaintMap = ref InvMap.empty
  let bwdInvMap = ref InvMap.empty
  let addBwdInv l (a : D.t) = bwdInvMap := InvMap.add l a !bwdInvMap

  let bwdMap_print fmt m =
    InvMap.iter
      (fun l a -> Format.fprintf fmt "%a: %a\n" label_print l D.print a)
      m

  (*Backward Iterator + Recursion *)
  let rec bwdStm ?property ?domain funcs env vars p s tvl =
    match s with
    | A_label _ -> p
    | A_return -> D.zero ?domain env vars
    | A_assign ((l, _), (A_INPUT, _)) ->
        let uap = false in
        D.bwdAssign ?domain ~taint:true ~underapprox:uap p (l, A_INPUT)
    | A_assign ((l, _), (e, _)) ->
        let e_vars = Taint.avars (e, l) in
        let uap = false in
        let taint =
          VarSet.is_empty (VarSet.inter e_vars tvl) || not !Config.resilience
        in
        D.bwdAssign ?domain ~taint ~underapprox:uap p (l, e)
    | A_assert (b, _) -> D.filter ?domain p b
    | A_if ((b, ba), s1, s2) ->
        let uap = false in
        let taint = Taint.taint_b (b, ba) tvl && !Config.resilience in
        let p1 = bwdBlk funcs env vars p s1 in
        let p1 = D.filter ?domain ~taint ~underapprox:uap p1 b in
        let p2 = bwdBlk funcs env vars p s2 in
        let p2 =
          D.filter ?domain ~taint ~underapprox:uap p2 (fst (negBExp (b, ba)))
        in
        if !tracebwd && not !minimal then (
          Format.fprintf Format.std_formatter "if in p1: %a\n" D.print p1;
          Format.fprintf Format.std_formatter "p2: %a\n" D.print p2);
        let joinType =
          if taint || not !Config.resilience then APPROXIMATION
          else APPROXIMATION (* resilience *)
        in
        D.join joinType p1 p2
    | A_while (l, (b, ba), s) ->
        let a = InvMap.find l !fwdInvMap in
        let dm = if !refine then Some a else None in
        let uap = false in
        let p1 =
          D.filter ?domain:dm p ~underapprox:uap (fst (negBExp (b, ba)))
        in
        let rec aux i p2 n =
          if !abort then raise Abort
          else
            let i' = D.join APPROXIMATION p1 p2 in
            if !tracebwd && not !minimal then (
              Format.fprintf !fmt "### %a:%i ###:\n" label_print l n;
              Format.fprintf !fmt "p1: %a\n" D.print p1;
              Format.fprintf !fmt "i: %a\n" D.print i;
              Format.fprintf !fmt "p2: %a\n" D.print p2;
              Format.fprintf !fmt "i': %a\n" D.print i');
            let jokers =
              0
              (* max 0 ((!retrybwd * (!Config.ordmax + 1)) - n + !joinbwd) *)
            in
            if D.isLeq COMPUTATIONAL i' i then (
              if D.isLeq APPROXIMATION i' i then (
                if !tracebwd && not !minimal then (
                  Format.fprintf !fmt "### %a:FIXPOINT ###:\n" label_print l;
                  Format.fprintf !fmt "i: %a\n" D.print i);
                i)
              else
                let i'' = if n <= !joinbwd then i' else D.widen ~jokers i i' in
                if !tracebwd && not !minimal then
                  Format.fprintf !fmt "i'': %a\n" D.print i'';
                let p2 = bwdBlk funcs env vars i'' s in
                let p2' = D.filter ?domain:dm ~underapprox:uap p2 b in
                aux i'' p2' (n + 1))
            else
              let i'' =
                if n <= !joinbwd then i'
                else D.widen ~jokers i (D.join COMPUTATIONAL i i')
              in
              if !tracebwd && not !minimal then
                Format.fprintf !fmt "i'': %a\n" D.print i'';
              let p2 = bwdBlk funcs env vars i'' s in
              let p2' = D.filter ?domain:dm ~underapprox:uap p2 b in
              aux i'' p2' (n + 1)
        in
        let i = D.bot ?domain:dm env vars in
        let p2 = bwdBlk funcs env vars i s in
        let p2' = D.filter ?domain:dm ~underapprox:uap p2 b in
        let p = aux i p2' 1 in
        addBwdInv l p;
        if !refine then D.refine p a else p
    | A_call (f, ss) ->
        let f = StringMap.find f funcs in
        let p = bwdRec funcs env vars p f.funcBody in
        List.fold_left
          (fun ap (s, _) ->
            bwdStm ?domain funcs env vars ap s tvl)
          p ss
    | A_recall (f, ss) -> failwith "Recursive function call are not supported"
  (* (match domain with
       | None ->
         List.fold_left (fun (ap, ar, aflag) (s, _) ->
             bwdStm funcs env vars (ap, ar, aflag) s tvl
           ) (D.join APPROXIMATION p r, r, true) ss
       | Some domain ->
         List.fold_left (fun (ap, ar, aflag) (s, _) ->
             bwdStm ~domain:domain funcs env vars (ap, ar, aflag) s tvl
           ) (r, r, true) ss) *)

  and bwdBlk ?property funcs env vars p (b : block) : D.t =
    let result_print l p =
      Format.fprintf !fmt "### %a ###:\n%a@." label_print l D.print p
    in
    match b with
    | A_empty l ->
        let a = InvMap.find l !fwdInvMap in
        let p = if !refine then D.refine p a else p in
        if !tracebwd && not !minimal then result_print l p;
        addBwdInv l p;
        p
    | A_block (l, (s, _), b) ->
        stop := Sys.time ();
        if !stop -. !start > !timeout then raise Timeout
        else
          let b = bwdBlk funcs env vars p b in
          let a = InvMap.find l !fwdInvMap in
          let tvl = InvMap.find l !fwdTaintMap in
          let p =
            if !refine then bwdStm ~domain:a funcs env vars b s tvl
            else bwdStm funcs env vars b s tvl
          in
          let p = if !refine then D.refine p a else p in
          if !tracebwd && not !minimal then result_print l p;
          addBwdInv l p;
          p

  and bwdRec ?property funcs env vars (p : D.t) (b : block) : D.t =
    bwdBlk funcs env vars p b
    

  (* Analyzer *)
  let rec initStm env vars s =
    match s with
    | A_if (_, s1, s2) ->
        initBlk env vars s1;
        initBlk env vars s2
    | A_while (l, _, s) ->
        addBwdInv l (D.bot env vars);
        initBlk env vars s
    | _ -> ()

  and initBlk env vars b =
    match b with
    | A_empty l -> addBwdInv l (D.bot env vars)
    | A_block (l, (s, _), b) ->
        addBwdInv l (D.bot env vars);
        initStm env vars s;
        initBlk env vars b

  let analyze ?(precondition = Some A_TRUE) ?property (vars, stmts, funcs) main
      =
    let rec init_env xs env =
      match xs with
      | [] -> env
      | x :: xs ->
          init_env xs (Environment.add env [| Var.of_string x.varId |] [||])
    in
    let f = StringMap.find main funcs in
    let v1 = snd (List.split (StringMap.bindings vars)) in
    let v2 = snd (List.split (StringMap.bindings f.funcVars)) in
    let v1set = VarSet.of_list v1 in
    let v2set = VarSet.of_list v2 in
    let var_set = VarSet.union v1set v2set in
    let vars = List.append v1 v2 in
    let env = init_env vars (Environment.make [||] [||]) in
    let s = f.funcBody in
    initBlk env vars stmts;
    initBlk env vars s;
    (* TODO: handle functions calls *)
    (* Forward Analysis *)
    if !tracefwd && not !minimal then
      Format.fprintf !fmt "\nForward Analysis Trace:\n";
    let startfwd = Sys.time () in
    let _ =
      ForwardIteratorB.fwdBlk funcs env vars
        (ForwardIteratorB.fwdBlk funcs env vars (B.top env vars) stmts)
        s
    in
    let _ = ForwardIteratorB.fwdTBlk funcs var_set stmts in
    let _ = ForwardIteratorB.fwdTBlk funcs var_set s in
    fwdInvMap := !ForwardIteratorB.fwdInvMap;
    fwdTaintMap := !ForwardIteratorB.fwdTaintMap;
    let stopfwd = Sys.time () in
    if not !minimal then (
      if !timefwd then
        Format.fprintf !fmt "\nForward Analysis (Time: %f s):\n"
          (stopfwd -. startfwd)
      else Format.fprintf !fmt "\nForward Analysis numerical:\n";
      ForwardIteratorB.fwdMap_print !fmt !fwdInvMap B.print;
      Format.fprintf !fmt "\nForward Analysis taint: size %d\n"
        (InvMap.cardinal !fwdTaintMap);
      InvMap.iter
        (fun l a ->
          Format.printf "%a: %s\n" label_print l
            (VarSet.fold
               (fun x acc -> acc ^ "" ^ x.varId ^ "{" ^ x.varName ^ "}")
               a ""))
        !fwdTaintMap);
    (* Backward Analysis *)
    if !tracebwd && not !minimal then
      Format.fprintf !fmt "\nBackward Analysis Trace:\n";
    start := Sys.time ();
    let startbwd = Sys.time () in
    let i =
      bwdRec funcs env vars (bwdRec funcs env vars (D.zero env vars) s) stmts
    in
    let stopbwd = Sys.time () in
    if not !minimal then (
      if !timebwd then
        Format.fprintf !fmt "\nBackward Analysis (Time: %f s):\n"
          (stopbwd -. startbwd)
      else Format.fprintf !fmt "\nBackward Analysis:\n";
      bwdMap_print !fmt !bwdInvMap);
    tree := D.output_json vars i;
    D.defined ?condition:precondition i
end
