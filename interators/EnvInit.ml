open Typed_syntax
open Apron
open Sig.Ranking
open Utils.Datatypes

module type ENVINIT = sig
  type env

  val env : Typed_syntax.prog -> env * var list
end

module Make (B : PARTITION) : ENVINIT with type env = B.env = struct
  type env = B.env

  let rec initStat s (t, vars) =
    match s with
    | T_add_var (v, _) when not @@ B.dim_in_env t v ->
        (B.add_dim_to_env t v, v :: vars)
    | T_assign (lval, rval) -> (
        match lval with
        | T_var v, typ, ext when not @@ B.dim_in_env t v ->
            (B.add_dim_to_env t v, v :: vars)
        | T_var v, typ, ext when B.dim_in_env t v ->
            Printf.printf "ici?\n";
            (t, vars)
        | T_deref (T_var v, typ, ext), _, _ ->
            let v =
              {
                v with
                var_name = Printf.sprintf "*%s" v.var_name;
                var_typ = Typed_syntax.deref_typ v.var_typ;
              }
            in
            if not @@ B.dim_in_env t v then (B.add_dim_to_env t v, v :: vars)
            else (t, vars)
        | _ -> failwith "nyi")
    | T_if (b, s1, s2) ->
        let t, vars = initBlock s1 (t, vars) in
        initBlock s2 (t, vars)
    | T_while ((l, _), b, s) -> initBlock s (t, vars)
    | T_call (f, ss) -> initBlock f.func_body (t, vars)
    | _ -> (t, vars)

  and initBlock block (t, vars) =
    match block with
    | T_empty (l, _) -> (t, vars)
    | T_stat ((l, _), (s, _), b) ->
        let t, vars = initStat s (t, vars) in
        initBlock b (t, vars)

  let rec initEnv xs t =
    match xs with
    | [] -> t
    | x :: xs ->
        if B.dim_in_env t x then initEnv xs t
        else initEnv xs (B.add_dim_to_env t x)

  let env (prog : Typed_syntax.prog) =
    let block, funcmap, varmap = prog in
    let f = StringMap.find !Config.main funcmap in
    let retvars =
      StringMap.bindings funcmap
      |> List.fold_left (fun acc (_, f) -> f.func_return :: acc) []
      |> List.fold_left
           (fun acc ret -> match ret with None -> acc | Some v -> v :: acc)
           []
    in
    let v1 = snd (List.split (IdMap.bindings varmap)) @ f.func_args @ retvars in
    let top = B.init_env () |> B.top in
    let top = List.fold_left (fun t v -> B.add_dim_to_env top v) top v1 in
    let top, vars = initBlock block (top, v1) |> initBlock f.func_body in
    (initEnv v1 top |> B.env, vars)
end
