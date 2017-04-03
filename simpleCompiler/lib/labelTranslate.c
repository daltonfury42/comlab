#include <stdio.h>
#include "labelTranslate.h"

int LabelTable[1024];
int FunLabelTable[1024];

void storeLabel(int label, int address)
{
	if (LabelTable[label] != 0)
		printf("Warning: overwriting labels.\n");

	LabelTable[label] = address;
}

int getLabelAddr(int label)
{
	if (LabelTable[label] == 0)
		printf("Warning: Attempted to lookup a label that doesnot exist..\n");

	return(LabelTable[label]);
}

void storeFunLabel(int label, int address)
{
	if (FunLabelTable[label] != 0)
		printf("Warning: overwriting function labels.\n");

	FunLabelTable[label] = address;
}

int getFunLabelAddr(int label)
{
	if (FunLabelTable[label] == 0)
		printf("Warning: Attempted to lookup a function label that doesnot exist..\n");

	return(FunLabelTable[label]);
}
