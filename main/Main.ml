(***************************************************)
(*                                                 *)
(*                        Main                     *)
(*                                                 *)
(*                  Caterina Urban                 *)
(*     École Normale Supérieure, Paris, France     *)
(*                   2012 - 2015                   *)
(*                                                 *)
(***************************************************)

(* parsing *)
open Iterators
open Config

let parseFile filename =
  let f = open_in filename in
  let lex = Lexing.from_channel f in
  try
    lex.Lexing.lex_curr_p <-
      {lex.Lexing.lex_curr_p with Lexing.pos_fname= filename} ;
    let r = Parser.file Lexer.start lex in
    close_in f ; r
  with
  | Parser.Error ->
      Printf.eprintf "Parse Error (Invalid Syntax) near %s\n"
        (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p) ;
      failwith "Parse Error"
  | Failure e ->
      if e == "lexing: empty token" then (
        Printf.eprintf "Parse Error (Invalid Token) near %s\n"
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p) ;
        failwith "Parse Error" )
      else failwith e

let parsePropertyString str =
  let lex = Lexing.from_string str in
  try PropertyParser.file PropertyLexer.start lex with
  | PropertyParser.Error ->
      Printf.eprintf "Parse Error (Invalid Syntax) near %s\n"
        (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p) ;
      failwith "Parse Error"
  | Failure e ->
      if e == "lexing: empty token" then (
        Printf.eprintf "Parse Error (Invalid Token) near %s\n"
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p) ;
        failwith "Parse Error" )
      else failwith e

let parseProperty filename =
  let f = open_in filename in
  let lex = Lexing.from_channel f in
  try
    lex.Lexing.lex_curr_p <-
      {lex.Lexing.lex_curr_p with Lexing.pos_fname= filename} ;
    let r = PropertyParser.file PropertyLexer.start lex in
    close_in f ; r
  with
  | PropertyParser.Error ->
      Printf.eprintf "Parse Error (Invalid Syntax) near %s\n"
        (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p) ;
      failwith "Parse Error"
  | Failure e ->
      if e == "lexing: empty token" then (
        Printf.eprintf "Parse Error (Invalid Token) near %s\n"
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p) ;
        failwith "Parse Error" )
      else failwith e

let parseCTLProperty filename =
  let f = open_in filename in
  let lex = Lexing.from_channel f in
  try
    lex.Lexing.lex_curr_p <-
      {lex.Lexing.lex_curr_p with Lexing.pos_fname= filename} ;
    let res = CTLPropertyParser.prog CTLPropertyLexer.read lex in
    close_in f ;
    CTLProperty.map (fun p -> fst (parsePropertyString p)) res
  with
  | CTLPropertyParser.Error ->
      Printf.eprintf "Parse Error (Invalid Syntax) near %s\n"
        (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p) ;
      failwith "Parse Error"
  | Failure e ->
      if e == "lexing: empty token" then (
        Printf.eprintf "Parse Error (Invalid Token) near %s\n"
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p) ;
        failwith "Parse Error" )
      else failwith e

let parseCTLPropertyString_plain (property : string) =
  let lex = Lexing.from_string property in
  try
    lex.Lexing.lex_curr_p <-
      {lex.Lexing.lex_curr_p with Lexing.pos_fname= "string"} ;
    CTLPropertyParser.prog CTLPropertyLexer.read lex
  with
  | CTLPropertyParser.Error ->
      Printf.eprintf "Parse Error (Invalid Syntax) near %s\n"
        (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p) ;
      failwith "Parse Error"
  | Failure e ->
      if e == "lexing: empty token" then (
        Printf.eprintf "Parse Error (Invalid Token) near %s\n"
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p) ;
        failwith "Parse Error" )
      else failwith e

let parseCTLPropertyString (property : string) =
  CTLProperty.map (fun p -> fst (parsePropertyString p))
  @@ parseCTLPropertyString_plain property

