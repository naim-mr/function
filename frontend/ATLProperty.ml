(*

   'A' stands for 'all paths'
   'E' stands for 'exists a path'

   Operators
   X: next
   F: future/eventually
   G: global/always
   U: until
   
*)

  type player = I | R | IR 
  type controllable_players = player option
type 'a generic_property =
  | Atomic of ('a * string option) (* atomic property with optional label *)
  | X of  (controllable_players * 'a generic_property )(* next *)
  | F of controllable_players * 'a generic_property (* future/eventually *)
  | G of controllable_players * 'a generic_property (* global *)
  | U of (controllable_players * 'a generic_property * 'a generic_property) (* until *)
  | AND of ('a generic_property * 'a generic_property) (* and *)
  | OR of ('a generic_property * 'a generic_property) (* or *)
  | NOT of 'a generic_property (* not *)

let rec map f property =
  match property with
  | Atomic (x, l) -> Atomic (f x, l)
  | X (p,e) -> X (p,(map f e))
  | F (p,e) -> F (p,(map f e))
  | G (p,e) -> G (p,(map f e))
  | U (p,e1, e2) -> U (p,map f e1, map f e2)
  | AND (e1, e2) -> AND (map f e1, map f e2)
  | OR (e1, e2) -> OR (map f e1, map f e2)
  | NOT e -> NOT (map f e)
