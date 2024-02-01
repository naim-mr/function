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

type ctl_property = AbstractSyntax.bExp CTLProperty.generic_property
type 'a p = Ctl of ctl_property | Exp of   (bExp*'a) StringMap.t


let get_ctl prop = match prop with
| Ctl prop -> prop
| _ -> raise (Invalid_argument ("Waiting a ctl property received a bexp"))
let get_bexp prop = match prop with
| Exp prop -> prop
| _ -> raise (Invalid_argument ("Waiting a bexp property received a ctl"))

module type SEMANTIC = 
sig 
   (** 
      [D]: Underlying instanciantion of the DecisionTree Abstract Domain 
   *)
   module D : RANKING_FUNCTION

   (**
      [B]: Underlying instanciantion of the Numerical Abstract Domain used in D 
   *)
   module B = D.B
   (**
      [r]: Ghost type to to handle the  different types returned by bwdBlk in different iterators
   *)
   type r
   (**
      [p]: Ghost type to to handle the  different types for the properties
      two case:
         (bExp*'a) StringMap.t
         or 
         ctl_property
   *)
   
   val dummy_prop: 'a p 
   (**
      [fwdInvMap]: a map from the label of the program to an associated the over-approximating numerical abstraction computed in a forward analysis
   *)
   val fwdInvMap: B.t InvMap.t ref
   (**
      [bwdInvMap]: a map from the label of the program to an associated a decision tree that abstract a ranking function of the program.
   *)
   val bwdInvMap: D.t InvMap.t ref
   (**
      [bwdStm]: abstract backward transfer function of statement for the decision tree abstract domain
   *)
   (* val bwdStm: ?property:'a p -> ?domain:B.t -> func StringMap.t -> Environment.t -> var list -> r -> stmt -> r
   (**
      [bwdBlk]: abstract backward transfer function of blocks for the decision tree abstract domain
   *)
   val bwdBlk: ?property:'a p -> func StringMap.t -> Environment.t -> var list -> r -> block ->  r  *)

   val bwdRec: ?property:'a p -> func StringMap.t -> Environment.t -> var list -> D.t -> block ->  D.t 
   val initBlk: Environment.t -> var list -> block -> unit
   (**
      [analyze]: iterating function that run the analysis for the given semantic
   *)
   val analyze: ?precondition:bExp -> ?property:'a p -> AbstractSyntax.prog ->  string -> bool

end