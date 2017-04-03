%{

	#include "labelTranslate.h"
	int lineCount = 0;
	int pass = 1;	//1st or second pass;
	FILE* fp;

%}

%%

[FL][0-9]+:\n 	{
			if(pass == 1)
			{
				int label;
				if(yytext[0] == 'L')
				{
					sscanf(yytext, "L%d", &label);
					storeLabel(label, lineCount);	
				}
				else if(yytext[0] == 'F')
				{
					sscanf(yytext, "F%d", &label);
					storeFunLabel(label, lineCount);	
				}
			}
		}
[FL][0-9]+	{ 
			if(pass == 2)
			{	int label;
				if(yytext[0] == 'L')
				{
					sscanf(yytext, "L%d", &label);
					fprintf(fp, "%d", getLabelAddr(label));
				}
				else if(yytext[0] == 'F')
				{
					sscanf(yytext, "F%d", &label);
					fprintf(fp, "%d", getFunLabelAddr(label));
				}
			}
		}
MAIN		{
			if(pass == 2)
			{
				fprintf(fp, "%d", getFunLabelAddr(0));	
			}
		}
MAIN:\n		{
			if(pass == 1)	
					storeFunLabel(0, lineCount);	
		}
\n		{
			if(pass == 1)
				lineCount += 2;
			else
				fprintf(fp, "\n");
		}
.		{ 	
			if(pass == 2)
				fprintf(fp, "%s", yytext);
		}

%%

int yywrap()
{
	if(pass == 1)
	{
		fclose(yyin);
		yyin = fopen("xsm.lib", "r");
		fp = fopen("xsm.out", "w");
		pass = 2;
		return 0;
	}
	
	else return 1;
}

int main(int argc, char* argv[])
{
	fp = fopen("lib.xsm", "r");
	if(fp)
	{
		yyin = fp;
		printf("Opended input.\n");
	}
	else
	{
		printf("Failed to open lib.xsm\n");
		exit(0);
	}
	yylex();
	return 1;
}
