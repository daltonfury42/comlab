%{
	#include <stdio.h>
	#include "y.tab.h"
	#include <string.h>
%}

%%

"+" 		{ 	return *yytext;
		}

["][^"]+["] 	{  	yylval.str = malloc(1000);
			yytext[strlen(yytext)-1] = '\0';
			strcpy(yylval.str, yytext+1);
			//printf("got: %s", yytext);
			return STRING;	
   		}

[\n] 		{	return NEWLINE;
		}
[ ]		{}
. 		{	return *yytext;
		}

%%

yywrap()
{
	return 1;
}
