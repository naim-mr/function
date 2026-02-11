open Apron
open Domain
open Constraints
open Abstract_syntax
open Typed_syntax

(** Signature for a single partition of the domain of a ranking function. *)
module type PARTITION = sig
  include DOMAIN
  module C : CONSTRAINT
  val assume : ?pow:float -> t -> t * t
  val print : Format.formatter -> t -> unit
end

module type FUNCTION = sig
  include BDOMAIN
  module B : PARTITION
  type a
  val reinit : t -> t
  val zero : env -> t
  val ranking : t -> a
  val defined : t -> bool
  val is_eq : t -> t -> bool

  (* returns the domain where the two functions are equal *)
  val domain_eq : B.t -> t -> t -> B.t
  val plus : B.t -> t -> t -> t
  val extend : B.t -> B.t -> t -> t -> t
  val learn : B.t -> t -> t -> t
  val reset : t -> t
  val predecessor : t -> t
  val successor : t -> t
  val print : Format.formatter -> t -> unit
end

module type RANKING_FUNCTION = sig
  module B : PARTITION
  include BDOMAIN

  val domain_zero : t -> t
  val plus : t -> t -> t
  val defined : ?condition:expr typed -> t -> bool
  val partially_defined : ?condition:expr typed -> t -> bool
  val complement : t -> t
  val reset : ?mask:t -> t -> expr typed -> t
  val until : t -> t -> t -> t
  val refine : t -> B.t -> t
  val mask : t -> t -> t
  val learn : t -> t -> t
  val conflict : t -> B.t list
  val reinit : t -> t
  val compress : t -> t
  val merge_after : t -> t
  val print : Format.formatter -> t -> unit
  val output_json : var list -> t -> Yojson.Safe.t
  val print_graphviz_dot : Format.formatter -> t -> unit
end
