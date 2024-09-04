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

module ForwardIterator (B: PARTITION) =
struct
  (* compute invariant map based on forward analysis *)
  
  
  let rec assignedStmt stmt b fwdInvMap=
    match stmt with
      | A_label _ -> []
      | A_return -> []
      | A_assign ((A_var (x),(l,_)),(A_INPUT,_)) 
      | A_assign ((A_var (x),(l,_)),(A_RANDOM,_)) -> [x]
      | A_assign ((A_var (x),(l,_)),(exp,_)) -> [x]
      | A_assign _ -> []
      | A_assert _ -> []
      | A_if ((b,ba),s1,s2) ->
        let a1 = assignedBlk s1 b fwdInvMap in
        let a2 = assignedBlk s2 (fst (negBExp (b,ba))) fwdInvMap in
        a1@a2
      | A_while (l,(b,ba),s) ->
        assert false
      | A_call (f,ss) ->
        raise (Invalid_argument "fwdStm:A_call")
      | A_recall (f,ss) -> raise (Invalid_argument "fwdStm:A_recall")
    and assignedBlk block bnum fwdInvMap =
      match block with
      | A_empty l ->
        []
      | A_block (l,(s,_),b) ->
        (assignedStmt s (InvMap.find l fwdInvMap) fwdInvMap) @ (assignedBlk b bnum fwdInvMap)
      

  let dep (vars, stmts, funcs) main env fwdInvMap =
    let fwdTaintMap = ref InvMap.empty in
    let addFwdInv l (a: var list) = fwdTaintMap := InvMap.add l a !fwdTaintMap in
    let rec fwdStm dpl s num_env =
      match s with
      | A_label _ -> dpl
      | A_return -> dpl
      (* Random sequence read is controlled or not ? *)
      | A_assign ((A_var (x),(l,_)),(exp,_)) ->
        let dpl = List.filter (fun v -> v.varName <> x.varName ) dpl in 
        if B.taint exp num_env dpl env then
          x::dpl
        else 
          dpl
      | A_assign ((l, _),(e,_)) -> 
        dpl
      | A_assert (b,_) -> dpl
      | A_if ((b,ba),s1,s2) ->
        let num_env1 = B.filter num_env b in
        let num_env2 = B.filter num_env (fst (negBExp (b,ba))) in
        let diff = 
          if B.taint_b b num_env dpl env then 
            assignedStmt s num_env fwdInvMap
          else
            []
        in 
        let dpl1 = B.refine dpl num_env1 env in 
        let dpl2 = B.refine dpl num_env2 env in 
        let dpl1 = fwdBlk dpl1 s1 in
        let dpl2 = fwdBlk dpl2 s2 in
        List.sort_uniq (fun v1 v2 -> String.compare v1.varName v2.varName) (dpl@dpl1@dpl2@diff)
      | A_while (l,(b,ba),s) ->
        (* attention *)
        let rec aux dpl_1 = 
          let dpl_2 = fwdStm dpl_1 (A_if ((b,ba),s, A_empty l)) num_env in
          let res = List.sort_uniq (fun v1 v2 -> String.compare v1.varName v2.varName) (dpl_2@dpl_1@dpl) in 
          let cmp =  (List.for_all  (fun x -> List.mem x res) dpl_1) in 
          if cmp then
             let num_env = B.filter num_env (fst (AbstractSyntax.negBExp (b,ba))) in
             B.refine res num_env env
          else
            aux res 
          in 
          aux []
      | A_call (f,ss) ->
        raise (Invalid_argument "fwdStm:A_recall")
      | A_recall (f,ss) -> raise (Invalid_argument "fwdStm:A_recall")
    and fwdBlk (dpl: var list) (b:block) =
      match b with
      | A_empty l ->
        (* if !tracefwd && not !minimal then *)
        if true then
          Format.fprintf !fmt "Taint at %a ###: %a\n" label_print l (fun fmt dpl -> List.iter (fun v -> Format.fprintf fmt "%s" v.varName) dpl)  dpl ;
        addFwdInv l dpl; dpl
      | A_block (l,(s,_),b) ->
        (* if !tracefwd && not !minimal then *)
        if true then
          Format.fprintf !fmt "Taint at %a ###: %a\n" label_print l (fun fmt dpl -> List.iter (fun v -> Format.fprintf fmt "%s" v.varName) dpl) dpl;
        addFwdInv l dpl; fwdBlk (fwdStm dpl s (InvMap.find l fwdInvMap)) b
    in 
    let f = StringMap.find main funcs in
    let s = f.funcBody in
    let _ = fwdBlk (fwdBlk [] stmts) s in
    !fwdTaintMap

  let compute (vars, stmts, funcs) p  main env = 
    let fwdInvMap = ref InvMap.empty in
    let addFwdInv l (a:B.t) = fwdInvMap := InvMap.add l a !fwdInvMap in
    let rec fwdStm p s =
      match s with
      | A_label _ -> p
      | A_return -> B.bot env vars
      | A_assign ((l,_),(e,_)) -> B.fwdAssign p (l,e)
      | A_assert (b,_) -> B.filter p b
      | A_if ((b,ba),s1,s2) ->
        let p1 = fwdBlk (B.filter p b) s1 in
        let p2 = fwdBlk (B.filter p (fst (negBExp (b,ba)))) s2 in
        B.join p1 p2
      | A_while (l,(b,ba),s) ->
        let rec aux i p2 n =
          let i' = B.join p p2 in
          if !tracefwd && not !minimal then begin
            Format.fprintf !fmt "### %a:%i ###:\n" label_print l n;
            Format.fprintf !fmt "p: %a\n" B.print p;
            Format.fprintf !fmt "i: %a\n" B.print i;
            Format.fprintf !fmt "p2: %a\n" B.print p2;
            Format.fprintf !fmt "i': %a\n" B.print i';
          end;
          if B.isLeq i' i then i
          else
            let i'' = if n <= !joinfwd then i' else B.widen i i' in
            if !tracefwd && not !minimal then Format.fprintf !fmt "i'': %a\n" B.print i'';
            aux i'' (fwdBlk (B.filter i'' b) s) (n+1)
        in
        let i = B.bot env vars in
        let p2 = fwdBlk (B.filter i b) s in
        let p = aux i p2 1 in
        addFwdInv l p;
        B.filter p (fst (negBExp (b,ba)))
      | A_call (f,ss) ->
        let f = StringMap.find f funcs in
        let p = List.fold_left (fun ap (s,_) -> fwdStm p s) p ss in
        fwdBlk p f.funcBody
      | A_recall (f,ss) -> raise (Invalid_argument "fwdStm:A_recall")
    and fwdBlk (p:B.t) (b:block) : B.t =
      match b with
      | A_empty l ->
        if !tracefwd && not !minimal then
          Format.fprintf !fmt "### %a ###: %a\n" label_print l B.print p;
        addFwdInv l p; p
      | A_block (l,(s,_),b) ->
        if !tracefwd && not !minimal then
          Format.fprintf !fmt "### %a ###: %a\n" label_print l B.print p;
        addFwdInv l p; fwdBlk (fwdStm p s) b
    in 
    let f = StringMap.find main funcs in
    let s = f.funcBody in
    let _ = fwdBlk  (fwdBlk p stmts) s in
    !fwdInvMap

end
