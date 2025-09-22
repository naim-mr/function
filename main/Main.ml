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


let parse_args () =
  Arg.parse
    [
      ( "-config",
        Arg.String (fun s -> Config.from_json s),
        "Set analysis configuration with a json file" );
      ( "-domain",
        Arg.String (fun s -> Config.domain := s),
        "Numerical Abstract Domain used" );
      ( "-timeout",
        Arg.Float (fun d -> Config.timeout := d),
        "Maximal analysis time in seconds" );
      ( "-joinfwd",
        Arg.Int (fun i -> Config.joinfwd := i),
        "Widening delay in forward analysis" );
      ( "-joinbwd",
        Arg.Int (fun i -> Config.joinfwd := i),
        "Widening delay in backward analysis" );
      ("-main", Arg.String (fun s -> Config.main := s), "Analysis entry point");
      ( "-meetbwd",
        Arg.Int (fun i -> Config.meetbwd := i),
        "Dual widening delay in backward analysis" );
      ( "-minimal",
        Arg.Unit (fun _ -> Config.minimal := true),
        "Output analysis result only" );
      ( "-ordinals",
        Arg.Int
          (fun i ->
            Config.ordmax := i;
            Config.ordinals := true),
        "Set ordinals based analysis" );
      ( "-refine",
        Arg.Unit (fun _ -> Config.refine := true),
        "Refine the backward analysis" );
      ( "-retrybwd",
        Arg.Int (fun i -> Config.retrybwd := i),
        "Retry widening heuristic" );
      ( "-tracefwd",
        Arg.Unit (fun _ -> Config.tracefwd := true),
        "Forward analysis trace" );
      ( "-tracebwd",
        Arg.Unit (fun _ -> Config.tracebwd := true),
        "Backward analysis trace" );
      ( "-cda",
        Arg.Int
          (fun i ->
            Config.cda := true;
            Config.refine := true;
            Config.size := i),
        "Conflict-driven analysis" );
      ( "-termination",
        Arg.Unit (fun _ -> Config.analysis := "termination"),
        "Termination analysis" );
      ("-time", Arg.Unit (fun _ -> Config.time := true), "Track analysis time");
      ( "-timefwd",
        Arg.Unit (fun _ -> Config.timefwd := true),
        "Track forward analysis time" );
      ( "-timebwd",
        Arg.Unit (fun _ -> Config.timefwd := true),
        "Track backward analysis time" );
      ("-ctl", Arg.String (fun s -> Config.analysis := "ctl"; Config.property := s), "CTL analysis");
      ( "-dot",
        Arg.Unit (fun _ -> Config.dot := true),
        "Output decision trees in dot format" );
      ( "-precondition",
        Arg.String (fun s -> Config.precondition := s),
        "Optional precondition that holds at the starts of the program" );
      ( "-ctl_existential_equivalence",
        Arg.Unit (fun _ -> Config.ctl_existential_equivalence := true),
        "Convert existential ctl properties to universal" );
      ( "-vulnerability",
        Arg.Unit (fun _ -> Config.vulnerability := true),
        "Vulnerability analysis" );
      ( "-resilience",
        Arg.Unit
          (fun _ ->
            Config.analysis := "termination";
            Config.resilience := true),
        "Termination Resilience analysis" );
      ( "-json_output",
        Arg.Unit (fun _ -> Config.json_output := true),
        "Summary of the analysis in a json" );
      ( "-json_output",
        Arg.String
          (fun s ->
            Config.json_output := true;
            Config.output_dir := s),
        "Summary of the analysis in a json" );
    ]
    (fun s -> Config.filename := s)
    ""

let check_args () =
  if !Config.resilience && String.compare !Config.analysis "termination" <> 0
  then
    raise
      (Invalid_argument "Resilience analysis is avalaible only for termination");
  if String.compare !Config.filename "" = 0 then
    raise (Invalid_argument "No Source File Specified");
  if
    String.compare !property "" = 0
    && String.compare !analysis "termination" <> 0
  then raise (Invalid_argument "No Property File Specified")

(* Factorised function to run termination analysis *)
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

let run_cda s : (module Cda.CDA_ITERATOR) =
  let module D = (val s : SEMANTIC) in
  (module Cda.Make (D))

let get_semantic () =
  match !analysis with
  | "termination" -> termination_iterator ()
  | "ctl" -> ctl_iterator ()
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
  | "ctl" ->
      let parsedProperty = parseCTLPropertyString !property in
      let program, property =
        ItoA.ctl_prog_itoa parsedProperty !main (parseFile !filename)
      in
      (program, Semantics.Ctl property, None)
  | _ -> raise (Invalid_argument "Unknown Analysis")

let doit () =
  (* Parsing cli args -> into Config ref variables *)
  parse_args ();
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
     | "ctl" (* default CTL analysis is CTL-AST *) ->
         run_ctl_ast
           (module S)
           program
           (match property with
           | Semantics.Ctl p -> p
           | _ -> raise (Invalid_argument "Impossible to reach"))
     | _ -> raise (Invalid_argument "Unknown Analysis"));
  if !Config.vulnerability then (
    (* Launch the vulnerability analysisand output the infered variables *)
    let varlist =
      List.map snd @@ List.of_seq @@ AbstractSyntax.StringMap.to_seq vars
    in
    Vulnerability.analyse S.D.vulnerable varlist func !S.bwdInvMap;
    Format.fprintf !fmt " \n %s \n"
      (Yojson.Safe.pretty_to_string !Config.vuln_res));
  if !Config.json_output then Regression.output_json ()

let _ = doit ()
