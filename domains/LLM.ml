(* LLM.ml — Claude API integration for LLM-assisted widening *)

open Apron

(* ------------------------------------------------------------------ *)
(* System prompt                                                       *)
(* ------------------------------------------------------------------ *)

let system_prompt = {|You are an expert in program termination analysis. You assist a static analyzer that proves termination of C-like programs by inferring piecewise-defined ranking functions.

BACKGROUND

A ranking function maps program states to a well-ordered set such that the value strictly decreases on each loop iteration. This proves the loop must terminate.

The analyzer computes ranking functions backward through the program. For loops, it uses iterative fixpoint computation with widening to ensure convergence. The ranking functions are represented as decision trees:
- Internal nodes: linear constraints of the form "$id{name} >= constant" that partition the state space
- Leaves: ordinal-valued expressions over program variables

ORDINAL VALUES

Leaf values are ordinal expressions of the form:
    (a₃)ω³ + (a₂)ω² + (a₁)ω + a₀
where each aᵢ is a linear combination of program variables with integer coefficients. You may use ordinals up to ω³ (three levels).

In the trees shown to you, ordinal leaves are displayed as e.g.:
    (2$11{x}+1)⍵² + (-$13{y}+3)⍵ + $11{x}+5
where ⍵ = ω. A leaf with no ω component is just a plain linear expression (the finite part a₀).

The variable "#" is an internal implementation detail — never reference it.

Variables are identified by a unique numeric ID and a human-readable name, written as $id{name} (e.g., $11{x}, $13{y}).

BACKWARD ANALYSIS

The analysis proceeds BACKWARD from zero. At each iteration the ranking function values can only INCREASE. Widening accelerates this ascending sequence. Your proposals must be >= the current iteration values.

YOUR ROLE

During widening, you receive:
1. A ranking function tree from the PREVIOUS iteration
2. A ranking function tree from the CURRENT iteration

Your job: propose generalized leaf expressions that extrapolate the upward trend, helping the widening converge faster.

You do NOT propose the tree structure, only the leaf values.

OUTPUT FORMAT

Respond with a JSON object:
{
  "reasoning": "brief explanation",
  "leaves": [
    {
      "partition_id": <integer>,
      "expression": [
        {"$id{name}": <coeff>, "cst": <constant>},
        {"$id{name}": <coeff>, "cst": <constant>},
        {"$id{name}": <coeff>, "cst": <constant>},
        {"$id{name}": <coeff>, "cst": <constant>}
      ]
    }
  ]
}

The "expression" field is an ARRAY of coefficient maps, ordered by ordinal power:
- Index 0 = finite part (a₀, coefficient of ω⁰)
- Index 1 = coefficient of ω¹
- Index 2 = coefficient of ω²
- Index 3 = coefficient of ω³

You may omit trailing zero levels. For a purely finite expression, a single-element array suffices:
    "expression": [{"$11{x}": 2, "cst": 1}]

For an ordinal like (3)ω + $11{x}+1:
    "expression": [{"$11{x}": 1, "cst": 1}, {"cst": 3}]

Use only variables listed in the context. All coefficients must be integers.
CRITICAL: If a leaf in the CURRENT iteration tree is "top", you MUST keep it as "top". Output the string "top" for that partition's expression instead of an array.
The analyzer will verify your proposal and may ask again if it fails.|}

(* ------------------------------------------------------------------ *)
(* Helpers                                                             *)
(* ------------------------------------------------------------------ *)

(** Parse "$11{x}" -> APRON variable named "11". *)
let apron_var_of_llm_key key =
  if String.length key > 1 && key.[0] = '$' then
    match String.index_opt key '{' with
    | Some i -> Var.of_string (String.sub key 1 (i - 1))
    | None   -> Var.of_string (String.sub key 1 (String.length key - 1))
  else
    Var.of_string key

(** Build a Linexpr1.t from a (variable_key * integer_coeff) list.
    Keys are "$id{name}" or "cst". *)
let linexpr_of_coeffs env (coeffs : (string * int) list) : Linexpr1.t =
  let linexpr = Linexpr1.make env in
  List.iter (fun (key, coef) ->
    if key = "cst" then
      Linexpr1.set_cst linexpr (Coeff.s_of_int coef)
    else begin
      let var = apron_var_of_llm_key key in
      if Environment.mem_var env var then
        Linexpr1.set_coeff linexpr var (Coeff.s_of_int coef)
    end
  ) coeffs;
  linexpr

