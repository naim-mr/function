(***************************************************)
(*                                                 *)
(*        Ranking Function Domain Partition        *)
(*                                                 *)
(*                  Caterina Urban                 *)
(*     École Normale Supérieure, Paris, France     *)
(*                   2012 - 2015                   *)
(*                                                 *)
(***************************************************)

open Typed_syntax
open Apron
open Constraints

(** Signature for a single partition of the domain of a ranking function. *)
module type PARTITION = sig
  module C : CONSTRAINT
  type t
  type lib
  val manager : lib Manager.t
  val constraints : t -> C.t list
  val env : t -> Environment.t
  val vars : t -> var list
  val bot : Environment.t -> var list -> t
  val inner : Environment.t -> var list -> C.t list -> t
  val top : Environment.t -> var list -> t
  val isBot : t -> bool
  val isLeq : t -> t -> bool
  val assume : ?pow:float -> t -> t * t
  val join : t -> t -> t
  val widen : t -> t -> t
  val meet : t -> t -> t
  val fwdAssign : t -> expr typed * expr typed -> t
  val bwdAssign : t -> expr typed * expr typed -> t
  val bwdAssign_underapprox : t -> expr typed * expr typed -> t
  val filter : t -> expr typed -> t
  val filter_underapprox : t -> expr typed -> t
  val print : Format.formatter -> t -> unit
end
