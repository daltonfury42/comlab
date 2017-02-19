#include "symbolTable.h"
#include "constants.h"
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

extern struct Gsymbol * GST;
int nextFreeLocation = 0;

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

	i->BINDING = nextFreeLocation;
	nextFreeLocation += SIZE;
}
