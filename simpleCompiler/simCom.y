%{
	#define YYSTYPE struct Tnode*
	#include "exptree.h"
	#include "symbolTable.h"
	#include <stdlib.h>
	#include <stdio.h>	
	#include "constants.h"
	extern FILE* yyin;

	int yylex();
	int yyerror(const char*);
%}


%token ID READ WRITE ASGN NEWLINE IF THEN ELSE ENDIF WHILE DO ENDWHILE LT GT EQ BEGN END BREAK CONTINUE DECL ENDDECL 
%token BOOL INT
%token NUM BOOLEAN

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

decl 		: INT ID ';'		{ Ginstall($2->NAME, T_INT, sizeof(int)); }
		| BOOL ID ';'		{ Ginstall($2->NAME, T_BOOL, sizeof(int)); }
		| INT ID '[' NUM ']' ';'{ Ginstall($2->NAME, T_BOOL, sizeof(int)*$4->VALUE); }
		;

mainBody : BEGN slist END 	{ evaluate($2); exit(0); }
	     ;
slist 	: slist stmt		{ $$ = TreeCreate(VOID, STATEMENT, NULL, 0, NULL, $1, $2, NULL); }
	| stmt			{ $$ = $1; }
     	;


expr	: expr PLUS expr	{ $$ = makeBinaryOperatorNode(PLUS, $1, $3, T_INT); }
     	| expr MUL expr		{ $$ = makeBinaryOperatorNode(MUL, $1, $3, T_INT); }
     	| expr EQ expr		{ $$ = makeBinaryOperatorNode(EQ, $1, $3, T_BOOL); }
     	| expr LT expr		{ $$ = makeBinaryOperatorNode(LT, $1, $3, T_BOOL); }
     	| expr GT expr		{ $$ = makeBinaryOperatorNode(GT, $1, $3, T_BOOL); }
	| '(' expr ')'		{ $$ = $2; }
	| NUM			{ $$ = $1; }
	| BOOLEAN 		{ $$ = $1; }
	| ID '[' expr ']'	{ $$ = makeBinaryOperatorNode(ARROP, $1, $4, T_INT); }
	| ID			{
				  $$ = $1;
				}

stmt 	: ID ASGN expr ';'	{ 
      				  $$ = TreeCreate(VOID, ASGN, $1->NAME, 0, NULL, $3, NULL, NULL);
				}
stmt 	: ID '[' expr ']' ASGN expr ';'	{ 
      				  $$ = TreeCreate(VOID, ASGNARR, $1->NAME, 0, NULL, $3, $6, NULL);
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
