%{
	#include <stdlib.h>
	#include <stdio.h>	
	int *var[26];
%}

%union{
	int integer;
	char character;
};
%type <integer>expr
%type <integer>NUM
%type <character>ID
%token NUM ID READ WRITE ASGN NEWLINE
%left PLUS
%left MUL 

%%
Program : slist NEWLINE {exit(0);}
	     ;
slist : slist stmt
           | stmt
     ;


expr	: expr PLUS expr		{ $$ = $1 + $3; }
     	| expr MUL expr		{ $$ = $1 * $3; }
	| '(' expr ')'		{ $$ = $2; }
	| NUM			{ $$ = $1; }
	| ID			{
				  if(var[$1 - 'a'] == NULL)
					printf("unassigned variable\n");
				  else
					$$ = *var[$1 - 'a']; 
				}

stmt 	: ID ASGN expr ';'	{ if(var[$1 - 'a'] == NULL)
      					var[$1 - 'a'] = malloc(sizeof(int));
					*var[$1 - 'a'] = $3;
      					
				}
	| READ '(' ID ')' ';' 	{ if(var[$3-'a'] == NULL) 
					var[$3 - 'a'] = malloc(sizeof(int));
				  scanf("%d", var[$3-'a']);
				}
     	| WRITE '(' expr ')' ';'{ printf("%d", $3);
				}
     	;


	

%%

int yyerror(char const *s)
{
	printf("yyerror %s", s);
}

int main()
{
	yyparse();
	return 1;
}
