(***************************************************)
(*                                                 *)
(*      Forward/Backward Termination Iterator      *)
(*                                                 *)
(*                  Caterina Urban                 *)
(*     École Normale Supérieure, Paris, France     *)
(*                   2012 - 2015                   *)
(*                                                 *)
(***************************************************)

open Typed_syntax
open InvMap
open Config
open Apron
open Dnew.Domain
open Dnew.Functions
open Semantics
open Dnew.DecisionTree
open ForwardNew
open VarSet
open Utils.Datatypes

module TerminationIteratorNew =
functor
  (D : RANKING_FUNCTION)
  ->
  struct
    type r = D.t

    module D = D
    module B = D.B
    module ForwardIteratorB = ForwardIterator (B)

    let dummy_prop = Ctl (CTLIterator.atomic_property_of_bexp A_TRUE)
    let fwdInvMap = ref InvMap.empty
    let fwdTaintMap = ref InvMap.empty
    let bwdInvMap = ref InvMap.empty
    let addBwdInv l (a : D.t) = bwdInvMap := InvMap.add l a !bwdInvMap

    let bwdMap_print fmt m =
      InvMap.iter
        (fun l a -> Format.fprintf fmt "%a: %a\n" label_print l D.print a)
        m

    let blockLabel b =
      match b with T_empty (l, _) -> l | T_stat ((l, _), _, _) ->  l
      

    (*Backward Iterator + Recursion *)
    let rec bwdStm ?property ?domain funcs env vars p s =
      match s with
      | T_label _ | T_print _ | T_add_var (_, None) | T_del_var _ -> p
      | T_RETURN -> D.zero ?domain env vars
      | T_BREAK -> raise (UnsupportedFeature "break")
      | T_add_var (v, Some (exp, typ, ext)) | T_assign ((v, _), (exp, typ, ext))
        ->
          D.bwdAssign ?domain ~taint:true ~underapprox:false p
            ((T_var v, typ, ext), (exp, typ, ext))
      | T_assert (b, _) | T_assume b -> D.filter ?domain p b
      | T_if ((b, typ, ba), s1, s2) ->
          let uap = false in
          let p1 = bwdBlk funcs env vars p s1 in
          let p1 = D.filter ?domain ~underapprox:uap p1 (b, typ, ba) in
          let p2 = bwdBlk funcs env vars p s2 in
          let p2 =
            D.filter ?domain ~underapprox:uap p2 (neg_bexp (b, typ, ba))
          in
          if !tracebwd && not !minimal then (
            Format.fprintf Format.std_formatter "if in p1: %a\n" D.print p1;
            Format.fprintf Format.std_formatter "p2: %a\n" D.print p2);
          let joinType = APPROXIMATION in
          D.join joinType p1 p2
      | T_while ((l, _), (b, t, ba), s) ->
          let a = InvMap.find l !fwdInvMap in
          let dm = if !refine then Some a else None in
          let uap = false in
          let p1 =
            D.filter ?domain:dm p ~underapprox:uap (neg_bexp (b, t, ba))
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
                max 0 ((!retrybwd * (!Config.ordmax + 1)) - n + !joinbwd)
              in
              if D.isLeq COMPUTATIONAL i' i then (
                if D.isLeq APPROXIMATION i' i then (
                  if !tracebwd && not !minimal then (
                    Format.fprintf !fmt "### %a:FIXPOINT ###:\n" label_print l;
                    Format.fprintf !fmt "i: %a\n" D.print i);
                  i)
                else
                  let i'' =
                    if n <= !joinbwd then i' else D.widen ~jokers i i'
                  in
                  if !tracebwd && not !minimal then
                    Format.fprintf !fmt "i'': %a\n" D.print i'';
                  let p2 = bwdBlk funcs env vars i'' s in
                  let p2' =
                    D.filter ?domain:dm ~underapprox:uap p2 (b, t, ba)
                  in
                  aux i'' p2' (n + 1))
              else
                let i'' =
                  if n <= !joinbwd then i'
                  else D.widen ~jokers i (D.join COMPUTATIONAL i i')
                in
                if !tracebwd && not !minimal then
                  Format.fprintf !fmt "i'': %a\n" D.print i'';
                let p2 = bwdBlk funcs env vars i'' s in
                let p2' = D.filter ?domain:dm ~underapprox:uap p2 (b, t, ba) in
                aux i'' p2' (n + 1)
          in
          let i = D.bot ?domain:dm env vars in
          let p2 = bwdBlk funcs env vars i s in
          let p2' = D.filter ?domain:dm ~underapprox:uap p2 (b, t, ba) in
          let p = aux i p2' 1 in
          addBwdInv l p;
          if !refine then D.refine p a else p
      | T_recall (f, ss) -> raise (UnsupportedConversion ("bwdStmt: T_Recall"))
      | T_call (f, ss) ->
            let zero = D.domain_zero p in 
            let p' =  bwdRec funcs env vars zero f.func_body in
            let b = InvMap.find (Z.succ (blockLabel f.func_body)) !fwdInvMap in
            D.meet APPROXIMATION (D.refine p b ) p'
      | T_expr e -> D.top env vars (* todo handle this *)

    and bwdBlk ?property funcs env vars p (b : block) : D.t =
      let result_print l p =
        Format.fprintf !fmt "### %a ###:\n%a@." label_print l D.print p
      in
      match b with
      | T_empty (l, _) ->
          let a = InvMap.find l !fwdInvMap in
          let p = if !refine then D.refine p a else p in
          if !tracebwd && not !minimal then result_print l p;
          addBwdInv l p;
          p
      | T_stat ((l, _), (s, _), b) ->
          stop := Sys.time ();
          if !stop -. !start > !timeout then raise Timeout
          else
            let b = bwdBlk funcs env vars p b in
            let a = InvMap.find l !fwdInvMap in
            (* let tvl = InvMap.find l !fwdTaintMap in *)
            let p =
              if !refine then bwdStm ~domain:a funcs env vars b s
              else bwdStm funcs env vars b s
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
      | T_if (_, s1, s2) ->
          initBlk env vars s1;
          initBlk env vars s2
      | T_while ((l, _), _, s) ->
          addBwdInv l (D.bot env vars);
          initBlk env vars s
      | _ -> ()

    and initBlk env vars b =
      match b with
      | T_empty (l, _) -> addBwdInv l (D.bot env vars)
      | T_stat ((l, _), (s, _), b) ->
          addBwdInv l (D.bot env vars);
          initStm env vars s;
          initBlk env vars b

    let analyze ?(precondition = Some (T_bool_const True)) ?property prog =
      let rec init_env xs env =
        match xs with
        | [] -> env
        | x :: xs ->
            if Environment.mem_var env (Var.of_string (Z.to_string x.var_id))
            then init_env xs env
            else
              init_env xs
                (Environment.add env
                   [| Var.of_string (Z.to_string x.var_id) |]
                   [||])
      in
      let block, funcmap, varmap = prog in
      let f = StringMap.find !Config.main funcmap in
      let retvars =
        StringMap.bindings funcmap
        |> List.fold_left (fun acc (_, f) -> f.func_return :: acc) []
        |> List.fold_left
             (fun acc ret -> match ret with None -> acc | Some v -> v :: acc)
             []
      in
      let v1 = snd (List.split (IdMap.bindings varmap)) in
      let v1 = v1 @ f.func_args @ retvars in
      let env = Environment.make [||] [||] in
      let env, vars =
        ForwardIteratorB.initBlock block (env, v1)
        |> ForwardIteratorB.initBlock f.func_body
      in
      let env = init_env v1 env in
      let s = f.func_body in
      initBlk env vars block;
      initBlk env vars s;
      (* TODO: handle functions calls *)
      (* Forward Analysis *)
      if !tracefwd && not !minimal then
        Format.fprintf !fmt "\nForward Analysis Trace:\n";
      let startfwd = Sys.time () in
      let _ = ForwardIteratorB.analyze prog in
      fwdInvMap := !ForwardIteratorB.fwdInvMap;
      fwdTaintMap := !ForwardIteratorB.fwdTaintMap;
      let stopfwd = Sys.time () in
      if not !minimal then (
        if !timefwd then
          Format.fprintf !fmt "\nForward Analysis (Time: %f s):\n"
            (stopfwd -. startfwd)
        else Format.fprintf !fmt "\nForward Analysis numerical:\n";
        ForwardIteratorB.fwdMap_print !fmt !fwdInvMap B.print
        (* Format.fprintf !fmt "\nForward Analysis taint: size %d\n"
        (InvMap.cardinal !fwdTaintMap); *)
        (* InvMap.iter
        (fun l a ->
          Format.printf "%a: %s\n" label_print l
            (VarSet.fold
               (fun x acc -> acc ^ "" ^ x.var_id ^ "{" ^ x.var_name ^ "}")
               a ""))
        !fwdTaintMap); *));
      (* Backward Analysis *)
      if !tracebwd && not !minimal then
        Format.fprintf !fmt "\nBackward Analysis Trace:\n";
      start := Sys.time ();
      let startbwd = Sys.time () in
      let i =
        bwdRec funcmap env vars
          (bwdRec funcmap env vars (D.zero env vars) s)
          block
      in
      let stopbwd = Sys.time () in
      if not !minimal then (
        if !timebwd then
          Format.fprintf !fmt "\nBackward Analysis (Time: %f s):\n"
            (stopbwd -. startbwd)
        else Format.fprintf !fmt "\nBackward Analysis:\n";
        bwdMap_print !fmt !bwdInvMap);
      tree := D.output_json vars i;
      Config.result := D.defined i;
      !Config.result
  end
