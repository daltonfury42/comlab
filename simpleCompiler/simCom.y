%{
	#define YYSTYPE struct Tnode*
	#include "exptree.h"
	#include "symbolTable.h"
	#include <stdlib.h>
	#include <string.h>
	#include <stdio.h>	
	#include "constants.h"
	#include "codeGen.h"

	//for checking if function prototype and the definition header matches.
	#define INPROTOTYPE 	8000
	#define INDEFINITION   	8001
	int position;
	struct ArgStruct* currentArg;

	extern FILE* yyin;
	extern FILE* ltin;
	FILE* fp;

	int vartype;
	struct Gsymbol* currentSymbol;

	int yylex();
	int ltlex();
	int yyerror(const char*);
	extern int yylineno;
%}

%token ID READ WRITE ASGN NEWLINE IF THEN ELSE ENDIF WHILE DO ENDWHILE LT GT EQ BEGN END BREAK CONTINUE DECL ENDDECL RETURN MAIN VOID LE BREAKPOINT
%token BOOL INT
%token NUM BOOLEAN

%nonassoc LT GT EQ LE
%left PLUS SUB
%left MUL DIV
%%
Program		: header globalDecl functDeclList main footer	{}
	 	| header globalDecl main footer 		{}
	 	| header main footer		 		{}
		;

header		: %empty	{	position = INPROTOTYPE;
					fp = fopen("tmp.out", "w");
					Ginstall("main", T_VOID, 0);
				}

footer		: %empty	{
					printFooter(); 
					fclose(fp);
					ltin = fopen("tmp.out", "r");
					ltlex();
					fclose(ltin);
					fclose(fp);
					exit(0); 
				}

globalDecl	: DECL globalDeclList ENDDECL	{ 	position = INDEFINITION; 
	 						printHeader(); 
						}
localDecl	: DECL localDeclList ENDDECL	{}


globalDeclList	: globalDecl globalDeclList	{}
	 	| globalDecl			{}
		;

localDeclList	: localDeclList	localDecl	{}
	 	| localDecl			{}
		;

globalDecl	: type globalVarlist ';'
		;

localDecl	: type localVarlist ';'
		;

type		: INT			{ vartype = T_INT; }
		| BOOL 			{ vartype = T_BOOL; }
		| VOID			{ vartype = T_VOID; }
		;

IDx		: ID	{ Ginstall($1->NAME, vartype, 0); currentSymbol = Glookup($1->NAME); }