(* ------------------------------------------------------------------ *)
(* JSON parsing (no Yojson.Util — manual pattern matching)            *)
(* ------------------------------------------------------------------ *)

(** Extract the last top-level JSON object from text that may contain
    markdown fences and reasoning before the JSON block.
    Scans backward from the last '}' to find its matching '{'. *)
(** Remove <think>...</think> blocks from deepseek-r1 responses *)
let strip_think text =
  let re_open = "<think>" and re_close = "</think>" in
  let rec strip s =
    match String.split_on_char '<' s with
    | _ ->
        (* Simple approach: find and remove all <think>...</think> *)
        let buf = Buffer.create (String.length s) in
        let i = ref 0 in
        let len = String.length s in
        while !i < len do
          match String.index_from_opt s !i '<' with
          | None ->
              Buffer.add_string buf (String.sub s !i (len - !i));
              i := len
          | Some p ->
              Buffer.add_string buf (String.sub s !i (p - !i));
              if p + 7 <= len && String.sub s p 7 = re_open then
                match String.index_from_opt s (p + 7) '<' with
                | None -> i := len
                | Some _ ->
                    (match String.index_from_opt s (p + 7) '/' with
                     | Some sl when sl > 0 && s.[sl-1] = '<' &&
                                    sl + 7 <= len && String.sub s (sl-1) 8 = re_close ->
                         i := sl + 7
                     | _ ->
                         (* Fallback: scan for </think> *)
                         let close_pos = ref len in
                         for k = p + 7 to len - 8 do
                           if !close_pos = len && String.sub s k 8 = re_close then
                             close_pos := k + 8
                         done;
                         i := !close_pos)
              else begin
                Buffer.add_char buf '<';
                i := p + 1
              end
        done;
        Buffer.contents buf
  in
  strip text

(** Clean parenthesized negative numbers: (−2) → -2 *)
let clean_parens_in_json s =
  let buf = Buffer.create (String.length s) in
  let i = ref 0 in
  let len = String.length s in
  while !i < len do
    if s.[!i] = '(' && !i + 1 < len && s.[!i + 1] = '-' then begin
      (* Look for closing paren *)
      let j = ref (!i + 2) in
      while !j < len && s.[!j] <> ')' && (s.[!j] >= '0' && s.[!j] <= '9' || s.[!j] = '.') do incr j done;
      if !j < len && s.[!j] = ')' then begin
        Buffer.add_string buf (String.sub s (!i + 1) (!j - !i - 1));
        i := !j + 1
      end else begin
        Buffer.add_char buf s.[!i];
        incr i
      end
    end else begin
      Buffer.add_char buf s.[!i];
      incr i
    end
  done;
  Buffer.contents buf

