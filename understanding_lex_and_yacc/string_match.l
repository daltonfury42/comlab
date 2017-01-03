%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
	int inString = 0;
%}
	
dquote \"
character .

%%

{dquote}	{ 	if(inString) 
				inString = 0;
		 	else
				inString = 1;
			printf("%s", yytext);
		}
{character}|\n 	{
			if(inString)
				printf("%s", yytext);
		}

%%
 
int main(int argc, char* argv[])
{
	FILE* ip = fopen(argv[1], "r");
	yyin = ip;
	yylex();
	return 1;
}
