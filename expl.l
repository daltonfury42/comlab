%{
	#include "y.tab.h"
	#include <stdlib.h>
%}

%%

[a-z] 	{ yylval.character = yytext[0]; return ID; }
[0-9]+	{ yylval.integer = atoi(yytext); return NUM; }
"read" 	{ return READ; }
[=]	{ return ASGN; }
"write"	{ return WRITE;}
"+"	{ return PLUS; }
"*"	{ return MUL; }
[ \t] 	{}
[\n]	{ return NEWLINE; }
.	{ return *yytext; }
%%

yywrap()
{
	return 1;
}
