open Config

let create_logfile_name () = 
  let replace = Str.regexp ("tests/[A-Za-z]+/") in
  let name = Str.replace_first (replace) (!output_dir^(!analysis)^"/") (!filename) in
  let name = name^"-domain"^(!domain)^(if !ordinals then "-ordinals"^(string_of_int !Ordinals.max) else "")^(if !refine then "-refine" else "")^(if !vulnerability then "-vulnerability" else "" )^".out" in
  Config.logfile := name
 
let json_string filename time analysis property  result domain  time  =
   Printf.sprintf {|
  {"filename" : "%s",
   "analysis_type": "%s",
   "property": "%s",
   "result": "%s",
   "domain": "%s",
   "time": %s
    }|} 
    filename analysis property result  domain time

let output_json () =   
  let replace =  Str.regexp ("tests/[A-Za-z]+/") in
  let basefile = Str.replace_first (replace) ((!output_dir)^(!analysis)^"/") (!filename) in
  let basefile = basefile^"-domain"^(!domain)^(if !ordinals then "-ordinals"^(string_of_int !Ordinals.max) else "")^(if !refine then "-refine" else "") in 
  let jsonfile = basefile^".json" in
  let output =  json_string !filename time !analysis !property (if !Config.result then "TRUE" else "UKNOWN") !domain  !exectime in
  let json : Yojson.Safe.t =  `Assoc(("Config",Yojson.Safe.from_string output)::("tree", !tree)::[("vulnerability", !vuln_res)]) in 
  let f = open_out_bin (jsonfile) in
  Yojson.Safe.pretty_to_channel f json;
  close_out f