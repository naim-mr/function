open InvMap
open Semantics
open AbstractSyntax
open Domain
open DecisionTree
open Apron
open ForwardIterator
open Partition
open Config



module type CDA_ITERATOR = 
sig 
  val  analyze : ?precondition:bExp option -> ?property: 'a Semantics.p-> func StringMap.t  -> var StringMap.t  -> block -> string -> bool
end 


module Make (S:SEMANTIC) : 
sig 
  include CDA_ITERATOR
end = 
struct
  module D = S.D
  module B = S.B

  let fwdMap_print fmt m = InvMap.iter (fun l a -> Format.fprintf fmt "%a: %a\n" label_print l B.print a) m
  module ForwardIteratorB = ForwardIterator(B)
  
  let bwdMap_print fmt m =
    if !Config.compress then
      InvMap.iter (fun l a -> Format.fprintf fmt "%a:\n%a\n" label_print l D.print (D.compress a)) m
    else
      InvMap.iter (fun l a -> Format.fprintf fmt "%a:\n%a\n" label_print l D.print a) m
  
  let rec analyze ?(precondition=Some A_TRUE) ?(property= S.dummy_prop) funcs vars stmts  main= 
    (* f =  main function *)
    let f = StringMap.find main funcs in
    (* We collect the vars defined in the program and by the function *)
    let v1 = snd (List.split (StringMap.bindings vars)) in
    let v2 = snd (List.split (StringMap.bindings f.funcVars)) in
    let vars = List.append v1 v2 in
    let rec init_env xs env = match xs with
    | [] -> env
    | x::xs -> 
      init_env xs (Environment.add env [|(Var.of_string x.varId)|] [||])
    in
    
    (* Apron env initalized for every variable *)
    let env = init_env vars (Environment.make [||] [||]) in 
    let s = f.funcBody in
    AbstractSyntax.block_print "main" !fmt s;
    S.fwdTaintMap := fst (ForwardIteratorB.fwdTBlk  funcs env vars [] s) ;
    Format.fprintf !fmt "\nForward Analysis taint: size %d\n" (InvMap.cardinal !S.fwdTaintMap);
          InvMap.iter (fun l a -> 
            Format.printf "%a: %s\n" label_print l (List.fold_left (fun  acc x -> acc^" "^x.varName) "" a)) !S.fwdTaintMap;
    (* Conflict driven analysis result *)
    let i = cda_recursive  ~property:property funcs env vars  stmts main  f in
    
    let block_label block = 
    match block with
      | A_empty l -> l
      | A_block (l,_,_) -> l
    in
    if not !minimal then
      Format.fprintf !fmt "\n Conflict Driven Analysis Result: %a@." D.print
        i ;
    let ret = D.defined ~condition:(Option.get precondition) i in
    Format.fprintf !fmt "Final Analysis Result: ";
    let result = if ret then "TRUE" else "UNKNOWN" in
    Format.fprintf !fmt "%s\n" result;
    S.bwdInvMap:= InvMap.update (block_label f.funcBody) (fun _ -> Some i) !S.bwdInvMap;
    ret
  and cda_recursive  ?(property = S.dummy_prop) funcs  env vars  stmts  main f =
    let open S in   
    let s = f.funcBody in
    let compress () =
      S.bwdInvMap := InvMap.map (fun a -> D.compress a) !S.bwdInvMap
    in
    let reinit () =
      S.bwdInvMap := InvMap.map (fun a -> D.reinit a) !S.bwdInvMap
    in
    let rec aux b p n =
      (* Forward Analysis *)
      if !tracefwd && not !minimal then
        Format.fprintf !fmt "\nForward Analysis[%i] Trace:\n" n ;
      let startfwd = Sys.time () in
      (* Compute the forward analysis starting from the environment b (top at the begining) *)
      S.fwdInvMap := ForwardIteratorB.compute   (vars,stmts,funcs)  b main env;
      
      
       (* fwdBlk funcs env vars (fwdBlk funcs env vars b stmts) s in *)
      let stopfwd = Sys.time () in
      if not !minimal then (
        if !timefwd then
          Format.fprintf !fmt "\nForward Analysis[%i] (Time: %f s):\n" n
            (stopfwd -. startfwd)
        else Format.fprintf !fmt "\nForward Analysis[%i]:\n" n ;
         fwdMap_print !fmt !S.fwdInvMap ) ; 
      (* Backward Analysis *)
      if !tracebwd && not !minimal then
        Format.fprintf !fmt "\nBackward Analysis[%i] Trace:\n" n ;
      start := Sys.time () ;
      let startbwd = Sys.time () in      
      (* 
          Compute the backward analysis for the given Semantic. 
          Refine option is always activated for cda 
      *)
      let tree0 =  if !analysis = "termination" then D.zero env vars else (D.bot env vars)
      in
      let i =
        bwdRec ~property:property funcs env vars
          (bwdRec  ~property:property funcs env vars tree0 s)
          stmts
      in
      let stopbwd = Sys.time () in
      if not !minimal then (
        if !timebwd then
          Format.fprintf !fmt "\nBackward Analysis[%i] (Time: %f s):\n" n
            (stopbwd -. startbwd)
        else Format.fprintf !fmt "\nBackward Analysis[%i]:\n" n ;
        bwdMap_print !fmt !S.bwdInvMap ) ;
      if not !minimal then
        if D.defined i then
          Format.fprintf !fmt "Analysis[%i] Result: TRUE\n" n
        else Format.fprintf !fmt "Analysis[%i] Result: UNKNOWN\n" n ;
      if D.defined i || n > !size then
        (* 
          Return if we can already infer the property or if the maximum number of
          iteration is reached 
        *)
         D.learn p (D.compress i)
      else (
        learn := true ;
        (* 
          Cumulate the constraints along the path to an undefined piece of
          the ranking function i.e. the conflicts
        *)
        let bs = D.conflict i in
        if not !minimal then (
          Format.fprintf !fmt "CONFLICTS: { " ;
          List.iter (fun b -> Format.fprintf !fmt "%a; " B.print b) bs ;
          Format.fprintf !fmt "}\n" ) ;
        let i =
          List.fold_left
            (fun (ai:D.t) (ab:B.t) ->
              (* 
                [ai] is a tree,
                [ab] is a contraint toward an undefined leaf the tree
              *)
              if
                B.isLeq b ab
                (* If the current domain [b] from which we start is smaller that the one define by the constraint [ab]
                   we need to split [ab]. 
                   Needed to divide the domain if after one iteration we cannot infer the property
                *)
              then (
                (*
                  [b1] \cup [b2] == ab
                *)
                
                let b1, b2 = B.assume ~pow:(float_of_int n) ab  in
                (* We reinit the leaf that are at top *)
                assert (B.isLeq ab (B.join b1 b2 ));
                assert (B.isLeq (B.join b1 b2 ) ab);
                assert (not (B.isBot b1));
                assert (not (B.isBot b2));
                reinit () ;
                compress () ;
                if not !minimal then
                  Format.fprintf !fmt "\nASSUME-1: %a\n" B.print b1 ;
                (* restart with b1 *)
                let i = aux b1 ai (n + 1) in
                reinit () ;
                compress () ;
                if not !minimal then
                  Format.fprintf !fmt "\nASSUME-2: %a\n" B.print b2 ;
                (* continue with b2*)
                aux b2 i (n + 1) )
              else (
                reinit () ;
                compress () ;
                if not !minimal then
                  Format.fprintf !fmt "\nASSUME: %a\n" B.print ab ;
                aux ab ai (n + 1) ) )
            i bs
        in
        (* We learn from the cda analysis new part of the domain where the property of interest holds *)
        D.learn p (D.compress i) )
    in
   (* We start from the numerical domain top and decision tree bot *)
   (aux (B.top env vars) (D.bot env vars) 1)


end