(** Find all top-level JSON objects in a text and merge their "leaves" arrays *)
let extract_json_str text =
  let text = strip_think text in
  let text = clean_parens_in_json text in
  let text = String.trim text in
  (* Collect all top-level {...} blocks *)
  let blocks = ref [] in
  let len = String.length text in
  let i = ref 0 in
  while !i < len do
    if text.[!i] = '{' then begin
      let depth = ref 1 in
      let j = ref (!i + 1) in
      while !j < len && !depth > 0 do
        if text.[!j] = '{' then incr depth
        else if text.[!j] = '}' then decr depth;
        incr j
      done;
      let block = String.sub text !i (!j - !i) in
      blocks := block :: !blocks;
      i := !j
    end else
      incr i
  done;
  let blocks = List.rev !blocks in
  match blocks with
  | [] -> text
  | [single] -> single
  | _ ->
      (* Multiple JSON blocks: merge all "leaves" into one object *)
      let all_leaves = List.filter_map (fun b ->
        try
          match Yojson.Safe.from_string b with
          | `Assoc fields ->
              (match List.assoc_opt "leaves" fields with
               | Some (`List l) -> Some l
               | _ -> None)
          | _ -> None
        with _ -> None
      ) blocks in
      let merged = `Assoc [
        ("reasoning", `String "merged from multiple blocks");
        ("leaves", `List (List.concat all_leaves))
      ] in
      Yojson.Safe.to_string merged

(** Extract the integer value from a Yojson scalar. *)
let int_of_json = function
  | `Int i    -> i
  | `Float f  -> int_of_float f
  | `Intlit s -> int_of_string s
  | other     ->
      failwith ("Expected integer, got: " ^ Yojson.Safe.to_string other)

(** Parse a single coefficient map { "$id{name}": coeff, "cst": val } *)
let parse_coeff_map = function
  | `Assoc expr_fields ->
      List.map (fun (k, v) -> (k, int_of_json v)) expr_fields
  | other -> failwith ("Expected coefficient map, got: " ^ Yojson.Safe.to_string other)

(** Result type for a parsed leaf expression *)
type parsed_expr =
  | Top_expr
  | Bot_expr
  | Ordinal_expr of (string * int) list list
    (* list of coefficient maps, index 0 = finite, 1 = ω, 2 = ω², 3 = ω³ *)

(** Parse the LLM JSON response into (partition_id, parsed_expr) list. *)
let parse_llm_json text =
  try
    let json = Yojson.Safe.from_string (extract_json_str text) in
    let leaves =
      match json with
      | `Assoc fields ->
          (match List.assoc_opt "leaves" fields with
           | Some (`List l) -> l
           | _ -> failwith "No 'leaves' array in response")
      | _ -> failwith "Response is not a JSON object"
    in
    let parsed = List.map (fun leaf ->
      match leaf with
      | `Assoc fields ->
          let partition_id =
            match List.assoc_opt "partition_id" fields with
            | Some v -> int_of_json v
            | None   -> failwith "Missing 'partition_id'"
          in
          let expr =
            match List.assoc_opt "expression" fields with
            | Some (`String s) when String.lowercase_ascii s = "top" ->
                Top_expr
            | Some (`String s) when String.lowercase_ascii s = "bottom"
                                  || String.lowercase_ascii s = "bot" ->
                Bot_expr
            (* New format: array of coefficient maps [finite, ω, ω², ω³] *)
            | Some (`List components) ->
                Ordinal_expr (List.map parse_coeff_map components)
            (* Old format: single coefficient map (treated as finite only) *)
            | Some (`Assoc _ as obj) ->
                Ordinal_expr [parse_coeff_map obj]
            | _ -> failwith "Missing or invalid 'expression'"
          in
          (partition_id, expr)
      | _ -> failwith "Leaf is not a JSON object"
    ) leaves in
    Ok parsed
  with e -> Error (Printexc.to_string e)

(** Extract the plain-text content from a Claude API response. *)
let extract_text_from_api_response api_json_str =
  try
    let json = Yojson.Safe.from_string api_json_str in
    match json with
    | `Assoc fields ->
        (* Check for API error first *)
        (match List.assoc_opt "error" fields with
         | Some (`Assoc err) ->
             let msg = match List.assoc_opt "message" err with
               | Some (`String m) -> m
               | _ -> "unknown API error"
             in
             Error (Printf.sprintf "API error: %s" msg)
         | _ ->
             let blocks = match List.assoc_opt "content" fields with
               | Some (`List l) -> l
               | _ -> []
             in
             let texts = List.filter_map (fun block ->
               match block with
               | `Assoc bf ->
                   (match List.assoc_opt "type" bf, List.assoc_opt "text" bf with
                    | Some (`String "text"), Some (`String t) -> Some t
                    | _ -> None)
               | _ -> None
             ) blocks in
             let result = String.concat "" texts in
             if result = "" then Error "Empty response from API"
             else Ok result)
    | _ -> Error "Response is not a JSON object"
  with e -> Error (Printexc.to_string e)

(* ------------------------------------------------------------------ *)
(* Logging                                                             *)
(* ------------------------------------------------------------------ *)

let log_interaction ~user_prompt ~llm_text ~result_summary =
  let path = !Config.llm_log in
  if path = "" then ()
  else
    try
      let oc  = open_out_gen [Open_append; Open_creat; Open_text] 0o644 path in
      let sep = String.make 72 '-' in
      let tm  = Unix.localtime (Unix.gettimeofday ()) in
      Printf.fprintf oc "\n%s\n" sep;
      Printf.fprintf oc "[%04d-%02d-%02d %02d:%02d:%02d] LLM WIDENING CALL\n"
        (tm.Unix.tm_year + 1900) (tm.Unix.tm_mon + 1) tm.Unix.tm_mday
        tm.Unix.tm_hour tm.Unix.tm_min tm.Unix.tm_sec;
      Printf.fprintf oc "%s\n" sep;
      Printf.fprintf oc "## USER PROMPT\n%s\n" user_prompt;
      Printf.fprintf oc "\n## LLM RESPONSE\n%s\n" llm_text;
      Printf.fprintf oc "\n## RESULT\n%s\n" result_summary;
      close_out oc
    with _ -> ()

(* ------------------------------------------------------------------ *)
(* Backend: Anthropic                                                  *)
(* ------------------------------------------------------------------ *)

let build_anthropic_request user_prompt =
  Yojson.Safe.to_string (`Assoc [
    ("model",      `String "claude-opus-4-6");
    ("max_tokens", `Int 2048);
    ("system",     `String system_prompt);
    ("messages",   `List [
      `Assoc [("role", `String "user"); ("content", `String user_prompt)]
    ])
  ])

let curl_anthropic api_key tmp_in tmp_out =
  Printf.sprintf
    "curl -s --max-time 300 -X POST https://api.anthropic.com/v1/messages \
     -H 'x-api-key: %s' \
     -H 'anthropic-version: 2023-06-01' \
     -H 'content-type: application/json' \
     -d @%s -o %s 2>/dev/null"
    api_key tmp_in tmp_out

(** Extract text from Anthropic response:
    { "content": [{ "type": "text", "text": "..." }] } *)
let extract_anthropic api_json =
  extract_text_from_api_response api_json

(* ------------------------------------------------------------------ *)
(* Backend: Gemini                                                     *)
(* ------------------------------------------------------------------ *)

let build_gemini_request user_prompt =
  Yojson.Safe.to_string (`Assoc [
    ("system_instruction", `Assoc [
      ("parts", `List [`Assoc [("text", `String system_prompt)]])
    ]);
    ("contents", `List [
      `Assoc [
        ("role",  `String "user");
        ("parts", `List [`Assoc [("text", `String user_prompt)]])
      ]
    ])
  ])