let parse_args () =
  Arg.parse
    [ ( "-config"
      , Arg.String (fun s -> Config.from_json s)
      , "Set analysis configuration with a json file" )
    ; ( "-domain"
      , Arg.String (fun s -> Config.domain := s)
      , "Numerical Abstract Domain used" )
    ; ( "-nowrap"
      , Arg.Unit (fun _ -> Config.nowrap := true)
      , "Refine the backward analysis" )
    ; ( "-timeout"
      , Arg.Float (fun d -> Config.timeout := d)
      , "Maximal analysis time in seconds" )
    ; ( "-joinfwd"
      , Arg.Int (fun i -> Config.joinfwd := i)
      , "Widening delay in forward analysis" )
    ; ( "-joinbwd"
      , Arg.Int (fun i -> Config.joinbwd := i)
      , "Widening delay in backward analysis" )
    ; ( "-main"
      , Arg.String (fun s -> Config.main := s)
      , "Analysis entry point" )
    ; ( "-meetbwd"
      , Arg.Int (fun i -> Config.meetbwd := i)
      , "Dual widening delay in backward analysis" )
    ; ( "-minimal"
      , Arg.Unit (fun _ -> Config.minimal := true)
      , "Output analysis result only" )
    ; ( "-ordinals"
      , Arg.Int
          (fun i ->
            Config.ordmax := i ;
            Config.ordinals := true )
      , "Set ordinals based analysis" )
    ; ( "-refine"
      , Arg.Unit (fun _ -> Config.refine := true)
      , "Refine the backward analysis" )
    ; ( "-retrybwd"
      , Arg.Int (fun i -> Config.retrybwd := i)
      , "Retry widening heuristic" )
    ; ( "-tracefwd"
      , Arg.Unit (fun _ -> Config.tracefwd := true)
      , "Forward analysis trace" )
    ; ( "-tracebwd"
      , Arg.Unit (fun _ -> Config.tracebwd := true)
      , "Backward analysis trace" )
    ; ( "-cda"
      , Arg.Int
          (fun i ->
            Config.cda := true ;
            Config.refine := true ;
            Config.size := i )
      , "Conflict-driven analysis" )
    ; ( "-termination"
      , Arg.Unit (fun _ -> Config.analysis := "termination")
      , "Termination analysis" )
    ; ( "-nontermination"
      , Arg.Unit (fun _ -> Config.analysis := "non-termination")
      , "Non-termination analysis" )
    ; ( "-time"
      , Arg.Unit (fun _ -> Config.time := true)
      , "Track analysis time" )
    ; ( "-timefwd"
      , Arg.Unit (fun _ -> Config.timefwd := true)
      , "Track forward analysis time" )
    ; ( "-timebwd"
      , Arg.Unit (fun _ -> Config.timefwd := true)
      , "Track backward analysis time" )
    ; ( "-ctl"
      , Arg.String
          (fun s ->
            Config.analysis := "ctl" ;
            Config.property := s )
      , "CTL analysis" )
    ; ( "-dot"
      , Arg.Unit (fun _ -> Config.dot := true)
      , "Output decision trees in dot format" )
    ; ( "-precondition"
      , Arg.String (fun s -> Config.precondition := s)
      , "Optional precondition that holds at the starts of the program" )
    ; ( "-ctl_existential_equivalence"
      , Arg.Unit (fun _ -> Config.ctl_existential_equivalence := true)
      , "Convert existential ctl properties to universal" )
    ; ( "-vulnerability"
      , Arg.Unit (fun _ -> Config.vulnerability := true)
      , "Vulnerability analysis" )
    ; ( "-resilience"
      , Arg.Unit
          (fun _ ->
            Config.analysis := "termination" ;
            Config.resilience := true )
      , "Termination Resilience analysis" )
    ; ( "-json_output"
      , Arg.String
          (fun s ->
            Config.json_output := true ;
            Config.output_dir := s )
      , "Summary of the analysis in a json file" )
    ; ( "-json_output_std"
      , Arg.Unit (fun _ -> Config.json_output := true)
      , "Summary of the analysis as a json in stdout" ) ]
    (fun s -> Config.filename := s)
    ""

(* do all *)

let run_analysis analysis_function program () =
  try
    let start = Sys.time () in
    let result = analysis_function program !main in
    let stop = Sys.time () in
    Format.fprintf !fmt "Analysis Result: " ;
    let result = if result then "TRUE" else "UNKNOWN" in
    Format.fprintf !fmt "%s\n" result ;
    if !time then Format.fprintf !fmt "Time: %f s\n" (stop -. start) ;
    Format.fprintf !fmt "\nDone.\n"
  with Iterator.Timeout ->
    Format.fprintf !fmt "\nThe Analysis Timed Out!\n" ;
    Format.fprintf !fmt "\nDone.\n"

