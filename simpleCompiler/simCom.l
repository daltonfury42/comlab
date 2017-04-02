%{
	#define YYSTYPE struct Tnode*
	#include "exptree.h"
	#include "y.tab.h"
	#include "symbolTable.h"
	#include "typeTable.h"
	#include "constants.h"
	#include <stdlib.h>

%}

%option yylineno

%%

"integer" 		{ return INT; }
"boolean"		{ return BOOL; }
"TRUE"		{ yylval = makeLeafNode(TRUE, Tlookup("boolean")); return BOOLEAN; }
"FALSE"		{ yylval = makeLeafNode(FALSE, Tlookup("boolean")); return BOOLEAN; }
"type"		{ return TYPESTART; }
"endtype"		{ return ENDTYPE; }
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
"breakpoint"	{ return BREAKPOINT; }
"continue"	{ return CONTINUE; }
"main"		{ return MAIN; }
"return"	{ return RETURN; }
"void"		{ return VOID; }
[a-zA-Z_][a-zA-Z_0-9]*	{ 	char * varName = strdup(yytext); //malloc(sizeof(char)*strlen(yytext)+1);
			yylval = TreeCreate(Tlookup("void"), ID, varName, 0, NULL, NULL, NULL, NULL); 
			return ID;
		}
[0-9]+		{ yylval = makeLeafNode(atoi(yytext), Tlookup("integer")); return NUM;}
[=]		{ return ASGN; }
"+"		{ return PLUS; }
"*"		{ return MUL; }
"/"		{ return DIV; }
"-"		{ return SUB; }
"=="		{ return EQ; }
"<"		{ return LT; }
"<="		{ return LE; }
">"		{ return GT; }
[ \t\n]		{}
.		{ return *yytext; }
%%

int yywrap()
{
	return 1;
}
