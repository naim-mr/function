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
open SetTaint
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
  let rec bwdStm ?property ?domain funcs env vars (p, r, flag) s tvl =
    match s with
    | A_label _ -> (p, r, flag)
    | A_return -> (D.zero ?domain env vars, r, flag)
    | A_assign ((l, _), (A_INPUT, _)) ->
        let uap = false in
        ( D.bwdAssign ?domain ~taint:true ~underapprox:uap p (l, A_INPUT),
          r,
          flag )
    | A_assign ((l, _), (e, _)) ->
        let e_vars = Taint.avars (e, l) in
        let uap = false in
        let taint =
          SetTaint.is_empty (SetTaint.inter e_vars tvl) || not !Config.resilience
        in
        (D.bwdAssign ?domain ~taint ~underapprox:uap p (l, e), r, flag)
    | A_assert (b, _) -> (D.filter ?domain p b, r, flag)
    | A_if ((b, ba), s1, s2) ->
        let uap = false in
        let taint =
          Taint.taint_b (b, ba) tvl && !Config.resilience
        in
        let p1, _, flag1 = bwdBlk funcs env vars (p, r, flag) s1 in
        let p1 = D.filter ?domain ~taint ~underapprox:uap p1 b in
        let p2, _, flag2 = bwdBlk funcs env vars (p, r, flag) s2 in
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
        (D.join joinType p1 p2, r, flag1 || flag2)
    | A_while (l, (b, ba), s) ->
        let a = InvMap.find l !fwdInvMap in
        let dm = if !refine then Some a else None in
        let uap = false in
        let p1 =
          D.filter ?domain:dm p ~underapprox:uap (fst (negBExp (b, ba)))
        in
        let rec aux (i, _, _) (p2, _, flag2) n =
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
              (* max 0 ((!retrybwd * (!Ordinals.max + 1)) - n + !joinbwd) *)
            in
            if D.isLeq COMPUTATIONAL i' i then (
              if D.isLeq APPROXIMATION i' i then (
                if !tracebwd && not !minimal then (
                  Format.fprintf !fmt "### %a:FIXPOINT ###:\n" label_print l;
                  Format.fprintf !fmt "i: %a\n" D.print i);
                (i, r, flag2))
              else
                let i'' = if n <= !joinbwd then i' else D.widen ~jokers i i' in
                if !tracebwd && not !minimal then
                  Format.fprintf !fmt "i'': %a\n" D.print i'';
                let p2, _, flag2 = bwdBlk funcs env vars (i'', r, flag2) s in
                let p2' = D.filter ?domain:dm ~underapprox:uap p2 b in
                aux (i'', r, flag2) (p2', r, flag2) (n + 1))
            else
              let i'' =
                if n <= !joinbwd then i'
                else D.widen ~jokers i (D.join COMPUTATIONAL i i')
              in
              if !tracebwd && not !minimal then
                Format.fprintf !fmt "i'': %a\n" D.print i'';
              let p2, _, flag2 = bwdBlk funcs env vars (i'', r, flag2) s in
              let p2' = D.filter ?domain:dm ~underapprox:uap p2 b in
              aux (i'', r, flag2) (p2', r, flag2) (n + 1)
        in
        let i = (D.bot ?domain:dm env vars, r, flag) in
        let p2, _, flag2 = bwdBlk funcs env vars i s in
        let p2' = D.filter ?domain:dm ~underapprox:uap p2 b in
        let p, r, flag = aux i (p2', r, flag2) 1 in
        addBwdInv l p;
        if !refine then (D.refine p a, r, flag) else (p, r, flag)
    | A_call (f, ss) ->
        let f = StringMap.find f funcs in
        let p = bwdRec funcs env vars p f.funcBody in
        List.fold_left
          (fun (ap, ar, aflag) (s, _) ->
            bwdStm ?domain funcs env vars (ap, ar, aflag) s tvl)
          (p, r, flag) ss
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

  and bwdBlk ?property funcs env vars (p, r, flag) (b : block) :
      D.t * D.t * bool =
    let result_print l p =
      Format.fprintf !fmt "### %a ###:\n%a@." label_print l D.print p
    in
    match b with
    | A_empty l ->
        let a = InvMap.find l !fwdInvMap in
        let p = if !refine then D.refine p a else p in
        if !tracebwd && not !minimal then result_print l p;
        addBwdInv l p;
        (p, r, flag)
    | A_block (l, (s, _), b) ->
        stop := Sys.time ();
        if !stop -. !start > !timeout then raise Timeout
        else
          let b, rb, flagb = bwdBlk funcs env vars (p, r, flag) b in
          let a = InvMap.find l !fwdInvMap in
          let tvl = InvMap.find l !fwdTaintMap in
          let p, r, flag =
            if !refine then bwdStm ~domain:a funcs env vars (b, rb, flagb) s tvl
            else bwdStm funcs env vars (b, rb, flagb) s tvl
          in
          let p = if !refine then D.refine p a else p in
          if !tracebwd && not !minimal then result_print l p;
          addBwdInv l p;
          (p, r, flag)

  and bwdRec ?property funcs env vars (p : D.t) (b : block) : D.t =
    let res, _, _ = bwdBlk funcs env vars (p, D.bot env vars, false) b in
    res

  (* NOTE: unsound *)
  (* and bwdRec funcs env vars (p:D.t) (b:block) : D.t = *)
  (* let rec aux r n = *)
  (*   let (r',_,_) = bwdBlk funcs env vars (r,r,true) b in *)
  (*   if !tracebwd && not !minimal then begin *)
  (*     Format.fprintf !fmt "r: %a@." D.print r; *)
  (*     Format.fprintf !fmt "r': %a@." D.print r' *)
  (*   end; *)
  (*   if (D.isLeq COMPUTATIONAL r' r) *)
  (*   then *)
  (*     if (D.isLeq APPROXIMATION r' r) *)
  (*     then *)
  (*       let r = r in *)
  (*       if !tracebwd && not !minimal then begin *)
  (*         Format.fprintf !fmt "### REC-FIXPOINT ###:@."; *)
  (*         Format.fprintf !fmt "r: %a@." D.print r *)
  (*       end; *)
  (*       r *)
  (*     else *)
  (*       let r'' = if n <= !joinbwd then r' else D.widen r r' in *)
  (*       if !tracebwd && not !minimal then *)
  (*         Format.fprintf !fmt "r'': %a@." D.print r''; *)
  (*       aux r'' (n+1) *)
  (*   else *)
  (*     let r'' = if n <= !joinbwd then r' else *)
  (*         D.widen r (D.join COMPUTATIONAL r r') in *)
  (*     if !tracebwd && not !minimal then *)
  (*       Format.fprintf !fmt "r'': %a@." D.print r''; *)
  (*     aux r'' (n+1) *)
  (* in *)
  (* let (i,_,flag) = bwdBlk funcs env vars (p,D.bot env vars,false) b in *)
  (* if flag then aux i 1 *)
  (* else i *)

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
    let rec aux xs env =
      match xs with
      | [] -> env
      | x :: xs -> aux xs (Environment.add env [| Var.of_string x.varId |] [||])
    in
    let f = StringMap.find main funcs in
    let v1 = snd (List.split (StringMap.bindings vars)) in
    let v2 = snd (List.split (StringMap.bindings f.funcVars)) in
    let vars = List.append v1 v2 in
    let env = aux vars (Environment.make [||] [||]) in
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
    let _ =
      ForwardIteratorB.fwdTBlk funcs env (SetTaint.of_list vars)
        (snd @@ ForwardIteratorB.fwdTBlk funcs env vars (SetTaint.of_list vars) stmts)
        s
    in
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
            (SetTaint.fold (fun x acc -> acc ^ " " ^ x.varName) a ""))
        !fwdTaintMap);
    (* Backward Analysis *)
    if !tracebwd && not !minimal then
      Format.fprintf !fmt "\nBackward Analysis Trace:\n";
    start := Sys.time ();
    let startbwd = Sys.time () in
    let i =
      bwdRec funcs env vars (bwdRec funcs env vars (D.zero env vars) s) stmts
    in
    (* let i = 
      if !resilience then
       D.merge_after (List.fold_left (fun i x -> D.bwdAssign i (AbstractSyntax.A_var  x, A_RANDOM )) i (InvMap.find (block_label f.funcBody) !fwdTaintMap))
      else 
        i
    in *)
    let stopbwd = Sys.time () in
    if not !minimal then (
      if !timebwd then
        Format.fprintf !fmt "\nBackward Analysis (Time: %f s):\n"
          (stopbwd -. startbwd)
      else Format.fprintf !fmt "\nBackward Analysis:\n";
      bwdMap_print !fmt !bwdInvMap;);
    tree := D.output_json vars i;
    D.defined ?condition:precondition i
end
