open Apron
open Domain
open Constraints
open Abstract_syntax
open Typed_syntax

(** Signature for a single partition of the domain of a ranking function. *)
module type PARTITION = sig
  (* A Partition has to implements operators of an abstract domain *)
  include DOMAIN

  val bwd_assign : t -> expr typed * expr typed -> t
  val ubwd_assign :t -> expr typed * expr typed -> t
  val bwd_filter : t -> expr typed -> t
  val ubwd_filter : t -> expr typed -> t

  module C : CONSTRAINT
  (** [module C] The underlying constraints domains, a parititon is a
      conjunction of such constraints *)

  val env : t -> env
  (** [env t] returns the environment in which is defined the partition *)

  val constraints : t -> C.cons list
  (** [constraints t] returns the conjunction of constraints as a list of
      constraints in C*)
  val conjunction : t -> C.t list
      (** [constraints t] returns the conjunction of constraints as a list of
          constraints in C*)
  val assume : ?pow:float -> t -> t * t
  (** [assume t] split the set of constraints in two set of constraints for
      conflict-driven analysis *)
  
  val inner : env -> C.t list -> t
  (** [inner env cs] returns the partitions defined by the constraints in [cs] on [env]*)
  val print : Format.formatter -> t -> unit

  val add_var_to_env: env -> var -> env
end

module type AP_NUMERICAL = sig
  type lib

  val manager : lib Manager.t
  val supports_underapproximation : bool
end

(** Signature for a single partition of the domain of a ranking function. *)
module type AP_PARTITION = sig
  module C : AP_CONSTRAINT
  module N : AP_NUMERICAL
  include PARTITION with module C := C and type env = C.env

  val ap_env : env -> Environment.t
  val inner : env -> C.t list -> t
end

module type FUNCTION = sig
  module B : PARTITION

  type rank
  type t
  type env = B.env

  val bot : env -> t
  val top : env -> t
  val env : t -> env
  val is_top : t -> bool
  val is_bot : t -> bool
  val is_leq : kind -> B.t -> t -> t -> bool
  val join : ?random:bool -> kind -> B.t -> t -> t -> t
  val widen : ?jokers:int -> B.t -> t -> t -> t
  val bwd_assign : t -> expr typed * expr typed -> t
  val filter : t -> expr typed -> t
  val reinit : t -> t
  val zero : env -> t
  val ranking : t -> rank
  val defined : t -> bool
  val is_eq : B.t -> t -> t -> bool

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
  include DOMAIN

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
