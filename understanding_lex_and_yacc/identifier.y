%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <ctype.h>
%}

%token letter digit space

%%

start 		: variable '\n'		{ printf("Yes\n"); exit(0); }
      		;

variable 	: letter alphanum	
	 	;

alphanum 	: letter alphanum
	 	| digit alphanum
		| letter
		| digit
		;

%%

yyerror(char const *s)
{
	printf("No");
}

yylex()
{
	char c;
	c = getchar();
	if(isdigit(c))
		return digit;
	else if(isalpha(c))
		return letter;
	else
		return c;
}

main()
{
	yyparse();
	return 1;
}