globalVarlist	: globalVarlist ',' ID 		{ Ginstall($3->NAME, vartype, 1); }
	 	| globalVarlist ',' IDx '(' argList ')'{
/*								done in a more apt location
								int argBinding = -3;
								struct ArgStruct* a = currentSymbol->ARGLIST;
								while(a != NULL)
								{
									Linstall(a->ARGNAME, a->TYPE, 1);
									Llookup(a->ARGNAME)->BINDING = argBinding;
									argBinding--;
								 	a = a->NEXT;	
								}*/
							}
		| ID 				{ Ginstall($1->NAME, vartype, 1); }
		| IDx '(' argList ')' 		{
/*							int argBinding = -3;
							struct ArgStruct* a = currentSymbol->ARGLIST;
							while(a != NULL)
							{
								Linstall(a->ARGNAME, a->TYPE, 1);
								Llookup(a->ARGNAME)->BINDING = argBinding;
								argBinding--;
							 	a = a->NEXT;	
							}*/
						}

		| globalVarlist ',' ID '[' NUM ']'	{ 	if($5->TYPE != T_INT)
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
		| ID '[' NUM ']' 	{ 	
						if($3->TYPE != T_INT)
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

localVarlist	: localVarlist ',' ID 		{ Linstall($3->NAME, vartype, 1); }
		| ID 				{ Linstall($1->NAME, vartype, 1); }
		;

argList		: argList ',' arg	{
					}
	 	| arg	{}
		| %empty
		;

arg		: type ID	{
     					if(position == INPROTOTYPE)	
     						appendArg(currentSymbol, $2->NAME, vartype);
					else if(position == INDEFINITION)
					{
						if(currentArg->TYPE != vartype || strcmp(currentArg->ARGNAME, $2->NAME) != 0)
						{
							printf("Mismatch in function header.\n");
							exit(0);
						}
						currentArg = currentArg->NEXT;
						Linstall($2->NAME, vartype, 1);
					}		
				}
		;

functDeclList	: functDecl  			{} 
	      	| functDeclList functDecl	{} 

typeID		: type ID 	{	currentSymbol = Glookup($2->NAME); 
					if(currentSymbol == NULL)
					{	
						printf("Function undeclared: %s.\n", $2->NAME);
						exit(0);
					}
					currentArg = currentSymbol->ARGLIST;
					if(vartype != currentSymbol->TYPE)
					{
						printf("Type error: mismatch in return value of %s.\n", $2->NAME);
						exit(0);
					}
				}
		;

functDecl	: typeID '(' argList ')' '{' localDeclList body '}'	{
										int argBinding = -3;
										struct ArgStruct* a = currentSymbol->ARGLIST;
										while(a != NULL)
										{
											Llookup(a->ARGNAME)->BINDING = argBinding;
											argBinding--;
										 	a = a->NEXT;	
										}
	
										
										if(currentSymbol->TYPE != $7->TYPE)
										{
											printf("Return value type does not match with the hunction header for %s\n", currentSymbol->NAME);
											exit(0);
										}
										$$ = TreeCreate(VOID, FUNDEF, currentSymbol->NAME, 0, NULL, $7, NULL, NULL);
										codeGen($$);
										freeLST();
									}

functDecl	: typeID '(' argList ')' '{' body '}'	{
										
										if(currentSymbol->TYPE != $6->TYPE)
										{
											printf("Return value type does not match with the hunction header for %s\n", currentSymbol->NAME);
											exit(0);
										}
										$$ = TreeCreate(VOID, FUNDEF, currentSymbol->NAME, 0, NULL, $6, NULL, NULL);
										codeGen($$);
										freeLST();
									}



main		: type MAIN '(' ')' '{' localDeclList mainBody '}'	{
	  									currentSymbol = Glookup("main");
										currentArg = currentSymbol->ARGLIST;
										$$ = TreeCreate(VOID, FUNDEF, "main", 0, NULL, $7, NULL, NULL);
										codeGen($$);
										freeLST();
									}

body 	: BEGN slist retn END 		{ 	
       				  		$$ = TreeCreate(VOID, STATEMENT, NULL, 0, NULL, $2, $3, NULL); 
					  	$$->right = $3;	
						$$->TYPE = $3->TYPE;
					}
	| BEGN retn END 		{ 	
						$$ = $2;
					}
	;

mainBody 	: BEGN slist END 	{ 
						$$ = $2;
					}
	;

retn	: RETURN expr ';' 	{ $$ = TreeCreate(VOID, RETURN, NULL, 0, NULL, $2, NULL, NULL); 
				  $$->TYPE = $2->TYPE;
				}
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

     	| expr LE expr		{ 	if($1->TYPE != T_INT || $3->TYPE != T_INT)
       					{
						printf("type error: le");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(LE, $2, $3, T_BOOL); 
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
					if(Llookup($1->NAME)->TYPE == T_INTARR)
					{
						$$ = makeBinaryOperatorNode(ARROP, $1, $4, T_INT); 
					}
					else if(Llookup($1->NAME)->TYPE == T_BOOLARR)
					{
						$$ = makeBinaryOperatorNode(ARROP, $1, $4, T_BOOL); 
					}
					else
					{
						printf("Type error: [] on non array");
						exit(0);
					}
				}
	| ID			{	if(Llookup($1->NAME) == NULL)
					{
						printf("1Unallocated variable %s.\n", $1->NAME);
						exit(0);
					}
					$1->TYPE = Llookup($1->NAME)->TYPE;
				  	$$ = $1;
				}
	| ID '(' formalParamList ')' 	{
						if(Llookup($1->NAME) == NULL)
						{
							printf("Undefine function %s\n", $1->NAME);
							exit(0);
						}
						
						$$ = TreeCreate(Llookup($1->NAME)->TYPE, FUNCALL, $1->NAME, 0, NULL, $3, NULL, NULL);
						}
	;
formalParamList	: formalParamList ',' expr 	{ $1->ArgList = $3; }
		| expr				{ $$ = $1; }
		| %empty			{ $$ = NULL; }

stmt 	: ID ASGN expr ';'	{ 	if(Llookup($1->NAME) == NULL)
					{
						printf("2Unallocated variable %s.\n", $1->NAME);
						exit(0);
					}
      					if(Llookup($1->NAME)->TYPE != $3->TYPE)
       					{
						printf("type error: ASSG");
						exit(0);
					}
				
      				  	$$ = TreeCreate(VOID, ASGN, $1->NAME, 0, NULL, $3, NULL, NULL);
				}
stmt 	: ID '[' expr ']' ASGN expr ';'	{	if(Llookup($1->NAME) == NULL)
						{
							printf("3Unallocated variable %s.\n", $1->NAME);
							exit(0);
						}
						if(Llookup($1->NAME)->TYPE != T_INTARR || $3->TYPE != T_INT || $6->TYPE != T_INT)
						if(Llookup($1->NAME)->TYPE != T_BOOLARR || $3->TYPE != T_INT || $6->TYPE != T_BOOL)
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
				  	if(Llookup($3->NAME) == NULL)
					{
						printf("4Unallocated variable %s.\n", $3->NAME);
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
							if(Llookup($3->NAME) == NULL)
							{
								printf("5Unallocated variable %s.\n", $3->NAME);
								exit(0);
							}
							if(Llookup($3->NAME)->TYPE != T_INTARR && Llookup($3->NAME)->TYPE != T_BOOLARR)
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
	| expr ';'		{ $$ = $1; }
	| BREAKPOINT ';'	{
				  $$ = TreeCreate(VOID, BREAKPOINT, NULL, 0, NULL, NULL, NULL, NULL);
				}
     	;


	

%%

int yyerror(char const *s)
{
	printf("Syntax error near line %d.\n", yylineno);
}

int main(int argc, char** argv)
{
	yyin = fopen(argv[1], "r");
	yyparse();
	return 1;
}
