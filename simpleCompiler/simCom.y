%{
	#define YYSTYPE struct Tnode*
	#include "exptree.h"
	#include "symbolTable.h"
	#include <stdlib.h>
	#include <string.h>
	#include <stdio.h>	
	#include "constants.h"
	#include "codeGen.h"
	#include "typeTable.h"

	//for checking if function prototype and the definition header matches.
	#define INPROTOTYPE 	8000
	#define INDEFINITION   	8001
	int position;
	struct ArgStruct* currentArg;

	extern FILE* yyin;
	extern FILE* ltin;
	FILE* fp;

	char* vartype;
	struct ArgStruct* argl;
	struct Gsymbol* currentSymbol;

	int yylex();
	int ltlex();
	int yyerror(const char*);
	extern int yylineno;
%}

%token ID READ WRITE ASGN NEWLINE IF THEN ELSE ENDIF WHILE DO ENDWHILE LT GT EQ BEGN END BREAK CONTINUE DECL ENDDECL RETURN MAIN VOID LE BREAKPOINT TYPESTART ENDTYPE ALLOC NULLC NEQ
%token BOOL INT
%token NUM BOOLEAN

%nonassoc LT GT EQ LE NEQ
%left PLUS SUB
%left MUL DIV
%%
Program		: header typeDefBlock globalDecl functDeclList main footer	{}
	 	| header typeDefBlock globalDecl main footer 		{}
	 	| header typeDefBlock main footer		 		{}
		;

