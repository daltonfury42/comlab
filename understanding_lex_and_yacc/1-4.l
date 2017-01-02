%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
	
	int inComment = 0;
%}

singleLine "//".*
multiLineStart "/*"
multiLineEnd "*/"

oth .
%%

{singleLine} { printf("%s", yytext);}
{multiLineStart} { printf("%s", yytext); inComment = 1; }
{multiLineEnd} { printf("%s", yytext); inComment = 0; }
. { if(inComment) printf("%s", yytext);}

%%
 
int main(int argc, char* argv[])
{
	FILE* ip = fopen(argv[1], "r");
	yyin = ip;
	yylex();
	return 1;
}
