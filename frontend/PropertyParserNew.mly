(*   
            ********* Menhir Property Parser ************
   Copyright (C) 2012-2014 by Caterina Urban. All rights reserved.
*)

%{
open Typed_syntax
open Utils
open Abstract_syntax
open CTLProperty
%}

%token TOK_FALSE;
%token TOK_TRUE;

%token <string> TOK_id

%token TOK_LPAREN;
%token TOK_RPAREN;
%token TOK_LBRACKET;
%token TOK_RBRACKET;
%token TOK_COMMA;
%token TOK_COLON;
%token TOK_AND;
%token TOK_OR;
%token TOK_NOT;
%token TOK_LESS;
%token TOK_LESS_EQUAL;
%token TOK_EQUAL_EQUAL;
%token TOK_NOT_EQUAL;
%token TOK_GREATER;
%token TOK_GREATER_EQUAL;
%token TOK_PLUS;
%token TOK_MINUS;
%token TOK_MULTIPLY;
%token TOK_DIVIDE;
%token TOK_MODULO;

%token <string> TOK_const

%token TOK_EOF

%start <Typed_syntax.expr typed> file

%%

file: t = exp TOK_EOF {  t }

exp:
	| e = annotate(logical_or_exp)						{ e }
	| l = TOK_id TOK_COLON e = annotate(logical_or_exp)	{ e }

logical_or_exp:
	| e = logical_and_exp													{ e }
	| e1 = annotate(logical_or_exp) TOK_OR e2 = annotate(logical_and_exp)	{ T_binary (A_OR,e1,e2) }

logical_and_exp:
	| e = equality_exp														{ e }
	| e1 = annotate(logical_and_exp) TOK_AND e2 = annotate(equality_exp)	{ T_binary  (A_AND,e1,e2) }

equality_exp:
	| e = relational_exp															{ e }
	| e1 = annotate(equality_exp) TOK_EQUAL_EQUAL e2 = annotate(relational_exp)		{ T_binary  (A_EQUAL,e1,e2) }
	| e1 = annotate(equality_exp) TOK_NOT_EQUAL e2 = annotate(relational_exp)		{ T_binary  (A_NOT_EQUAL,e1,e2) }

relational_exp:
	| e = add_exp																{ e }
	| e1 = annotate(relational_exp) TOK_LESS e2 = annotate(add_exp)				{ T_binary  (A_LESS,e1,e2) }
	| e1 = annotate(relational_exp) TOK_LESS_EQUAL e2 = annotate(add_exp)		{ T_binary  (A_LESS_EQUAL,e1,e2) }
	| e1 = annotate(relational_exp) TOK_GREATER e2 = annotate(add_exp)			{ T_binary  (A_GREATER,e1,e2) }
	| e1 = annotate(relational_exp) TOK_GREATER_EQUAL e2 = annotate(add_exp)	{ T_binary  (A_GREATER_EQUAL,e1,e2) }

add_exp:
	| e = mul_exp												{ e }
	| e1 = annotate(add_exp) TOK_PLUS e2 = annotate(mul_exp)	{ T_binary  (A_PLUS,e1,e2) }
	| e1 = annotate(add_exp) TOK_MINUS e2 = annotate(mul_exp)	{ T_binary  (A_MINUS,e1,e2) }

mul_exp:
	| e = unary_exp													{ e }
	| e1 = annotate(mul_exp) TOK_MULTIPLY e2 = annotate(unary_exp)	{ T_binary  (A_MULTIPLY,e1,e2) }
	| e1 = annotate(mul_exp) TOK_DIVIDE e2 = annotate(unary_exp)	{ T_binary  (A_DIVIDE,e1,e2) }
	| e1 = annotate(mul_exp) TOK_MODULO e2 = annotate(unary_exp)	{ T_binary  (A_MODULO,e1,e2) }

unary_exp:
	| e = primary_exp							{ e }
	| TOK_NOT e = annotate(unary_exp)			{ T_unary (A_NOT,e) }
	| o = unary_op e = annotate(unary_exp)		{ T_unary (o,e) }

unary_op:
	| TOK_PLUS	{ A_UNARY_PLUS }
	| TOK_MINUS	{ A_UNARY_MINUS }

primary_exp:
	| TOK_TRUE																										{ T_bool_const True }
	| TOK_FALSE																										{ T_bool_const False }
	| e = TOK_id 													                                                { T_var { var_name = e; var_extent = ($startpos,$endpos); var_typ = A_BOOL; var_id = Z.zero; var_synthetic = true; var_scope = T_GLOBAL} }   	
	| e = TOK_const																									{ T_int_const (Intinf.of_string e,Intinf.of_string e) }
	| TOK_LBRACKET e1 = TOK_const TOK_COMMA e2 = TOK_const TOK_RBRACKET												{ T_int_const (Intinf.of_string e1,Intinf.of_string e2) }
	| TOK_LPAREN e = logical_or_exp TOK_RPAREN																		{ e }

annotate(X): 
	| x = X  { x, Abstract_syntax.A_BOOL, ($startpos, $endpos) }

%%
