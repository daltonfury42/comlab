%{
	#define YYSTYPE struct Tnode*
	#include "exptree.h"
	#include "y.tab.h"
	#include <stdlib.h>
%}

%%

"read" 		{ return READ; }
"write"		{ return WRITE; }
"if" 		{ return IF; }
"then" 		{ return THEN; }
"else" 		{ return ELSE; }
"endif"		{ return ENDIF; }
"while" 	{ return WHILE; }
"do" 		{ return DO; }
"endwhile" 	{ return ENDWHILE; }
[a-z] 		{ 	char * varName = malloc(sizeof(char));
			*varName = *yytext;
			yylval = TreeCreate(VOID, ID, varName, 0, NULL, NULL, NULL, NULL); return ID; 
		}
[0-9]+		{ yylval = makeIntegerLeafNode(atoi(yytext)); return NUM; }
[=]		{ return ASGN; }
"+"		{ return PLUS; }
"*"		{ return MUL; }
"=="		{ return EQ; }
"<"		{ return LT; }
">"		{ return GT; }
[ \t] 		{}
[\n]		{ return NEWLINE; }
.		{ return *yytext; }
%%

int yywrap()
{
	return 1;
}
