(*   
   Processed syntax tree:
   - variable scoping is resolved
   - trees are typed
   - casts are explicit
   - expressions are side-effect free
   - statements are labelled with unique identifiers

   Copyright (C) 2011 Antoine Miné
*)

open Banal_datatypes
include Frontend.Abstract_syntax
include Frontend.Typed_syntax
