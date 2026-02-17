(*   
          ********* Forward/Backward Iterator ************
   Copyright (C) 2012-2014 by Caterina Urban. All rights reserved.
*)
open Config
open Typed_syntax
open Domains
open Sig
open Sig.Domain
open Decision_Tree
open Apron
open InvMap
open CTLProperty
open VarSet
open Utils.Datatypes

type ctl_property = expr typed CTLProperty.generic_property
type 'a p = Ctl of ctl_property | Other

let get_ctl prop =
  match prop with
  | Ctl prop -> prop
  | Other -> raise (Invalid_argument "Expected a ctl property: got an other")

module type SEMANTIC = sig
  type bwd_t
  (** [BWD]: Underlying Abstract Domain that will be use in the bwd analysis *)

  type fwd_t
  (** [B]: Underlying Abstract Domain used in the fwd analysis *)

  type env

  val fwdInvMap : fwd_t InvMap.t ref
  (** [fwdInvMap]: a map from the label of the program to an associated
      abstraction computed in a forward analysis *)

  val bwdInvMap : bwd_t InvMap.t ref
  (** [bwdInvMap]: a map from the label of the program to an associated a
      decision tree that abstract a ranking function of the program. *)

  val bwdRec :
    ?property:'a p ->
    func StringMap.t ->
    env ->
    var list ->
    bwd_t ->
    block ->
    bwd_t
  (** [bwdRec]: abstract backward transfer function of statement for the
      decision tree abstract domain *)

  val initBlk : env -> block -> unit
  (** [initBlk]: initialisation function *)

  val analyze :
    ?precondition:expr typed option ->
    ?property:'a p ->
    Typed_syntax.prog ->
    bool
  (** [analyze]: iterating function that run the analysis for the given semantic
  *)
end