header		: %empty	{	
					position = INPROTOTYPE;
					fp = fopen("tmp.out", "w");
					typeTableCreate();
					Ginstall("main", Tlookup("void"), 0);
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

typeDefBlock	: TYPESTART typeDefList ENDTYPE
		| %empty
		;

typeDefList	: typeDefList typeDef
		| typeDef
		;

typeDef		: IDy '{' fieldDeclList '}'	{ 
							Tlookup($1->NAME)->size = computeFLSize((struct fieldList*)$3);
							Tlookup($1->NAME)->fields = (struct fieldList*)$3;
							int nextFreeField = 0;
							struct fieldList* tmp = Tlookup($1->NAME)->fields;
							while(tmp != NULL)
							{
								tmp->fieldIndex = nextFreeField;
								nextFreeField++;
								tmp = tmp->next;
							}
						}
		;
IDy		: ID 	{ Tinstall($1->NAME, 0, NULL); }

fieldDeclList	: fieldDeclList fieldDecl	{ $$ = $2; ((struct fieldList*)$$)->next = (struct fieldList*)$1; }
		| fieldDecl			{ 
							$$ = $1;
						}
		;

fieldDecl	: type ID ';'			{ $$ = (struct Tnode*)Fcreate($2->NAME, Tlookup(vartype)); }
		;


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

globalDecl	: type globalVarlist ';'	{}
		;

localDecl	: type localVarlist ';'		{}
		;

type		: INT			{ vartype = "integer"; }
		| BOOL 			{ vartype = "boolean"; }
		| VOID			{ vartype = "void"; }
		| ID			{ vartype = $1->NAME; }
		;

IDx		: ID	{ Ginstall($1->NAME, Tlookup(vartype), 0); currentSymbol = Glookup($1->NAME); }
		;

globalVarlist	: globalVarlist ',' ID 		{ Ginstall($3->NAME, Tlookup(vartype), 1); }
	 	| globalVarlist ',' IDx '(' argList ')'{}
		| ID 				{ Ginstall($1->NAME, Tlookup(vartype), 1); }
		| IDx '(' argList ')' 		{}
		| globalVarlist ',' ID '[' NUM ']'	{ 	if($5->TYPE != Tlookup("integer"))
							{
								printf("Type error in integer array declaration.\n");
								exit(0);
							}
							if(Tlookup(vartype) == Tlookup("integer"))
							{
								Ginstall($3->NAME, Tlookup("intarr"), $5->VALUE); 
							}
							else if(Tlookup(vartype) == Tlookup("boolean"))
							{
								Ginstall($3->NAME, Tlookup("boolarr"), $5->VALUE); 
							}
							else
							{
								printf("Type error(2) in integer array declaration.\n");
							}
				 		}
		| ID '[' NUM ']' 	{ 	
						if($3->TYPE != Tlookup("integer"))
						{
							printf("Type error in integer array declaration.\n");
							exit(0);
						}
						if(Tlookup(vartype) == Tlookup("integer"))
						{
							Ginstall($1->NAME, Tlookup("intarr"), $3->VALUE); 
						}
						else if(Tlookup(vartype) == Tlookup("boolean"))
						{
							Ginstall($1->NAME, Tlookup("boolarr"), $3->VALUE); 
						}
						else
						{
							printf("Type error(3) in integer array declaration.\n");
						}
				 	}
		;

localVarlist	: localVarlist ',' ID 		{ Linstall($3->NAME, Tlookup(vartype), 1); }
		| ID 				{ Linstall($1->NAME, Tlookup(vartype), 1); }
		;

argList		: argList ',' arg	{
					}
	 	| arg	{}
		| %empty
		;

arg		: type ID	{
     					if(position == INPROTOTYPE)	
     						appendArg(currentSymbol, $2->NAME, Tlookup(vartype));
					else if(position == INDEFINITION)
					{
						if(currentArg->TYPE != Tlookup(vartype) || strcmp(currentArg->ARGNAME, $2->NAME) != 0)
						{
							printf("Mismatch in function header.\n");
							exit(0);
						}
						currentArg = currentArg->NEXT;
						Linstall($2->NAME, Tlookup(vartype), 0);
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
					if(Tlookup(vartype) != currentSymbol->TYPE)
					{
						printf("Type error: mismatch in return value of %s.\n", $2->NAME);
						exit(0);
					}
				}
		;

functDecl	: typeID '(' argList ')' '{' localDecl body '}'	{
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
										$$ = TreeCreate(Tlookup("void"), FUNDEF, currentSymbol->NAME, 0, NULL, $7, NULL, NULL);
										codeGen($$);
										freeLST();
									}

functDecl	: typeID '(' argList ')' '{' body '}'	{
										int argBinding = -3;
										struct ArgStruct* a = currentSymbol->ARGLIST;
										while(a != NULL)
										{
											Llookup(a->ARGNAME)->BINDING = argBinding;
											argBinding--;
										 	a = a->NEXT;	
										}
										
										if(currentSymbol->TYPE != $6->TYPE)
										{
											printf("Return value type does not match with the hunction header for %s\n", currentSymbol->NAME);
											exit(0);
										}
										$$ = TreeCreate(Tlookup("void"), FUNDEF, currentSymbol->NAME, 0, NULL, $6, NULL, NULL);
										codeGen($$);
										freeLST();
									}



main		: type MAIN '(' ')' '{' localDeclList mainBody '}'	{
	  									currentSymbol = Glookup("main");
										currentArg = currentSymbol->ARGLIST;
										$$ = TreeCreate(Tlookup("void"), FUNDEF, "main", 0, NULL, $7, NULL, NULL);
										codeGen($$);
										freeLST();
									}

body 	: BEGN slist retn END 		{ 	
       				  		$$ = TreeCreate(Tlookup("void"), STATEMENT, NULL, 0, NULL, $2, $3, NULL); 
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

retn	: RETURN expr ';' 	{ $$ = TreeCreate(Tlookup("void"), RETURN, NULL, 0, NULL, $2, NULL, NULL); 
				  $$->TYPE = $2->TYPE;
				}
	;

slist 	: slist stmt		{ 	if($1->TYPE != Tlookup("void") || $2->TYPE != Tlookup("void"))
       					{
						printf("type error");
						exit(0);
					}
       				  	$$ = TreeCreate(Tlookup("void"), STATEMENT, NULL, 0, NULL, $1, $2, NULL); 
				}
	| stmt			{ 	if($1->TYPE != Tlookup("void"))
       					{
						printf("type error");
						exit(0);
					}
					$$ = $1; 
				}
     	;

expr	: expr PLUS expr	{ 	if($1->TYPE != Tlookup("integer") || $3->TYPE != Tlookup("integer"))
       					{
						printf("type error: +");
						exit(0);
					}

     					$$ = makeBinaryOperatorNode(PLUS, $1, $3, Tlookup("integer")); 
     				}
     	| expr MUL expr		{ 	if($1->TYPE != Tlookup("integer") || $3->TYPE != Tlookup("integer"))
       					{
						printf("type error: *");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(MUL, $1, $3, Tlookup("integer")); 
				}
     	| expr SUB expr		{ 	if($1->TYPE != Tlookup("integer") || $3->TYPE != Tlookup("integer"))
       					{
						printf("type error: SUB");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(SUB, $1, $3, Tlookup("integer")); 
				}
     	| expr DIV expr		{ 	if($1->TYPE != Tlookup("integer") || $3->TYPE != Tlookup("integer"))
       					{
						printf("type error: DIV");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(DIV, $1, $3, Tlookup("integer")); 
				}
     	| expr EQ expr		{ 	if($1->TYPE != Tlookup("integer") || $3->TYPE != Tlookup("integer"))
       					{
						printf("type error: eq");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(EQ, $1, $3, Tlookup("boolean")); 
				}
     	| expr EQ NULLC 	{ 	if($1->TYPE == Tlookup("integer") || $1->TYPE == Tlookup("boolean") || $1->TYPE == Tlookup("void"))
       					{
						printf("type error: eq(nv)");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(EQ, $1, makeLeafNode(-1, Tlookup("integer")), Tlookup("boolean")); 
				}
     	| expr NEQ expr		{ 	if($1->TYPE != Tlookup("integer") || $3->TYPE != Tlookup("integer"))
       					{
						printf("type error: eq");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(NEQ, $1, $3, Tlookup("boolean")); 
				}
      	| expr NEQ NULLC 	{ 	if($1->TYPE == Tlookup("integer") || $1->TYPE == Tlookup("boolean") || $1->TYPE == Tlookup("void"))
       					{
						printf("type error: eq(nv)");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(NEQ, $1, makeLeafNode(-1, Tlookup("integer")), Tlookup("boolean")); 
				}
 
     	| expr LT expr		{ 	if($1->TYPE != Tlookup("integer") || $3->TYPE != Tlookup("integer"))
       					{
						printf("type error: lt");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(LT, $1, $3, Tlookup("boolean")); 
				}

     	| expr LE expr		{ 	if($1->TYPE != Tlookup("integer") || $3->TYPE != Tlookup("integer"))
       					{
						printf("type error: le");
						exit(0);
					}
					$$ = makeBinaryOperatorNode(LE, $1, $3, Tlookup("boolean")); 
				}
     	| expr GT expr		{ 	if($1->TYPE != Tlookup("integer") || $3->TYPE != Tlookup("integer"))
					{
						printf("type error: gt");
						exit(0);
					}	
					$$ = makeBinaryOperatorNode(GT, $1, $3, Tlookup("boolean")); 
				}
	| '(' expr ')'		{ $$ = $2; }
	| NUM			{ $$ = $1; }
	| BOOLEAN 		{ $$ = $1; }
	| ID '[' expr ']'	{ 	if($3->TYPE != Tlookup("integer"))
       					{
						printf("type error: [expr]");
						exit(0);
					}
					if(Llookup($1->NAME)->TYPE == Tlookup("intarr"))
					{
						$$ = makeBinaryOperatorNode(ARROP, $1, $4, Tlookup("integer")); 
					}
					else if(Llookup($1->NAME)->TYPE == Tlookup("boolarr"))
					{
						$$ = makeBinaryOperatorNode(ARROP, $1, $4, Tlookup("boolean")); 
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
	| IDz '(' formalParamList ')' 	{
						if(Llookup($1->NAME) == NULL)
						{
							printf("Undefine function %s\n", $1->NAME);
							exit(0);
						}

						$$ = TreeCreate(Llookup($1->NAME)->TYPE, FUNCALL, $1->NAME, 0, NULL, $3, NULL, NULL);
						}
	| field			{ $$ = TreeCreate(Tlookup("integer"), EXPRFLD, NULL, 0, NULL, $1, NULL, NULL);}		//todo type not set 
	;

IDz	: ID	{	
			argl = Llookup($1->NAME)->ARGLIST;
			$$ = $1;
		}

field	: 	ID '.' ID	{ $$ = $1; $$->left = $3; $$->TYPE = $3->TYPE; }
	|	ID '.' field	{ $$ = $1; $$->left = $3; $$->TYPE = $3->TYPE; }
	;

formalParamList	: formalParamList ',' expr 	{ 	$3->ArgList = $1; 
						  	$$ = $3;
							struct Tnode* gdb = $$;
							if($3->TYPE != argl->TYPE)
							{
								printf("1Mismatch in type of arguments to function.\n");
								exit(0);
							}
							argl = argl->NEXT;
						}
		| expr				{ 	$$ = $1; 
							struct Tnode* gdb = $$;
							if($$->TYPE != argl->TYPE && 0)
							{
								printf("2Mismatch in type of arguments to function.\n");
								exit(0);
							}
							argl = argl->NEXT;

						}
		| %empty			{ $$ = NULL; }

stmt 	: ID ASGN expr ';'	{ 	if(Llookup($1->NAME) == NULL)
					{
						printf("2Unallocated variable %s.\n", $1->NAME);
						exit(0);
					}
					/* uncommet and fix, type error in BST program
      					if(Llookup($1->NAME)->TYPE != $3->TYPE)
       					{
						printf("type error: ASSG(%s)", $1->NAME);
						exit(0);
					}*/
				
      				  	$$ = TreeCreate(Tlookup("void"), ASGN, $1->NAME, 0, NULL, $3, NULL, NULL);
				}
	| field ASGN ALLOC '(' ')' ';'	{
						$$ = TreeCreate(Tlookup("void"), ALLOC, NULL, 0, NULL, $1, NULL, NULL);
					}
	| ID ASGN ALLOC '(' ')' ';'	{
						$$ = TreeCreate(Tlookup("void"), ALLOC, NULL, 0, NULL, $1, NULL, NULL);
					}
	| field ASGN expr ';'	{
					if(Llookup($1->NAME)->TYPE == Tlookup("integer") || Llookup($1->NAME)->TYPE == Tlookup("boolean") || Llookup($1->NAME)->TYPE == Tlookup("null") || Llookup($1->NAME)->TYPE == Tlookup("void"))
					{
						printf("Type error.\n");
						exit(0);
					}
					$$ = TreeCreate(Tlookup("void"), ASGNFLD, NULL, 0, NULL, $1, $3, NULL);
				}			
	| ID '[' expr ']' ASGN expr ';'	{	if(Llookup($1->NAME) == NULL)
						{
							printf("3Unallocated variable %s.\n", $1->NAME);
							exit(0);
						}
						if(Llookup($1->NAME)->TYPE != Tlookup("intarr") || $3->TYPE != Tlookup("integer") || $6->TYPE != Tlookup("integer"))
						if(Llookup($1->NAME)->TYPE != Tlookup("boolarr") || $3->TYPE != Tlookup("integer") || $6->TYPE != Tlookup("boolean"))
       						{
							printf("type error: []=");
							exit(0);
						}
						if($3->TYPE != Tlookup("integer"))
       						{
							printf("type error: asgnarr[expr]");
							exit(0);
						}

      				 	 	$$ = TreeCreate(Tlookup("void"), ASGNARR, $1->NAME, 0, NULL, $3, $6, NULL);
					}
	| READ '(' ID ')' ';' 	{ 
				  	if(Llookup($3->NAME) == NULL)
					{
						printf("4Unallocated variable %s.\n", $3->NAME);
						exit(0);
					}
				 	$$ = TreeCreate(Tlookup("void"), READ, $3->NAME, 0, NULL, NULL, NULL, NULL);
				}
	| READ '(' field ')' ';' 		{
							$$ = TreeCreate(Tlookup("void"), READFLD, NULL, 0, NULL, $3, NULL, NULL);	
						}
	| READ '(' ID '[' expr ']' ')' ';' 	{ 
							if($5->TYPE != Tlookup("integer"))
       							{
								printf("type error: readarr[expr]");
								exit(0);
							}
							if(Llookup($3->NAME) == NULL)
							{
								printf("5Unallocated variable %s.\n", $3->NAME);
								exit(0);
							}
							if(Llookup($3->NAME)->TYPE != Tlookup("intarr") && Llookup($3->NAME)->TYPE != Tlookup("boolarr"))
       							{
								printf("type error: READARR");
								exit(0);
							}
					 	 	$$ = TreeCreate(Tlookup("void"), READARR, $3->NAME, 0, NULL, $5, NULL, NULL);
						}
     	| WRITE '(' expr ')' ';'{ $$ = TreeCreate(Tlookup("void"), WRITE, NULL, 0, NULL, $3, NULL, NULL);
				}
	| IF '(' expr ')' THEN slist ENDIF ';'
				{
      					if($3->TYPE != Tlookup("boolean"))
       					{
						printf("type error: IF(GUARD)");
						exit(0);
					}   
      					if($6->TYPE != Tlookup("void"))
       					{
						printf("type error: IF(THEN)");
						exit(0);
					}   
					
				  $$ = TreeCreate(Tlookup("void"), IF, NULL, 0, NULL, $3, $6, NULL);
				}
	| IF '(' expr ')' THEN slist ELSE slist ENDIF ';'
				{
      					if($3->TYPE != Tlookup("boolean"))
       					{
						printf("type error: IF(GUARD)");
						exit(0);
					}   
      					if($6->TYPE != Tlookup("void"))
       					{
						printf("type error: IF(THEN)");
						exit(0);
					}   
      					if($8->TYPE != Tlookup("void"))
       					{
						printf("type error: IF(ELSE)");
						exit(0);
					}   
				  $$ = TreeCreate(Tlookup("void"), IF, NULL, 0, NULL, $3, $6, $8);
				}
	| WHILE '(' expr ')' DO slist ENDWHILE ';'
				{
      					if($3->TYPE != Tlookup("boolean"))
       					{
						printf("type error: WHILE(GUARD)");
						exit(0);
					}   
      					if($6->TYPE != Tlookup("void"))
       					{
						printf("type error: WHILE(DO)");
						exit(0);
					}   
				  $$ = TreeCreate(Tlookup("void"), WHILE, NULL, 0, NULL, $3, $6, NULL);
				}
	| BREAK ';'		{
				  $$ = TreeCreate(Tlookup("void"), BREAK, NULL, 0, NULL, NULL, NULL, NULL);
				}
	| CONTINUE ';'		{
				  $$ = TreeCreate(Tlookup("void"), CONTINUE, NULL, 0, NULL, NULL, NULL, NULL);
				}
	| BREAKPOINT ';'	{
				  $$ = TreeCreate(Tlookup("void"), BREAKPOINT, NULL, 0, NULL, NULL, NULL, NULL);
				}
	| field ASGN NULLC ';'	{ 
					if(Llookup($1->NAME)->TYPE == Tlookup("integer") || Llookup($1->NAME)->TYPE == Tlookup("boolean") || Llookup($1->NAME)->TYPE == Tlookup("null") || Llookup($1->NAME)->TYPE == Tlookup("void"))
					{
						printf("Type error.\n");
						exit(0);
					}
		
					$$ = TreeCreate(Tlookup("void"), NULLC, NULL, 0, NULL, $1, NULL, NULL); 
				}
	| ID ASGN NULLC ';'	{ 
					if(Llookup($1->NAME)->TYPE == Tlookup("integer") || Llookup($1->NAME)->TYPE == Tlookup("boolean") || Llookup($1->NAME)->TYPE == Tlookup("null") || Llookup($1->NAME)->TYPE == Tlookup("void"))
					{
						printf("Type error.\n");
						exit(0);
					}
					$$ = TreeCreate(Tlookup("void"), NULLC, NULL, 0, NULL, $1, NULL, NULL); 
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
