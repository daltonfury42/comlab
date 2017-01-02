%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
	int line_count = 0;
	int word_count = 0;
	int char_count = 0;
%}
	
line "\n"
space " "
charecter .

%%

{line} { 
		line_count++;
		word_count++;
	}
		
{space}* { 
		word_count++;	
	}

{charecter} { 
		char_count++;
	}

%%
 
int main(int argc, char* argv[])
{
	FILE* ip = fopen(argv[1], "r");
	yyin = ip;
	yylex();
	printf("L: %d W: %d C: %d\n", line_count, word_count, char_count);
	return 1;
}
