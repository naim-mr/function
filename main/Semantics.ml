(*   
          ********* Forward/Backward Iterator ************
   Copyright (C) 2012-2014 by Caterina Urban. All rights reserved.
*)
open Config
open AbstractSyntax
open DecisionTree
open Apron
open InvMap
open CTLProperty
open Domain
open SetTaint

type ctl_property = AbstractSyntax.bExp CTLProperty.generic_property
type 'a p = Ctl of ctl_property | Exp of (bExp * 'a) StringMap.t

let get_ctl prop =
  match prop with
  | Ctl prop -> prop
  | _ -> raise (Invalid_argument "Expected a ctl property: received a bexp")

let get_bexp prop =
  match prop with
  | Exp prop -> prop
  | _ -> raise (Invalid_argument "Expected a bexp property, got a ctl")

module type SEMANTIC = sig
  module D : RANKING_FUNCTION
  (** [D]: Underlying instanciantion of the DecisionTree Abstract Domain *)

  module B = D.B
  (** [B]: Underlying instanciantion of the Numerical Abstract Domain used in D
  *)

  type r
  (** [r]: Ghost type to to handle the different types returned by bwdBlk in
      different iterators *)

  val dummy_prop : 'a p
 
  val fwdInvMap : B.t InvMap.t ref
  (** [fwdInvMap]: a map from the label of the program to an associated the
      over-approximating numerical abstraction computed in a forward analysis *)

  val fwdTaintMap : SetTaint.t InvMap.t ref 

  val bwdInvMap : D.t InvMap.t ref
  (** [bwdInvMap]: a map from the label of the program to an associated a
      decision tree that abstract a ranking function of the program. *)

  val bwdRec :
    ?property:'a p ->
    func StringMap.t ->
    Environment.t ->
    var list ->
    D.t ->
    block ->
    D.t
  (** [bwdRec]: abstract backward transfer function of statement for the
      decision tree abstract domain *)

  val initBlk : Environment.t -> var list -> block -> unit
  (** [initBlk]: initialisation function *)

  val analyze :
    ?precondition:bExp option ->
    ?property:'a p ->
    AbstractSyntax.prog ->
    string ->
    bool
  (** [analyze]: iterating function that run the analysis for the given semantic
  *)
end
