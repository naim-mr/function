open Abstract_syntax
open Typed_syntax

type kind = APPROXIMATION | COMPUTATIONAL | RESILIENCE

module type DOMAIN = sig
  type t
  type env
  type dim
  val bot : env -> t
  val top : env -> t
  val is_bot : t -> bool
  val is_leq : kind -> t -> t -> bool
  val join : kind -> t -> t -> t
  val meet : kind -> t -> t -> t
  val widen : ?jokers:int -> t -> t -> t
  val print : Format.formatter -> t -> unit
  val init_env : unit -> env
  (** [init env ()] returns an empty env *)
  val env : t -> env
  (** [env t] returns the environment in which is defined the partition *)
  val set_env : env -> t -> t
  (** [update_env env t] returns [t] with the environment [env]*)
  val add_dim_to_env: t -> dim -> t
  (** [add_var_to_env env x] add the variable [x] inside the environment [env]*)
  val dim_in_env: t -> dim -> bool
  (** [dim_in_env t x] tests if the variable [x] is inside the environment of [t]*)
  val remove_dim_of_env: t -> dim -> t
  (** [remove_dim_of_env env x] remove the variable [x] inside the environment [env]*)

end
