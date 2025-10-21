(* value domain of each type *)
open Utils.Datatypes
open Abstract_syntax
open Utils
open Typed_syntax

let signed_set bsize =
  ( Finite (Int.neg (Int.shift_left Int.one (bsize - 1))),
    Finite (Int.pred (Int.shift_left Int.one (bsize - 1))) )

let unsigned_set bsize =
  (Finite Int.zero, Finite (Int.pred (Int.shift_left Int.one bsize)))

let int_type_set (t : int_type) (s : int_sign) : Itv_int.t =
  match (t, s) with
  | A_CHAR, A_SIGNED -> signed_set 8
  | A_CHAR, A_UNSIGNED -> unsigned_set 8
  | A_SHORT, A_SIGNED -> signed_set 16
  | A_SHORT, A_UNSIGNED -> unsigned_set 16
  | A_INT, A_SIGNED -> signed_set 32
  | A_INT, A_UNSIGNED -> unsigned_set 32
  | A_LONG, A_SIGNED -> signed_set 64
  | A_LONG, A_UNSIGNED -> unsigned_set 64
  | A_INTEGER, A_SIGNED -> (MINF, INF)
  | A_INTEGER, A_UNSIGNED -> (Finite Int.zero, INF)
  | A_DYNINT (l,h), A_SIGNED -> (Finite (Int.of_string l), Finite (Int.of_string h))
  | A_DYNINT (l,h), A_UNSIGNED -> (Finite (Int.of_string l |> Int.max Int.zero), Finite (Int.of_string h |> Int.max Int.zero))

let const_fit_in_type (t : int_type) (s : int_sign) (c : Intinf.t) : bool =
  let l, h = int_type_set t s in
  Intinf.geq c l && Intinf.leq c h

let float_type_set (t : float_type) : Itv_float.t =
  match t with
  | A_FLOAT -> (-.Float.Single.max_normal, Float.Single.max_normal)
  | A_DOUBLE -> (-.Float.Double.max_normal, Float.Double.max_normal)
  | A_REAL -> (neg_infinity, infinity)

let bool_type_set = Maybe

let type_set_expr (t : typ) : expr =
  match t with
  | A_int (i, s) -> T_int_const (int_type_set i s)
  | A_float f -> T_float_const (float_type_set f)
  | A_BOOL -> T_bool_const Maybe
