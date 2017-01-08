%{

	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

%}

%token NEWLINE
%left '+'
%union { char* str; }

%token<str> STRING

%%

start 	: expr NEWLINE		{ printf("%s", $<str>1); exit(0);}

expr	: expr '+' expr		{ 	$<str>$ = malloc(1000);
     					strcpy($<str>$, $<str>1); 
					strcat($<str>$, $<str>3); 
				}
	| STRING		{ 	$<str>$ = malloc(1000);
					strcpy($<str>$, $<str>1); }
	;

%%

int yyerror(char *s)
{
	printf("yyerror %s", s);
	return 0;
}

int main()
{
	yyparse();
	return 1;
}
