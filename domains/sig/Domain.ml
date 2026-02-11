open Abstract_syntax
open Typed_syntax

type kind = APPROXIMATION | COMPUTATIONAL | RESILIENCE
module type DOMAIN = sig
  type t
  type env
  val bot : env -> t
  val top : env -> t
  val is_bot : t -> bool
  val is_leq : kind -> t -> t -> bool
  val join : kind -> t -> t -> t
  val meet : kind -> t -> t -> t
  val widen : ?jokers:int -> t -> t -> t
  val print : Format.formatter -> t -> unit
end

module type FDOMAIN = sig
  include DOMAIN

  val fwd_assign : t -> expr typed * expr typed -> t
  val filter : t -> expr typed -> t
end

module type BDOMAIN = sig
  include FDOMAIN

  type t_fwd

  val bwd_assign : ?pre:t_fwd -> t -> expr typed * expr typed -> t
  val ubwd_assign : ?pre:t_fwd -> t -> expr typed * expr typed -> t
  val bwd_filter : t -> expr typed -> t
  val ubwd_filter : t -> expr typed -> t
end

module type FBDOMAIN = sig
  include FDOMAIN
  include BDOMAIN
end