let termination () =
  if !filename = "" then raise (Invalid_argument "No Source File Specified") ;
  let sources = parseFile !filename in
  let program, _ = ItoA.prog_itoa sources in
  if not !minimal then (
    Format.fprintf !fmt "\nAbstract Syntax:\n" ;
    AbstractSyntax.prog_print !fmt program ) ;
  let analysis_function =
    match !domain with
    | "boxes" ->
        if !ordinals then TerminationBoxesOrdinals.analyze
        else TerminationBoxes.analyze
    | "octagons" ->
        if !ordinals then TerminationOctagonsOrdinals.analyze
        else TerminationOctagons.analyze
    | "polyhedra" ->
        if !ordinals then TerminationPolyhedraOrdinals.analyze
        else TerminationPolyhedra.analyze
    | _ -> raise (Invalid_argument "Unknown Abstract Domain")
  in
  run_analysis (fun a b -> analysis_function a b !robust) program ()

let guarantee () =
  if !filename = "" then raise (Invalid_argument "No Source File Specified") ;
  if !property = "" then raise (Invalid_argument "No Property File Specified") ;
  let sources = parseFile !filename in
  let property = parseProperty !property in
  let program, property =
    ItoA.prog_itoa ~property:(!main, property) sources
  in
  let property =
    match property with
    | None -> raise (Invalid_argument "Unknown Property")
    | Some property -> property
  in
  if not !minimal then (
    Format.fprintf !fmt "\nAbstract Syntax:\n" ;
    AbstractSyntax.prog_print !fmt program ;
    Format.fprintf !fmt "\nProperty: " ;
    AbstractSyntax.property_print !fmt property ) ;
  let analysis_function =
    match !domain with
    | "boxes" ->
        if !ordinals then GuaranteeBoxesOrdinals.analyze
        else GuaranteeBoxes.analyze
    | "octagons" ->
        if !ordinals then GuaranteeOctagonsOrdinals.analyze
        else GuaranteeOctagons.analyze
    | "polyhedra" ->
        if !ordinals then GuaranteePolyhedraOrdinals.analyze
        else GuaranteePolyhedra.analyze
    | _ -> raise (Invalid_argument "Unknown Abstract Domain")
  in
  run_analysis (analysis_function !robust property) program ()

let recurrence () =
  if !filename = "" then raise (Invalid_argument "No Source File Specified") ;
  if !property = "" then raise (Invalid_argument "No Property File Specified") ;
  let sources = parseFile !filename in
  let property = parseProperty !property in
  let program, property =
    ItoA.prog_itoa ~property:(!main, property) sources
  in
  let property =
    match property with
    | None -> raise (Invalid_argument "Unknown Property")
    | Some property -> property
  in
  if not !minimal then (
    Format.fprintf !fmt "\nAbstract Syntax:\n" ;
    AbstractSyntax.prog_print !fmt program ;
    Format.fprintf !fmt "\nProperty: " ;
    AbstractSyntax.property_print !fmt property ) ;
  let analysis_function =
    match !domain with
    | "boxes" ->
        if !ordinals then RecurrenceBoxesOrdinals.analyze
        else RecurrenceBoxes.analyze
    | "octagons" ->
        if !ordinals then RecurrenceOctagonsOrdinals.analyze
        else RecurrenceOctagons.analyze
    | "polyhedra" ->
        if !ordinals then RecurrencePolyhedraOrdinals.analyze
        else RecurrencePolyhedra.analyze
    | _ -> raise (Invalid_argument "Unknown Abstract Domain")
  in
  run_analysis (analysis_function property) program ()

