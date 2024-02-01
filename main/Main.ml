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



(* parsing *)



let parseFile filename =
  let f = open_in filename in
  let lex = Lexing.from_channel f in
  try
    lex.Lexing.lex_curr_p <- { lex.Lexing.lex_curr_p
                               with Lexing.pos_fname = filename; };
    let r = Parser.file Lexer.start lex in
    close_in f; r
  with
  | Parser.Error ->
    Printf.eprintf "Parse Error (Invalid Syntax) near %s\n"
      (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
    failwith "Parse Error"
  | Failure e ->
    if e == "lexing: empty token" then 
      begin
        Printf.eprintf "Parse Error (Invalid Token) near %s\n" (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
        failwith "Parse Error"
      end 
    else
      failwith e

let parsePropertyString str =
  let lex = Lexing.from_string str in
  try
    PropertyParser.file PropertyLexer.start lex 
  with
  | PropertyParser.Error ->
    Printf.eprintf "Parse Error (Invalid Syntax) near %s\n" (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
    failwith "Parse Error"
  | Failure e ->
    if e == "lexing: empty token" then 
      begin
        Printf.eprintf "Parse Error (Invalid Token) near %s\n" (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
        failwith "Parse Error"
      end 
    else
      failwith e

let parseProperty filename =
  let f = open_in filename in
  let lex = Lexing.from_channel f in
  try
    lex.Lexing.lex_curr_p <- { lex.Lexing.lex_curr_p
                               with Lexing.pos_fname = filename; };
    let r = PropertyParser.file PropertyLexer.start lex in
    close_in f; r
  with
  | PropertyParser.Error -> Printf.eprintf "Parse Error (Invalid Syntax) near %s\n" (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
    failwith "Parse Error"
  | Failure e ->
    if e == "lexing: empty token" then 
      begin
        Printf.eprintf "Parse Error (Invalid Token) near %s\n" (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
        failwith "Parse Error"
      end 
    else
      failwith e

let parseCTLProperty filename =
  let f = open_in filename in
  let lex = Lexing.from_channel f in
  try
    lex.Lexing.lex_curr_p <- { lex.Lexing.lex_curr_p with Lexing.pos_fname = filename; };
    let res = CTLPropertyParser.prog CTLPropertyLexer.read lex in
    close_in f; 
    CTLProperty.map (fun p -> fst (parsePropertyString p)) res 
  with
  | CTLPropertyParser.Error->
    Printf.eprintf "Parse Error (Invalid Syntax) near %s\n" 
      (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
    failwith "Parse Error"
  | Failure e ->
    if e == "lexing: empty token" then 
      begin
        Printf.eprintf "Parse Error (Invalid Token) near %s\n" 
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
        failwith "Parse Error"
      end 
    else
      failwith e

let parseCTLPropertyString_plain (property:string) =
  let lex = Lexing.from_string property in
  try
    lex.Lexing.lex_curr_p <- { lex.Lexing.lex_curr_p with Lexing.pos_fname = "string"; };
    CTLPropertyParser.prog CTLPropertyLexer.read lex 
  with
  | CTLPropertyParser.Error->
    Printf.eprintf "Parse Error (Invalid Syntax) near %s\n" 
      (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
    failwith "Parse Error"
  | Failure e ->
    if e == "lexing: empty token" then 
      begin
        Printf.eprintf "Parse Error (Invalid Token) near %s\n" 
          (IntermediateSyntax.position_tostring lex.Lexing.lex_start_p);
        failwith "Parse Error"
      end 
    else
      failwith e

let parseCTLPropertyString (property:string) =
    CTLProperty.map (fun p -> fst (parsePropertyString p)) @@ parseCTLPropertyString_plain property 

let parse_args () =
  let rec doit args =
    match args with
    (* General arguments -----------------------------------------------------*)
    | "-domain"::x::r -> (* abstract domain: boxes|octagons|polyhedra *)
      Config.domain := x; doit r
    | "-timeout"::x::r -> (* analysis timeout *)
      Config.timeout := float_of_string x; doit r
    | "-joinfwd"::x::r -> (* widening delay in forward analysis *)
      Config.joinfwd := int_of_string x; doit r
    | "-joinbwd"::x::r -> (* widening delay in backward analysis *)
      Config.joinbwd := int_of_string x; doit r
    | "-main"::x::r -> (* analyzer entry point *) Config.main := x; doit r
    | "-meetbwd"::x::r -> (* dual widening delay in backward analysis *)
      Config.meetbwd := int_of_string x; doit r
    | "-minimal"::r -> (* analysis result only *)
      Config.minimal := true; Config.minimal := true; doit r
    | "-ordinals"::x::r -> (* ordinal-valued ranking functions *)
      Config.ordinals := true; Ordinals.max := int_of_string x; doit r
    | "-refine"::r -> (* refine in backward analysis *)
      Config.refine := true; doit r
    | "-retrybwd"::x::r ->
      Config.retrybwd := int_of_string x;
      DecisionTree.retrybwd := int_of_string x;
      doit r
    | "-tracefwd"::r -> (* forward analysis trace *)
      Config.tracefwd := true; doit r
    | "-tracebwd"::r -> (* backward analysis trace *)
      Config.tracebwd := true;
      DecisionTree.tracebwd := true;
      CFGInterpreter.trace := true;
      CFGInterpreter.trace_states := true;
      doit r
    (* Conflict driven analysis arguments -------------------------------------------------*)
    | "-cda"::x::r -> 
      Config.cda := true;
      Config.size :=  int_of_string x;
      Config.refine := true;
      doit r;
    (* Termination arguments -------------------------------------------------*)
    | "-termination"::r -> (* guarantee analysis *)
      Config.analysis := "termination"; doit r
    (* Recurrence / Guarantee arguments --------------------------------------*)
    | "-guarantee"::x::r -> (* guarantee analysis *)
      Config.analysis := "guarantee"; Config.property := x; doit r
    | "-recurrence"::x::r -> (* recurrence analysis *)
      Config.analysis := "recurrence";Config.property := x; doit r
    | "-time"::r -> (* track analysis time *)
      Config.time := true; doit r
    
    | "-timefwd"::r -> (* track forward analysis time *)
      Config.timefwd := true; doit r
    | "-timebwd"::r -> (* track backward analysis time *)
      Config.timebwd := true; doit r
    (* CTL arguments ---------------------------------------------------------*)
    | "-ctl"::x::r -> (* CTL analysis *)
      Config.analysis := "ctl"; Config.property := x; doit r
    | "-ctl-ast"::x::r -> (* CTL analysis *)
      Config.analysis := "ctl-ast"; Config.property := x; doit r
    | "-ctl-cfg"::x::r -> (* CTL analysis *)
      Config.analysis := "ctl-cfg"; Config.property := x; doit r
    | "-dot"::r -> (* print CFG and decision trees in 'dot' format *)
      Config.dot := true; doit r
    | "-precondition"::c::r -> (* optional precondition that holds 
                                  at the start of the program, default = true *)
      Config.precondition := c; doit r 
    | "-ctl_existential_equivalence"::r -> (* use CTL equivalence relations to 
                                              convert existential to universal CTL properties *)
      Config.ctl_existential_equivalence := true; doit r
    | "-noinline"::r -> (* don't inline function calls, only for CFG based analysis *)
      Config.noinline := true; doit r
    | x::r -> Config.filename := x; doit r
    | [] -> ()
  in
  doit (List.tl (Array.to_list Sys.argv))

(* do all *)

module TerminationBoxes =
  TerminationIterator.TerminationIterator(DecisionTree.TSAB)
module TerminationBoxesOrdinals =
  TerminationIterator.TerminationIterator(DecisionTree.TSOB)
module TerminationOctagons =
  TerminationIterator.TerminationIterator(DecisionTree.TSAO)
module TerminationOctagonsOrdinals =
  TerminationIterator.TerminationIterator(DecisionTree.TSOO)
module TerminationPolyhedra =
  TerminationIterator.TerminationIterator(DecisionTree.TSAP)
module TerminationPolyhedraOrdinals =
  TerminationIterator.TerminationIterator(DecisionTree.TSOP)

module GuaranteeBoxes =
  GuaranteeIterator.GuaranteeIterator(DecisionTree.TSAB)
module GuaranteeBoxesOrdinals =
  GuaranteeIterator.GuaranteeIterator(DecisionTree.TSOB)
module GuaranteeOctagons =
  GuaranteeIterator.GuaranteeIterator(DecisionTree.TSAO)
module GuaranteeOctagonsOrdinals =
  GuaranteeIterator.GuaranteeIterator(DecisionTree.TSOO)
module GuaranteePolyhedra =
  GuaranteeIterator.GuaranteeIterator(DecisionTree.TSAP)
module GuaranteePolyhedraOrdinals =
  GuaranteeIterator.GuaranteeIterator(DecisionTree.TSOP)

module RecurrenceBoxes =
  RecurrenceIterator.RecurrenceIterator(DecisionTree.TSAB)
module RecurrenceBoxesOrdinals =
  RecurrenceIterator.RecurrenceIterator(DecisionTree.TSOB)
module RecurrenceOctagons =
  RecurrenceIterator.RecurrenceIterator(DecisionTree.TSAO)
module RecurrenceOctagonsOrdinals =
  RecurrenceIterator.RecurrenceIterator(DecisionTree.TSOO)
module RecurrencePolyhedra =
  RecurrenceIterator.RecurrenceIterator(DecisionTree.TSAP)
module RecurrencePolyhedraOrdinals =
  RecurrenceIterator.RecurrenceIterator(DecisionTree.TSOP)

module CTLBoxes = CTLIterator.CTLIterator(DecisionTree.TSAB)
module CTLBoxesOrdinals = CTLIterator.CTLIterator(DecisionTree.TSOB)
module CTLOctagons = CTLIterator.CTLIterator(DecisionTree.TSAO)
module CTLOctagonsOrdinals = CTLIterator.CTLIterator(DecisionTree.TSOO)
module CTLPolyhedra = CTLIterator.CTLIterator(DecisionTree.TSAP)
module CTLPolyhedraOrdinals = CTLIterator.CTLIterator(DecisionTree.TSOP)

module CFGCTLBoxes = CFGCTLIterator.CFGCTLIterator(DecisionTree.TSAB)
module CFGCTLBoxesOrdinals = CFGCTLIterator.CFGCTLIterator(DecisionTree.TSOB)
module CFGCTLOctagons = CFGCTLIterator.CFGCTLIterator(DecisionTree.TSAO)
module CFGCTLOctagonsOrdinals = CFGCTLIterator.CFGCTLIterator(DecisionTree.TSOO)
module CFGCTLPolyhedra = CFGCTLIterator.CFGCTLIterator(DecisionTree.TSAP)
module CFGCTLPolyhedraOrdinals = CFGCTLIterator.CFGCTLIterator(DecisionTree.TSOP)



let result = ref false

let run_analysis analysis_function program () =
  try 
    
    let start = Sys.time () in
    let terminating = analysis_function program !main in
    let stop = Sys.time () in
    Format.fprintf !fmt "Final Analysis Result: ";
    let result = if terminating then "TRUE" else "UNKNOWN" in
    Format.fprintf !fmt "%s\n" result;
    if !time then
      Format.fprintf !fmt "Time: %f s\n" (stop-.start);
    Format.fprintf !fmt "\nDone.\n";
    terminating
  with
  | Config.Timeout ->
    Format.fprintf !fmt "\nThe Analysis Timed Out!\n";
    Format.fprintf !fmt "\nDone.\n";
    false

let cda_run s : (module Cda.CDA_ITERATOR)= 
  let module D = (val s: SEMANTIC) in
  (module Cda.Make(D))
  
  
let termination_iterator (): (module SEMANTIC)=
  let module S =
    (val (match !domain with
    | "boxes" -> if !ordinals then (module TerminationBoxesOrdinals) else (module TerminationBoxes)
    | "octagons" -> if !ordinals then (module TerminationOctagonsOrdinals) else (module TerminationOctagons)
    | "polyhedra" -> if !ordinals then (module TerminationPolyhedraOrdinals) else (module TerminationPolyhedra)
    | _ -> raise (Invalid_argument "Unknown Abstract Domain"))
    : SEMANTIC)
  in 
  (module S)

let guarantee_iterator (): (module SEMANTIC)=
  let module S =
    (val (match !domain with
    | "boxes" -> if !ordinals then (module GuaranteeBoxesOrdinals) else (module GuaranteeBoxes)
    | "octagons" -> if !ordinals then (module GuaranteeOctagonsOrdinals) else (module GuaranteeOctagons)
    | "polyhedra" -> if !ordinals then (module GuaranteePolyhedraOrdinals) else (module GuaranteePolyhedra)
    | _ -> raise (Invalid_argument "Unknown Abstract Domain"))
    : SEMANTIC)
  in 
  (module S)



let recurrence_iterator (): (module SEMANTIC)=
  let module S =
    (val (match !domain with
    | "boxes" -> if !ordinals then (module RecurrenceBoxesOrdinals) else (module RecurrenceBoxes)
    | "octagons" -> if !ordinals then (module RecurrenceOctagonsOrdinals) else (module RecurrenceOctagons)
    | "polyhedra" -> if !ordinals then (module RecurrencePolyhedra) else (module RecurrencePolyhedraOrdinals)
    | _ -> raise (Invalid_argument "Unknown Abstract Domain"))
    : SEMANTIC)
  in 
  (module S)

  
let ctl_iterator (): (module SEMANTIC)=
  let module S =
    (val (match !domain with
    | "boxes" -> if !ordinals then (module CTLBoxesOrdinals) else (module CTLBoxes)
    | "octagons" -> if !ordinals then (module CTLOctagonsOrdinals) else (module CTLOctagons)
    | "polyhedra" -> if !ordinals then (module CTLPolyhedraOrdinals) else (module CTLPolyhedra)
    | _ -> raise (Invalid_argument "Unknown Abstract Domain"))
    : SEMANTIC)
  in 
  (module S)

let termination ()  =
  if !filename = "" then raise (Invalid_argument "No Source File Specified") ;
  let sources = parseFile !filename in
  let program, _ = ItoA.prog_itoa sources in
  if not !minimal then (
    Format.fprintf !fmt "\nAbstract Syntax:\n" ;
    AbstractSyntax.prog_print !fmt program ) ;
  let open AbstractSyntax in 
  let analysis_function =
    match !domain with
    | "boxes" ->
        if !ordinals then TerminationBoxesOrdinals.analyze ~property: TerminationBoxesOrdinals.dummy_prop
        else TerminationBoxes.analyze  ~property: TerminationBoxes.dummy_prop
    | "octagons" ->
        if !ordinals then TerminationOctagonsOrdinals.analyze ~property:TerminationOctagonsOrdinals.dummy_prop
        else TerminationOctagons.analyze ~property:TerminationOctagons.dummy_prop
    | "polyhedra" ->
        if !ordinals then TerminationPolyhedraOrdinals.analyze ~property:TerminationPolyhedraOrdinals.dummy_prop
        else TerminationPolyhedra.analyze ~property:TerminationPolyhedra.dummy_prop
    | _ -> raise (Invalid_argument "Unknown Abstract Domain")
  in
  run_analysis  analysis_function program ()


let guarantee () =
  if !filename = "" then raise (Invalid_argument "No Source File Specified");
  if !property = "" then raise (Invalid_argument "No Property File Specified");
  let sources = parseFile !filename in
  let property = parseProperty !property in
  let (program, property) =
    ItoA.prog_itoa ~property:(!main,property) sources in
  let property =
    match property with
    | None -> raise (Invalid_argument "Unknown Property")
    | Some property -> property
  in
  if not !minimal then
    begin
      Format.fprintf !fmt "\nAbstract Syntax:\n";
      AbstractSyntax.prog_print !fmt program;
      Format.fprintf !fmt "\nProperty: ";
      AbstractSyntax.property_print !fmt property;
    end;
  let analysis_function  =
    match !domain with
    | "boxes" -> if !ordinals then GuaranteeBoxesOrdinals.analyze else GuaranteeBoxes.analyze
    | "octagons" -> if !ordinals then GuaranteeOctagonsOrdinals.analyze else GuaranteeOctagons.analyze
    | "polyhedra" -> if !ordinals then GuaranteePolyhedraOrdinals.analyze else GuaranteePolyhedra.analyze
    | _ -> raise (Invalid_argument "Unknown Abstract Domain")
  in run_analysis (analysis_function ~property:(Exp property)) program ()

let recurrence () =
  if !filename = "" then raise (Invalid_argument "No Source File Specified");
  if !property = "" then raise (Invalid_argument "No Property File Specified");
  let sources = parseFile !filename in
  let property = parseProperty !property in
  let (program,property) =
    ItoA.prog_itoa ~property:(!main,property) sources in
  let property =
    match property with
    | None -> raise (Invalid_argument "Unknown Property")
    | Some property -> property
  in
  if not !minimal then
    begin
      Format.fprintf !fmt "\nAbstract Syntax:\n";
      AbstractSyntax.prog_print !fmt program;
      Format.fprintf !fmt "\nProperty: ";
      AbstractSyntax.property_print !fmt property;
    end;
  let analysis_function =
    match !domain with
    | "boxes" -> if !ordinals then RecurrenceBoxesOrdinals.analyze else RecurrenceBoxes.analyze
    | "octagons" -> if !ordinals then RecurrenceOctagonsOrdinals.analyze else RecurrenceOctagons.analyze
    | "polyhedra" -> if !ordinals then RecurrencePolyhedraOrdinals.analyze else RecurrencePolyhedra.analyze
    | _ -> raise (Invalid_argument "Unknown Abstract Domain")
  in run_analysis (analysis_function ~property:(Exp property)) program ()

let ctl_ast () =
  if !filename = "" then raise (Invalid_argument "No Source File Specified");
  if !property = "" then raise (Invalid_argument "No Property Specified");
  let starttime = Sys.time () in
  let parsedPrecondition = parsePropertyString !precondition in
  let parsedProperty = parseCTLPropertyString !property in
  let (prog, property) = ItoA.ctl_prog_itoa parsedProperty !main (parseFile !filename) in
  let precondition = fst @@ AbstractSyntax.StringMap.find "" @@ ItoA.property_itoa_of_prog prog !main parsedPrecondition in
  if not !minimal then
    begin
      Format.fprintf !fmt "\nAbstract Syntax:\n";
      AbstractSyntax.prog_print !fmt prog;
      Format.fprintf !fmt "\n";
    end;
  let analyze =
    match !domain with
    | "boxes" -> if !ordinals then CTLBoxesOrdinals.analyze else CTLBoxes.analyze
    | "octagons" -> if !ordinals then CTLOctagonsOrdinals.analyze else CTLOctagons.analyze
    | "polyhedra" -> if !ordinals then CTLPolyhedraOrdinals.analyze else CTLPolyhedra.analyze
    | _ -> raise (Invalid_argument "Unknown Abstract Domain")
  in
  let result = analyze ~precondition:precondition  ~property:(Ctl property) prog "" in
  if !time then begin
    let stoptime = Sys.time () in
    Format.fprintf !fmt "\nTime: %f" (stoptime-.starttime)
  end;
  if result then 
    Format.fprintf !fmt "\nFinal Analysis Result: TRUE\n"
  else 
    Format.fprintf !fmt "\nFinal Analysis Result: UNKNOWN\n"
  ;
  result
let ctl_cfg () =
  if !filename = "" then raise (Invalid_argument "No Source File Specified");
  if !property = "" then raise (Invalid_argument "No Property Specifilet s = Lexing.dummy_posed");
  let starttime = Sys.time () in
  let (cfg, getProperty) = Tree_to_cfg.prog (File_parser.parse_file !filename) !main in
  let mainFunc = Cfg.find_func !main cfg in
  let cfg = Cfg.insert_entry_exit_label cfg mainFunc in (* add exit/entry labels to main function *)
  let cfg = if !noinline then cfg else Cfg.inline_function_calls cfg in (* inline all non recursive functions unless -noinline is used *)
  let cfg = Cfg.add_function_call_arcs cfg in (* insert function call edges for remaining function calls *)
  let ctlProperty = CTLProperty.map File_parser.parse_bool_expression @@ parseCTLPropertyString_plain !property in
  let ctlProperty = CTLProperty.map getProperty ctlProperty in
  let precondition = getProperty @@ File_parser.parse_bool_expression !precondition in
  let analyze =
    match !domain with
    | "boxes" -> if !ordinals then CFGCTLBoxesOrdinals.analyze else CFGCTLBoxes.analyze
    | "octagons" -> if !ordinals then CFGCTLOctagonsOrdinals.analyze else CFGCTLOctagons.analyze
    | "polyhedra" -> if !ordinals then CFGCTLPolyhedraOrdinals.analyze else CFGCTLPolyhedra.analyze
    | _ -> raise (Invalid_argument "Unknown Abstract Domain")
  in
  if not !minimal then
    begin
      Printf.printf "\nCFG:\n";
      Printf.printf "%a" Cfg_printer.print_cfg cfg;
      Printf.printf "\n";
    end;
  if not !minimal && !Config.dot then
    begin
      Printf.printf "CFG_DOT:\n %a" Cfg_printer.output_dot cfg;
      Printf.printf "\n";
    end;
  let mainFunc = Cfg.find_func !main cfg in
  let possibleLoopHeads = Loop_detection.possible_loop_heads cfg mainFunc in
  let domSets = Loop_detection.dominator cfg mainFunc in
  let result = analyze ~precondition:precondition cfg mainFunc possibleLoopHeads domSets ctlProperty in
  if !time then begin
    let stoptime = Sys.time () in
    Format.fprintf !fmt "\nTime: %f" (stoptime-.starttime)
  end;
  if result then 
    Format.fprintf !fmt "\nAnalysis Result: TRUE\n"
  else 
    Format.fprintf !fmt "\nAnalysis Result: UNKNOWN\n"
  ;
  result

let doit () =  
  parse_args ();
  if !Config.cda then 
    let semantic = 
    match !analysis with
    | "termination" -> termination_iterator ()
    | "guarantee"   -> guarantee_iterator ()
    | "recurrence"  -> recurrence_iterator ()
    | "ctl" 
    | "ctl-ast"  
    | "ctl-cfg" ->  ctl_iterator ()
    | _ -> raise (Invalid_argument "Unknown Analysis") 
    in
    if !filename = "" then raise (Invalid_argument "No Source File Specified");
    if !property = "" then 
      begin
      match !analysis with
       | "termination" -> ()
       | _ ->  raise (Invalid_argument "No Property File Specified")
      end;
    let sources = parseFile !filename in
    (* 
      #TODO
      let alert_prop =
        function
       | None -> raise (Invalid_argument "Unknown Property")
       | Some property -> property 
    in*)
    let program,property = match !analysis with  
                          | "termination" ->  let s = Lexing.dummy_pos in 
                                              let p =  ((IntermediateSyntax.I_universal (IntermediateSyntax.I_TRUE,(s,s))),(s,s)) in 
                                              let program , property =  ItoA.prog_itoa ~property:(!main,p) sources in
                                              program, (Semantics.Exp (Option.get property))
                                              

                          | "guarantee"  
                          | "recurrence" ->  let program,property  = ItoA.prog_itoa ~property:(!main,parseProperty !property ) sources in program ,(Semantics.Exp (Option.get property))
                          | "ctl" 
                          | "ctl-ast"  
                          | "ctl-cfg" ->  let parsedProperty = parseCTLPropertyString !property in
                                          let program, property = ItoA.ctl_prog_itoa parsedProperty !main (parseFile !filename) in
                                          program,(Semantics.Ctl property) 
    | _ -> raise (Invalid_argument "Unknown Analysis") 
    in
    if not !minimal then (
      Format.fprintf !fmt "\nAbstract Syntax:\n" ;
      AbstractSyntax.prog_print !fmt program ) ;
    let (vars,b,func)  = program  in
    let module C = (val (cda_run semantic): CDA_ITERATOR) in
    C.analyze ~property:property func vars b !main
  else
    match !analysis with
    | "termination" -> termination ()
    | "guarantee"   -> guarantee  ()
    | "recurrence" -> recurrence ()   
    | "ctl" -> ctl_ast  ()  (* default CTL analysis is CTL-AST *)
    | "ctl-ast" -> ctl_ast ()
    | "ctl-cfg" -> ctl_ast ()
    | _ -> raise (Invalid_argument "Unknown Analysis")   
let _ = doit () 
