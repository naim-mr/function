(***************************************************)
(*                                                 *)
(*                        Main                     *)
(*                                                 *)
(*                  Caterina Urban                 *)
(*     École Normale Supérieure, Paris, France     *)
(*                   2012 - 2015                   *)
(*                                                 *)
(***************************************************)

open Cda
open Config
open Semantics

let parseFile filename =
  let f = open_in filename in
  let lex = Lexing.from_channel f in
  try
    lex.Lexing.lex_curr_p <-
      { lex.Lexing.lex_curr_p with Lexing.pos_fname = filename };
    let r = Parser.file Lexer.start lex in
    close_in f;
    r
  with
  | Parser.Error ->
      Format.eprintf "Parse Error (Invalid Syntax) near %s\n"
        (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
      failwith "Parse Error"
  | Failure e ->
      if e == "lexing: empty token" then (
        Format.eprintf "Parse Error (Invalid Token) near %s\n"
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
        failwith "Parse Error")
      else failwith e

let parsePropertyString str =
  let lex = Lexing.from_string str in
  try PropertyParser.file PropertyLexer.start lex with
  | PropertyParser.Error ->
      Format.eprintf "Parse Error (Invalid Syntax) near %s\n"
        (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
      failwith "Parse Error"
  | Failure e ->
      if e == "lexing: empty token" then (
        Format.eprintf "Parse Error (Invalid Token) near %s\n"
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
        failwith "Parse Error")
      else failwith e

let parseProperty filename =
  let f = open_in filename in
  let lex = Lexing.from_channel f in
  try
    lex.Lexing.lex_curr_p <-
      { lex.Lexing.lex_curr_p with Lexing.pos_fname = filename };
    let r = PropertyParser.file PropertyLexer.start lex in
    close_in f;
    r
  with
  | PropertyParser.Error ->
      Format.eprintf "Parse Error (Invalid Syntax) near %s\n"
        (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
      failwith "Parse Error"
  | Failure e ->
      if e == "lexing: empty token" then (
        Format.eprintf "Parse Error (Invalid Token) near %s\n"
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
        failwith "Parse Error")
      else failwith e

let parseCTLProperty filename =
  let f = open_in filename in
  let lex = Lexing.from_channel f in
  try
    lex.Lexing.lex_curr_p <-
      { lex.Lexing.lex_curr_p with Lexing.pos_fname = filename };
    let res = CTLPropertyParser.prog CTLPropertyLexer.read lex in
    close_in f;
    CTLProperty.map (fun p -> fst (parsePropertyString p)) res
  with
  | CTLPropertyParser.Error ->
      Format.eprintf "Parse Error (Invalid Syntax) near %s\n"
        (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
      failwith "Parse Error"
  | Failure e ->
      if e == "lexing: empty token" then (
        Format.eprintf "Parse Error (Invalid Token) near %s\n"
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
        failwith "Parse Error")
      else failwith e

let parseCTLPropertyString_plain (property : string) =
  let lex = Lexing.from_string property in
  try
    lex.Lexing.lex_curr_p <-
      { lex.Lexing.lex_curr_p with Lexing.pos_fname = "string" };
    CTLPropertyParser.prog CTLPropertyLexer.read lex
  with
  | CTLPropertyParser.Error ->
      Format.eprintf "Parse Error (Invalid Syntax) near %s\n"
        (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
      failwith "Parse Error"
  | Failure e ->
      if e == "lexing: empty token" then (
        Format.eprintf "Parse Error (Invalid Token) near %s\n"
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
        failwith "Parse Error")
      else failwith e

let parseCTLPropertyString (property : string) =
  CTLProperty.map (fun p -> fst (parsePropertyString p))
  @@ parseCTLPropertyString_plain property

let isKeyword = function
  | "-domain" | "-timeout" | "-joinfwd" | "-joinbwd" | "-main" | "-meetbwd"
  | "-minimal" | "-ordinals" | "-refine" | "-retrybwd" | "-tracefwd"
  | "-tracebwd" | "-cda" | "-termination" | "-guarantee" | "-recurrence"
  | "-time" | "-timefwd" | "-timebwd" | "-ctl" | "-ctl-ast" | "-ctl-cfg"
  | "-dot" | "-precondition" | "-ctl_existential_equivalence" | "-noinline"
  | "-vulnerability" | "-output_std" | "-json_output" | "-resilience" ->
      true
  | _ -> false

let parseArgs () =
  let rec doit args =
    match args with
    | "-domain" :: x :: r ->
        (* abstract domain: boxes|octagons|polyhedra *)
        Config.domain := x;
        doit r
    | "-timeout" :: x :: r ->
        (* analysis timeout *)
        Config.timeout := float_of_string x;
        doit r
    | "-joinfwd" :: x :: r ->
        (* widening delay in forward analysis *)
        Config.joinfwd := int_of_string x;
        doit r
    | "-joinbwd" :: x :: r ->
        (* widening delay in backward analysis *)
        Config.joinbwd := int_of_string x;
        doit r
    | "-main" :: x :: r ->
        (* analyzer entry point *)
        Config.main := x;
        doit r
    | "-meetbwd" :: x :: r ->
        (* dual widening delay in backward analysis *)
        Config.meetbwd := int_of_string x;
        doit r
    | "-minimal" :: r ->
        (* analysis result only *)
        Config.minimal := true;
        Config.minimal := true;
        doit r
    | "-ordinals" :: x :: r ->
        (* ordinal-valued ranking functions *)
        Config.ordinals := true;
        Ordinals.max := int_of_string x;
        doit r
    | "-refine" :: r ->
        (* refine in backward analysis *)
        Config.refine := true;
        doit r
    | "-retrybwd" :: x :: r ->
        (* Retry widening heuristic *)
        Config.retrybwd := int_of_string x;
        doit r
    | "-tracefwd" :: r ->
        (* forward analysis trace *)
        Config.tracefwd := true;
        doit r
    | "-tracebwd" :: r ->
        (* backward analysis trace *)
        Config.tracebwd := true;
        CFGInterpreter.trace := true;
        CFGInterpreter.trace_states := true;
        doit r
    | "-cda" :: x :: r ->
        (* Conflict-driven analysis *)
        Config.cda := true;
        Config.size := int_of_string x;
        Config.refine := true;
        doit r
    | "-termination" :: r ->
        (* termination analysis *)
        Config.analysis := "termination";
        doit r
    | "-guarantee" :: x :: r ->
        (* guarantee analysis *)
        Config.analysis := "guarantee";
        Config.property := x;
        doit r
    | "-recurrence" :: x :: r ->
        (* recurrence analysis *)
        Config.analysis := "recurrence";
        Config.property := x;
        doit r
    | "-time" :: r ->
        (* track analysis time *)
        Config.time := true;
        doit r
    | "-timefwd" :: r ->
        (* track forward analysis time *)
        Config.timefwd := true;
        doit r
    | "-timebwd" :: r ->
        (* track backward analysis time *)
        Config.timebwd := true;
        doit r
    | "-ctl" :: x :: r ->
        (* CTL analysis *)
        Config.analysis := "ctl";
        Config.property := x;
        doit r
    | "-ctl-ast" :: x :: r ->
        (* CTL analysis *)
        Config.analysis := "ctl";
        Config.ctltype := "AST";
        property := x;
        doit r
    | "-ctl-cfg" :: x :: r ->
        (* CTL analysis *)
        Config.analysis := "ctl";
        Config.ctltype := "CFG";
        property := x;
        doit r
    | "-dot" :: r ->
        (* print CFG and decision trees in 'dot' format *)
        dot := true;
        doit r
    | "-precondition" :: c :: r ->
        (* optional precondition that holds 
                                  at the start of the program, default = true *)
        Config.precondition := c;
        doit r
    | "-ctl_existential_equivalence" :: r ->
        (* use CTL equivalence relations to 
                                              convert existential to universal CTL properties *)
        Config.ctl_existential_equivalence := true;
        doit r
    | "-noinline" :: r ->
        (* don't inline function calls, only for CFG based analysis *)
        Config.noinline := true;
        doit r
    | "-vulnerability" :: r ->
        Config.vulnerability := true;
        doit r
    | "-resilience" :: r ->
        (* resilience analysis *)
        Config.analysis := "termination";
        Config.resilience := true;
        doit r
    | "-json_output" :: x :: r when not (isKeyword x) ->
        Config.json_output := true;
        output_dir := x;
        time := true
    | "-json_output" :: r ->
        Config.json_output := true;
        time := true;
        doit r
    | x :: r ->
        filename := x;
        doit r
    | [] -> ()
  in
  doit (List.tl (Array.to_list Sys.argv))

let check_args () =
  if
    !Config.resilience
    && not (String.compare !Config.analysis "termination" <> 0)
  then
    raise
      (Invalid_argument "Resilience analysis is avalaible only for termination");
  if !Config.vulnerability && String.compare !Config.ctltype "CFG" == 0 then
    raise
      (Invalid_argument
         "Vulnerability  analysis is avalaible only for AST based iterations");
  if String.compare !Config.filename "" = 0 then
    raise (Invalid_argument "No Source File Specified");
  if
    String.compare !property "" = 0
    && String.compare !analysis "termination" <> 0
  then raise (Invalid_argument "No Property File Specified")

(* Factorised function to run termination/guarantee/reccurence analysis *)
let run_analysis analysis_function program () =
  try
    let start = Sys.time () in
    Config.result := analysis_function program !main;
    let stop = Sys.time () in
    let res = if !Config.result then "TRUE" else "UNKNOW" in
    Format.fprintf !fmt "Final Analysis Result: %s\n" res;
    if !time then exectime := string_of_float (stop -. start);
    Format.fprintf !fmt "Time: %f s\n" (stop -. start);
    Format.fprintf !fmt "\nDone.\n"
  with Config.Timeout ->
    Format.fprintf !fmt "\nThe Analysis Timed Out!\n";
    Format.fprintf !fmt "\nDone.\n"

let termination_iterator () : (module SEMANTIC) =
  let open TerminationIterator in
  let module S =
    (val match !domain with
         | "boxes" ->
             if !ordinals then (module TerminationIterator (DecisionTree.TSOB))
             else (module TerminationIterator (DecisionTree.TSAB))
         | "octagons" ->
             if !ordinals then (module TerminationIterator (DecisionTree.TSOO))
             else (module TerminationIterator (DecisionTree.TSAO))
         | "polyhedra" ->
             if !ordinals then (module TerminationIterator (DecisionTree.TSOP))
             else (module TerminationIterator (DecisionTree.TSAP))
         | _ -> raise (Invalid_argument "Unknown Abstract Domain")
        : SEMANTIC)
  in
  (module S)

let guarantee_iterator () : (module SEMANTIC) =
  let open GuaranteeIterator in
  let module S =
    (val match !domain with
         | "boxes" ->
             if !ordinals then (module GuaranteeIterator (DecisionTree.TSOB))
             else (module GuaranteeIterator (DecisionTree.TSAB))
         | "octagons" ->
             if !ordinals then (module GuaranteeIterator (DecisionTree.TSOO))
             else (module GuaranteeIterator (DecisionTree.TSAO))
         | "polyhedra" ->
             if !ordinals then (module GuaranteeIterator (DecisionTree.TSOP))
             else (module GuaranteeIterator (DecisionTree.TSAP))
         | _ -> raise (Invalid_argument "Unknown Abstract Domain")
        : SEMANTIC)
  in
  (module S)

let recurrence_iterator () : (module SEMANTIC) =
  let open RecurrenceIterator in
  let module S =
    (val match !domain with
         | "boxes" ->
             if !ordinals then (module RecurrenceIterator (DecisionTree.TSOB))
             else (module RecurrenceIterator (DecisionTree.TSAB))
         | "octagons" ->
             if !ordinals then (module RecurrenceIterator (DecisionTree.TSOO))
             else (module RecurrenceIterator (DecisionTree.TSAO))
         | "polyhedra" ->
             if !ordinals then (module RecurrenceIterator (DecisionTree.TSOP))
             else (module RecurrenceIterator (DecisionTree.TSAP))
         | _ -> raise (Invalid_argument "Unknown Abstract Domain")
        : SEMANTIC)
  in
  (module S)

let ctl_iterator () : (module SEMANTIC) =
  let open CTLIterator in
  let module S =
    (val match !domain with
         | "boxes" ->
             if !ordinals then (module CTLIterator (DecisionTree.TSOB))
             else (module CTLIterator (DecisionTree.TSAB))
         | "octagons" ->
             if !ordinals then (module CTLIterator (DecisionTree.TSOO))
             else (module CTLIterator (DecisionTree.TSAO))
         | "polyhedra" ->
             if !ordinals then (module CTLIterator (DecisionTree.TSOP))
             else (module CTLIterator (DecisionTree.TSAP))
         | _ -> raise (Invalid_argument "Unknown Abstract Domain")
        : SEMANTIC)
  in
  (module S)

(* TODO: factorised it with a first order module manipulating function *)
module CFGCTLBoxes = CFGCTLIterator.CFGCTLIterator (DecisionTree.TSAB)
module CFGCTLBoxesOrdinals = CFGCTLIterator.CFGCTLIterator (DecisionTree.TSOB)
module CFGCTLOctagons = CFGCTLIterator.CFGCTLIterator (DecisionTree.TSAO)
module CFGCTLOctagonsOrdinals = CFGCTLIterator.CFGCTLIterator (DecisionTree.TSOO)
module CFGCTLPolyhedra = CFGCTLIterator.CFGCTLIterator (DecisionTree.TSAP)

module CFGCTLPolyhedraOrdinals =
  CFGCTLIterator.CFGCTLIterator (DecisionTree.TSOP)

let run_termination (module S : SEMANTIC) program =
  if not !minimal then (
    Format.fprintf !fmt "\nAbstract Syntax:\n";
    AbstractSyntax.prog_print !fmt program);
  let parsedPrecondition = parsePropertyString !precondition in
  (* TODO:  property_itoa_of_prog logic is strange *)
  let precondition =
    fst
    @@ AbstractSyntax.StringMap.find ""
    @@ ItoA.property_itoa_of_prog program !main parsedPrecondition
  in
  let analysis_function =
    S.analyze ~precondition:(Some precondition) ~property:S.dummy_prop
  in
  run_analysis analysis_function program ()

let run_rec_gua (module S : SEMANTIC) program property =
  let property =
    match property with
    | None -> raise (Invalid_argument "Unknown Property")
    | Some property -> property
  in
  if not !minimal then (
    Format.fprintf !fmt "\nAbstract Syntax:\n";
    AbstractSyntax.prog_print !fmt program;
    Format.fprintf !fmt "\nProperty: ";
    AbstractSyntax.property_print !fmt property);
  let parsedPrecondition = parsePropertyString !precondition in
  let precondition =
    fst
    @@ AbstractSyntax.StringMap.find ""
    @@ ItoA.property_itoa_of_prog program !main parsedPrecondition
  in
  let analysis_function = S.analyze in
  run_analysis
    (analysis_function ~precondition:(Some precondition)
       ~property:(Exp property))
    program ()

let run_ctl_ast (module S : SEMANTIC) prog property =
  let starttime = Sys.time () in
  let parsedPrecondition = parsePropertyString !precondition in
  let precondition =
    fst
    @@ AbstractSyntax.StringMap.find ""
    @@ ItoA.property_itoa_of_prog prog !main parsedPrecondition
  in
  if not !minimal then (
    Format.fprintf !fmt "\nAbstract Syntax:\n";
    AbstractSyntax.prog_print !fmt prog;
    Format.fprintf !fmt "\n");
  let analyze = S.analyze in
  Config.result :=
    analyze ~precondition:(Some precondition) ~property:(Ctl property) prog "";
  if !time then (
    let stoptime = Sys.time () in
    exectime := string_of_float (stoptime -. starttime);
    Format.fprintf !fmt "\nTime: %f" (stoptime -. starttime));
  if !Config.result then Format.fprintf !fmt "\nFinal Analysis Result: TRUE\n"
  else Format.fprintf !fmt "\nFinal Analysis Result: UNKNOWN\n"

let run_ctl_cfg () =
  if !filename = "" then raise (Invalid_argument "No Source File Specified");
  if !property = "" then
    raise (Invalid_argument "No Property Specifilet s = Lexing.dummy_posed");
  let starttime = Sys.time () in
  let cfg, getProperty =
    Tree_to_cfg.prog (File_parser.parse_file !filename) !main
  in
  let mainFunc = Cfg.find_func !main cfg in
  let cfg = Cfg.insert_entry_exit_label cfg mainFunc in
  (* add exit/entry labels to main function *)
  let cfg = if !noinline then cfg else Cfg.inline_function_calls cfg in
  (* inline all non recursive functions unless -noinline is used *)
  let cfg = Cfg.add_function_call_arcs cfg in
  (* insert function call edges for remaining function calls *)
  let ctlProperty =
    CTLProperty.map File_parser.parse_bool_expression
    @@ parseCTLPropertyString_plain !property
  in
  let ctlProperty = CTLProperty.map getProperty ctlProperty in
  let precondition =
    getProperty @@ File_parser.parse_bool_expression !precondition
  in
  let analyze =
    match !domain with
    | "boxes" ->
        if !ordinals then CFGCTLBoxesOrdinals.analyze else CFGCTLBoxes.analyze
    | "octagons" ->
        if !ordinals then CFGCTLOctagonsOrdinals.analyze
        else CFGCTLOctagons.analyze
    | "polyhedra" ->
        if !ordinals then CFGCTLPolyhedraOrdinals.analyze
        else CFGCTLPolyhedra.analyze
    | _ -> raise (Invalid_argument "Unknown Abstract Domain")
  in
  if not !minimal then (
    Format.fprintf !fmt "\nCFG:\n";
    Format.fprintf !fmt "%a" Cfg_printer.print_cfg cfg;
    Format.fprintf !fmt "\n");
  if (not !minimal) && !Config.dot then (
    Format.fprintf !fmt "CFG_DOT:\n %a" Cfg_printer.output_dot cfg;
    Format.fprintf !fmt "\n");
  let mainFunc = Cfg.find_func !main cfg in
  let possibleLoopHeads = Loop_detection.possible_loop_heads cfg mainFunc in
  let domSets = Loop_detection.dominator cfg mainFunc in
  Config.result :=
    analyze ~precondition cfg mainFunc possibleLoopHeads domSets ctlProperty;
  if !time then (
    let stoptime = Sys.time () in
    exectime := string_of_float (stoptime -. starttime);
    Format.fprintf !fmt "\nTime: %f" (stoptime -. starttime));
  if !Config.result then Format.fprintf !fmt "\nFinal Analysis Result: TRUE\n"
  else Format.fprintf !fmt "\nFinal Analysis Result: UNKNOWN\n"

let run_cda s : (module Cda.CDA_ITERATOR) =
  let module D = (val s : SEMANTIC) in
  (module Cda.Make (D))

let get_semantic () =
  match !analysis with
  | "termination" -> termination_iterator ()
  | "guarantee" -> guarantee_iterator ()
  | "recurrence" -> recurrence_iterator ()
  | "ctl" | "ctl-ast" | "ctl-cfg" -> ctl_iterator ()
  | _ -> raise (Invalid_argument "Unknown Analysis")

let get_ast_prop itast =
  match !analysis with
  | "termination" ->
      let s = Lexing.dummy_pos in
      let p =
        ( IntermediateSyntax.I_universal (IntermediateSyntax.I_TRUE, (s, s)),
          (s, s) )
      in
      let program, property = ItoA.prog_itoa ~property:(!main, p) itast in
      (program, Semantics.Exp (Option.get property), None)
  | "guarantee" | "recurrence" ->
      let program, property =
        ItoA.prog_itoa ~property:(!main, parseProperty !property) itast
      in
      (program, Semantics.Exp (Option.get property), property)
  | "ctl" | "ctl-ast" | "ctl-cfg" ->
      let parsedProperty = parseCTLPropertyString !property in
      let program, property =
        ItoA.ctl_prog_itoa parsedProperty !main (parseFile !filename)
      in
      (program, Semantics.Ctl property, None)
  | _ -> raise (Invalid_argument "Unknown Analysis")

let doit () =
  (* Parsing cli args -> into Config ref variables *)
  parseArgs ();
  check_args ();
  (* Get the iterator for the demanded analysis *)
  let semantic = get_semantic () in
  (* Property and filename must be given (except for termination property) *)
  (* Parsing the property and the file to an intermediate ast *)
  let itast = parseFile !filename in
  (* Get the ast and the properties*)
  let program, property, prop = get_ast_prop itast in
  (* A program is a map of variable, a block (see: AbstractSyntax.ml) and a map of functions *)
  let vars, b, funcs = program in
  (* Get the main function and the variables as a list *)
  let func = AbstractSyntax.StringMap.find !main funcs in
  let module S = (val semantic : SEMANTIC) in
  (* Launch the analysis and get the returned output "true" or "unknow" *)
  (if !Config.cda then
     let module C = (val run_cda semantic : CDA_ITERATOR) in
     let parsedPrecondition = parsePropertyString !precondition in
     let precondition =
       fst
       @@ AbstractSyntax.StringMap.find ""
       @@ ItoA.property_itoa_of_prog program !main parsedPrecondition
     in
     Config.result :=
       C.analyze ~property ~precondition:(Some precondition) funcs vars b !main
   else
     match !analysis with
     | "termination" -> run_termination (module S) program
     | "guarantee" | "recurrence" -> run_rec_gua (module S) program prop
     | "ctl" when !ctltype = "CFG" -> run_ctl_cfg ()
     | "ctl" (* default CTL analysis is CTL-AST *) ->
         run_ctl_ast
           (module S)
           program
           (match property with
           | Semantics.Ctl p -> p
           | _ -> raise (Invalid_argument "Impossible to reach"))
     | _ -> raise (Invalid_argument "Unknown Analysis"));
  if !Config.vulnerability && !ctltype <> "CFG" then (
    (* Launch the vulnerability analysisand output the infered variables *)
    let varlist =
      List.map snd @@ List.of_seq @@ AbstractSyntax.StringMap.to_seq vars
    in
    Vulnerability.analyse S.D.vulnerable varlist func !S.bwdInvMap;
    Format.fprintf !fmt " \n %s \n"
      (Yojson.Safe.pretty_to_string !Config.vuln_res);
    if !Config.json_output then Regression.output_json ())

let _ = doit ()
