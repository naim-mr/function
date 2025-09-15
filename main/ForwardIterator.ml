(*   
     ********* Forward Iterator ************
   Copyright (C) 2012-2014 by Caterina Urban. All rights reserved.
*)

open AbstractSyntax
open InvMap
open Apron
open Functions
open Config
open Semantics
open Domain
open Partition
open VarSet
open Taint

module ForwardIterator (B : PARTITION) = struct
  let fwdMap_print fmt m fprint =
    InvMap.iter
      (fun l a -> Format.fprintf fmt "%a: %a\n" label_print l fprint a)
      m

  let fwdMap_print fmt m fprint =
    InvMap.iter
      (fun l a -> Format.fprintf fmt "%a: %a\n" label_print l fprint a)
      m

  let fwdInvMap = ref InvMap.empty
  let addFwdInv l (a : B.t) = fwdInvMap := InvMap.add l a !fwdInvMap

  (* compute invariant map based on forward analysis *)
  let rec compute (vars, stmts, funcs) p main env =
    let f = StringMap.find main funcs in
    let s = f.funcBody in
    let _ = fwdBlk funcs env vars (fwdBlk funcs env vars p stmts) s in
    !fwdInvMap

  and fwdStm funcs env vars p s =
    match s with
    | A_label _ -> p
    | A_return -> B.bot env vars
    | A_assign ((l, _), (e, _)) -> B.fwdAssign p (l, e)
    | A_assert (b, _) -> B.filter p b
    | A_if ((b, ba), s1, s2) ->
        let p1 = fwdBlk funcs env vars (B.filter p b) s1 in
        let p2 =
          fwdBlk funcs env vars (B.filter p (fst (negBExp (b, ba)))) s2
        in
        B.join p1 p2
    | A_while (l, (b, ba), s) ->
        let rec aux i p2 n =
          let i' = B.join p p2 in
          if !tracefwd && not !minimal then (
            Format.fprintf !fmt "### %a:%i ###:\n" label_print l n;
            Format.fprintf !fmt "p: %a\n" B.print p;
            Format.fprintf !fmt "i: %a\n" B.print i;
            Format.fprintf !fmt "p2: %a\n" B.print p2;
            Format.fprintf !fmt "i': %a\n" B.print i');
          if B.isLeq i' i then i
          else
            let i'' = if n <= !joinfwd then i' else B.widen i i' in
            if !tracefwd && not !minimal then
              Format.fprintf !fmt "i'': %a\n" B.print i'';
            aux i'' (fwdBlk funcs env vars (B.filter i'' b) s) (n + 1)
        in
        let i = B.bot env vars in
        let p2 = fwdBlk funcs env vars (B.filter i b) s in
        let p = aux i p2 1 in
        addFwdInv l p;
        B.filter p (fst (negBExp (b, ba)))
    | A_call (f, ss) ->
        let f = StringMap.find f funcs in
        let p =
          List.fold_left (fun ap (s, _) -> fwdStm funcs env vars p s) p ss
        in
        fwdBlk funcs env vars p f.funcBody
    | A_recall (f, ss) -> raise (Invalid_argument "fwdStm:A_recall")

  and fwdBlk funcs env vars (p : B.t) (b : block) : B.t =
    match b with
    | A_empty l ->
        if !tracefwd && not !minimal then
          Format.fprintf !fmt "### %a ###: %a\n" label_print l B.print p;
        addFwdInv l p;
        p
    | A_block (l, (s, _), b) ->
        if !tracefwd && not !minimal then
          Format.fprintf !fmt "### %a ###: %a\n" label_print l B.print p;
        addFwdInv l p;
        fwdBlk funcs env vars (fwdStm funcs env vars p s) b

  (* Assgined block: return set of variables assigned in a block (only syntactic) *)
  let rec fwdTStm funcs p s =
    let open Taint in
    match s with
    | A_label _ -> p
    | A_return -> p
    | A_assign ((A_var x, _), (A_INPUT, _)) -> add x p
    | A_assign ((A_var x, _), (A_RANDOM, _)) ->
        filter (fun v -> String.compare v.varId x.varId != 0) p
    | A_assign ((A_var x, _), (e, l)) ->
        let e_vars = avars (e, l) in
        if is_bot (meet e_vars p) then add x p
        else filter (fun v -> String.compare v.varId x.varId != 0) p
    | A_assign (_, _) -> p
    | A_assert _ -> p
    | A_if ((b, ba), s1, s2) ->
        let assigned_vars = join (assigned s1) (assigned s2) in
        let r1 = fwdTBlk funcs p s1 in
        let r2 = fwdTBlk funcs p s2 in
        let iflow = if taint_b (b, ba) p then assigned_vars else VarSet.empty in
        join (join (snd r1) (snd r2)) iflow
    | A_while (l, (b, ba), s) ->
        let rec aux i p2 =
          if VarSet.subset i p2 then i
          else aux p2 (fwdTStm funcs p2 (A_if ((b, ba), s, A_empty l)))
        in
        let i = p in
        let p2 = fwdTStm funcs i (A_if ((b, ba), s, A_empty l)) in
        let p = aux i p2 in
        addFwdTaint l p;
        p
    | A_call (f, ss) ->
        let f = StringMap.find f funcs in
        let p = List.fold_left (fun ap (s, _) -> fwdTStm funcs p s) p ss in
        snd (fwdTBlk funcs p f.funcBody)
    | A_recall (f, ss) -> raise (Invalid_argument "fwdStm:A_recall")

  and fwdTBlk funcs p (b : block) =
    match b with
    | A_empty l ->
        addFwdTaint l p;
        (!fwdTaintMap, p)
    | A_block (l, (s, _), b) ->
        Format.printf "%a: %s\n" label_print l
          (VarSet.fold (fun x acc -> acc ^ "-" ^ x.varName) p "");
        let p' = fwdTStm funcs p s in
        addFwdTaint l p;
        fwdTBlk funcs p' b

  and fwdTaintMap : VarSet.t InvMap.t ref = ref InvMap.empty
  and addFwdTaint l (a : VarSet.t) = fwdTaintMap := InvMap.add l a !fwdTaintMap
end
