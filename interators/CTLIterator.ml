open Typed_syntax
open CTLProperty
open Apron
open Sig.Ranking
open Sig.Domain
open Config
open ForwardIterator
open Config
open VarSet
open Utils
open Datatypes
open Utils.InvMap
open Semantics

(* type for CTL properties, instantiated with bExp for atomic propositions *)
type ctl_property = Typed_syntax.expr typed CTLProperty.generic_property

let atomic_property_of_bexp (b : Typed_syntax.expr typed) = Atomic (b, None)

type quantifier = UNIVERSAL | EXISTENTIAL

let rec print_ctl_property fmt (property : ctl_property) =
  match property with
  | Atomic ((p, _, _), Some l) ->
      Format.fprintf fmt "%s: %a" l Typed_syntax.pp_expr p
  | Atomic ((p, _, _), None) -> Typed_syntax.pp_expr fmt p
  | AX p -> Format.fprintf fmt "AX{%a}" print_ctl_property p
  | AF p -> Format.fprintf fmt "AF{%a}" print_ctl_property p
  | AG p -> Format.fprintf fmt "AG{%a}" print_ctl_property p
  | AU (p1, p2) ->
      Format.fprintf fmt "AU{%a}{%a}" print_ctl_property p1 print_ctl_property
        p2
  | EX p -> Format.fprintf fmt "EX{%a}" print_ctl_property p
  | EF p -> Format.fprintf fmt "EF{%a}" print_ctl_property p
  | EG p -> Format.fprintf fmt "EG{%a}" print_ctl_property p
  | EU (p1, p2) ->
      Format.fprintf fmt "EU{%a}{%a}" print_ctl_property p1 print_ctl_property
        p2
  | AND (p1, p2) ->
      Format.fprintf fmt "AND{%a}{%a}" print_ctl_property p1 print_ctl_property
        p2
  | OR (p1, p2) ->
      Format.fprintf fmt "OR{%a}{%a}" print_ctl_property p1 print_ctl_property
        p2
  | NOT p -> Format.fprintf fmt "NOT{%a}" print_ctl_property p

(* Bundle commonly used values (AST, Apron env. variable list) to one struct *)
type program = {
  environment : Apron.Environment.t;
  variables : Typed_syntax.var list;
  mainFunction : Typed_syntax.func;
  globalBlock : Typed_syntax.block;
}

(* Computes the set of all labels of a program *)

let labels_of_program program =
  let rec stmtLabels s =
    match s with
    | T_if (_, s1, s2) -> List.append (blockLabels s1) (blockLabels s2)
    | T_while (l, (b, typ, ba), s) -> l :: blockLabels s
    | T_call (f, ss) -> (f.func_id, fst ss) :: blockLabels f.func_body
    | _ -> []
  and blockLabels b =
    match b with
    | T_empty l -> [ l ]
    | T_stat (l, (s, _), b) -> l :: List.append (stmtLabels s) (blockLabels b)
  in
  blockLabels program.globalBlock @ blockLabels program.mainFunction.func_body

(* get label at start of block *)
let block_label block =
  match block with T_empty l -> fst l | T_stat (l, _, _) -> fst l

(* generate map that assigns a block to each label in the program *)
let block_label_map block : block InvMap.t =
  let rec aux (b : block) (map : block InvMap.t) =
    let map' = InvMap.add (block_label b) b map in
    match b with
    | T_empty _ -> map'
    | T_stat (blockLabel, (stmt, _), nextBlock) -> (
        let map'' = aux nextBlock map' in
        match stmt with
        | T_if (_, bIf, bElse) -> aux bElse (aux bIf map'')
        | T_while ((whileLabel, _), _, loop_body) ->
            let map''' = InvMap.add whileLabel b map'' in
            aux loop_body map'''
        | T_call (f, ss) ->
            let map''' = InvMap.add f.func_id f.func_body map'' in
            aux f.func_body map'''
        | _ -> map'')
  in
  aux block InvMap.empty

