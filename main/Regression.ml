open Config

let create_logfile_name () = 
  let replace = Str.regexp ("tests/[A-Za-z]+/") in
  let name = Str.replace_first (replace) (!output_dir^(!analysis)^"/") (!filename) in
  let name = name^"-domain"^(!domain)^(if !ordinals then "-ordinals"^(string_of_int !Ordinals.max) else "")^(if !refine then "-refine" else "")^".out" in
  Config.logfile := name

let json_string filename time analysis property  domain    =
   Printf.sprintf {|
  {"filename" : "%s",
   "analysis_type": "%s",
   "property": "%s",
   "result": "%s",
   "domain": "%s"
    }|} 
    filename analysis property domain  

let output_json () =   
  let replace =  Str.regexp ("tests/[A-Za-z]+/") in
  let basefile = Str.replace_first (replace) ((!output_dir)^(!analysis)^"/") (!filename) in
  let basefile = basefile^"-domain"^(!domain)^(if !ordinals then "-ordinals"^(string_of_int !Ordinals.max) else "")^(if !refine then "-refine" else "") in 
  let jsonfile = basefile^".json" in
  let output =  json_string !filename time !analysis !property (if !Config.result then "TRUE" else "UKNOWN") !domain  in
  let json : Yojson.Safe.t =  `Assoc(("Config",Yojson.Safe.from_string output)::[("tree", !tree)]) in 
  let f = Out_channel.open_bin (jsonfile) in
  Yojson.Safe.pretty_to_channel f json;
  Out_channel.close f