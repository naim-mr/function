open Typed_syntax
open Apron
open Sig.Ranking
open Utils.Datatypes

module type ENVINIT = sig
  type env

  val env : Typed_syntax.prog -> env * var list
end

module Make (B : PARTITION) : ENVINIT = struct
  type env = B.env

  let rec initStat s (env, vars) =
    match s with
    | T_add_var (v, _) when not @@ B.mem_var env (Z.to_string v.var_id) ->
        (B.add_var_to_env env (Z.to_string v.var_id), v :: vars)
    | T_assign ((v, _), _) when not @@ B.mem_var env (Z.to_string v.var_id) ->
        (B.add_var_to_env env (Z.to_string v.var_id), v :: vars)
    | T_if (b, s1, s2) ->
        let env, vars = initBlock s1 (env, vars) in
        initBlock s2 (env, vars)
    | T_while ((l, _), b, s) -> initBlock s (env, vars)
    | T_call (f, ss) when not @@ B.mem_var env (Z.to_string f.func_id) ->
        initBlock f.func_body (env, vars)
    | _ -> (env, vars)

  and initBlock block (env, vars) =
    match block with
    | T_empty (l, _) -> (env, vars)
    | T_stat ((l, _), (s, _), b) ->
        let env, vars = initStat s (env, vars) in
        initBlock b (env, vars)

  let rec initEnv xs env =
    match xs with
    | [] -> env
    | x :: xs ->
        if B.mem_var env (Z.to_string x.var_id) then initEnv xs env
        else initEnv xs (B.add_var_to_env env (Z.to_string x.var_id))

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
    let env = B.init v1 |> B.env in
    let env, vars = initBlock block (env, v1) |> initBlock f.func_body in
    (initEnv v1 env, vars)
end