(*
   This function takes a given paresed program and introduces a new label called 'exit' 
   before each 'return' statement and at the end of the program

   The augmented program can be checked for termination with the following ctl: 'AF{exit: true}'
*)
let program_of_prog (prog : Typed_syntax.prog) (main : StringMap.key) : program
    =
  let globalBlock, functions, globalVariables = prog in
  let mainFunction = StringMap.find main functions in
  let dummyExtent = (Lexing.dummy_pos, Lexing.dummy_pos) in
  let exitLabel = T_label ("exit", dummyExtent) in
  let id = ref Z.minus_one in
  let nextId () =
    let i = !id in
    id := Z.( - ) i Z.one;
    i
  in
  let rec addTerminationStmt (block : block) =
    match block with
    | T_empty l ->
        T_stat ((nextId (), Lexing.dummy_pos), (exitLabel, dummyExtent), block)
    | T_stat (l, stmt, nextBlock) ->
        T_stat (l, stmt, addTerminationStmt nextBlock)
  in
  let rec addTerminationStmtReturn (block : block) =
    match block with
    | T_empty l -> block
    | T_stat (l, (T_RETURN, a), nextBlock) -> 
        let nextBlock =
          T_stat (l, (T_RETURN, a), addTerminationStmtReturn nextBlock)
        in
        T_stat
          ((nextId (), Lexing.dummy_pos), (exitLabel, dummyExtent), nextBlock)
    | T_stat (l, (T_call (f, ss), a), nextBlock) ->
        let f = { f with func_body = addTerminationStmtReturn f.func_body } in
        T_stat (l, (T_call (f, ss), a), addTerminationStmtReturn nextBlock)
    | T_stat (l, stmt, nextBlock) ->
        T_stat (l, stmt, addTerminationStmtReturn nextBlock)
  in
  let augmentedBody =
    addTerminationStmtReturn @@ addTerminationStmt mainFunction.func_body
  in
  let v1 = snd (List.split (IdMap.bindings globalVariables)) in
  let v2 = mainFunction.func_args in
  let vars = List.append v1 v2 in
  let var_to_apron v = Apron.Var.of_string (Z.to_string v.var_id) in
  let apron_vars = Array.map var_to_apron (Array.of_list vars) in
  let env = Environment.make apron_vars [||] in
  let program =
    {
      environment = env;
      variables = vars;
      mainFunction = { mainFunction with func_body = augmentedBody };
      globalBlock;
    }
  in
  program

let prog_of_program (program : program) : prog =
  let funcMap = StringMap.add "main" program.mainFunction StringMap.empty in
  let varMap =
    List.fold_left
      (fun map var -> IdMap.add var.var_id var map)
      IdMap.empty program.variables
  in
  (program.globalBlock, funcMap, varMap)

