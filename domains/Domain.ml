(***************************************************)
(*                                                 *)
(*      The Ranking Functions Abstract Domain      *)
(*                                                 *)
(*                 Caterina Urban                  *)
(*     École Normale Supérieure, Paris, France     *)
(*                   2012 - 2015                   *)
(*          ETH Zurich, Zurich, Switzerland        *)
(*                      2016                       *)
(*                                                 *)
(***************************************************)

open AbstractSyntax
open Apron
open Partition
open Functions
open Vulnerability
module type RANKING_FUNCTION =
sig

  module B : PARTITION

  type t

  val bot : ?domain:B.t -> Environment.t -> var list -> t
  val zero : ?domain:B.t -> Environment.t -> var list -> t
  val top : ?domain:B.t -> Environment.t -> var list -> t

  val isLeq : kind -> t -> t -> bool
  val join : kind -> t -> t -> t
  val meet : kind -> t -> t -> t
  val widen : ?jokers:int -> t -> t -> t
  val dual_widen : t -> t -> t

  val defined : ?condition:bExp -> t -> bool
  val complement: t -> t
  val bwdAssign : ?domain:B.t -> ?taint:bool -> ?underapprox:bool -> t -> aExp * aExp -> t
  val filter : ?domain:B.t -> ?underapprox:bool -> t -> bExp -> t
  val reset : ?mask:t -> t -> bExp -> t
  val until: t -> t -> t -> t
  val refine : t -> B.t -> t
  val mask: t -> t -> t
  val learn: t -> t -> t
  val conflict : t -> B.t list
  val reinit: t -> t
  val compress : t -> t
  val vulnerable : t  ->  (Polka.strict Polka.t Vulnerability.t)   list
  val print : Format.formatter -> t -> unit
  val output_json : var list -> t -> Yojson.Safe.t
  val print_graphviz_dot : Format.formatter -> t -> unit
end
