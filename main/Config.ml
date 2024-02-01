let joinbwd = ref 2
let joinfwd = ref 2
let learn = ref false (* conflict-driven conditional termination *)
let meetbwd = ref 2
let minimal = ref false
let refine = ref false
let retrybwd = ref 5
let analysis = ref "termination"
let domain = ref "boxes"
let filename = ref ""
let fmt = ref Format.std_formatter
let main = ref "main"
let minimal = ref false
let compress = ref true (* false *)
let ordinals = ref false
let cda = ref false
let cdamax = ref 0
let property = ref ""
let precondition = ref "true"
let time = ref false
let noinline = ref false
let size = ref 2 (* conflict-driven conditional termination *)
let start = ref 0.0
let stop = ref 0.0
let timebwd = ref false
let timefwd = ref false
let fmt = ref Format.std_formatter
let timeout = ref 300.0
let ctl_existential_equivalence = ref false 
let tracefwd = ref false
let tracebwd = ref false
let dot = ref false (* output trees in graphviz dot format *)
let abort = ref false
exception Abort
exception Timeout

(* 
type config = {
  analysis: analysis_type;
  domain : domain ; 
  filename: string;
  entry_point: string;
  minimal: bool;
  property: string option;
  precondition: string option;
  time: bool;
  noinline: bool;
  abort: bool;
  refine: bool;
  cda: bool;
  cdamax: int option;
  retrybwd: int option;
  ordinals: bool;
  ordmax: int option;
  ctl_existential_equivalence:bool;
  joinbwd: int;
  joinfwd: int;
  meetbwd: int;
  learn: bool;
  mutable start: float;
  mutable stop: float;
  timebwd: bool;
  timefwd: bool;
  timeout: float;
  tracefwd:bool;
  tracebwd:bool;
  dot: bool;
}
and 
domain = Boxes | Poly | Octa
and 
analysis_type = Termination | Guarantee | Recurrence | CTL of ctl_type
and 
ctl_type = AST | CFG | DEFAUL

let config    = ref {
  analysis      = Termination;
  domain        = Boxes ; 
  filename      = "";
  entry_point   = "main";
  minimal       = false;
  property      = None;
  precondition  = None;
  time          = false;
  noinline      = false;
  abort         = false;
  refine        = false;
  cda           = false;
  cdamax        = None;
  retrybwd      = Some(2);
  ordinals      = false;
  ordmax        = None;
  ctl_existential_equivalence = false;
  joinbwd       = 2;
  joinfwd       = 2; 
  meetbwd       = 0;
  learn         = false;
  start         = 0.0;
  stop          = 0.0;
  timebwd       = false;
  timefwd       = false;
  timeout       = 300.0;
  tracefwd      = false;
  tracebwd      = false;
  dot      = false;  
} 


let parse_args () =
  let parse_domain d  = match d with
  | "boxes" -> Boxes
  | "octagons" -> Octa
  |  "polyhedra" -> Poly
  |   _ -> failwith "Unknow domain %s"  d
  in
  let rec doit args config=
    match args with
    (* General arguments -----------------------------------------------------*)
    | "-domain"::x::r -> (* abstract domain: boxes|octagons|polyhedra *)
      doit r  {config with domain = parse_domain x}
    | "-timeout"::x::r -> (* analysis timeout *)
      doit r  {config with timeout = float_of_string x}
    | "-joinfwd"::x::r -> (* widening delay in forward analysis *)
      doit r  {config with joinfwd = int_of_string x}
    | "-joinbwd"::x::r -> (* widening delay in backward analysis *)
      doit r  {config with joinbwd = int_of_string x}
    | "-main"::x::r -> (* analyzer entry point *) 
      doit r  {config with entry_point = x}
    | "-meetbwd"::x::r -> (* dual widening delay in backward analysis *)
      doit r  {config with meetbwd = int_of_string x}
    | "-minimal"::r -> (* analysis result only *)
      doit r  {config with minimal = true}
    | "-ordinals"::x::r -> (* ordinal-valued ranking functions *)
      doit r  {config with ordinals = true; ordmax = Some (int_of_string x) }
    | "-refine"::r -> (* refine in backward analysis *)
      doit r  {config with refine = true }
    | "-retrybwd"::x::r ->
      doit r  {config with retrybwd = Some (int_of_string x) }
    | "-tracefwd"::r -> (* forward analysis trace *)
      doit r  {config with tracefwd = true }
    | "-tracebwd"::r -> (* backward analysis trace *)
      (* Iterator.tracebwd := true;
      DecisionTree.tracebwd := true;
      CFGInterpreter.trace := true;
      CFGInterpreter.trace_states := true; *)
      doit r  {config with tracebwd = true }
    (* Termination arguments -------------------------------------------------*)
    | "-termination"::r -> (* guarantee analysis *)
      doit r  {config with analysis = Termination }
    (* Recurrence / Guarantee arguments --------------------------------------*)
    | "-guarantee"::x::r -> (* guarantee analysis *)
      doit r  {config with analysis = Termination; property = Some x }
      
    | "-recurrence"::x::r -> (* recurrence analysis *)
      doit r  {config with analysis = Termination; property = Some x }
    | "-time"::r -> (* track analysis time *)
      doit r  {config with time = true }
    | "-timefwd"::r -> (* track forward analysis time *)
      doit r  {config with timefwd = true }
    | "-timebwd"::r -> (* track backward analysis time *)
      doit r  {config with timebwd = true }
    (* CTL arguments ---------------------------------------------------------*)
    | "-ctl"::x::r -> (* CTL analysis *)
      doit r  {config with analysis = CTL(DEFAULT); property = Some x}
    | "-ctl-ast"::x::r -> (* CTL analysis *)
      doit r  {config with analysis = CTL(AST); property = Some x}
    | "-ctl-cfg"::x::r -> (* CTL analysis *)
      doit r  {config with analysis = CTL(CFG); property = Some x}
    | "-dot"::r -> (* print CFG and decision trees in 'dot' format *)
      doit r  {config with dot = true }
    | "-precondition"::c::r -> (* optional precondition that holds 
                                  at the start of the program, default = true *)
      doit r  {config with precondition = Some c}
    | "-ctl_existential_equivalence"::r -> (* use CTL equivalence relations to 
                                              convert existential to universal CTL properties *)
      doit r  {config with ctl_existential_equivalence = true}
    | "-noinline"::r -> (* don't inline function calls, only for CFG based analysis *)
      doit r  {config with noinline = true}
    | x::r -> doit r  {config with filename=x}
    | [] -> config
  in
  doit (List.tl (Array.to_list Sys.argv)) !config
 *)