module CTLIterator (D : RANKING_FUNCTION) : Semantics.SEMANTIC = struct
  (*
     Fixed Point Computation:

     The fixed point for the 'unit' and 'global' operators are computed by performing a backward-analysis.

     Given a statement, we call the state that holds before the statement the 'in' state, and the state that holds
     after the statement the 'out' state (before and after according to the control-flow). 
     The backward analysis starts with an initial 'out' state at the end of the program
     and propagates it backwards to the start of the program. For each statement, the 'in' state is computed based on the 'out' state.
     At loop heads the final 'in' state is computed by iterating over the loop body until a fixed-point is reached.
  *)

  module ForwardIteratorB = ForwardIterator (D.B)
  module D = D
  module B = D.B

  (* We use fwdInvMap but not the bwd, necessaray for now to match SEMANTIC module type *)
  let fwdInvMap = ref InvMap.empty
  let fwdTaintMap = ref InvMap.empty
  let bwdInvMap = ref InvMap.empty

  (* 
     Type that represents an invariant/fixed-point.
     An invariant assigns an abstract state to each statement of a program
  *)
  type inv = D.t InvMap.t

  (* type returned by the bwd analysis function: also necessary to match SEMANTIC module type *)
  type r = inv

  (* dummy_prop to give a default value to optional (due to termination iterator) parameter ?property *)
  let dummy_prop = StringMap.empty

  (* Also to match module type: to remove in the future *)
  let initStm env vars s = ()
  let initBlk env vars b = ()

  let printInv ?fwdInvOpt fmt (inv : inv) =
    let inv = if !compress then InvMap.map D.compress inv else inv in
    let printState l a =
      if !dot then
        Format.fprintf fmt "%a:\n%a\nDOT: %a\n" label_print l D.print a
          D.print_graphviz_dot a
      else Format.fprintf fmt "%a:\n%a\n" label_print l D.print a
    in
    InvMap.iter printState inv

  let abstract_transformer (quantifier : quantifier) =
    match quantifier with
    | UNIVERSAL ->
        ( D.join APPROXIMATION,
          D.bwd_assign ~underapprox:false,
          D.filter ~underapprox:false )
    | EXISTENTIAL ->
        ( D.join COMPUTATIONAL,
          D.bwd_assign ~underapprox:true,
          D.filter ~underapprox:true )

  (* Computes fixed-point for 'until' properties: AU{inv_keep}{inv_reset} 
     inv_keep and inv_reset are fixed-point for the nested properties

     Applies the 'until' operator of the decision tree domain to each state. 
     This resets the ranking function for those parts of the domain where inv_reset is also 
     defined and it discards those parts of the ranking function where neither inv_keep nor inv_reset are defined.
  *)
  let until (quantifier : quantifier) (fwdInv : label -> D.B.t)
      (program : program) (inv_keep : inv) (inv_reset : inv) : inv =
    let branch_join, bwd_assign, bwd_filter = abstract_transformer quantifier in
    let inv = ref InvMap.empty in
    (* variable where the resulting invariant/fixed-point is stored *)
    let addInv l (a : D.t) =
      inv := InvMap.add l a !inv;
      a
    in
    (* update InvMap with new value and return new updated value *)
    let bot = D.bot program.environment program.variables in
    let start = Sys.time () in
    let rec bwd (out : D.t) (b : block) : D.t =
      (* recursive function that performs the backward analysis *)
      if Sys.time () -. start > !timeout then raise Timeout;
      (* check for timeout *)
      match b with
      | T_empty (blockLabel, ext) ->
          let invBlockKeep = InvMap.find blockLabel inv_keep in
          let invBlockReset = InvMap.find blockLabel inv_reset in
          let out =
            if !refine then D.refine out (fwdInv (blockLabel, ext)) else out
          in
          let in_state = D.until out invBlockKeep invBlockReset in
          if !tracebwd && not !minimal then
            Format.fprintf !fmt "### %a ###:\n%a\n" label_print blockLabel
              D.print in_state;
          addInv blockLabel in_state
      | T_stat ((blockLabel, ext), (stmt, _), nextBlock) ->
          let pre_dom =
            if !refine then Some (fwdInv (blockLabel, ext)) else None
          in
          let invBlockKeep = InvMap.find blockLabel inv_keep in
          let invBlockReset = InvMap.find blockLabel inv_reset in
          let d_until = fun t -> D.until t invBlockKeep invBlockReset in
          let out_state = bwd out nextBlock in
          (* recursively process the rest of the program, this gives us the 'out' state for this statement *)
          (* compute 'in' state for this statement *)
          let in_state =
            match stmt with
            | T_expr _ | T_label _
            | T_add_var (_, None)
            | T_del_var _ | T_print _ ->
                out_state
            | T_RETURN -> bot
            | T_add_var (l, Some e) | T_assign ((l, _), e) ->
                bwd_assign ?domain:pre_dom out_state
                  ((T_var l, l.var_typ, l.var_extent), e)
            | T_assert (b, _) | T_assume b ->
                bwd_filter ?domain:pre_dom out_state b
            | T_if ((b, typ, ba), s1, s2) ->
                let in_if = bwd out_state s1 in
                (* compute 'in state for if-block*)
                let in_else = bwd out_state s2 in
                (* compute 'in state for else-block *)
                let in_if_filtered =
                  bwd_filter ?domain:pre_dom in_if (b, typ, ba)
                in
                (* filter *)
                let in_else_filtered =
                  bwd_filter ?domain:pre_dom in_else (neg_bexp (b, typ, ba))
                in
                (* filter *)
                branch_join in_if_filtered
                  in_else_filtered (* join the two branches *)
            | T_while (l, (b, typ, ba), loop_body) ->
                let pre_dom = if !refine then Some (fwdInv l) else None in
                let out_exit =
                  bwd_filter ?domain:pre_dom out_state (neg_bexp (b, typ, ba))
                in
                (* 'out' state when not entering the loop body *)
                let rec aux
                    (* recursive function that iteratively computes fixed point for 'in' state at loop head *)
                      in_state (* 'in' state of the previous iteration *)
                    out_enter
                    (* current 'out' state when entering the loop body *) n =
                  (* iteration counter *)
                  let in_state' = d_until (branch_join out_exit out_enter) in
                  (* 'in' state for this iteration *)
                  if !tracebwd && not !minimal then (
                    Format.fprintf !fmt "### %a:%i ###:\n" label_print (fst l) n;
                    Format.fprintf !fmt "out_exit: %a\n" D.print out_exit;
                    Format.fprintf !fmt "in: %a\n" D.print in_state;
                    Format.fprintf !fmt "out_enter: %a\n" D.print out_enter;
                    Format.fprintf !fmt "in': %a\n" D.print in_state');
                  let is_leqComp = D.is_leq COMPUTATIONAL in_state' in_state in
                  let is_leqApprox = D.is_leq APPROXIMATION in_state' in_state in
                  let jokers =
                    max 0 ((!retrybwd * (!Config.ordmax + 1)) - n + !joinbwd)
                  in
                  if is_leqComp then (
                    if is_leqApprox then (
                      (* fixed-point reached *)
                      let fixed_point = in_state in
                      if !tracebwd && not !minimal then (
                        Format.fprintf !fmt "### %a:FIXPOINT ###:\n" label_print
                          (fst l);
                        Format.fprintf !fmt "in_state: %a\n" D.print fixed_point);
                      fixed_point)
                    else
                      (*fixed-point not yet reached, continue with next iteration*)
                      let in_state'' =
                        if n <= !joinbwd then in_state'
                          (* iteration count below widening threshold *)
                        else D.widen ~jokers in_state in_state'
                        (* widening threshold reached, apply widening *)
                      in
                      if !tracebwd && not !minimal then
                        Format.fprintf !fmt "in'': %a\n" D.print in_state'';
                      let out_enter' =
                        bwd_filter ?domain:pre_dom (bwd in_state'' loop_body)
                          (b, typ, ba)
                      in
                      (* process loop body again with updated 'in' state *)
                      aux in_state'' out_enter' (n + 1) (* run next iteration *))
                  else
                    let in_state'' =
                      if n <= !joinbwd then in_state'
                      else
                        D.widen ~jokers in_state
                          (D.join COMPUTATIONAL in_state in_state')
                      (* NOTE: the join might be necessary to ensure termination because of a bug (???) *)
                    in
                    if !tracebwd && not !minimal then
                      Format.fprintf !fmt "in'': %a\n" D.print in_state'';
                    let out_enter' = bwd in_state'' loop_body in
                    let out_enter' =
                      D.filter ?domain:pre_dom out_enter' (b, typ, ba)
                    in
                    aux in_state'' out_enter' (n + 1)
                in
                let initial_in =
                  D.bot ?domain:pre_dom program.environment program.variables
                in
                (* start with bottom as initial 'in' state *)
                let initial_out_enter =
                  D.filter ?domain:pre_dom (bwd initial_in loop_body)
                    (b, typ, ba)
                in
                (* process loop body with initial 'in' state *)
                let final_in_state = aux initial_in initial_out_enter 1 in
                (* compute fixed point for loop-head *)
                let ret = addInv (fst l) final_in_state in
                if !refine then D.refine ret (Option.get pre_dom) else ret
            | T_call (f, ss) ->
                let p =
                  bwd (D.zero program.environment program.variables) f.func_body
                in
                let p' = D.plus p (D.join COMPUTATIONAL p out_state) in
                addInv f.func_id p'
            | T_BREAK -> raise (Invalid_argument "bwdStm:T_BREAK")
            (* | A_recall (f, ss) -> raise (Invalid_argument "bwdStm:A_recall") *)
          in
          let in_state =
            if !refine then D.refine in_state (fwdInv (blockLabel, ext))
            else in_state
          in
          let in_state = d_until in_state in
          (* reset ranking functions *)
          if !tracebwd && not !minimal then
            Format.fprintf !fmt "### %a ###:\n%a\n" label_print blockLabel
              D.print in_state;
          addInv blockLabel in_state
    in
    let _ = bwd bot program.mainFunction.func_body in
    (* process entire program starting with bottom *)
    !inv (* return computed program invariant *)

  (*
    Computed fixed-point for 'global' operator (i.e. AG{...}), takes an existing fixed point for the nested property as argument.

    Applies the 'mask' operator to compute the greatest-fixed point starting from the given fixed point for the nested property. 
    During the backward analysis, the reachable state at each statement is computed by inspecting the 'out' states. 
    Then this reachable state is used to shrink down the given fixed-point of the nested property by using 'maks'. 
    To backward analysis for the while-loop uses dual_widening to get convergence.


    By default, the global operator only holds for infinite traces in which the property is satisfied. 
    As a consequence, it's not possible to argue about properties that hold globally until termination. 
    This problem could be solved by adding an endless loop at the end of the program. 
    The result of adding an infinite loop at the end of the program can be simulated by setting the optional 'use_sink_state' parameter to true.
    This will start the backward analysis with a zero state that is defined on the entire domain. By doing so, we avoid cutting away states on finite traces.

  *)

  let global (quantifier : quantifier) (fwdInv : label -> D.B.t)
      ?(use_sink_state = false) (program : program) (fixed_point : inv) : inv =
    let branch_join, bwd_assign, bwd_filter = abstract_transformer quantifier in
    let inv = ref (InvMap.union (fun _ _ _ -> None) fixed_point InvMap.empty) in
    (* initialize InvMap with given fixed-point for nested property *)
    let addInv l (a : D.t) =
      inv := InvMap.add l a !inv;
      a
    in
    let target = ref "" in
    (* update InvMap with new value and return new updated value *)
    let blockState block = InvMap.find (block_label block) !inv in
    (* returns current 'in' state of a block *)
    let zero = D.zero program.environment program.variables in
    let bot = D.bot program.environment program.variables in
    let start = Sys.time () in
    let rec bwd (out : D.t) (b : block) : D.t =
      (* recursive function that performs block-wise backward analysis *)
      if Sys.time () -. start > !timeout then raise Timeout;
      (* check for timeout *)
      let current_in = blockState b in
      (* current 'in' state for this block *)
      match b with
      | T_empty (blockLabel, ext) ->
          let out =
            if !refine then D.refine out (fwdInv (blockLabel, ext)) else out
          in
          addInv blockLabel (D.mask current_in out)
      | T_stat ((blockLabel, ext), (stmt, _), nextBlock) ->
          let pre_dom =
            if !refine then Some (fwdInv (blockLabel, ext)) else None
          in
          let out_state = bwd out nextBlock in
          let new_node = Z.to_string blockLabel in
          target := new_node;
          (* recursively process the rest of the program, this gives us the 'out' state for this statement *)
          let new_in =
            match stmt with
            | T_expr _ | T_label _
            | T_add_var (_, None)
            | T_del_var _ | T_print _ ->
                out_state
            | T_RETURN -> if use_sink_state then zero else bot
            | T_add_var (l, Some e) | T_assign ((l, _), e) ->
                D.mask current_in
                @@ bwd_assign ?domain:pre_dom out_state
                @@ ((T_var l, l.var_typ, l.var_extent), e)
            | T_assert (b, _) | T_assume b ->
                D.mask current_in @@ bwd_filter ?domain:pre_dom out_state b
            | T_if (b, s1, s2) ->
                let out_if = bwd_filter ?domain:pre_dom (bwd out_state s1) b in
                (* compute 'out' state for if-block*)
                let out_else =
                  bwd_filter ?domain:pre_dom (bwd out_state s2) (neg_bexp b)
                in
                (* compute 'out' state for else-block *)
                D.mask current_in (branch_join out_if out_else)
                (* join the two branches and combine with current 'in' state using mask *)
            | T_while (l, b, loop_body) ->
                let pre_dom = if !refine then Some (fwdInv l) else None in
                let out_exit =
                  bwd_filter ?domain:pre_dom out_state (neg_bexp b)
                in
                (* 'out' state when not entering the loop body *)
                let rec aux
                    (* recursive function that iteratively computes fixed point for 'in' state at loop head *)
                      (current_in : D.t)
                      (* 'in' state of the previous iteration *)
                    (out_enter : D.t)
                      (* current 'out' state when entering the loop body *)
                    (n : int) : D.t =
                  (* iteration counter *)
                  let out_joined = branch_join out_exit out_enter in
                  (* new 'in' state after joining the incoming branches *)
                  let updated_in = D.mask current_in out_joined in
                  (* join two branches and combine with current 'in' state using mask *)
                  if !tracebwd && not !minimal then (
                    Format.fprintf !fmt "### %a:%i ###:\n" label_print (fst l) n;
                    Format.fprintf !fmt "out_exit: %a\n" D.print out_exit;
                    Format.fprintf !fmt "out_enter: %a\n" D.print out_enter;
                    Format.fprintf !fmt "out_joined: %a\n" D.print out_joined;
                    Format.fprintf !fmt "current_in: %a\n" D.print current_in;
                    Format.fprintf !fmt "updated_in: %a\n" D.print updated_in);
                  let is_leqApprox =
                    D.is_leq APPROXIMATION current_in updated_in
                  in
                  let is_leqComp = D.is_leq COMPUTATIONAL current_in updated_in in
                  if is_leqComp && is_leqApprox then (
                    (* fixed point *)
                    let fixed_point = current_in in
                    if !tracebwd && not !minimal then
                      Format.fprintf !fmt "Fixed-Point reached \n";
                    fixed_point)
                  else
                    let updated_in' =
                      if n <= !joinbwd then updated_in
                        (* widening threshold not yet reached *)
                      else D.dual_widen current_in updated_in
                      (* use dual_widen after widening threshold reached *)
                    in
                    let out_enter' =
                      bwd_filter ?domain:pre_dom (bwd updated_in' loop_body) b
                    in
                    (* process loop body again with updated 'in' state *)
                    (* next iteration *)
                    aux updated_in' out_enter' (n + 1)
                in
                let initial_out_enter =
                  bwd_filter ?domain:pre_dom (bwd current_in loop_body) b
                in
                (* process loop body with current 'in' state at loop-head *)
                let final_in_state = aux current_in initial_out_enter 1 in
                (* compute fixed point for while-loop starting with current 'in' state at loop-head *)
                addInv (fst l) final_in_state
            | T_call (f, ss) -> bwd out f.func_body
            | T_BREAK -> raise (Invalid_argument "bwdStm:T_BREAK")
            (* | A_recall (f, ss) -> raise (Invalid_argument "bwdStm:A_recall") *)
          in
          let new_in =
            if !refine then D.refine new_in (fwdInv (blockLabel, ext))
            else new_in
          in

          addInv blockLabel
            new_in (* use mask to compute the new 'in' state for this block *)
    in
    let _ =
      bwd (if use_sink_state then zero else bot) program.mainFunction.func_body
    in
    (* run backward analysis starting from bottom *)
    (* print_string !header; *)
    !inv

  (* 
    Computes fixed-point for 'next' operator (e.g. AX{...})
    For each program label, this function joins all 'out' states and sets this value as the new invariant.
    This computatoin is straight-forward with the exception of empty blocks. 
    There we need to inject the 'out' state of the next basic block in the control-flow-graph. 
    This is done by passing in said state through the recursion of the backward analysis.
  *)
  let next (quantifier : quantifier) (program : program) (fp : inv) : inv =
    let branch_join, bwd_assign, bwd_filter = abstract_transformer quantifier in
    let invMap = ref InvMap.empty in
    let addInv label state = invMap := InvMap.add label state !invMap in
    let rec aux (b : block) (nextOuterState : D.t) () =
      (* nextOuterState is the 'out' state of the next basic block in the CFG *)
      match b with
      | T_empty (l, _) ->
          addInv l nextOuterState
          (* here we use 'nextOuterState' because there is no 'out' state coming in from the next block *)
      | T_stat ((blockLabel, ext), (stmt, _), nextBlock) -> (
          let nextBlockLabel = block_label nextBlock in
          let nextBlockState = InvMap.find nextBlockLabel fp in
          aux nextBlock nextOuterState ();
          match stmt with
          | T_if (b, bIf, bElse) ->
              let sIf = bwd_filter (InvMap.find (block_label bIf) fp) b in
              let sElse =
                bwd_filter (InvMap.find (block_label bElse) fp) (neg_bexp b)
              in
              let s = branch_join sIf sElse in
              addInv blockLabel s;
              aux bElse nextBlockState ();
              aux bIf nextBlockState ()
          | T_while (whileLabel, b, whileBlock) ->
              let blockState = InvMap.find blockLabel fp in
              let sFall =
                bwd_filter (InvMap.find (block_label whileBlock) fp) b
              in
              let sJump = bwd_filter nextBlockState (neg_bexp b) in
              let s = branch_join sFall sJump in
              addInv blockLabel s;
              aux whileBlock blockState ()
          | T_add_var (l, Some e) | T_assign ((l, _), e) ->
              let s =
                bwd_assign nextBlockState ((T_var l, l.var_typ, l.var_extent), e)
              in
              addInv blockLabel s
          | _ -> addInv blockLabel nextBlockState)
    in
    let bot = D.bot program.environment program.variables in
    let top = D.top program.environment program.variables in
    aux program.mainFunction.func_body bot ();
    let zero_leafs t = D.until t top t in
    (* set all defined leafs of the decision trees to zero *)
    InvMap.map zero_leafs !invMap

  (* 
    Assign atomic state to those blocks that match the label and bot to all others
  *)
  let label_atomic (program : program) (propertyLabel : string)
      (property : expr typed) : inv =
    let bot = D.bot program.environment program.variables in
    let labelState = D.reset bot property in
    let blockMap = block_label_map program.mainFunction.func_body in
    let reducer (inv : D.t InvMap.t) (label, block) =
      let state =
        match block with
        | T_stat (_, (T_label (l, _), _), _) ->
            if String.equal l propertyLabel then labelState else bot
        | _ -> bot
      in
      InvMap.add label state inv
    in
    List.fold_left reducer InvMap.empty (InvMap.bindings blockMap)

  (* 
    Assign atomic state to each label of the program.
    Atomic state is a function that returns zero for all states that satisfy the property
  *)
  let atomic (program : program) (property : expr typed) : inv =
    let bot = D.bot program.environment program.variables in
    let blockMap = block_label_map program.mainFunction.func_body in
    let atomicState = D.reset bot property in
    let reducer (inv : D.t InvMap.t) (label, block) =
      InvMap.add label atomicState inv
    in
    List.fold_left reducer InvMap.empty (InvMap.bindings blockMap)

  let atomic_true (program : program) : inv =
    let bot = D.bot program.environment program.variables in
    let trueState =
      D.reset bot (T_bool_const True, A_BOOL, Abstract_syntax.extent_unknown)
    in
    let labels = labels_of_program program in
    List.fold_left
      (fun inv label -> InvMap.add label trueState inv)
      InvMap.empty (List.map fst labels)

  (* CTL 'or' opperator *)
  let logic_or (fp1 : inv) (fp2 : inv) : inv =
    let f _ t1 t2 = Some (D.join COMPUTATIONAL t1 t2) in
    InvMap.union f fp1 fp2

  (* CTL 'and' opperator *)
  let logic_and (fp1 : inv) (fp2 : inv) : inv =
    let f _ t1 t2 = Some (D.meet COMPUTATIONAL t1 t2) in
    InvMap.union f fp1 fp2

  (* CTL 'not' opperator *)
  let logic_not (fp : inv) : inv = InvMap.map D.complement fp

  (*
    Recusively compute fixed-point for CTL properties 
  *)
  let compute (program : program) (property : ctl_property) : inv =
    let atomic_true_inv = atomic_true program in
    let fwdInv (l, _) = InvMap.find l !fwdInvMap in
    let a_until = until UNIVERSAL fwdInv in
    let e_until = until EXISTENTIAL fwdInv in
    let a_global = global UNIVERSAL fwdInv in
    let e_global = global EXISTENTIAL fwdInv in
    let a_next = next UNIVERSAL in
    let e_next = next EXISTENTIAL in
    let print_inv property inv =
      if not !minimal then (
        Format.fprintf !fmt "Property: %a\n\n" print_ctl_property property;
        printInv !fmt inv)
    in
    let rec inv (property : ctl_property) : inv =
      let result =
        match property with
        | Atomic (b, None) -> atomic program b
        | Atomic (b, Some l) -> label_atomic program l b
        | AX p -> a_next program (inv p)
        | AF p -> a_until program atomic_true_inv (inv p)
        | AG p -> a_global program (inv p)
        | AU (p1, p2) -> a_until program (inv p1) (inv p2)
        | EU (p1, p2) ->
            if !ctl_existential_equivalence then
              raise
                (Invalid_argument
                   "existential equivalence conversion not supported for \
                    'until' operator")
            else e_until program (inv p1) (inv p2)
        | EF p ->
            if !ctl_existential_equivalence then (
              (* use the following equivalence relation: EF(p) := not AG(not p)  *)
              let inv_not_p = inv (NOT p) in
              let inv_ag = a_global ~use_sink_state:true program inv_not_p in
              print_inv (AG (NOT p)) inv_ag;
              let not_inv_ag = logic_not inv_ag in
              not_inv_ag)
            else e_until program atomic_true_inv (inv p)
        | EG p ->
            if !ctl_existential_equivalence then (
              (* use the following equivalence realtion: EG(p) := not AF(not p)  *)
              let inv_not_p = inv (NOT p) in
              let inv_af = a_until program atomic_true_inv inv_not_p in
              print_inv (AF (NOT p)) inv_af;
              let not_inv_af = logic_not inv_af in
              not_inv_af)
            else e_global program (inv p)
        | EX p ->
            (* EX(p) := not AX(not p)  *)
            if !ctl_existential_equivalence then (
              (* use the following equivalence relation: EX(p) := not AX(not p)  *)
              let inv_not_p = inv (NOT p) in
              let inv_ax = a_next program inv_not_p in
              print_inv (AX (NOT p)) inv_ax;
              let not_inv_ax = logic_not inv_ax in
              not_inv_ax)
            else e_next program (inv p)
        | AND (p1, p2) -> logic_and (inv p1) (inv p2)
        | OR (p1, p2) -> logic_or (inv p1) (inv p2)
        | NOT (Atomic (b, None)) -> atomic program @@ neg_bexp b
        | NOT p -> logic_not (inv p)
      in
      print_inv property result;
      result
    in
    inv property

  (* Function called by cda same as analyze *)
  let bwdRec ?(property = dummy_prop) func env (vars : var list) _ b : D.t =
    let f = StringMap.find !Config.main func in
    let p =
      { environment = env; variables = vars; mainFunction = f; globalBlock = b }
    in
    let i = compute p (Semantics.get_ctl property) in
    let initialLabel = block_label p.mainFunction.func_body in
    let programInvariant = InvMap.find initialLabel i in
    bwdInvMap := i;
    programInvariant

  let witness program inv =
    let header = ref {|entry_type: "violation_sequence"
    content:
  |} in
    let witness_statement s = header := Printf.sprintf "%s%s" !header s in
    let rec aux b =
      match b with
      | T_empty (blockLabel, ext) -> ()
      | T_stat ((blockLabel, ext), (stmt, ext'), nextBlock) -> (
          match stmt with
          | T_expr _ | T_label _ | T_add_var (_, None) | T_del_var _ | T_print _
            ->
              aux nextBlock
          | T_RETURN -> aux nextBlock
          | T_add_var (l, Some e) | T_assign ((l, _), e) -> aux nextBlock
          | T_assert (b, _) | T_assume b -> aux nextBlock
          | T_if (b, s1, s2) ->
              witness_statement
                (Printf.sprintf
                   {|- waypoint:
type: "branching"
constraint:
value: "true"
location:
file_name: ...
line: %s
action: "follow"|}
                   (Z.to_string blockLabel));
              aux nextBlock
          | T_while (l, b, loop_body) -> aux nextBlock
          | T_call (f, ss) -> aux nextBlock
          | T_BREAK -> raise (Invalid_argument "bwdStm:T_BREAK"))
      (* | A_recall (f, ss) -> raise (Invalid_argument "bwdStm:A_recall") *)
    in
    aux program.mainFunction.func_body

  let analyze
      ?(precondition =
        Some
          ( T_bool_const True,
            Abstract_syntax.A_BOOL,
            (Lexing.dummy_pos, Lexing.dummy_pos) )) ?(property = dummy_prop)
      prog =
    let module Init = EnvInit.Make (B) in
    let env, vars = Init.env prog in
    let property =
      get_ctl property
      |> CTLProperty.map (fun e ->
             let rec aux e =
               match e with
               | T_var v, t, ext ->
                   ( T_var
                       (List.find
                          (fun x -> String.compare x.var_name v.var_name = 0)
                          vars),
                     t,
                     ext )
               | T_unary (op, e), t, ext -> (T_unary (op, aux e), t, ext)
               | T_binary (bop, e1, e2), t, ext ->
                   (T_binary (bop, aux e1, aux e2), t, ext)
               | _ -> e
             in
             aux e)
    in
    let precondition =
      match precondition with
      | Some e ->
          let rec aux e =
            match e with
            | T_var v, t, ext ->
                ( T_var
                    (List.find
                       (fun x -> String.compare x.var_name v.var_name = 0)
                       vars),
                  t,
                  ext )
            | T_unary (op, e), t, ext -> (T_unary (op, aux e), t, ext)
            | T_binary (bop, e1, e2), t, ext ->
                (T_binary (bop, aux e1, aux e2), t, ext)
            | _ -> e
          in
          Some (aux e)
      | None -> None
    in
    let block, funcmap, _ = prog in
    let f = StringMap.find !Config.main funcmap in
    let program =
      {
        (program_of_prog prog f.func_name) with
        environment = env;
        variables = vars;
      }
    in
    if not !minimal then (
      Format.printf "\nAbstract ctl typed Syntax:\n ";
      Typed_syntax.pp_prog !fmt (prog_of_program program));
    if !Config.refine then (* Run forward analysis if 'refine' flag is set *)
      ForwardIteratorB.analyze program.environment prog;
    fwdInvMap := !ForwardIteratorB.fwdInvMap;
    let inv = compute program property in
    let initialLabel = block_label program.mainFunction.func_body in
    let programInvariant = InvMap.find initialLabel inv in
    bwdInvMap := inv;
    witness program inv;
    tree := D.output_json program.variables programInvariant;
    Config.result :=
      if !Config.analysis = "non-termination" then
        D.partially_defined ?condition:precondition programInvariant
      else D.defined ?condition:precondition programInvariant;
    !Config.result
end