let curl_gemini api_key tmp_in tmp_out =
  Printf.sprintf
    "curl -s --max-time 300 -X POST \
     'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=%s' \
     -H 'content-type: application/json' \
     -d @%s -o %s 2>/dev/null"
    api_key tmp_in tmp_out

(** Extract text from Gemini response:
    { "candidates": [{ "content": { "parts": [{ "text": "..." }] } }] } *)
let extract_gemini api_json =
  try
    let json = Yojson.Safe.from_string api_json in
    let candidates =
      match json with
      | `Assoc fields ->
          (match List.assoc_opt "candidates" fields with
           | Some (`List l) -> l
           | _ -> failwith "No 'candidates' in Gemini response")
      | _ -> failwith "Gemini response is not an object"
    in
    let first = match candidates with c :: _ -> c | [] -> failwith "Empty candidates" in
    let parts =
      match first with
      | `Assoc fields ->
          (match List.assoc_opt "content" fields with
           | Some (`Assoc cf) ->
               (match List.assoc_opt "parts" cf with
                | Some (`List p) -> p
                | _ -> failwith "No 'parts' in content")
           | _ -> failwith "No 'content' in candidate")
      | _ -> failwith "Candidate is not an object"
    in
    let texts = List.filter_map (fun p ->
      match p with
      | `Assoc pf -> (match List.assoc_opt "text" pf with Some (`String t) -> Some t | _ -> None)
      | _ -> None
    ) parts in
    Ok (String.concat "" texts)
  with e -> Error (Printexc.to_string e)

(* ------------------------------------------------------------------ *)
(* Backend: Ollama (local)                                            *)
(* ------------------------------------------------------------------ *)

(* Model and host can be overridden via OLLAMA_MODEL / OLLAMA_HOST env vars *)
let ollama_model () =
  try Sys.getenv "OLLAMA_MODEL" with Not_found -> "qwen3:1.7b"

let ollama_host () =
  try Sys.getenv "OLLAMA_HOST" with Not_found -> "http://localhost:11434"

let build_ollama_request user_prompt =
  (* OpenAI-compatible /v1/chat/completions endpoint *)
  Yojson.Safe.to_string (`Assoc [
    ("model",    `String (ollama_model ()));
    ("messages", `List [
      `Assoc [("role", `String "system"); ("content", `String system_prompt)];
      `Assoc [("role", `String "user");   ("content", `String user_prompt)]
    ]);
    ("stream",   `Bool false)
  ])

let curl_ollama _unused tmp_in tmp_out =
  Printf.sprintf
    "curl -s --max-time 300 -X POST %s/v1/chat/completions \
     -H 'content-type: application/json' \
     -d @%s -o %s 2>/dev/null"
    (ollama_host ()) tmp_in tmp_out

(** Extract text from OpenAI-compatible response:
    { "choices": [{ "message": { "content": "..." } }] } *)
let extract_ollama api_json =
  try
    let json = Yojson.Safe.from_string api_json in
    let choices =
      match json with
      | `Assoc fields ->
          (match List.assoc_opt "choices" fields with
           | Some (`List l) -> l
           | _ -> failwith "No 'choices' in response")
      | _ -> failwith "Response is not an object"
    in
    let first = match choices with c :: _ -> c | [] -> failwith "Empty choices" in
    let content =
      match first with
      | `Assoc fields ->
          (match List.assoc_opt "message" fields with
           | Some (`Assoc mf) ->
               (match List.assoc_opt "content" mf with
                | Some (`String t) -> t
                | _ -> failwith "No 'content' in message")
           | _ -> failwith "No 'message' in choice")
      | _ -> failwith "Choice is not an object"
    in
    Ok content
  with e -> Error (Printexc.to_string e)

(* ------------------------------------------------------------------ *)
(* Backend: Proton (fine-tuned Llama 3.2 1B via Ollama /api/generate) *)
(* ------------------------------------------------------------------ *)

(** The prompt Proton was fine-tuned on (lib_prompt_co_inv_assigns_variant_2).
    We reproduce it verbatim so that the GGUF model behaves as trained. *)
let proton_prompt =
  "In order to prove the termination of a loop, we use the notion of loop variant. " ^
  "A loop variant is not a property but a value. It is an expression that involves the variables " ^
  "modified by the loop and that provides an upper bound to the number of iterations that remains " ^
  "to be executed by the loop before any iteration. Thus, this expression is greater or equals to 0, " ^
  "and strictly decreases at each loop iteration. " ^
  "You are a software engineer working on a safety-critical system. You are tasked with verifying the correctness of a " ^
  "loop in a given C program using Frama-C. " ^
  "I shall provide you with three things - 1. a C program delimited using the tags <sourcecode> and <\\sourcecode>, " ^
  "2. the source code of a loop from the provided C program and given as " ^
  "delimited by the tags <loopcode> and <\\loopcode> and 3. a unique loop identifer (integer) for the loop delimited by <loopid> and <\\loopid>. " ^
  "You are to generate a Frama-C ACSL (ANSI/ISO C Specification Language) loop variant for the given loop. " ^
  "In addition generate an ACSL inductive loop invariant that helps Frama-C to prove the termination of the loop using the ACSL variant " ^
  "and the ACSL inductive loop invariant, where the ACSL inductive loop invariant is true" ^
  "(i) before the loop execution, " ^
  "(ii) given that the inductive loop invariant holds at the head of the loop, " ^
  "it also holds at the end of one more iteration of the loop. " ^
  "Also generate an ACSL assigns clause that specifies the variables modified by the loop. " ^
  "Return only the loop id, ACSL loop variant, ACSL inductive loop invariant and assigns clause using the tags " ^
  "<loopid> id </loopid> <variant> generated variant </variant> <invariant> generated invariant </invariant> <assigns> generated assigns </assigns> " ^
  "and do not print anything else. " ^
  "If the invariant is a conjunction, use the string 'AND' to separate the conjuncts. " ^
  "Rules:" ^
  "**Do not use variables or functions that are not declared in the program.**" ^
  "**Do not make any assumptions about functions whose definitions are not given.**" ^
  "**All undefined variables contain garbage values. Do not use variables that have garbage values.**" ^
  "**Do not use keywords that are not supported in ACSL annotations for loops.**" ^
  "**Variables that are not explicitly initialized, could have garbage values. Do not make any assumptions about such values.**" ^
  "**Do not use the \\at(x, Pre) notation for any variable x.**" ^
  "**Do not use non-deterministic function calls.**" ^
  "**Do not generate &gt, &lt for greater than and less than symbols. Use the symbols > and < directly.**"

(** Build the full text prompt for the Proton model, matching its training format. *)
let build_proton_prompt ~source_code ~loop_code ~loop_id =
  Printf.sprintf "%s <sourcecode> %s </sourcecode> <loopcode> %s </loopcode> <loopid> %s </loopid>"
    proton_prompt source_code loop_code loop_id

(** Build Ollama /api/generate request (raw completion, not chat). *)
let build_proton_request prompt_text =
  Yojson.Safe.to_string (`Assoc [
    ("model",   `String "proton");
    ("prompt",  `String prompt_text);
    ("stream",  `Bool false);
    ("options", `Assoc [
      ("num_predict", `Int 128);
      ("num_ctx",     `Int 2048)
    ])
  ])

let curl_proton tmp_in tmp_out =
  Printf.sprintf
    "curl -s --max-time 60 -X POST %s/api/generate \
     -H 'content-type: application/json' \
     -d @%s -o %s 2>/dev/null"
    (ollama_host ()) tmp_in tmp_out

(** Extract text from Ollama /api/generate response: { "response": "..." } *)
let extract_proton_response api_json =
  try
    let json = Yojson.Safe.from_string api_json in
    match json with
    | `Assoc fields ->
        (match List.assoc_opt "response" fields with
         | Some (`String t) when t <> "" -> Ok t
         | _ -> Error "No 'response' in Ollama generate response")
    | _ -> Error "Response is not a JSON object"
  with e -> Error (Printexc.to_string e)

(** Extract the content between <tag> ... </tag> in a text string. *)
let extract_xml_tag tag text =
  let open_tag = "<" ^ tag ^ ">" in
  let close_tag = "</" ^ tag ^ ">" in
  let len = String.length text in
  let olen = String.length open_tag in
  let clen = String.length close_tag in
  let rec find_open i =
    if i + olen > len then None
    else if String.sub text i olen = open_tag then
      find_close (i + olen) (i + olen)
    else find_open (i + 1)
  and find_close start j =
    if j + clen > len then None
    else if String.sub text j clen = close_tag then
      Some (String.trim (String.sub text start (j - start)))
    else find_close start (j + 1)
  in
  find_open 0

(* --- Simple linear expression parser for ACSL variant strings --- *)
(* Handles: "n - i", "30 - i", "2*x + 3*y - 1", etc.              *)

type expr_token = TkInt of int | TkVar of string | TkPlus | TkMinus | TkStar | TkEnd

let tokenize_expr s =
  let len = String.length s in
  let result = ref [] in
  let i = ref 0 in
  while !i < len do
    let c = s.[!i] in
    if c = ' ' || c = '\t' || c = '\n' || c = '\r' then incr i
    else if c = '+' then (result := TkPlus :: !result; incr i)
    else if c = '-' then (result := TkMinus :: !result; incr i)
    else if c = '*' then (result := TkStar :: !result; incr i)
    else if c = '(' || c = ')' || c = ';' then incr i  (* skip parens/semicolons *)
    else if c >= '0' && c <= '9' then begin
      let j = ref !i in
      while !j < len && s.[!j] >= '0' && s.[!j] <= '9' do incr j done;
      result := TkInt (int_of_string (String.sub s !i (!j - !i))) :: !result;
      i := !j
    end else if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c = '_' then begin
      let j = ref !i in
      while !j < len &&
            (let ch = s.[!j] in
             (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')
             || (ch >= '0' && ch <= '9') || ch = '_') do
        incr j
      done;
      result := TkVar (String.sub s !i (!j - !i)) :: !result;
      i := !j
    end else incr i
  done;
  List.rev (TkEnd :: !result)

(** Parse a token list into [(key, coeff)] where key is a variable name or "cst". *)
let parse_linear_coeffs tokens =
  let toks = Array.of_list tokens in
  let len = Array.length toks in
  let pos = ref 0 in
  let peek () = if !pos < len then toks.(!pos) else TkEnd in
  let advance () = if !pos < len then incr pos in
  let coeffs = Hashtbl.create 8 in
  let add key v =
    let old = try Hashtbl.find coeffs key with Not_found -> 0 in
    Hashtbl.replace coeffs key (old + v)
  in
  let sign = ref 1 in
  while peek () <> TkEnd do
    (match peek () with
     | TkPlus  -> sign := 1; advance ()
     | TkMinus -> sign := -1; advance ()
     | TkInt n ->
         advance ();
         (match peek () with
          | TkStar ->
              advance ();
              (match peek () with
               | TkVar v -> add v (!sign * n); advance ()
               | _ -> add "cst" (!sign * n))
          | _ -> add "cst" (!sign * n));
         sign := 1
     | TkVar v ->
         advance ();
         (match peek () with
          | TkStar ->
              advance ();
              (match peek () with
               | TkInt n -> add v (!sign * n); advance ()
               | _ -> add v !sign)
          | _ -> add v !sign);
         sign := 1
     | _ -> advance ())
  done;
  Hashtbl.fold (fun k v acc -> (k, v) :: acc) coeffs []

(** Convert parsed linear coefficients (C var names) to LLM coefficient format ($id{name} keys).
    [var_map] is a list of [(c_name, dollar_key)] e.g. [("x", "$11{x}"); ("i", "$13{i}")]. *)
let variant_coeffs_to_llm_format coeffs var_map =
  List.filter_map (fun (name, coeff) ->
    if name = "cst" then Some ("cst", coeff)
    else match List.assoc_opt name var_map with
      | Some key -> Some (key, coeff)
      | None -> None  (* unknown variable, skip *)
  ) coeffs

(* ------------------------------------------------------------------ *)
(* Generic curl call + parse                                           *)
(* ------------------------------------------------------------------ *)

let do_curl_call ~body_str ~curl_cmd ~extract_text ~user_prompt =
  let tmp_in  = Filename.temp_file "llm_req"  ".json" in
  let tmp_out = Filename.temp_file "llm_resp" ".json" in
  let result =
    (try
      let oc = open_out tmp_in in
      output_string oc body_str;
      close_out oc;
      let ret = Sys.command (curl_cmd tmp_in tmp_out) in
      if ret <> 0 then begin
        let msg = Printf.sprintf "curl exited with code %d" ret in
        log_interaction ~user_prompt ~llm_text:"(no response)" ~result_summary:("ERROR: " ^ msg);
        Error msg
      end else begin
        let ic = open_in tmp_out in
        let n  = in_channel_length ic in
        let s  = Bytes.create n in
        really_input ic s 0 n;
        close_in ic;
        match extract_text (Bytes.to_string s) with
        | Error e ->
            let raw = Bytes.to_string s in
            log_interaction ~user_prompt ~llm_text:raw ~result_summary:("API PARSE ERROR: " ^ e);
            Error ("API parse error: " ^ e)
        | Ok text ->
            let parsed = parse_llm_json text in
            let summary = match parsed with
              | Ok leaves -> Printf.sprintf "OK — %d partitions" (List.length leaves)
              | Error e   -> "JSON PARSE ERROR: " ^ e
            in
            log_interaction ~user_prompt ~llm_text:text ~result_summary:summary;
            parsed
      end
    with e ->
      let msg = Printexc.to_string e in
      log_interaction ~user_prompt ~llm_text:"(exception)" ~result_summary:("EXCEPTION: " ^ msg);
      Error msg)
  in
  (try Sys.remove tmp_in  with _ -> ());
  (try Sys.remove tmp_out with _ -> ());
  result

(* ------------------------------------------------------------------ *)
(* Public entry points                                                 *)
(* ------------------------------------------------------------------ *)

(** Call the configured LLM backend with [user_prompt].
    Backend is selected by [Config.llm_backend].
    Returns [Ok proposals] on success, [Error reason] otherwise. *)
let query ~user_prompt =
  match !Config.llm_backend with
  | "anthropic" ->
      let api_key = try Sys.getenv "ANTHROPIC_API_KEY" with Not_found -> "" in
      if api_key = "" then Error "ANTHROPIC_API_KEY not set"
      else
        do_curl_call
          ~body_str:(build_anthropic_request user_prompt)
          ~curl_cmd:(curl_anthropic api_key)
          ~extract_text:extract_anthropic
          ~user_prompt
  | "gemini" ->
      let api_key = try Sys.getenv "GEMINI_API_KEY" with Not_found -> "" in
      if api_key = "" then Error "GEMINI_API_KEY not set"
      else
        do_curl_call
          ~body_str:(build_gemini_request user_prompt)
          ~curl_cmd:(curl_gemini api_key)
          ~extract_text:extract_gemini
          ~user_prompt
  | _ (* "ollama" *) ->
      do_curl_call
        ~body_str:(build_ollama_request user_prompt)
        ~curl_cmd:(curl_ollama "")
        ~extract_text:extract_ollama
        ~user_prompt

(** Cache: (source_code, loop_code, loop_id) -> variant result.
    Proton is called at most once per loop across all widening iterations. *)
let proton_cache : (string * string * string, (string, string) result) Hashtbl.t =
  Hashtbl.create 4

(** Query Proton for a raw variant string (step 1 of the pipeline).
    Returns [Ok variant_string] or [Error reason]. *)
let query_proton_raw ~source_code ~loop_code ~loop_id =
  let key = (source_code, loop_code, loop_id) in
  match Hashtbl.find_opt proton_cache key with
  | Some cached ->
      Format.fprintf !Config.fmt "[Proton] using cached variant\n%!";
      cached
  | None ->
  let prompt = build_proton_prompt ~source_code ~loop_code ~loop_id in
  let body_str = build_proton_request prompt in
  let tmp_in  = Filename.temp_file "proton_req"  ".json" in
  let tmp_out = Filename.temp_file "proton_resp" ".json" in
  let result =
    try
      let oc = open_out tmp_in in
      output_string oc body_str;
      close_out oc;
      let ret = Sys.command (curl_proton tmp_in tmp_out) in
      if ret <> 0 then begin
        let msg = Printf.sprintf "curl exited with code %d" ret in
        log_interaction ~user_prompt:prompt ~llm_text:"(no response)"
          ~result_summary:("PROTON RAW ERROR: " ^ msg);
        Error msg
      end else begin
        let ic = open_in tmp_out in
        let n  = in_channel_length ic in
        let s  = Bytes.create n in
        really_input ic s 0 n;
        close_in ic;
        let raw = Bytes.to_string s in
        match extract_proton_response raw with
        | Error e ->
            log_interaction ~user_prompt:prompt ~llm_text:raw
              ~result_summary:("PROTON RAW PARSE ERROR: " ^ e);
            Error e
        | Ok text ->
            let variant = extract_xml_tag "variant" text in
            let invariant = extract_xml_tag "invariant" text in
            let summary = Printf.sprintf "PROTON RAW: variant=%s invariant=%s"
              (Option.value variant ~default:"(none)")
              (Option.value invariant ~default:"(none)") in
            log_interaction ~user_prompt:prompt ~llm_text:text ~result_summary:summary;
            match variant with
            | Some v -> Ok v
            | None -> Error ("No <variant> tag in response: " ^ text)
      end
    with e -> Error (Printexc.to_string e)
  in
  (try Sys.remove tmp_in  with _ -> ());
  (try Sys.remove tmp_out with _ -> ());
  Hashtbl.replace proton_cache key result;
  result

(** Query the Proton model and parse its variant into a ranking function expression.
    Uses the cache from [query_proton_raw] — Proton is called at most once per loop.
    [var_map] is a list of [(c_name, dollar_key)] e.g. [("i", "$13{i}")]. *)
let query_proton ~source_code ~loop_code ~loop_id ~var_map =
  match query_proton_raw ~source_code ~loop_code ~loop_id with
  | Error e -> Error e
  | Ok variant_str ->
      let tokens = tokenize_expr variant_str in
      let coeffs = parse_linear_coeffs tokens in
      let llm_coeffs = variant_coeffs_to_llm_format coeffs var_map in
      if llm_coeffs = [] then
        Error ("Could not parse variant: " ^ variant_str)
      else
        Ok (Ordinal_expr [llm_coeffs])

(** Pipeline: Proton → hint → Ollama generaliste.
    1. Ask Proton for a variant from the source code
    2. Inject that variant as a hint into the widening prompt
    3. Send the enriched prompt to Ollama for per-partition JSON proposals *)
let query_with_proton_hint ~source_code ~loop_code ~loop_id ~user_prompt =
  (* Step 1: get Proton's variant hint *)
  let proton_hint =
    match query_proton_raw ~source_code ~loop_code ~loop_id with
    | Ok variant ->
        Format.fprintf !Config.fmt "[Proton→Ollama] Proton suggests variant: %s\n%!" variant;
        Printf.sprintf
          "\n\nHINT FROM SPECIALIZED MODEL:\n\
           A fine-tuned termination model suggests that the ranking function for this loop is: %s\n\
           Use this as guidance when proposing leaf expressions. \
           The hint may not be exact — adapt it to each partition's constraints.\n"
          variant
    | Error e ->
        Format.fprintf !Config.fmt "[Proton→Ollama] Proton failed: %s, continuing without hint\n%!" e;
        ""
  in
  (* Step 2: enrich the user prompt and send to Ollama *)
  let enriched_prompt = user_prompt ^ proton_hint in
  do_curl_call
    ~body_str:(build_ollama_request enriched_prompt)
    ~curl_cmd:(curl_ollama "")
    ~extract_text:extract_ollama
    ~user_prompt:enriched_prompt
