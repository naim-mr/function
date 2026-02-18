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
  (** [inner env cs] returns the partitions defined by the constraints in [cs]
      on [env]*)

  val bwd_assign : t -> expr typed * expr typed -> t
  (** [bwd_assign t lv exp] Over-approximating backward assignement [lv := exp]
      on [t]*)

  val ubwd_assign : t -> expr typed * expr typed -> t
  (** [ubwd_assign t lv exp] Under-approximating backward assignement
      [lv := exp] on [t]*)

  val fwd_assign : t -> expr typed * expr typed -> t
  (** [fwd_assign t lv exp] Over-approximating forward assignement [lv := exp]
      on [t]*)

  val fwd_filter : t -> expr typed -> t
  (** [fwd_assign t exp] Over-approximating forward filter [exp != 0] on [t]*)

  val ubwd_filter : t -> expr typed -> t
  (** [ubwd_assign t exp] Under-approximating backward filter [exp != 0] on [t]*)
end

(** [module type AP_NUMERICAL] include an apron domain type and a manager for it
*)
module type AP_NUMERICAL = sig
  type lib

  val manager : lib Manager.t
  val supports_underapproximation : bool
end

(** [module type AP_PARTITION] module type for [PARTITION] relying on APRON *)
module type AP_PARTITION = sig
  module C : AP_CONSTRAINT
  module N : AP_NUMERICAL
  include PARTITION with module C := C and type env = C.env

  val ap_env : env -> Environment.t
  val inner : env -> C.t list -> t
end

module type FUNCTION = sig
  module B : AP_PARTITION
  (** [module B] defines the domain on which the function is defined. *)

  type env = B.env
  (** Environement on which is defined the expression of function. *)

  type dim = B.dim
  (** Type of a dimension. *)

  type rank
  (** Type of an abstract expression for the function. *)

  type t
  (** Type of an abstract value. *)

  val init_env : unit -> env
  (** [init env ()] returns an empty env *)

  val env : t -> env
  (** [env t] returns the environment in which is defined the partition *)

  val set_env : env -> t -> t
  (** [update_env env t] returns [t] with the environment [env]*)

  val bot : env -> t
  (** [bot env] returns the bot element defines on [env]. *)

  val top : env -> t
  (** [top env] returns the top element defines on [env]. *)

  val is_bot : t -> bool
  (** [is_bot t] tests if [t] is equal to bot. *)

  val is_top : t -> bool
  (** [is_top t] tests if [t] is equal to top. *)

  val is_leq : kind -> B.t -> t -> t -> bool
  (** [is_leq kind domain t1 t2] checks if the function [t1] is less or equal
      than [t2] on the given [domain] *)

  val is_eq : B.t -> t -> t -> bool
  (** [is_eq kind domain t1 t2] returns the domains on which the functions [t1]
      and [t2] are equals *)

  val domain_eq : B.t -> t -> t -> B.t
  (** [domain_eq kind domain t1 t2] checks if the function [t1] is equal to [t2]
      on the given [domain] *)

  val join : ?random:bool -> kind -> B.t -> t -> t -> t
  (** [is_leq kind domain t1 t2] compute the join of function [t1] and the
      function [t2] on the given [domain] *)

  val widen : ?jokers:int -> B.t -> t -> t -> t
  (** [widening domain t1 t2] compute the widening of function [t1] and the
      function [t2] on the given [domain] *)

  val bwd_assign : t -> expr typed * expr typed -> t
  (** [bwd_assign t lv exp] Over-approximating backward assignement [lv := exp]
      on the function [t]*)

  val filter : t -> expr typed -> t
  (** [bwd_assign t exp] Over-approximating backward filter [exp != 0] on [t]*)

  val reinit : t -> t
  (** [reinit t] set the function to bot *)

  val zero : env -> t
  (** [zero t env] return the constant function 0 on the environment [env]*)

  val defined : t -> bool
  (** [defined t] checks if the function [t] is a defined function *)

  val plus : B.t -> t -> t -> t
  (** [plus domain t1 t2] compute the sum of the function [t1] and [t2] on
      [domain] *)

  val extend : B.t -> B.t -> t -> t -> t
  (** [extends domain1 domain2 t1 t2] comment TODO *)

  val learn : B.t -> t -> t -> t
  (** [learn domain t1 t2] comment TODO *)

  val reset : t -> t
  (** [reset domain t] reset the expression of the function [t] on [domain] *)

  val predecessor : t -> t
  (** [predecessor t] -1 operator on the function [t] *)

  val successor : t -> t
  (** [successor t] +1 operator on the function [t] *)

  val print : Format.formatter -> t -> unit
  (** [print fmt t] pretty printer for the datatype t *)
end

module type RANKING_FUNCTION = sig
  module B : PARTITION
  (** [module B] defines the domain on which the function is defined. *)

  type env
  (** Environement on which is defined the expression of function. *)

  type dim = B.dim
  (** Type of a dimension. *)

  type t
  (** Type of an abstract value. *)

  val env : t -> env
  (** [env t] returns the environment in which is defined the partition *)

  val bot : env -> t
  (** [bot env] returns the bot element defines on [env]. *)

  val top : env -> t
  (** [top env] returns the top element defines on [env]. *)

  val is_bot : t -> bool
  (** [is_bot t] tests if [t] is equal to bot. *)

  val is_leq : kind -> t -> t -> bool
  val join : kind -> t -> t -> t
  val widen : ?jokers:int -> t -> t -> t
  val meet : kind -> t -> t -> t
  val lift_fenv : B.env -> env
  val dual_widen : t -> t -> t
  val update_dom : B.t option -> env -> env
  val bwd_assign : ?domain:B.t -> t -> expr typed * expr typed -> t
  val filter : ?domain:B.t -> t -> expr typed -> t
  val ubwd_assign : ?domain:B.t -> t -> expr typed * expr typed -> t
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
