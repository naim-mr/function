open Abstract_syntax
open Typed_syntax

type kind = APPROXIMATION | COMPUTATIONAL | RESILIENCE

module type DOMAIN = sig
  type t
  type env
  type dim

  val bot : env -> t
  (** [bot env] returns the bot element defines on [env]. *)

  val top : env -> t
  (** [top env] returns the top element defines on [env]. *)

  val is_bot : t -> bool
  (** [is_bot t] tests if [t] is equal to bot. *)

  val is_leq : kind -> t -> t -> bool
  (** [is_leq kind t1 t2] (partial) order on t *)

  val join : kind -> t -> t -> t
  (** [join kind t1 t2] least upper bound of t1 and t2 *)

  val meet : kind -> t -> t -> t
  (** [meet kind t1 t2] greatest lower bound of t1 and t2 *)

  val widen : ?jokers:int -> t -> t -> t
  (** [widen jokers t t] widening operator on t. The optional type jokers is
      mainly for widening. *)

  val init_env : unit -> env
  (** [init env ()] returns an empty env *)

  val env : t -> env
  (** [env t] returns the environment in which is defined the partition *)

  val set_env : env -> t -> t
  (** [update_env env t] returns [t] with the environment [env]*)

  val add_dim_to_env : t -> dim -> t
  (** [add_var_to_env env x] add the variable [x] inside the environment [env]*)

  val dim_in_env : t -> dim -> bool
  (** [dim_in_env t x] tests if the variable [x] is inside the environment of
      [t]*)

  val remove_dim_of_env : t -> dim -> t
  (** [remove_dim_of_env env x] remove the variable [x] inside the environment
      [env]*)

  val print : Format.formatter -> t -> unit
  (** [print fmt t] pretty printer for type t *)
end
