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

  (*  Taint forward analysis *)
  (* Join of two list*)
  let join l1 l2 = 
    let l = l1 @ l2 in 
    List.sort_uniq (fun x y -> String.compare x.varId y.varId) l
  (* List of vars in an expression *)
  let avars (e,ext) =
      let rec aux e acc = 
        match e with
      | A_var x -> x::acc
      | A_interval _ |  A_const _ | A_INPUT | A_RANDOM -> acc
      | A_aunary (_,(a,_)) -> aux a acc 
      | A_abinary (_,(a1,_), (a2,_)) -> aux a1 acc @ aux a2 acc 
      in 
      aux e []
  (* Test if a boolean expression is taint *)
  let taint_b (e,ext) tvl =
      let rec aux e  = 
        match e with
      | A_MAYBE_INP  -> true
      | A_TRUE  | A_MAYBE	 	| A_FALSE -> false
      | A_bunary (_,(b,l)) -> aux b
      | A_bbinary (_,(b1,_),(b2,l)) -> aux b1 || aux b2
      | A_rbinary (_,a1,a2) -> let vl1 =  avars a1 in  
                               let vl2 =  avars a2 in 
                               if List.exists (fun x -> List.mem x tvl) vl1 || List.exists (fun x -> List.mem x tvl) vl2
                                then true
                              else false
      in 
      aux e 
  let assigned block =
        let rec aux stmt acc = 
         match stmt with 
        | A_assign ((A_var x ,_ ), (_,_))-> x :: acc
        | A_if ((b,ba),s1,s2) -> aux_block s1 acc @ aux_block s2 acc
        | A_while (l,(b,ba),s) -> aux_block s acc
        | _ -> acc
        and 
        aux_block s acc =  match s with 
        | A_empty l ->
           acc
        | A_block (l,(s,_),b) ->
          aux s acc @ aux_block b acc
        in
        aux_block block []
  (* Assgined block: return set of variables assigned in a block (only syntactic) *)
    let rec fwdTStm funcs env vars p s =

      match s with
      | A_label _ -> p
      | A_return -> p 
      | A_assign ((A_var x,_),(A_INPUT,_)) -> x::p
      | A_assign ((A_var x,_),(A_RANDOM,_)) -> List.filter (fun v -> v <> x ) p
      | A_assign ((A_var x,_),(e,l)) -> let e_vars = avars (e,l) in 
                                  if List.exists (fun x -> List.mem x e_vars) p
                                    then x::p
                                  else List.filter (fun v -> v <> x ) p
      | A_assign (_,_) -> p 
      | A_assert _  -> p
      | A_if ((b,ba),s1,s2) ->
        let assigned_vars = assigned s1 @ assigned s2 in 
        let r1 = fwdTBlk funcs env vars p s1 in
        let r2 = fwdTBlk funcs env vars p s2 in
        let iflow = if taint_b (b,ba) p then 
                    assigned_vars 
                    else []
        in
        join (join (snd r1) (snd r2)) iflow
      | A_while (l,(b,ba),s) ->
        let rec aux i p2 =
          if List.for_all (fun x-> List.mem x i) p2 then i
          else
            aux p2 (fwdTStm funcs env vars p2 (A_if ((b,ba),s, A_empty l)))
          in
        let i = p in
        let p2 = (fwdTStm funcs env vars i (A_if ((b,ba),s, A_empty l))) in
        let p = aux i p2 in
        addFwdTaint l p;
        p
      | A_call (f,ss) ->
        let f = StringMap.find f funcs in
        let p = List.fold_left (fun ap (s,_) -> fwdTStm funcs env vars p s) p ss in
        snd (fwdTBlk funcs env vars p f.funcBody)
      | A_recall (f,ss) -> raise (Invalid_argument "fwdStm:A_recall")
    and fwdTBlk funcs env vars (p:var list) (b:block) =
      
      
      match b with
      | A_empty l ->
        Printf.printf "empty debug cda %d \n" (InvMap.cardinal !fwdTaintMap);
        addFwdTaint l p; 
        !fwdTaintMap,p
      | A_block (l,(s,_),b) ->
        if !tracefwd && not !minimal then
          Format.printf "%a: %s\n" label_print l (List.fold_left (fun  acc x -> acc^"-"^x.varName) "" p);
        let p' = (fwdTStm funcs env vars p s) in 
        addFwdTaint l p; 
        fwdTBlk funcs env vars p' b
  and 
  fwdTaintMap = ref InvMap.empty
  and 
  addFwdTaint l (a:var list) = fwdTaintMap := InvMap.add l a !fwdTaintMap  
        

end
