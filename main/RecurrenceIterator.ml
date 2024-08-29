(*   
     ********* Forward/Backward Recurrence Iterator ************
   Copyright (C) 2012-2014 by Caterina Urban. All rights reserved.
*)

open AbstractSyntax
open ForwardIterator
open InvMap
open Apron
open Config
open Domain
open Functions
open Semantics


module RecurrenceIterator (D: RANKING_FUNCTION) =
struct

  type r = D.t

  module D = D

  module B = D.B

  module ForwardIteratorB = ForwardIterator(B)
  type 'a p = (bExp*'a) StringMap.t
  let dummy_prop = Exp (StringMap.empty)
  let fwdInvMap = ref InvMap.empty

  let fwdMap_print fmt m = InvMap.iter (fun l a -> Format.fprintf fmt "%a: %a\n" label_print l B.print a) m

  let bwdInvMap = ref InvMap.empty


  let addBwdInv l (a:D.t) = bwdInvMap := InvMap.add l a !bwdInvMap

  let bwdMap_print fmt m =
    if !compress then
      InvMap.iter (fun l a -> Format.fprintf fmt "%a:\n%a\n" label_print l D.print (D.compress a)) m
    else
      InvMap.iter (fun l a -> Format.fprintf fmt "%a:\n%a\n" label_print l D.print a) m
  
  let rec initStm env vars s =
    match s with
    | A_if (_,s1,s2) -> initBlk env vars s1; initBlk env vars s2
    | A_while (l,_,s) -> 
      addBwdInv l (D.bot env vars); initBlk env vars s
    | _ -> ()

  and	initBlk env vars b =
    match b with
    | A_empty l -> addBwdInv l (D.bot env vars)
    | A_block (l,(s,_),b) -> addBwdInv l (D.bot env vars); 
      initStm env vars s; initBlk env vars b
    

  (* Backward Iterator *)

  let rec bwdStm ?(property = dummy_prop) ?domain funcs env vars p s =
    match s with
    | A_label (l,_) ->
      let p = try D.reset p (fst (StringMap.find l (Semantics.get_bexp property))) with Not_found -> p in p (* TODO: is this OK? *)
    | A_return -> D.bot env vars
    | A_assign ((l,_),(e,_)) -> D.bwdAssign p (l,e)
    | A_assert (b,_) -> D.filter p b
    | A_if ((b,ba),s1,s2) ->
      let p1 = D.filter (bwdBlk ~property:property funcs env vars p s1) b in
      let p2 = D.filter (bwdBlk ~property:property funcs env vars p s2) (fst (negBExp (b,ba))) in
      D.join APPROXIMATION p1 p2
    | A_while (l,(b,ba),s) ->
      let p1 = D.filter p (fst (negBExp (b,ba))) in
      let rec aux m o =
        let rec auxaux i p2 n =
          let i' = D.reset ~mask:m (D.join APPROXIMATION p1 p2) (fst (StringMap.find "" (Semantics.get_bexp property))) in
          if !tracebwd && not !minimal then begin
            Format.fprintf !fmt "### %a-INNER:%i ###:\n" label_print l n;
            Format.fprintf !fmt "p1: %a\n" D.print p1;
            Format.fprintf !fmt "i: %a\n" D.print i;
            Format.fprintf !fmt "p2: %a\n" D.print p2;
            Format.fprintf !fmt "i': %a\n" D.print i';
          end;
          if (D.isLeq COMPUTATIONAL i' i)
          then
            if (D.isLeq APPROXIMATION i' i)
            then
              let i = i in
              if !tracebwd && not !minimal then
                Format.fprintf !fmt "### %a-INNER:FIXPOINT ###:\n" label_print l;
              if !tracebwd && not !minimal then
                Format.fprintf !fmt "i: %a\n" D.print i;
              i
            else
              let i'' = if n <= !joinbwd then i' else D.widen i i' in
              if !tracebwd && not !minimal then
                Format.fprintf !fmt "i'': %a\n" D.print i'';
              auxaux i'' (D.filter (bwdBlk ~property:property funcs env vars i'' s) b) (n+1)
          else
            let i'' = if n <= !joinbwd then i' else D.widen i (D.join COMPUTATIONAL i i') in
            if !tracebwd && not !minimal then
              Format.fprintf !fmt "i'': %a\n" D.print i'';
            auxaux i'' (D.filter (bwdBlk ~property:property funcs env vars i'' s) b) (n+1)
        in

        if !tracebwd && not !minimal then
          Format.fprintf !fmt "### %a-OUTER:%i ###:\n" label_print l o;
        if !tracebwd && not !minimal then
          Format.fprintf !fmt "m: %a\n" D.print m;

        let p2 = D.filter (D.bot env vars) b in
        let p = auxaux (D.bot env vars) p2 1 in					
        let p = D.join APPROXIMATION p1 (D.filter (bwdBlk ~property:property funcs env vars p s) b) in

        if !tracebwd && not !minimal then
          Format.fprintf !fmt "p: %a\n" D.print p;

        let m' = D.meet APPROXIMATION m p in

        if !tracebwd && not !minimal then
          Format.fprintf !fmt "m': %a\n" D.print m';

        if (D.isLeq COMPUTATIONAL m' m) && (D.isLeq COMPUTATIONAL m m')
        then
          let p = p in
          if !tracebwd && not !minimal then begin
            Format.fprintf !fmt "### %a-OUTER:FIXPOINT ###:\n" label_print l;
            Format.fprintf !fmt "m: %a\n" D.print m;
          end;
          p
        else
          let m'' = if o <= !meetbwd then m' else D.dual_widen m m' in
          if !tracebwd && not !minimal then
            Format.fprintf !fmt "m'': %a\n" D.print m'';
          aux m'' (o+1)
      in
      let p = aux (D.top env vars) 1 in
      addBwdInv l p; p
    | A_call (f,ss) -> raise (Invalid_argument "bwdStm:A_call")
    | A_recall (f,ss) -> raise (Invalid_argument "bwdStm:A_recall")

  and bwdBlk ?(property = dummy_prop)  funcs env vars (p:r) (b:block) : r =
    match b with
    | A_empty l ->
      let a = InvMap.find l !fwdInvMap in
      let p = if !refine then D.refine p a else p in
      let m = if !refine then D.meet APPROXIMATION (D.refine (D.top env vars) a) p else D.meet APPROXIMATION (D.top env vars) p in
      let p = D.reset ~mask:m p (fst (StringMap.find "" (Semantics.get_bexp property))) in
      if !tracebwd && not !minimal then
        Format.fprintf !fmt "### %a ###:\n%a\n" label_print l D.print p;
      addBwdInv l p; p			  
    | A_block (l,(s,_),b) ->
      stop := Sys.time ();
      if ((!stop -. !start) > !timeout)
      then raise Timeout
      else
        let b = bwdBlk ~property:property funcs env vars p b in
        let p = bwdStm ~property:property funcs env vars b s in
        let a = InvMap.find l !fwdInvMap in
        let p = if !refine then D.refine p a else p in
        let m = if !refine then D.meet APPROXIMATION (D.refine (D.top env vars) a) p else D.meet APPROXIMATION (D.top env vars) p in
        let p = D.reset ~mask:m p (fst (StringMap.find "" (Semantics.get_bexp property))) in
        if !tracebwd && not !minimal then
          Format.fprintf !fmt "### %a ###:\n%a\n" label_print l D.print p;
        addBwdInv l p; p

  let bwdRec = bwdBlk
  (* Analyzer *)

  let analyze ?(precondition  = Some A_TRUE ) ?(property=dummy_prop) (vars,stmts,funcs) main =
    let rec aux xs env =
      match xs with
      | [] -> env
      | x::xs -> aux xs (Environment.add env [|(Var.of_string x.varId)|] [||])
    in
    let f = StringMap.find main funcs in
    let v1 = snd (List.split (StringMap.bindings vars)) in
    let v2 = snd (List.split (StringMap.bindings f.funcVars)) in
    let vars = List.append v1 v2 in
    let env = aux vars (Environment.make [||] [||]) in
    let s = f.funcBody in
    (* Forward Analysis *)
    if !tracefwd && not !minimal then
      Format.fprintf !fmt "\nForward Analysis Trace:\n";
    let startfwd = Sys.time () in
    fwdInvMap := ForwardIteratorB.compute (vars, stmts, funcs) (B.top env vars) main env;
    let stopfwd = Sys.time () in
    if not !minimal then
      begin
        if !timefwd then
          Format.fprintf !fmt "\nForward Analysis (Time: %f s):\n" (stopfwd-.startfwd)
        else
          Format.fprintf !fmt "\nForward Analysis:\n";
        fwdMap_print !fmt !fwdInvMap;
      end;
    (* Backward Analysis *)
    if !tracebwd && not !minimal then
      Format.fprintf !fmt "\nBackward Analysis Trace:\n";
    start := Sys.time ();
    let startbwd = Sys.time () in
    let i = bwdBlk ~property:property funcs env vars (bwdBlk ~property:property funcs env vars (D.bot env vars) s) stmts in
    let stopbwd = Sys.time () in
    if not !minimal then
      begin
        if !timebwd then
          Format.fprintf !fmt "\nBackward Analysis (Time: %f s):\n" (stopbwd-.startbwd)
        else
          Format.fprintf !fmt "\nBackward Analysis:\n";
        bwdMap_print !fmt !bwdInvMap;
      end;
    tree := (D.output_json vars i);
    D.defined  ?condition:precondition i

end
