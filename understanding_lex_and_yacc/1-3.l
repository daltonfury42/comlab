%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
	int line_count = 0;
	int word_count = 0;
	int char_count = 0;
%}

whitespace [ \t\n]
target A[A-Za-z]{2} 
oth .

%%

{target}{whitespace} { printf("%s", yytext);}
{oth} { ; }

%%
 
int main(int argc, char* argv[])
{
	FILE* ip = fopen(argv[1], "r");
	yyin = ip;
	yylex();
	return 1;
}
