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
open Sig.Domain
open Sig.Ranking
open Semantics
open Domains.Decision_Tree
open ForwardIterator
open VarSet
open Utils.Datatypes

module TerminationIterator (D : RANKING_FUNCTION) : Semantics.SEMANTIC = struct
  module D = D
  module B = D.B
  module ForwardIteratorB = ForwardIterator (B)

  type bwd_t = D.t
  type fwd_t = D.B.t
  type env = D.env

  let dummy_prop = StringMap.empty
  let fwdInvMap = ref InvMap.empty
  let fwdTaintMap = ref InvMap.empty
  let bwdInvMap = ref InvMap.empty
  let addBwdInv l (a : D.t) = bwdInvMap := InvMap.add l a !bwdInvMap

  let bwdMap_print fmt m =
    InvMap.iter
      (fun l a -> Format.fprintf fmt "%a: %a\n" label_print l D.print a)
      m

  let blockLabel b =
    match b with T_empty (l, _) -> l | T_stat ((l, _), _, _) -> l

  (*Backward Iterator + Recursion *)
  let rec bwdStm ?property ?domain ?(visited : string Seq.t = Seq.empty) funcs
      env vars p s =
    match s with
    | T_label _ | T_print _ | T_add_var (_, None) | T_del_var _ -> (p, visited)
    | T_RETURN -> (D.update_dom domain env |> D.zero, visited)
    | T_BREAK -> raise (UnsupportedFeature "break")
    | T_add_var (v, Some (exp, typ, ext)) ->
        (* s *)
        (D.bwd_assign ?domain p ((T_var v, typ, ext), (exp, typ, ext)), visited)
    | T_assign (lval, rval) -> (D.bwd_assign ?domain p (lval, rval), visited)
    | T_assert (b, _) | T_assume b -> (p, visited)
    | T_if ((b, typ, ba), s1, s2) ->
        let p1, visited2 = bwdBlk ~visited funcs env vars p s1 in
        let p2, visited1 = bwdBlk ~visited funcs env vars p s2 in
        let p1 = D.filter ?domain p1 (b, typ, ba) in
        let p2 = D.filter ?domain p2 (neg_bexp (b, typ, ba)) in
        if !tracebwd && not !minimal then (
          Format.fprintf Format.std_formatter "if in p1: %a\n" D.print p1;
          Format.fprintf Format.std_formatter "p2: %a\n" D.print p2);
        let joinType = APPROXIMATION in
        (D.join joinType p1 p2, Seq.append visited1 visited2)
    | T_while ((l, _), (b, t, ba), s) ->
        let a = InvMap.find_opt l !fwdInvMap in
        let dm = if !refine then a else None in
        let p1 = D.filter ?domain:dm p (neg_bexp (b, t, ba)) in
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
            if D.is_leq COMPUTATIONAL i' i then (
              if D.is_leq APPROXIMATION i' i then (
                if !tracebwd && not !minimal then (
                  Format.fprintf !fmt "### %a:FIXPOINT ###:\n" label_print l;
                  Format.fprintf !fmt "i: %a\n" D.print i);
                i)
              else
                let i'' = if n <= !joinbwd then i' else D.widen ~jokers i i' in
                if !tracebwd && not !minimal then
                  Format.fprintf !fmt "i'': %a\n" D.print i'';
                let p2, visited2 = bwdBlk ~visited funcs env vars i'' s in
                let p2' = D.filter ?domain:dm p2 (b, t, ba) in
                aux i'' p2' (n + 1))
            else
              let i'' =
                if n <= !joinbwd then i'
                else D.widen ~jokers i (D.join COMPUTATIONAL i i')
              in
              if !tracebwd && not !minimal then
                Format.fprintf !fmt "i'': %a\n" D.print i'';
              let p2, visited2 = bwdBlk ~visited funcs env vars i'' s in
              let p2' = D.filter ?domain:dm p2 (b, t, ba) in
              aux i'' p2' (n + 1)
        in
        let i = D.update_dom dm env |> D.bot in
        let p2, visited2 = bwdBlk ~visited funcs env vars i s in
        let p2' = D.filter ?domain:dm p2 (b, t, ba) in
        let p = aux i p2' 1 in
        addBwdInv l p;
        ((if !refine then D.refine p (Option.get a) else p), visited)
    | T_call (f, ss) -> (
        let p1, visited = bwdBlk ~visited funcs env vars p f.func_body in
        let f_in =
          Seq.find (fun name -> String.compare name f.func_name = 0) visited
        in
        match f_in with
        | Some f_in -> raise (UnsupportedFeature "Recursive function")
        | None -> (D.plus p p1, Seq.cons f.func_name visited))
    | T_expr e -> (D.top env, visited (* todo handle this *))

  and bwdBlk ?property ?(visited : string Seq.t = Seq.empty) funcs env vars p
      (b : block) : D.t * string Seq.t =
    let result_print l p =
      Format.fprintf !fmt "### %a ###:\n%a@." label_print l D.print p
    in
    match b with
    | T_empty (l, _) ->
        let a = InvMap.find_opt l !fwdInvMap in
        let p = if !refine then D.refine p (Option.get a) else p in
        if !tracebwd && not !minimal then result_print l p;
        addBwdInv l p;
        (p, visited)
    | T_stat ((l, _), (s, _), b) ->
        stop := Sys.time ();
        if !stop -. !start > !timeout then raise Timeout
        else
          let b, visited = bwdBlk ~visited funcs env vars p b in
          let a = InvMap.find_opt l !fwdInvMap in
          (* let tvl = InvMap.find l !fwdTaintMap in *)
          let p, visited =
            if !refine then
              bwdStm ~visited ~domain:(Option.get a) funcs env vars b s
            else bwdStm ~visited funcs env vars b s
          in
          let p = if !refine then D.refine p (Option.get a) else p in
          if !tracebwd && not !minimal then result_print l p;
          addBwdInv l p;
          (p, visited)

  and bwdRec ?property funcs env vars (p : D.t) (b : block) : D.t =
    fst (bwdBlk funcs env vars p b)

  (* Analyzer *)
  let rec initStm env s =
    match s with
    | T_if (_, s1, s2) ->
        initBlk env s1;
        initBlk env s2
    | T_while ((l, _), _, s) ->
        addBwdInv l (D.bot env);
        initBlk env s
    | _ -> ()

  and initBlk env b =
    match b with
    | T_empty (l, _) -> addBwdInv l (D.bot env)
    | T_stat ((l, _), (s, _), b) ->
        addBwdInv l (D.bot env);
        initStm env s;
        initBlk env b

  let analyze
      ?(precondition =
        Some
          ( T_bool_const True,
            Abstract_syntax.A_BOOL,
            (Lexing.dummy_pos, Lexing.dummy_pos) )) ?property
      (prog : Typed_syntax.prog) =
    let block, funcmap, varmap = prog in
    let f = StringMap.find !Config.main funcmap in
    let module Init = EnvInit.Make (B) in
    let f_env, vars = Init.env prog in
    let s = f.func_body in
    let env = f_env |> D.lift_fenv in
    initBlk env block;
    initBlk env s;
    let precondition =
      Option.bind precondition (fun e ->
          Some (Typed_syntax.expr_prop_handler e vars))
    in
    (* TODO: handle functions calls *)
    (* Forward Analysis *)
    if !tracefwd && not !minimal then
      Format.fprintf !fmt "\nForward Analysis Trace:\n";
    if !refine then ForwardIteratorB.analyze f_env prog;
    fwdInvMap := !ForwardIteratorB.fwdInvMap;
    fwdTaintMap := !ForwardIteratorB.fwdTaintMap;
    (* Backward Analysis *)
    if !tracebwd && not !minimal then
      Format.fprintf !fmt "\nBackward Analysis Trace:\n";
    start := Sys.time ();
    let startbwd = Sys.time () in
    let i =
      bwdRec funcmap env vars (bwdRec funcmap env vars (D.zero env) s) block
    in
    let stopbwd = Sys.time () in
    if not !minimal then (
      if !timebwd then
        Format.fprintf !fmt "\nBackward Analysis (Time: %f s):\n"
          (stopbwd -. startbwd)
      else Format.fprintf !fmt "\nBackward Analysis:\n";
      bwdMap_print !fmt !bwdInvMap);
    tree := D.output_json vars i;
    Config.result := D.defined ?condition:precondition i;
    !Config.result
end
