%{
open ATLProperty

let label_name l = String.sub l 0 (String.length l - 1)

%}

%token <string> ATOMIC
%token <string list> COALITION
%token <string> LABEL
%token X
%token F
%token G
%token U
%token IMPLY
%token AND
%token OR
%token NOT

%token NP
%token LEFT_BRACE
%token RIGHT_BRACE

%start <string ATLProperty.generic_property> prog
%%

player: 
  | c=COALITION  { c }
;
prog:
  | e = ATOMIC { Atomic (e, None) }
  | l = LABEL; e = ATOMIC { Atomic (e, Some (label_name l)) }
  | p=player; X; LEFT_BRACE; e = prog; RIGHT_BRACE {X (p,e)}
  | p=player; F; LEFT_BRACE; e = prog; RIGHT_BRACE {F (p,e)}
  | p=player; G; LEFT_BRACE; e = prog; RIGHT_BRACE {G (p,e)}
  | p=player; U; LEFT_BRACE; e1 = prog; RIGHT_BRACE; LEFT_BRACE; e2 = prog; RIGHT_BRACE; { U (p,e1, e2) }
  | AND; LEFT_BRACE; e1 = prog; RIGHT_BRACE; LEFT_BRACE; e2 = prog; RIGHT_BRACE; { AND (e1, e2) }
  | OR; LEFT_BRACE; e1 = prog; RIGHT_BRACE; LEFT_BRACE; e2 = prog; RIGHT_BRACE; { OR (e1, e2) }
  | NOT; LEFT_BRACE; e = prog; RIGHT_BRACE; { NOT e}
  

