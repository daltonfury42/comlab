%{
	#define YYSTYPE struct Tnode*
	#include "exptree.h"
	#include "y.tab.h"
	#include "symbolTable.h"
	#include "constants.h"
	#include <stdlib.h>

	struct Gsymbol * GST = NULL;
%}

%%

"integer" 		{ return INT; }
"boolean"		{ return BOOL; }
"TRUE"		{ yylval = makeLeafNode(TRUE, T_BOOL); return BOOLEAN; }
"FALSE"		{ yylval = makeLeafNode(FALSE, T_BOOL); return BOOLEAN; }
"decl"		{ return DECL; }
"enddecl"	{ return ENDDECL; }
"begin"		{ return BEGN; }
"end"		{ return END; }
"read" 		{ return READ; }
"write"		{ return WRITE; }
"if" 		{ return IF; }
"then" 		{ return THEN; }
"else" 		{ return ELSE; }
"endif"		{ return ENDIF; }
"while" 	{ return WHILE; }
"do" 		{ return DO; }
"endwhile" 	{ return ENDWHILE; }
"break"		{ return BREAK; }
"continue"	{ return CONTINUE; }
[a-zA-Z_][a-zA-Z_0-9]*	{ 	char * varName = malloc(sizeof(char)*strlen(yytext)+1);
			strcpy(varName, yytext);
			yylval = TreeCreate(VOID, ID, varName, 0, NULL, NULL, NULL, NULL); 
			return ID;
		}
[0-9]+		{ yylval = makeLeafNode(atoi(yytext), T_INT); return NUM; }
[=]		{ return ASGN; }
"+"		{ return PLUS; }
"*"		{ return MUL; }
"=="		{ return EQ; }
"<"		{ return LT; }
">"		{ return GT; }
[ \t\n]		{}
.		{ return *yytext; }
%%

int yywrap()
{
	return 1;
}
