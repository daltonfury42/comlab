%{

	#include "labelTranslate.h"
	int lineCount = 2040;
	int pass = 1;	//1st or second pass;
	extern FILE* fp;

%}

%%

L[0-9]+:\n 	{
			if(pass == 1)
			{
				int label;
				sscanf(yytext, "L%d", &label);
				storeLabel(label, lineCount);	
			}
		}
L[0-9]+		{ 
			if(pass == 2)
			{	int label;
				sscanf(yytext, "L%d", &label);
				fprintf(fp, "%d", getLabelAddr(label));
			}
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
