

(* invariant map that assigns values to program labels *)

module InvMap = Map.Make (struct
  type t = Z.t

  let compare = compare
end)
