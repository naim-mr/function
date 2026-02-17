open Apron
(** Constraint domain The signature [CONSTRAINT] define the domain of constraint
    that can be used to partition a Decision Tree *)

open Abstract_syntax
open Typed_syntax

module type CONSTRAINT = sig
  type cons
  (** Type defining the constraint. *)

  type env
  (** Type representing the environment in which the constraint is defined. *)

  type t = { cons : cons; env : env }
  (** Type representing the constraint alongside with its environment. *)

  type linexpr
  (** Linear constraints type. *)

  type dim = var

  val init_env : unit -> env
  (** [init env ()] returns an empty env *)

  val env : t -> env
  (** [env t] returns the environment in which is defined the partition *)

  val set_env : env -> t -> t
  (** [update_env env t] returns [t] with the environment [env]*)

  val add_dim_to_env : env -> dim -> env
  (** [add_dim_to_env env x] add the dimension [x] inside the environment [env]*)

  val remove_dim_of_env : env -> dim -> env
  (** [remove_dim_of_env env x] remove the dimension [x] inside the environment
      [env]*)

  val make_unsat : env -> t
  (** [make_unsat env] returns a non satisfiable constraints over the
      environment [env]. *)

  val linexpr : t -> linexpr
  (** [linexpr t] linearises the constraint [t]. *)

  val is_bot : t -> bool
  (** [is_bot t] tests if [t] is unsat. *)

  val compare : t -> t -> int
  (** [compare t1 t2] compares the two constraints. It returns -1 if c1 < c2; 0
      if c1 = c2 and 1 if c1 > c2.*)

  val is_eq : t -> t -> bool
  (** [is_eq t1 t2] tests if two constraints are equals. *)

  val is_leq : t -> t -> bool
  (** [is_leq t1 t2] tests if t1 implies t2. *)

  val var : var -> t -> bool
  (** [var v t] tests if is constrained in t. *)

  val similar : t -> t -> bool
  (** [similar t1 t2] Tests if two constraints are similars e.g. differs only by
      a constant *)

  val negate : t -> t
  (** [negate t] returns the negation of t. *)

  val expand : t -> t * t
  (** [expand t] transforms equalities in pairs of supeq and infeq. *)

  val print : Format.formatter -> t -> unit
end

type lincons_env = { vars : var list; ap_env : Environment.t }

module type AP_CONSTRAINT =
  CONSTRAINT
    with type env = lincons_env
     and type cons = Lincons1.t
     and type linexpr = Linexpr1.t
