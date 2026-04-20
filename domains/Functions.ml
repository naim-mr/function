(*   
      ********* Ranking Functions Abstract Domain ************
   Copyright (C) 2012-2014 by Caterina Urban. All rights reserved.
*)

open Typed_syntax
open Apron
open Partition

type kind = APPROXIMATION | COMPUTATIONAL | RESILIENCE

module type FUNCTION = sig
  module B : PARTITION

  type a = Bot | Fun of Linexpr1.t | Top
  type f

  val env : f -> Environment.t
  val vars : f -> var list
  val reinit : f -> f
  val bot : Environment.t -> var list -> f
  val zero : Environment.t -> var list -> f
  val top : Environment.t -> var list -> f
  val ranking : f -> a
  val isBot : f -> bool
  val defined : f -> bool
  val isTop : f -> bool
  val isEq : B.t -> f -> f -> bool

  (* returns the domain where the two functions are equal *)
  val domainEq : B.t -> f -> f -> B.t
  val isLeq : kind -> B.t -> f -> f -> bool
  val join : ?random:bool -> kind -> B.t -> f -> f -> f
  val plus : B.t -> f -> f -> f
  val widen : ?jokers:int -> B.t -> f -> f -> f
  val extend : B.t -> B.t -> f -> f -> f
  val learn : B.t -> f -> f -> f
  val reset : f -> f
  val predecessor : f -> f
  val successor : f -> f
  val of_linexpr : Environment.t -> var list -> Linexpr1.t -> f
  (** Build from ordinal components: [finite; ω^1 coeff; ω^2 coeff; ...].
      For non-ordinal domains, only the first element is used. *)
  val of_ordinal_components : Environment.t -> var list -> Linexpr1.t list -> f
  val bwdAssign : f -> expr typed * expr typed -> f
  val filter : f -> expr typed -> f
  val print : Format.formatter -> f -> unit
end
