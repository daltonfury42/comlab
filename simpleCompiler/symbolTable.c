#include "symbolTable.h"
#include "constants.h"
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

struct Gsymbol * GST;
struct Gsymbol * LST;
int nextFreeLocation = 4096;
int nextFreeBPRelativeLocation = 0;

void appendArg(struct Gsymbol* symTableEntry, char *NAME, int TYPE)
{
	struct ArgStruct* i;
	if(symTableEntry->ARGLIST == NULL)
	{
		symTableEntry->ARGLIST = malloc(sizeof(struct ArgStruct));
		i = symTableEntry->ARGLIST;
	}
	else
	{
		i = symTableEntry->ARGLIST;
		while(i->NEXT != NULL)
			i = i->NEXT;

		i->NEXT = malloc(sizeof(struct ArgStruct));
		i = i->NEXT;
	}

	i->TYPE = TYPE;
	i->ARGNAME = NAME;
	i->NEXT = NULL;
}

struct Gsymbol *Glookup(char* NAME)
{
	struct Gsymbol *i = GST;
	while(i != NULL)
	{
		if (strcmp(NAME, i->NAME) == 0)
			return i;
		i = i->NEXT;
	}

	return NULL;
}

void Ginstall(char* NAME, int TYPE, int SIZE)
{
	struct Gsymbol *i;
	if(Glookup(NAME)!=NULL)
	{
		printf("Multiple declaration of variable %s", NAME);
		exit(0);
	}

	if (GST == NULL)
	{
		GST = malloc(sizeof(struct Gsymbol));
		i = GST;
	}
	else
	{
		i = GST;
		while(i->NEXT != NULL)
			i = i->NEXT;

		i->NEXT = malloc(sizeof(struct Gsymbol));
		i = i->NEXT;
	}

	i->NAME = NAME;
	i->TYPE = TYPE;
	i->SIZE = SIZE;
	i->ARGLIST = NULL;
	i->NEXT = NULL;

	i->BINDING = nextFreeLocation;
	nextFreeLocation += SIZE;
}

struct Gsymbol* LAloneLookup(char* NAME)
{
	struct Gsymbol *i = LST;
	while(i != NULL)
	{
		if (strcmp(NAME, i->NAME) == 0)
			return i;
		i = i->NEXT;
	}
	
	return NULL;
}

struct Gsymbol *Llookup(char* NAME)
{
	if(LAloneLookup(NAME) != NULL)
		return LAloneLookup(NAME);

	struct Gsymbol *i = GST;
	i = GST;
	while(i != NULL)
	{
		if (strcmp(NAME, i->NAME) == 0)
			return i;
		i = i->NEXT;
	}
	
	return NULL;
}

void Linstall(char* NAME, int TYPE, int SIZE)
{
	struct Gsymbol *i;
	if(LAloneLookup(NAME)!=NULL)
	{
		printf("Multiple declaration of variable %s", NAME);
		exit(0);
	}

	if (LST == NULL)
	{
		LST = malloc(sizeof(struct Gsymbol));
		nextFreeBPRelativeLocation = 0;
		i = LST;
	}
	else
	{
		i = LST;
		while(i->NEXT != NULL)
			i = i->NEXT;

		i->NEXT = malloc(sizeof(struct Gsymbol));
		i = i->NEXT;
	}

	i->NAME = NAME;
	i->TYPE = TYPE;
	i->SIZE = SIZE;
	i->ARGLIST = NULL;
	i->NEXT = NULL;

	i->BINDING = nextFreeBPRelativeLocation;
	nextFreeBPRelativeLocation += SIZE;
}

void freeLST()
{
	struct Gsymbol* i = LST;
	while(i!= NULL)
	{
		LST= i->NEXT;
		free(i);
		i = LST;
	}
	LST = NULL;
}
