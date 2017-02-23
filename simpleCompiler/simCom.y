%{
	#define YYSTYPE struct Tnode*
	#include "exptree.h"
	#include "symbolTable.h"
	#include <stdlib.h>
	#include <stdio.h>	
	#include "constants.h"
	#include "codeGen.h"
	extern FILE* yyin;
	int vartype;

	int yylex();
	int yyerror(const char*);
%}


%token ID READ WRITE ASGN NEWLINE IF THEN ELSE ENDIF WHILE DO ENDWHILE LT GT EQ BEGN END BREAK CONTINUE DECL ENDDECL 
%token BOOL INT
%token NUM BOOLEAN

%nonassoc LT GT EQ
%left PLUS SUB
%left MUL DIV
%%
Program		: globalDecl mainBody	{}
	 	| mainBody 		{}
		;

globalDecl	: DECL declList ENDDECL	{}


declList	: decl declList		{}
	 	| decl			{}
		;

decl 		: type varlist ';'
		;

type		: INT			{ vartype = T_INT; }
		| BOOL 			{ vartype = T_BOOL; }
		;

varlist		: varlist ',' ID 		{ Ginstall($3->NAME, vartype, 1); }
		| ID 				{ Ginstall($1->NAME, vartype, 1); }
		| varlist ',' ID '[' NUM ']'	{ 	if($5->TYPE != T_INT)
							{
								printf("Type error in integer array declaration.\n");
								exit(0);
							}
							if(vartype == T_INT)
							{
								Ginstall($3->NAME, T_INTARR, $5->VALUE); 
							}
							else if(vartype == T_BOOL)
							{
								Ginstall($3->NAME, T_BOOLARR, $5->VALUE); 
							}
							else
							{
								printf("Type error(2) in integer array declaration.\n");
							}
						
				 		}
		| ID '[' NUM ']' 	{ 	if($3->TYPE != T_INT)
						{
							printf("Type error in integer array declaration.\n");
							exit(0);
						}
							if(vartype == T_INT)
							{
								Ginstall($1->NAME, T_INTARR, $3->VALUE); 
							}
							else if(vartype == T_BOOL)
							{
								Ginstall($1->NAME, T_BOOLARR, $3->VALUE); 
							}
							else
							{
								printf("Type error(3) in integer array declaration.\n");
							}
				 	}
		;

mainBody : BEGN slist END 	{ printHeader(); codeGen($2); printFooter(); exit(0); }
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
     	| expr SUB expr		{ 	if($1->TYPE != T_INT || $3->TYPE != T_INT)
       					{
						printf("type error: SUB");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(SUB, $1, $3, T_INT); 
				}
     	| expr DIV expr		{ 	if($1->TYPE != T_INT || $3->TYPE != T_INT)
       					{
						printf("type error: DIV");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(DIV, $1, $3, T_INT); 
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
	| ID			{	if(GLookup($1->NAME) == NULL)
					{
						printf("Unallocated variable %s.\n", $3->NAME);
						exit(0);
					}
					$1->TYPE = Glookup($1->NAME)->TYPE;
				  	$$ = $1;
				}

stmt 	: ID ASGN expr ';'	{ 	if(GLookup($1->NAME) == NULL)
					{
						printf("Unallocated variable %s.\n", $3->NAME);
						exit(0);
					}
      					if(Glookup($1->NAME)->TYPE != $3->TYPE)
       					{
						printf("type error: ASSG");
						exit(0);
					}
				
      				  	$$ = TreeCreate(VOID, ASGN, $1->NAME, 0, NULL, $3, NULL, NULL);
				}
stmt 	: ID '[' expr ']' ASGN expr ';'	{	if(GLookup($1->NAME) == NULL)
						{
							printf("Unallocated variable %s.\n", $3->NAME);
							exit(0);
						}
						if(Glookup($1->NAME)->TYPE != T_INTARR || $3->TYPE != T_INT || $6->TYPE != T_INT)
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
				  	if(GLookup($3->NAME) == NULL)
					{
						printf("Unallocated variable %s.\n", $3->NAME);
						exit(0);
					}
				 	$$ = TreeCreate(VOID, READ, $3->NAME, 0, NULL, NULL, NULL, NULL);
				}
	| READ '(' ID '[' expr ']' ')' ';' 	{ 
							if($5->TYPE != T_INT)
       							{
								printf("type error: readarr[expr]");
								exit(0);
							}
							if(Glookup($3->NAME) == NULL)
							{
								printf("Unallocated variable %s.\n", $3->NAME);
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
