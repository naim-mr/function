open AbstractSyntax
open SetTaint

module Taint = struct
  type t = SetTaint.t

  let bot = SetTaint.empty
  let join = SetTaint.union
  let add x t = SetTaint.add x t
  let filter = SetTaint.filter
  let meet = SetTaint.inter
  let leq = SetTaint.subset
  let is_bot = SetTaint.is_empty

  (* List of vars in an expression *)
  let avars (e, ext) =
    let rec aux e acc =
      match e with
      | A_var x -> add x acc
      | A_interval _ | A_const _ | A_INPUT | A_RANDOM -> acc
      | A_aunary (_, (a, _)) -> aux a acc
      | A_abinary (_, (a1, _), (a2, _)) -> join (aux a1 acc) (aux a2 acc)
    in
    aux e bot

  (* Test if a boolean expression is taint *)
  let taint_b (e, ext) tvl =
    let rec aux e =
      match e with
      | A_MAYBE_INP -> true
      | A_TRUE | A_MAYBE | A_FALSE -> false
      | A_bunary (_, (b, l)) -> aux b
      | A_bbinary (_, (b1, _), (b2, l)) -> aux b1 || aux b2
      | A_rbinary (_, a1, a2) ->
          let vl1 = avars a1 in
          let vl2 = avars a2 in
          if
            is_bot (meet tvl vl1)
            || is_bot (meet tvl vl2)
          then true
          else false
    in
    aux e

  let assigned block =
    let rec aux stmt acc =
      match stmt with
      | A_assign ((A_var x, _), (_, _)) -> add x acc
      | A_if ((b, ba), s1, s2) ->
          join (aux_block s1 acc) (aux_block s2 acc)
      | A_while (l, (b, ba), s) -> aux_block s acc
      | _ -> acc
    and aux_block s acc =
      match s with
      | A_empty l -> acc
      | A_block (l, (s, _), b) -> join (aux s acc) (aux_block b acc)
    in
    aux_block block bot
end
