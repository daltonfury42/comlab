%{
	#define YYSTYPE struct Tnode*
	#include "exptree.h"
	#include "symbolTable.h"
	#include <stdlib.h>
	#include <stdio.h>	
	extern FILE* yyin;
%}

%token NUM ID READ WRITE ASGN NEWLINE IF THEN ELSE ENDIF WHILE DO ENDWHILE LT GT EQ BEGN END BREAK CONTINUE INT DECL ENDDECL
%nonassoc LT GT EQ
%left PLUS
%left MUL 
%%
Program		: globalDecl mainBody	{}
	 	| mainBody 		{}
		;

globalDecl	: DECL declList ENDDECL	{}


declList	: decl declList		{}
	 	| decl			{}
		;

decl 		: INT ID ';'		{
       					  Ginstall($2->NAME, NUM, sizeof(int));
					}

mainBody : BEGN slist END 	{ evaluate($2); exit(0); }
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
	| BREAK ';'		{
				  $$ = TreeCreate(VOID, BREAK, NULL, 0, NULL, NULL, NULL, NULL);
				}
	| CONTINUE ';'		{
				  $$ = TreeCreate(VOID, CONTINUE, NULL, 0, NULL, NULL, NULL, NULL);
				}
     	;


	

%%

int yyerror(char const *s)
{
	printf("yyerror %s", s);
}

int main(int argc, char** argv)
{
	yyin = fopen(argv[1], "r");
	yyparse();
	return 1;
}
