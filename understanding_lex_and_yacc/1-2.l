%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
	int line_count = 0;
	int word_count = 0;
	int char_count = 0;
	int int_count = 0;
	int float_count = 0;
%}
	
line "\n"
space " "
character .
integer [0-9]+
float [0-9]+[.][0-9]+

%%

{integer} { 
		int_count++;
	}

{float} { 
		float_count++;
	}

		
{space}+ { 
		word_count++;	
	}

{line} { 
		line_count++;
		word_count++;
	}
{character} { 
		char_count++;
	}

%%
 
int main(int argc, char* argv[])
{
	FILE* ip = fopen(argv[1], "r");
	yyin = ip;
	yylex();
	printf("L: %d W: %d C: %d I: %d F: %d\n", line_count, word_count, char_count, int_count, float_count);
	return 1;
}
