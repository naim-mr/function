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
let tree: Yojson.Safe.t ref  = ref `Null
let dot = ref false (* output trees in graphviz dot format *)
let abort = ref false
let json_output = ref false
let output_dir = ref "logs/"
let exectime = ref "0"
let ctltype = ref ""
let logfile = ref ""

let output_std = ref false
let f_log = ref Out_channel.stdout
let tree: Yojson.Safe.t ref  = ref `Null

exception Abort
exception Timeout

