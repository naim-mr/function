
open AbstractSyntax

module VarSet = Set.Make (struct
type t = var
let compare = fun x y -> String.compare x.varId y.varId
end)
