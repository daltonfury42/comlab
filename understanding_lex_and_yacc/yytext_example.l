%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
%}
	
number [0-9]+
 
%%
 
{number} {printf("Found : %d\n",atoi(yytext));}
[ \n\t]  {}
.	 { printf("Invalid character %s\n", yytext); exit(1); }
 
%%
 
int main(int argc, char* argv[])
{

	if(argc > 1)
	{
		FILE *fp = fopen(argv[1], "r");
		yyin = fp;
	}
		
	yylex();
	return 1;
}
