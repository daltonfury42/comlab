%{
	#define YYSTYPE struct Tnode*
	#include "exptree.h"
	#include <stdlib.h>
	#include <stdio.h>	
	int *var[26];
%}

%token NUM ID READ WRITE ASGN NEWLINE IF THEN ELSE ENDIF WHILE DO ENDWHILE LT GT EQ
%nonassoc LT GT EQ
%left PLUS
%left MUL 
%%
Program : slist NEWLINE { evaluate($1); exit(0);}
	     ;
slist 	: slist stmt		{
      				  $$ = TreeCreate(VOID, STATEMENT, NULL, 0, NULL, $1, $2, NULL);
				}
	| stmt			{ $$ = $1; }
     	;


expr	: expr PLUS expr	{ $$ = makeBinaryOperatorNode(PLUS, $1, $3); }
     	| expr MUL expr		{ $$ = makeBinaryOperatorNode(MUL, $1, $3); }
     	| expr EQ expr		{ $$ = makeBinaryOperatorNode(EQ, $1, $3); }
     	| expr LT expr		{ $$ = makeBinaryOperatorNode(LT, $1, $3); }
     	| expr GT expr		{ $$ = makeBinaryOperatorNode(GT, $1, $3); }
	| '(' expr ')'		{ $$ = $2; }
	| NUM			{ $$ = $1; }
	| ID			{
				  $$ = $1;
				}

stmt 	: ID ASGN expr ';'	{ 
      				  $$ = TreeCreate(VOID, ASGN, $1->NAME, 0, NULL, $3, NULL, NULL);
				}
	| READ '(' ID ')' ';' 	{ 
				  $$ = TreeCreate(VOID, READ, $3->NAME, 0, NULL, NULL, NULL, NULL);
				}
     	| WRITE '(' expr ')' ';'{ $$ = TreeCreate(VOID, WRITE, NULL, 0, NULL, $3, NULL, NULL);
				}
	| IF '(' expr ')' THEN slist ENDIF ';'
				{
				  $$ = TreeCreate(VOID, IF, NULL, 0, NULL, $3, $6, NULL);
				}
	| IF '(' expr ')' THEN slist ELSE slist ENDIF ';'
				{
				  $$ = TreeCreate(VOID, IF, NULL, 0, NULL, $3, $6, $8);
				}
	| WHILE '(' expr ')' DO slist ENDWHILE ';'
				{
				  $$ = TreeCreate(VOID, WHILE, NULL, 0, NULL, $3, $6, NULL);
				}
     	;


	

%%

int yyerror(char const *s)
{
	printf("yyerror %s", s);
}

int main()
{
	yyparse();
	return 1;
}
