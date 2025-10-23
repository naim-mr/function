(*
   Useful datatypes and functor instantiations.

   Copyright (C) 2011 Antoine Miné
*)

(* unique identifiers *)
(* ****************** *)

type id = Z.t

let id_of_yojson = function
  | `String s -> Z.of_string s
  | _ -> failwith "failed to deserialize a Z.t"

let yojson_of_id x = `String (Z.to_string x)
let cur_id = ref Z.zero
let pp_id = Int.pp

let new_id () =
  cur_id := Z.succ !cur_id;
  !cur_id

let reset_id () = cur_id := Z.zero
let string_of_id prefix id = prefix ^ Z.to_string id
let compare_id (x : id) (y : id) = compare x y
let dummy_id = Z.minus_one

(* maps and sets *)
(* ************* *)

module StringSet = Set.Make (struct
  type t = string

  let compare = compare
end)

module StringMap = Mapext.Make (struct
  type t = string

  let compare = compare
end)

module IdSet = Set.Make (struct
  type t = id

  let compare = compare_id
end)

module IdMap = Mapext.Make (struct
  type t = id

  let compare = compare_id
end)

(* option *)
(* ****** *)

let ( >>= ) = Option.bind
let ( >>| ) = Option.map
let ( let* ) = Option.bind

let option_or (a : 'a option) (b : 'a option) : 'a option =
  match (a, b) with
  | Some a, _ -> Some a
  | None, Some b -> Some b
  | None, None -> None

(* 3-valued logic *)
(* ************** *)

type tbool = True | False | Maybe [@@deriving yojson, show]

let tnot = function True -> False | False -> True | Maybe -> Maybe

let tor a b =
  match (a, b) with
  | True, _ | _, True -> True
  | Maybe, _ | _, Maybe -> Maybe
  | False, False -> False

let tand a b =
  match (a, b) with
  | False, _ | _, False -> False
  | Maybe, _ | _, Maybe -> Maybe
  | True, True -> True

let tbool_of_bool = function true -> True | false -> False

let string_of_tbool = function
  | True -> "true"
  | False -> "false"
  | Maybe -> "maybe"

(* infinities *)
(* ********** *)

type 'a inf =
  | Finite of 'a
  | INF
  (* +oo *)
  | MINF (* -oo *)
[@@deriving yojson, show]

(* see Intinf for operators on Int.t inf *)

(* file sets and report *)
(* ******************** *)

(* anal timeout setting *)
type anal_timeout = NO_TIMEOUT | TIMEOUT of float [@@deriving yojson, show]

(* anal mode *)
type anal_mode =
  | SUFFICIENT (* sufficient preconditions for assertion success *)
  | COUNTER (* sufficient preconditions for assertion failure *)
[@@deriving yojson, show]

(* anal params *)
type anal_params = {
  input_path : string;
  mode : anal_mode;
  expect_alarm : bool option; [@default None] (* only used in sufficient mode *)
  with_term : bool option; [@default None]
  timeout : anal_timeout option; [@default None]
  unroll : int option; [@default None]
  join : int option; [@default None]
  down : int option; [@default None]
  meet : int option; [@default None]
  colored_loop_iterator : bool option; [@default None]
  verbose_init : bool option; [@default None]
  verbose_fwd : bool option; [@default None]
  verbose_bwd : bool option; [@default None]
  verbose_term : bool option; [@default None]
  entry : string option; [@default None]
}
[@@deriving yojson, show]

(*type regression_res = {
  improv : A.point list;
  worse : A.point list;
  same : A.point list;
  incomp : A.point list;
}

type time_res = {
  old_time: float;
  new_time: float;
}

(* analysis outcome *)
type anal_outcome =
  | UNSUPPORTED_FEATURE of string
  | TIMEOUT
  | PRE of bool

(* analysis res *)
type anal_res = {
  path: string;
  correct : bool;
  outcome : anal_outcome;
  term : bool option;
  alarms: A.InvSet.t;
  reg : regression_res option;
  time: time_res option;
}*)

(* run params *)
type run_params = {
  domain : string;
  date : string;
  version : string;
  params : anal_params list;
}
[@@deriving yojson, show]

(* exceptions *)
(* ********** *)
exception UnsupportedConversion of string
exception UnsupportedFeature of string
exception Unexpected of string
exception Timeout
