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
		| INT ID '[' NUM ']' ';'{ 	if($4->TYPE != T_INT)
						{
							printf("Type error in integer array declaration.\n");
							exit(0);
						}
						Ginstall($2->NAME, T_INTARR, sizeof(int)*$4->VALUE); 
					}
		| BOOL ID '[' NUM ']' ';'{ 	if($4->TYPE != T_INT)
						{
							printf("Type error in bool array declaration.\n");
							exit(0);
						}
						Ginstall($2->NAME, T_BOOLARR, sizeof(int)*$4->VALUE); 
					}
		;

mainBody : BEGN slist END 	{ evaluate($2); exit(0); }
	     ;
slist 	: slist stmt		{ 	if($1->TYPE != VOID || $2->TYPE != VOID)
       					{
						printf("type error");
						exit(0);
					}
       				  	$$ = TreeCreate(VOID, STATEMENT, NULL, 0, NULL, $1, $2, NULL); 
				}
	| stmt			{ 	if($1->TYPE != VOID)
       					{
						printf("type error");
						exit(0);
					}
					$$ = $1; 
				}
     	;


expr	: expr PLUS expr	{ 	if($1->TYPE != T_INT || $3->TYPE != T_INT)
       					{
						printf("type error: +");
						exit(0);
					}

     					$$ = makeBinaryOperatorNode(PLUS, $1, $3, T_INT); 
     				}
     	| expr MUL expr		{ 	if($1->TYPE != T_INT || $3->TYPE != T_INT)
       					{
						printf("type error: *");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(MUL, $1, $3, T_INT); 
				}
     	| expr EQ expr		{ 	if($1->TYPE != T_INT || $3->TYPE != T_INT)
       					{
						printf("type error: eq");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(EQ, $1, $3, T_BOOL); 
				}
     	| expr LT expr		{ 	if($1->TYPE != T_INT || $3->TYPE != T_INT)
       					{
						printf("type error: lt");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(LT, $2, $3, T_BOOL); 
				}
     	| expr GT expr		{ 	if($1->TYPE != T_INT || $3->TYPE != T_INT)
					{
						printf("type error: gt");
						exit(0);
					}	
					$$ = makeBinaryOperatorNode(GT, $1, $3, T_BOOL); 
				}
	| '(' expr ')'		{ $$ = $2; }
	| NUM			{ $$ = $1; }
	| BOOLEAN 		{ $$ = $1; }
	| ID '[' expr ']'	{ 	if($3->TYPE != T_INT)
       					{
						printf("type error: [expr]");
						exit(0);
					}
					if(Glookup($1->NAME)->TYPE == T_INTARR)
					{
						$$ = makeBinaryOperatorNode(ARROP, $1, $4, T_INT); 
					}
					else if(Glookup($1->NAME)->TYPE == T_BOOLARR)
					{
						$$ = makeBinaryOperatorNode(ARROP, $1, $4, T_BOOL); 
					}
					else
					{
						printf("Type error: [] on non array");
						exit(0);
					}
				}
	| ID			{	$1->TYPE = Glookup($1->NAME)->TYPE;
				  	$$ = $1;
				}

stmt 	: ID ASGN expr ';'	{ 
      					if(Glookup($1->NAME)->TYPE != $3->TYPE)
       					{
						printf("type error: ASSG");
						exit(0);
					}
				
      				  	$$ = TreeCreate(VOID, ASGN, $1->NAME, 0, NULL, $3, NULL, NULL);
				}
stmt 	: ID '[' expr ']' ASGN expr ';'	{	if(Glookup($1->NAME)->TYPE != T_INTARR || $3->TYPE != T_INT || $6->TYPE != T_INT)
						if(Glookup($1->NAME)->TYPE != T_BOOLARR || $3->TYPE != T_INT || $6->TYPE != T_BOOL)
       						{
							printf("type error: []=");
							exit(0);
						}
						if($3->TYPE != T_INT)
       						{
							printf("type error: asgnarr[expr]");
							exit(0);
						}

      				 	 	$$ = TreeCreate(VOID, ASGNARR, $1->NAME, 0, NULL, $3, $6, NULL);
					}
	| READ '(' ID ')' ';' 	{ 
				  $$ = TreeCreate(VOID, READ, $3->NAME, 0, NULL, NULL, NULL, NULL);
				}
	| READ '(' ID '[' expr ']' ')' ';' 	{ 
							if($5->TYPE != T_INT)
       							{
								printf("type error: readarr[expr]");
								exit(0);
							}
							if(Glookup($3->NAME)->TYPE != T_INTARR && Glookup($3->NAME)->TYPE != T_BOOLARR)
       							{
								printf("type error: READARR");
								exit(0);
							}
					 	 	$$ = TreeCreate(VOID, READARR, $3->NAME, 0, NULL, $5, NULL, NULL);
						}
     	| WRITE '(' expr ')' ';'{ $$ = TreeCreate(VOID, WRITE, NULL, 0, NULL, $3, NULL, NULL);
				}
	| IF '(' expr ')' THEN slist ENDIF ';'
				{
      					if($3->TYPE != T_BOOL)
       					{
						printf("type error: IF(GUARD)");
						exit(0);
					}   
      					if($6->TYPE != VOID)
       					{
						printf("type error: IF(THEN)");
						exit(0);
					}   
					
				  $$ = TreeCreate(VOID, IF, NULL, 0, NULL, $3, $6, NULL);
				}
	| IF '(' expr ')' THEN slist ELSE slist ENDIF ';'
				{
      					if($3->TYPE != T_BOOL)
       					{
						printf("type error: IF(GUARD)");
						exit(0);
					}   
      					if($6->TYPE != VOID)
       					{
						printf("type error: IF(THEN)");
						exit(0);
					}   
      					if($8->TYPE != VOID)
       					{
						printf("type error: IF(ELSE)");
						exit(0);
					}   
				  $$ = TreeCreate(VOID, IF, NULL, 0, NULL, $3, $6, $8);
				}
	| WHILE '(' expr ')' DO slist ENDWHILE ';'
				{
      					if($3->TYPE != T_BOOL)
       					{
						printf("type error: WHILE(GUARD)");
						exit(0);
					}   
      					if($6->TYPE != VOID)
       					{
						printf("type error: WHILE(DO)");
						exit(0);
					}   
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
