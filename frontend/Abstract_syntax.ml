(*
   Abstract sytax tree output by the parser.

   Copyright (C) 2011 Antoine Miné
*)

open Lexing

(************************************************************************)
(* TYPES *)
(************************************************************************)

(* position in the source file *)
type position = Lexing.position

let yojson_of_position p =
  `Assoc
    [
      ("pos_fname", `String p.pos_fname);
      ("pos_lnum", `Int p.pos_lnum);
      ("pos_bol", `Int p.pos_bol);
      ("pos_cnum", `Int p.pos_cnum);
    ]

let position_of_yojson = function
  | `Assoc
      [
        ("pos_fname", `String pos_fname);
        ("pos_lnum", `Int pos_lnum);
        ("pos_bol", `Int pos_bol);
        ("pos_cnum", `Int pos_cnum);
      ] ->
      { pos_fname; pos_lnum; pos_bol; pos_cnum }
  | _ -> failwith "failed to deserialize `position`"

let pp_position fmt pos =
  Format.fprintf fmt
    "{\n\
    \    pos_fname: %s\n\
    \    pos_lnum: %d\n\
    \    pos_bol: %d\n\
    \    pos_cnum: %d\n\
    \  }"
    pos.pos_fname pos.pos_lnum pos.pos_bol pos.pos_cnum

type extent = position * position [@@deriving yojson, show] (* start/end *)

let position_tostring p =
  Printf.sprintf "%s:%i:%i" p.pos_fname p.pos_lnum (p.pos_cnum - p.pos_bol)

(* tree nodes are tagged with a source position *)
type 'a ext = 'a * extent [@@deriving yojson, show]

type int_type =
  | A_CHAR (* 8-bit *)
  | A_SHORT (* 16-bit *)
  | A_INT (* 32-bit *)
  | A_LONG (* 64-bit *)
  | A_INTEGER (* arbitrary precision *)
  | A_DYNINT of
      string
      * string (* integer with the specificed minimum and maximum values *)
[@@deriving yojson]

type int_sign = A_SIGNED | A_UNSIGNED [@@deriving yojson]
type float_type = A_FLOAT | A_DOUBLE | A_REAL [@@deriving yojson]

type typ =
  | A_int of int_type * int_sign
  | A_float of float_type
  | A_BOOL
  | A_pointer of typ  (** Scalar types. *)
[@@deriving yojson]

type unary_op = A_UNARY_PLUS | A_UNARY_MINUS | A_NOT | A_cast of typ ext
[@@deriving yojson]

and binary_op =
  | A_PLUS
  | A_MINUS
  | A_MULTIPLY
  | A_DIVIDE
  | A_MODULO
  | A_EQUAL
  | A_NOT_EQUAL
  | A_LESS
  | A_LESS_EQUAL
  | A_GREATER
  | A_GREATER_EQUAL
  | A_AND
  | A_OR

and incr = A_INCR | A_DECR
and prepost = A_PRE | A_POST

and binary_assign_op =
  | A_PLUS_ASSIGN
  | A_MINUS_ASSIGN
  | A_MULTIPLY_ASSIGN
  | A_DIVIDE_ASSIGN
  | A_MODULO_ASSIGN

and expr =
  | A_unary of unary_op * expr ext
  | A_binary of binary_op * expr ext * expr ext
  | A_address_of of expr
  | A_deref of expr
  | A_assign of expr ext * binary_assign_op option * expr ext
  | A_increment of expr ext * incr * prepost
  | A_call of string ext * expr ext list
  | A_INPUT
  | A_identifier of string
  | A_float_const of string
  | A_int_const of string
  | A_bool_const of bool
  | A_float_itv of string ext * string ext
  | A_int_itv of string ext * string ext
  | A_nondet of typ

and stat =
  | A_SKIP
  | A_BREAK
  | A_expr of expr ext
  | A_if of expr ext * stat ext * (* then *) stat ext option (* else *)
  | A_while of expr ext * stat ext (* body *)
  | A_return of expr ext option
  | A_block of stat ext list
  | A_local of vardecl
  | A_label of string ext
  | A_assert of expr ext
  | A_assume of expr ext
  | A_print of lvalue ext list

and lvalue = string
and decl = A_global of vardecl ext * global_kind | A_function of fundecl ext
and global_kind = A_VARIABLE | A_INPUT | A_VOLATILE
and vardecl = typ ext * (string ext * expr ext option) list

and fundecl =
  typ ext option * string ext * (string ext * typ ext) list * stat ext list

(************************************************************************)
(* UTILITIES *)
(************************************************************************)

let position_unknown = Lexing.dummy_pos
let extent_unknown = (position_unknown, position_unknown)

let cmp_neg = function
  | A_EQUAL -> A_NOT_EQUAL
  | A_NOT_EQUAL -> A_EQUAL
  | A_LESS -> A_GREATER_EQUAL
  | A_GREATER -> A_LESS_EQUAL
  | A_LESS_EQUAL -> A_GREATER
  | A_GREATER_EQUAL -> A_LESS
  | _ -> invalid_arg "not a comparison operator"

(* order in increasing filename, and the position in file *)
let compare_position p1 p2 =
  match compare p1.pos_fname p2.pos_fname with
  | 0 -> compare p1.pos_cnum p2.pos_cnum
  | _ -> compare p1.pos_fname p2.pos_fname

(* order in increasing start position, and then in reverse ending position *)
let compare_extent (b1, e1) (b2, e2) =
  match compare_position b1 b2 with 0 -> compare_position e2 e1 | x -> x

(************************************************************************)
(* PRINTERS *)
(************************************************************************)

(* pretty-print functions take usually two arguments: a formatter and
   the object to print. They can be easily integrated with the printf
   APIs thanks to the `%a` formatter.

   On the other hand, in a few places the code needs a object to string
   conversion. Using a high-order function it is possible to derive a
   obj -> string function from the pretty-print one *)
let pp_to_string pp obj =
  let buf = Buffer.create 16 in
  let fmt = Format.formatter_of_buffer buf in
  Format.fprintf fmt "%a" pp obj;
  Format.pp_print_flush fmt ();
  Buffer.contents buf

let string_of_position p =
  Printf.sprintf "%s:%i:%i" p.pos_fname p.pos_lnum (p.pos_cnum - p.pos_bol)

let string_of_extent (p, q) =
  if p.pos_fname = q.pos_fname then
    if p.pos_lnum = q.pos_lnum then
      if p.pos_cnum = q.pos_cnum then
        Printf.sprintf "%s:%i.%i" p.pos_fname p.pos_lnum (p.pos_cnum - p.pos_bol)
      else
        Printf.sprintf "%s:%i.%i-%i" p.pos_fname p.pos_lnum
          (p.pos_cnum - p.pos_bol) (q.pos_cnum - q.pos_bol)
    else
      Printf.sprintf "%s:%i.%i-%i.%i" p.pos_fname p.pos_lnum
        (p.pos_cnum - p.pos_bol) q.pos_lnum (q.pos_cnum - q.pos_bol)
  else
    Printf.sprintf "%s:%i.%i-%s:%i.%i" p.pos_fname p.pos_lnum
      (p.pos_cnum - p.pos_bol) q.pos_fname q.pos_lnum (q.pos_cnum - q.pos_bol)

let rec pp_typ fmt t =
  match t with
  | A_BOOL -> Format.fprintf fmt "bool"
  | A_float A_FLOAT -> Format.fprintf fmt "float"
  | A_float A_DOUBLE -> Format.fprintf fmt "double"
  | A_float A_REAL -> Format.fprintf fmt "real"
  | A_int (i, s) -> (
      let s = if s = A_UNSIGNED then "unsigned " else "" in
      match i with
      | A_CHAR -> Format.fprintf fmt "%schar" s
      | A_SHORT -> Format.fprintf fmt "%sshort" s
      | A_INT -> Format.fprintf fmt "%sint" s
      | A_LONG -> Format.fprintf fmt "%slong" s
      | A_INTEGER -> Format.fprintf fmt "%sinteger" s
      | A_DYNINT (l, h) -> Format.fprintf fmt "%sdynint(%s,%s)" s l h)
  | A_pointer t -> Format.fprintf fmt "%a*" pp_typ t

let string_of_typ = pp_to_string pp_typ

let pp_unary_op fmt op =
  match op with
  | A_UNARY_PLUS -> Format.fprintf fmt "+"
  | A_UNARY_MINUS -> Format.fprintf fmt "-"
  | A_NOT -> Format.fprintf fmt "!"
  | A_cast (t, _) -> Format.fprintf fmt "(%a)" pp_typ t

let pp_binary_op fmt op =
  match op with
  | A_PLUS -> Format.fprintf fmt "+"
  | A_MINUS -> Format.fprintf fmt "-"
  | A_MULTIPLY -> Format.fprintf fmt "*"
  | A_DIVIDE -> Format.fprintf fmt "/"
  | A_MODULO -> Format.fprintf fmt "%%"
  | A_EQUAL -> Format.fprintf fmt "=="
  | A_NOT_EQUAL -> Format.fprintf fmt "!="
  | A_LESS -> Format.fprintf fmt "<"
  | A_LESS_EQUAL -> Format.fprintf fmt "<="
  | A_GREATER -> Format.fprintf fmt ">"
  | A_GREATER_EQUAL -> Format.fprintf fmt ">="
  | A_AND -> Format.fprintf fmt "&&"
  | A_OR -> Format.fprintf fmt "||"

let pp_incr fmt incr =
  match incr with
  | A_INCR -> Format.fprintf fmt "++"
  | A_DECR -> Format.fprintf fmt "--"

let pp_binary_assign_op fmt assign =
  match assign with
  | A_PLUS_ASSIGN -> Format.fprintf fmt "+="
  | A_MINUS_ASSIGN -> Format.fprintf fmt "-="
  | A_MULTIPLY_ASSIGN -> Format.fprintf fmt "*="
  | A_DIVIDE_ASSIGN -> Format.fprintf fmt "/="
  | A_MODULO_ASSIGN -> Format.fprintf fmt "%%="

let rec pp_expr fmt e =
  match e with
  | A_unary (op, (e, _)) -> Format.fprintf fmt "%a(%a)" pp_unary_op op pp_expr e
  | A_binary (op, (e1, _), (e2, _)) ->
      Format.fprintf fmt "(%a %a %a)" pp_expr e1 pp_binary_op op pp_expr e2
  | A_assign ((lval, _), Some op, (rval, _)) ->
      Format.fprintf fmt "%a %a %a" pp_expr lval pp_binary_assign_op op pp_expr
        rval
  | A_assign ((lval, _), None, (rval, _)) ->
      Format.fprintf fmt "%a = %a" pp_expr lval pp_expr rval
  | A_identifier v -> Format.fprintf fmt "%s" v
  | A_increment ((lval, _), incr, A_PRE) ->
      Format.fprintf fmt "%a%a" pp_incr incr pp_expr lval
  | A_increment ((lval, _), incr, A_POST) ->
      Format.fprintf fmt "%a%a" pp_expr lval pp_incr incr
  | A_call ((tgt, _), args) ->
      Format.fprintf fmt "%s(" tgt;
      let rec proc_args = function
        | [] -> ()
        | (arg, _) :: [] -> Format.fprintf fmt "%a" pp_expr arg
        | (arg, _) :: l ->
            Format.fprintf fmt "%a, " pp_expr arg;
            proc_args l
      in
      proc_args args;
      Format.fprintf fmt ")"
  | A_float_const f -> Format.fprintf fmt "%s" f
  | A_int_const z -> Format.fprintf fmt "%s" z
  | A_INPUT -> Format.fprintf fmt "input"
  | A_bool_const b -> Format.fprintf fmt "%s" (Bool.to_string b)
  | A_float_itv ((f1, _), (f2, _)) -> Format.fprintf fmt "[%s, %s]" f1 f2
  | A_int_itv ((z1, _), (z2, _)) -> Format.fprintf fmt "[%s, %s]" z1 z2
  | A_nondet typ -> Format.fprintf fmt "nondet %a" pp_typ typ
  | A_deref e -> Format.fprintf fmt "*%a" pp_expr e
  | A_address_of e -> Format.fprintf fmt "&%a" pp_expr e

let rec pp_stat fmt stat =
  match stat with
  | A_SKIP -> Format.fprintf fmt "skip;"
  | A_BREAK -> Format.fprintf fmt "break;"
  | A_expr (e, _) -> Format.fprintf fmt "%a;" pp_expr e
  | A_if ((cond, _), (then_stat, _), None)
  | A_if ((cond, _), (then_stat, _), Some (A_block [], _)) ->
      Format.fprintf fmt "@[<v 4>if (%a)@,%a@]" pp_expr cond pp_stat then_stat
  | A_if ((cond, _), (then_stat, _), Some (else_stat, _)) ->
      Format.fprintf fmt "@[<v 4>if (%a)@,%a@]@,@[<v 4>else@,%a@]" pp_expr cond
        pp_stat then_stat pp_stat else_stat
  | A_while ((cond, _), (body, _)) ->
      Format.fprintf fmt "@[<v 4>while (%a)@,%a@]" pp_expr cond pp_stat body
  | A_return (Some (e, _)) -> Format.fprintf fmt "return %a;" pp_expr e
  | A_return None -> Format.fprintf fmt "return;"
  | A_block stats ->
      Format.fprintf fmt "@[<v 0>";
      let rec proc_stats = function
        | [] -> ()
        | (stat, _) :: [] -> Format.fprintf fmt "%a@]" pp_stat stat
        | (stat, _) :: l ->
            Format.fprintf fmt "%a@," pp_stat stat;
            proc_stats l
      in
      proc_stats stats
  | A_local ((t, _), vars_inits) ->
      Format.fprintf fmt "%a " pp_typ t;
      let rec proc_vars = function
        | [] -> ()
        | ((var, _), Some (e, _)) :: [] ->
            Format.fprintf fmt "%s = %a" var pp_expr e
        | ((var, _), Some (e, _)) :: l ->
            Format.fprintf fmt "%s = %a, " var pp_expr e;
            proc_vars l
        | ((var, _), None) :: [] -> Format.fprintf fmt "%s" var
        | ((var, _), None) :: l ->
            Format.fprintf fmt "%s, " var;
            proc_vars l
      in
      proc_vars vars_inits;
      Format.fprintf fmt ";"
  | A_label (l, _) -> Format.fprintf fmt "%s:" l
  | A_assert (e, _) -> Format.fprintf fmt "assert(%a);" pp_expr e
  | A_assume (e, _) -> Format.fprintf fmt "assume(%a);" pp_expr e
  | A_print args ->
      Format.fprintf fmt "print(";
      let rec proc_args = function
        | [] -> ()
        | (arg, _) :: [] -> Format.fprintf fmt "%s" arg
        | (arg, _) :: l ->
            Format.fprintf fmt "%s, " arg;
            proc_args l
      in
      proc_args args;
      Format.fprintf fmt ")"
