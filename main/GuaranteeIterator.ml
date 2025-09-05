(*   
     ********* Forward/Backward Guarantee Iterator ************
   Copyright (C) 2012-2014 by Caterina Urban. All rights reserved.
*)

open AbstractSyntax
open InvMap
open ForwardIterator
open Config
open Apron
open Domain
open Functions
open Semantics
open SetTaint

module GuaranteeIterator (D : RANKING_FUNCTION) : SEMANTIC = struct
  type r = D.t

  module D = D
  module B = D.B
  module ForwardIteratorB = ForwardIterator (D.B)

  let dummy_prop = Exp StringMap.empty
  let fwdInvMap = ref InvMap.empty

  let fwdMap_print fmt m =
    InvMap.iter
      (fun l a -> Format.fprintf fmt "%a: %a\n" label_print l B.print a)
      m

  let bwdInvMap = ref InvMap.empty
  let addBwdInv l (a : D.t) = bwdInvMap := InvMap.add l a !bwdInvMap
  let fwdTaintMap : SetTaint.t InvMap.t ref = ref InvMap.empty

  let fwdTBlk (funcs : func StringMap.t) env vars (p : var list) (b : block) :
      var list =
    []

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

  let bwdMap_print fmt m =
    if !compress then
      InvMap.iter
        (fun l a ->
          Format.fprintf fmt "%a:\n%a\n" label_print l D.print (D.compress a))
        m
    else
      InvMap.iter
        (fun l a -> Format.fprintf fmt "%a:\n%a\n" label_print l D.print a)
        m

  (* Backward Iterator *)

  let rec bwdStm ?(property = StringMap.empty) ?domain funcs env vars p s =
    match s with
    | A_label (l, _) ->
        let p =
          try D.reset p (fst (StringMap.find l property)) with Not_found -> p
        in
        p
    | A_return -> D.bot env vars
    | A_assign ((l, _), (e, _)) -> D.bwdAssign p (l, e)
    | A_assert (b, _) -> D.filter p b
    | A_if ((b, ba), s1, s2) ->
        let p1 = D.filter (bwdBlk ~property funcs env vars p s1) b in
        let p2 =
          D.filter
            (bwdBlk ~property funcs env vars p s2)
            (fst (negBExp (b, ba)))
        in
        D.join APPROXIMATION p1 p2
    | A_while (l, (b, ba), s) ->
        let p1 = D.filter p (fst (negBExp (b, ba))) in
        let rec aux i p2 n =
          let i' =
            D.reset
              (D.join APPROXIMATION p1 p2)
              (fst (StringMap.find "" property))
          in
          if !tracebwd && not !minimal then (
            Format.fprintf !fmt "### %a:%i ###:\n" label_print l n;
            Format.fprintf !fmt "p1: %a\n" D.print p1;
            Format.fprintf !fmt "i: %a\n" D.print i;
            Format.fprintf !fmt "p2: %a\n" D.print p2;
            Format.fprintf !fmt "i': %a\n" D.print i');
          if D.isLeq COMPUTATIONAL i' i then (
            if D.isLeq APPROXIMATION i' i then (
              let i = i in
              if !tracebwd && not !minimal then
                Format.fprintf !fmt "### %a:FIXPOINT ###:\n" label_print l;
              if !tracebwd && not !minimal then
                Format.fprintf !fmt "i: %a\n" D.print i;
              i)
            else
              let i'' = if n <= !joinbwd then i' else D.widen i i' in
              if !tracebwd && not !minimal then
                Format.fprintf !fmt "i'': %a\n" D.print i'';
              aux i''
                (D.filter (bwdBlk ~property funcs env vars i'' s) b)
                (n + 1))
          else
            let i'' =
              if n <= !joinbwd then i'
              else D.widen i (D.join COMPUTATIONAL i i')
            in
            if !tracebwd && not !minimal then
              Format.fprintf !fmt "i'': %a\n" D.print i'';
            aux i'' (D.filter (bwdBlk ~property funcs env vars i'' s) b) (n + 1)
        in
        let i = D.bot env vars in
        let p2 = D.filter (bwdBlk ~property funcs env vars i s) b in
        let p = aux i p2 1 in
        addBwdInv l p;
        p
    | A_call (f, ss) -> raise (Invalid_argument "bwdStm:A_call")
    | A_recall (f, ss) -> raise (Invalid_argument "bwdStm:A_recall")

  and bwdBlk ?(property = StringMap.empty) funcs env vars (p : D.t) (b : block)
      : D.t =
    match b with
    | A_empty l ->
        let a = InvMap.find l !fwdInvMap in
        let p = if !refine then D.refine p a else p in
        let p = D.reset p (fst (StringMap.find "" property)) in
        if !tracebwd && not !minimal then
          Format.fprintf !fmt "### %a ###:\n%a\n" label_print l D.print p;
        addBwdInv l p;
        p
    | A_block (l, (s, _), b) ->
        stop := Sys.time ();
        if !stop -. !start > !timeout then raise Timeout
        else
          let b = bwdBlk ~property funcs env vars p b in
          let p = bwdStm ~property funcs env vars b s in
          let a = InvMap.find l !fwdInvMap in
          let p = if !refine then D.refine p a else p in
          let p = D.reset p (fst (StringMap.find "" property)) in
          if !tracebwd && not !minimal then
            Format.fprintf !fmt "### %a ###:\n%a\n" label_print l D.print p;
          addBwdInv l p;
          p

  let bwdRec ?(property = dummy_prop) =
    bwdBlk ~property:(Semantics.get_bexp property)
  (* Analyzer *)

  let analyze ?(precondition = Some A_TRUE) ?(property = dummy_prop)
      (vars, stmts, funcs) main =
    let property = Semantics.get_bexp property in
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
    (* Forward Analysis *)
    if !tracefwd && not !minimal then
      Format.fprintf !fmt "\nForward Analysis Trace:\n";
    let startfwd = Sys.time () in
    fwdInvMap :=
      ForwardIteratorB.compute (vars, stmts, funcs) (B.top env vars) main env;
    let stopfwd = Sys.time () in
    if not !minimal then (
      if !timefwd then
        Format.fprintf !fmt "\nForward Analysis (Time: %f s):\n"
          (stopfwd -. startfwd)
      else Format.fprintf !fmt "\nForward Analysis:\n";
      fwdMap_print !fmt !fwdInvMap);
    (* Backward Analysis *)
    if !tracebwd && not !minimal then
      Format.fprintf !fmt "\nBackward Analysis Trace:\n";
    start := Sys.time ();
    let startbwd = Sys.time () in
    let i =
      bwdBlk ~property funcs env vars
        (bwdBlk ~property funcs env vars (D.bot env vars) s)
        stmts
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
