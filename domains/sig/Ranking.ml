open Apron
open Domain
open Constraints
open Abstract_syntax
open Typed_syntax

(** Signature for a single partition of the domain of a ranking function. *)
module type PARTITION = sig

  module C : CONSTRAINT
  (** [module C] The underlying constraints domains, a parititon is a
      conjunction of such constraints *)
  include DOMAIN with type dim = C.dim
  
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

  val bwd_assign : t -> expr typed * expr typed -> t
  (** [bwd_assign t lv exp] Over-approximating backward assignement [lv := exp] on [t]*)
  
  val ubwd_assign :t -> expr typed * expr typed -> t
  (** [ubwd_assign t lv exp] Under-approximating backward assignement [lv := exp] on [t]*)
  
  val fwd_assign : t -> expr typed * expr typed -> t
  (** [fwd_assign t lv exp] Over-approximating forward assignement [lv := exp] on [t]*)
  
  val fwd_filter : t -> expr typed -> t
  (** [fwd_assign t exp] Over-approximating forward filter [exp != 0] on [t]*)

  val ubwd_filter : t -> expr typed -> t
  (** [ubwd_assign t exp] Under-approximating backward filter [exp != 0] on [t]*)
  val print : Format.formatter -> t -> unit

end

module type AP_NUMERICAL = sig
  type lib

  val manager : lib Manager.t
  val supports_underapproximation : bool
end

module type AP_PARTITION = sig
  module C : AP_CONSTRAINT
  module N : AP_NUMERICAL
  include PARTITION with module C := C and type env = C.env

  val ap_env : env -> Environment.t
  val inner : env -> C.t list -> t
end

module type FUNCTION = sig
  module B : PARTITION
  type env = B.env 
  type dim = B.dim
  type t 
  type rank
  val bot : env -> t
  val top : env -> t
  val is_bot : t -> bool
  val is_top : t -> bool
  val init_env : unit -> env
  (** [init env ()] returns an empty env *)
  val env : t -> env
  (** [env t] returns the environment in which is defined the partition *)
  val set_env : env -> t -> t
  (** [update_env env t] returns [t] with the environment [env]*)
  val add_dim_to_env: t -> dim -> t
  (** [add_var_to_env env x] add the variable [x] inside the environment [env]*)

  val remove_dim_of_env: t -> dim -> t
  (** [remove_dim_of_env env x] remove the variable [x] inside the environment [env]*)

  val bwd_assign : t -> expr typed * expr typed -> t
  val filter : t -> expr typed -> t
  val reinit : t -> t
  val zero : env -> t
  val defined : t -> bool
  val is_leq : kind -> B.t -> t -> t -> bool
  val join : ?random:bool -> kind -> B.t -> t -> t -> t
  val widen : ?jokers:int -> B.t -> t -> t -> t
  val is_eq : B.t -> t -> t -> bool
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
  
  type dim = B.dim
  type t
  type env
  
  val dual_widen: t -> t -> t
  val update_dom: B.t option -> env -> env
  val bwd_assign : ?domain:B.t ->  t ->  expr typed * expr typed ->  t
  val filter : ?domain:B.t -> t -> expr typed -> t
  val ubwd_assign : ?domain:B.t ->  t ->  expr typed * expr typed ->  t
  val ubwd_filter : ?domain:B.t -> t -> expr typed -> t
  val zero : env -> t
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