let ctl_ast () =
  if !filename = "" then raise (Invalid_argument "No Source File Specified") ;
  if !property = "" then raise (Invalid_argument "No Property Specified") ;
  let starttime = Sys.time () in
  let parsedPrecondition = parsePropertyString !precondition in
  let parsedProperty = parseCTLPropertyString !property in
  let prog, property =
    ItoA.ctl_prog_itoa parsedProperty !main (parseFile !filename)
  in
  let precondition =
    fst
    @@ AbstractSyntax.StringMap.find ""
    @@ ItoA.property_itoa_of_prog prog !main parsedPrecondition
  in
  if not !minimal then (
    Format.fprintf !fmt "\nAbstract Syntax:\n" ;
    AbstractSyntax.prog_print !fmt prog ;
    Format.fprintf !fmt "\n" ) ;
  let program = ASTCTLIterator.program_of_prog prog !main in
  let analyze =
    match !domain with
    | "boxes" ->
        if !ordinals then ASTCTLBoxesOrdinals.analyze
        else ASTCTLBoxes.analyze
    | "octagons" ->
        if !ordinals then ASTCTLOctagonsOrdinals.analyze
        else ASTCTLOctagons.analyze
    | "polyhedra" ->
        if !ordinals then ASTCTLPolyhedraOrdinals.analyze
        else ASTCTLPolyhedra.analyze
    | _ -> raise (Invalid_argument "Unknown Abstract Domain")
  in
  let result = analyze ~precondition program property in
  ( if !time then
      let stoptime = Sys.time () in
      Format.fprintf !fmt "\nTime: %f" (stoptime -. starttime) ) ;
  if result then Format.fprintf !fmt "\nAnalysis Result: TRUE\n"
  else Format.fprintf !fmt "\nAnalysis Result: UNKNOWN\n"

let ctl_cfg () =
  if !filename = "" then raise (Invalid_argument "No Source File Specified") ;
  if !property = "" then raise (Invalid_argument "No Property Specified") ;
  let starttime = Sys.time () in
  let cfg, getProperty =
    ASTtoCFG.prog (FileParser.parse_file !filename) !main
  in
  let mainFunc = ControlFlowGraph.find_func !main cfg in
  let cfg = ControlFlowGraph.insert_entry_exit_label cfg mainFunc in
  (* add exit/entry labels to main function *)
  let cfg =
    if !noinline then cfg else ControlFlowGraph.inline_function_calls cfg
  in
  (* inline all non recursive functions unless -noinline is used *)
  let cfg = ControlFlowGraph.add_function_call_arcs cfg in
  (* insert function call edges for remaining function calls *)
  let ctlProperty =
    CTLProperty.map FileParser.parse_bool_expression
    @@ parseCTLPropertyString_plain !property
  in
  let ctlProperty = CTLProperty.map getProperty ctlProperty in
  let precondition =
    getProperty @@ FileParser.parse_bool_expression !precondition
  in
  let analyze =
    match !domain with
    | "boxes" ->
        if !ordinals then CTLBoxesOrdinals.analyze else CTLBoxes.analyze
    | "octagons" ->
        if !ordinals then CTLOctagonsOrdinals.analyze
        else CTLOctagons.analyze
    | "polyhedra" ->
        if !ordinals then CTLPolyhedraOrdinals.analyze
        else CTLPolyhedra.analyze
    | _ -> raise (Invalid_argument "Unknown Abstract Domain")
  in
  if not !minimal then (
    Printf.printf "\nCFG:\n" ;
    Printf.printf "%a" CFGPrinter.print_cfg cfg ;
    Printf.printf "\n" ) ;
  if (not !minimal) && !Iterator.dot then (
    Printf.printf "CFG_DOT:\n %a" CFGPrinter.output_dot cfg ;
    Printf.printf "\n" ) ;
  let mainFunc = ControlFlowGraph.find_func !main cfg in
  let possibleLoopHeads = Loop_detection.possible_loop_heads cfg mainFunc in
  let domSets = Loop_detection.dominator cfg mainFunc in
  analyze ~precondition cfg !robust mainFunc possibleLoopHeads domSets
    ctlProperty ;
  ( if !time then
      let stoptime = Sys.time () in
      Format.fprintf !fmt "\nTime: %f" (stoptime -. starttime) ) ;
  if !Config.result then Format.fprintf !fmt "\nAnalysis Result: TRUE\n"
  else Format.fprintf !fmt "\nAnalysis Result: UNKNOWN\n"

(*Main entry point for application*)
let doit () =
  parse_args () ;
  ( match !analysis with
  | "termination" -> termination ()
  | "guarantee" -> guarantee ()
  | "recurrence" -> recurrence ()
  | "ctl-ast" -> ctl_ast ()
  | "ctl" -> ctl_ast ()
  | "ctl-cfg" -> ctl_cfg ()
  | _ -> raise (Invalid_argument "Unknown Analysis") ) ;
  Regression.output_json ()

let _ = doit ()

(* DEPRECATED STUFF BELOW *)
