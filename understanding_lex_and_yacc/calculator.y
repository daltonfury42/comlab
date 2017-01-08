%{
/*** Auxiliary declarations section ***/

#include<stdio.h>
#include<stdlib.h>

/* Custom function to print an operator*/
void print_operator(char op);

/* Variable to keep track of the position of the number in the input */
int pos=0;

%}

 /*** YACC Declarations section ***/
%token DIGIT
%left '+'
%left '*'
%left '/'
%left '-'
%%

/*** Rules Section ***/
start : expr '\n'		{ printf("%d", $1); exit(1);}
      ;

expr: expr '+' expr     { $$ = $1 + $3; }
    | expr '*' expr     { $$ = $1 * $3; }
    | expr '/' expr     { $$ = $1 / $3; }
    | expr '-' expr     { $$ = $1 - $3; }
    | '(' expr ')'	{ $$ = $2; }
    | DIGIT             { $$ = $1; }
    ;

%%


/*** Auxiliary functions section ***/

void print_operator(char c){
    switch(c){
        case '+'  : printf("PLUS ");
                    break;
        case '*'  : printf("MUL ");
                    break;
        case '-'  : printf("SUB ");
                    break;
        case '/'  : printf("DIV ");
                    break;
    }
    return;
}

yyerror(char const *s)
{
    printf("yyerror %s",s);
}

yylex(){
    char c;
    c = getchar();
    if(isdigit(c)){
        pos++;
	yylval = c - '0';
        return DIGIT;
    }
    else if(c == ' '){
        yylex();         /*This is to ignore whitespaces in the input*/
    }
    else {
        return c;
    }
}

main()
{
	yyparse();
	return 1;
}
