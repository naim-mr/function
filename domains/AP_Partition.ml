(***************************************************)
(*                                                 *)
(*   Ranking Function Numerical Domain Partition   *)
(*                                                 *)
(*                  Caterina Urban                 *)
(*     École Normale Supérieure, Paris, France     *)
(*                   2012 - 2015                   *)
(*                                                 *)
(***************************************************)

open Typed_syntax
open Apron
open Tast_to_texpr
open Sig.Constraints
open Sig.Ranking
open Sig.Domain
open AP_LinearConstraint

(** Single partition of the domain of a ranking function represented by an APRON
    numerical abstract domain. *)
module AP_Partition (N : AP_NUMERICAL) (C : AP_CONSTRAINT) : AP_PARTITION =
struct
  module C = C
  module N = N
  module BanalApron = Banal_apron_domain.ApronDomain (N)

  type env = C.env
  type dim = var

  type t = {
    constraints : C.t list; (* representation as list of constraints *)
    env : C.env; (* environements over which the constraints are defined *)
  }

  type apron_t = N.lib Abstract1.t
  (** An element of the numerical abstract domain. *)

  (** The current representation as list of linear constraints. *)
  let constraints t =
    List.fold_right
      (fun c cs ->
        (* warning: fold_left impacts speed and result of the analysis *)
        try
          (* equality constraints are turned into pairs of inequalities *)
          let c1, c2 = C.expand c in
          c1.cons :: c2.cons :: cs
        with Invalid_argument _ -> c.cons :: cs)
      t.constraints []

  let conjunction t =
    List.fold_right
      (fun c cs ->
        (* warning: fold_left impacts speed and result of the analysis *)
        try
          (* equality constraints are turned into pairs of inequalities *)
          let c1, c2 = C.expand c in
          c1 :: c2 :: cs
        with Invalid_argument _ -> c :: cs)
      t.constraints []

  let env t = t.env
  let set_env env t = { t with env }

  (** The current underlying APRON environment. *)
  let ap_env env = env.ap_env

  (** The current list of variables used by the constraints i.e bind in the
      APRON environment. *)
  let vars t = t.env.vars

  (** Creates an APRON manager depending on the numerical abstract domain. *)

  let manager = N.manager
  (**)

  (** Converts t into an apron_t *)
  let to_apron_t (t : t) : apron_t =
    let ap_env = env t |> ap_env in
    let a = Lincons1.array_make ap_env (List.length t.constraints) in
    let i = ref 0 in
    List.iter
      (fun (c : C.t) ->
        Lincons1.array_set a !i c.cons;
        i := !i + 1)
      t.constraints;
    Abstract1.of_lincons_array manager ap_env a

  (** Converts apront_t into t *)
  let of_apron_t env (a : apron_t) : t =
    let a = Abstract1.to_lincons_array manager a in
    let (cs : C.t list ref) = ref [] in
    for i = 0 to Lincons1.array_length a - 1 do
      cs := { cons = Lincons1.array_get a i; env } :: !cs
      (*TODO: normalization *)
    done;
    { constraints = !cs; env }

  (** Returns the bottom elements: a singleton of an unsat constraint*)

  let bot e = { constraints = [ C.make_unsat e ]; env = e }
  let inner e cs = { constraints = cs; env = e }

  (** Returns the top elements: an empty list <-> no constraints*)
  let top e = { constraints = []; env = e }

  let init_env () = C.init_env ()
  let remove_dim_of_env t dim = { t with env = C.remove_dim_of_env t.env dim }

  let dim_in_env t dim =
    vars t |> List.exists (fun v -> Z.compare v.var_id dim.var_id = 0)

  let print fmt b =
    let env = env b in
    let b = to_apron_t b in
    let a = Abstract1.to_lincons_array manager b in
    let cs = ref [] in
    for i = 0 to Lincons1.array_length a - 1 do
      cs := Lincons1.array_get a i :: !cs
    done;
    match !cs with
    | [] -> Format.fprintf fmt "top"
    | x :: _ ->
        if C.is_bot { cons = x; env } then Format.fprintf fmt "bottom"
        else
          let i = ref 1 and l = List.length !cs in
          List.iter
            (fun c ->
              C.print fmt { cons = c; env };
              if !i = l then () else Format.fprintf fmt " && ";
              i := !i + 1)
            !cs

  let add_dim_to_env t dim = { t with env = C.add_dim_to_env t.env dim }
  (**)

  let lift1_apron op b = to_apron_t b |> op manager
  let is_bot = lift1_apron Abstract1.is_bottom

  let is_leq kind b1 b2 =
    let b1 = to_apron_t b1 in
    let b2 = to_apron_t b2 in
    Abstract1.is_leq manager b1 b2

  (**)

  let assume ?(pow = 5.) b = (b, b)

  let lift2_apron op b1 b2 =
    let env = env b1 in
    let b1 = to_apron_t b1 in
    let b2 = to_apron_t b2 in
    let b = op manager b1 b2 in
    of_apron_t env b

  let join kind = lift2_apron Abstract1.join
  let widen ?(jokers = 2) = lift2_apron Abstract1.widening
  let meet kind = lift2_apron Abstract1.meet

  (**)

  let add_var_to_env =
   fun env id ->
    { env with ap_env = Environment.add env.ap_env [| Var.of_string id |] [||] }

  let mem_var env id = Environment.mem_var env.ap_env (Var.of_string id)

  let remove_var_of_env =
   fun env id ->
    { env with ap_env = Environment.remove env.ap_env [| Var.of_string id |] }

  let fwd_assign b ((x, t, ext), e) =
    match x with
    | T_var x when String.starts_with ~prefix:"nondet_" x.var_name -> b
    | T_var x ->
        let env = env b in
        let ap_env = ap_env env in
        let e = Texpr1.of_expr ap_env (exp_to_apron e) in
        let b =
          Abstract1.assign_texpr manager (to_apron_t b) (apron_of_var x) e None
        in
        of_apron_t env b
    | _ -> raise (Invalid_argument "fwd_assign: unexpected lvalue")

  let ubwd_assign (t : t) ((x, typ, ext), e) =
    match x with
    | T_var x ->
        if not N.supports_underapproximation then
          raise
            (Invalid_argument
               "Underapproximation not supported by this abstract domain, use \
                polyhedra instead");
        let env = env t in
        let at = to_apron_t t in
        let top = Abstract1.top manager (Abstract1.env at) in
        let pre = top in
        (* use top as pre environment *)
        let assigned = BanalApron.bwd_assign at () (STRONG x) e pre in
        of_apron_t env assigned
    | _ -> raise (Invalid_argument "ubwd_assign: unexpected lvalue")

  let bwd_assign b (lv, e) =
    let (x, t, ext) : expr typed = lv in
    match x with
    | T_var x ->
        let f manager b (x, e) : t =
          let env = env b in
          let ap_env = ap_env env in
          let e = Texpr1.of_expr ap_env (exp_to_apron e) in
          let b =
            Abstract1.substitute_texpr manager (to_apron_t b) (apron_of_var x) e
              None
          in
          of_apron_t env b
        in
        (* if !Config.resilience && !Config.domain = "polyhedra" then
          let b1 = f manager b (x, e) in
          let man: lib Manager.t = N.of () in 
          let b2 = f man b (x, e) in
          { b1 with constraints = b1.constraints @ b2.constraints; env } 
          raise (Invalid_argument "resilience need to use boxes to complete") *)
       f manager b (x, e)
    | _ -> raise (Invalid_argument "bwd_assign: unexpected lvalue")

  let ubwd_filter (t : t) (e : expr typed) : t =
    if not N.supports_underapproximation then
      raise
        (Invalid_argument
           "Underapproximation not supported by this abstract domain, use \
            octagons or polyhedra instead");
    let env = env t in
    let at = to_apron_t t in
    let top = Abstract1.top manager (Abstract1.env at) in
    let bot = Abstract1.bottom manager (Abstract1.env at) in
    let pre = top in
    (* use top as pre environment *)
    let filtered = BanalApron.bwd_filter at bot () e () pre in
    of_apron_t env filtered

  let fwd_filter b (e, t, ext) =
    let rec f manager b (e, t, ext) =
      match e with
      | T_bool_const True -> b
      | T_bool_const Maybe -> b
      | T_bool_const False -> bot (env b)
      | T_binary (op, (T_var v, _, _), e2)
        when String.starts_with ~prefix:"nondet_" v.var_name ->
          f manager b (T_binary (op, e2, (T_bool_const Maybe, t, ext)), t, ext)
      | T_binary (op, e1, (T_var v, _, ext))
        when String.starts_with ~prefix:"nondet_" v.var_name ->
          f manager b (T_binary (op, e1, (T_bool_const Maybe, t, ext)), t, ext)
      | T_int_const _ | T_var _ ->
          let env = env b in
          let ap_env = ap_env env in
          let e = exp_to_apron (e, t, ext) in
          let e1 = Texpr1.of_expr ap_env e in
          let b = to_apron_t b in
          let c1 = Tcons1.make e1 Tcons1.SUPEQ in
          let eneg =
            Texpr1.of_expr ap_env
              (Texpr1.Unop (Texpr1.Neg, e, Texpr1.Int, Texpr1.Zero))
          in
          let c2 = Tcons1.make eneg Tcons1.SUPEQ in
          let a = Tcons1.array_make ap_env 2 in
          Tcons1.array_set a 0 c1;
          Tcons1.array_set a 1 c2;
          Abstract1.meet_tcons_array manager b a |> of_apron_t env
      | T_unary (A_cast (t, _), e) -> f manager b e
      | T_unary (A_NOT, e) -> neg_bexp e |> f manager b
      | T_unary (A_UNARY_PLUS, e) -> f manager b e
      | T_unary (A_UNARY_MINUS, e) ->
          let env = env b in
          let ap_env = ap_env env in
          let e = exp_to_apron e in
          let b = to_apron_t b in
          let eneg =
            Texpr1.of_expr ap_env
              (Texpr1.Unop (Texpr1.Neg, e, Texpr1.Int, Texpr1.Zero))
          in
          let c = Tcons1.make eneg Tcons1.SUPEQ in
          let a = Tcons1.array_make ap_env 1 in
          Tcons1.array_set a 0 c;
          Abstract1.meet_tcons_array manager b a |> of_apron_t env
      | T_binary (o, e1, e2) -> (
          match o with
          | A_MODULO -> top (env b)
          | A_AND ->
              let b1 = f manager b e1 and b2 = f manager b e2 in
              meet APPROXIMATION b1 b2
          | A_OR ->
              let b1 = f manager b e1 and b2 = f manager b e2 in
              join APPROXIMATION b1 b2
          | A_EQUAL ->
              let bop =
                T_binary
                  ( A_AND,
                    (T_binary (A_GREATER_EQUAL, e1, e2), t, ext),
                    (T_binary (A_GREATER_EQUAL, e2, e1), t, ext) )
              in
              f manager b (bop, t, ext)
          | A_NOT_EQUAL ->
              let bop =
                T_binary
                  ( A_OR,
                    (T_binary (A_GREATER, e1, e2), t, ext),
                    (T_binary (A_LESS, e1, e2), t, ext) )
              in
              f manager b (bop, t, ext)
          | o -> (
              let env = env b in
              let ap_env = ap_env env in
              let b = to_apron_t b in
              match o with
              | A_LESS ->
                  let e =
                    Texpr1.of_expr ap_env
                      (exp_to_apron (T_binary (A_MINUS, e2, e1), t, ext))
                  in
                  let c = Tcons1.make e Tcons1.SUP in
                  let a = Tcons1.array_make ap_env 1 in
                  Tcons1.array_set a 0 c;
                  Abstract1.meet_tcons_array manager b a |> of_apron_t env
              | A_LESS_EQUAL ->
                  let e =
                    Texpr1.of_expr ap_env
                      (exp_to_apron (T_binary (A_MINUS, e2, e1), t, ext))
                  in
                  let c = Tcons1.make e Tcons1.SUPEQ in
                  let a = Tcons1.array_make ap_env 1 in
                  Tcons1.array_set a 0 c;
                  Abstract1.meet_tcons_array manager b a |> of_apron_t env
              | A_GREATER ->
                  let e =
                    Texpr1.of_expr ap_env
                      (exp_to_apron (T_binary (A_MINUS, e1, e2), t, ext))
                  in
                  let c = Tcons1.make e Tcons1.SUP in
                  let a = Tcons1.array_make ap_env 1 in
                  Tcons1.array_set a 0 c;
                  Abstract1.meet_tcons_array manager b a |> of_apron_t env
              | A_GREATER_EQUAL ->
                  let e =
                    Texpr1.of_expr ap_env
                      (exp_to_apron (T_binary (A_MINUS, e1, e2), t, ext))
                  in
                  let c = Tcons1.make e Tcons1.SUPEQ in
                  let a = Tcons1.array_make ap_env 1 in
                  Tcons1.array_set a 0 c;
                  Abstract1.meet_tcons_array manager b a |> of_apron_t env
              | _ -> raise (Invalid_argument "Filter only boolean expression")))
      | _ -> raise (Invalid_argument "Unsupported float")
    in
    let b1 = f manager b (e, t, ext) in
    if !Config.resilience && !Config.domain = "polyhedra" then
      (* raise (Invalid_argument "resilience need to use boxes to complete") *)
      b1
    else b1

  (**)
end

module AP_Box : AP_NUMERICAL = struct
  type lib = Box.t

  let manager = Box.manager_alloc ()
  let supports_underapproximation = false
end

module AP_Oct : AP_NUMERICAL = struct
  type lib = Oct.t

  let manager = Oct.manager_alloc ()
  let supports_underapproximation = false
end

module AP_Poly : AP_NUMERICAL = struct
  type lib = Polka.loose Polka.t

  let manager = Polka.manager_alloc_loose ()
  let supports_underapproximation = true
end

module B = AP_Partition (AP_Box) (AP_LinearConstraint)
(** Single partition of the domain of a ranking function represented by the
    boxes numerical abstract domain. *)

module O = AP_Partition (AP_Oct) (AP_LinearConstraint)
(** Single partition of the domain of a ranking function represented by the
    octagons abstract domain. *)

module P = AP_Partition (AP_Poly) (AP_LinearConstraint)
(** Single partition of the domain of a ranking function represented by the
    polyhedra abstract domain. *)
