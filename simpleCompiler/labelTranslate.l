%{

	#include "labelTranslate.h"
	int lineCount = 2040;
	int pass = 1;	//1st or second pass;
	extern FILE* fp;

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

int ltwrap()
{
	if(pass == 1)
	{
		fclose(ltin);
		ltin = fopen("tmp.out", "r");
		fp = fopen("xsm.out", "w");
		pass = 2;
		return 0;
	}
	
	else return 1;
}
