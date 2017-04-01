#include "typeTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct typeTable* GTT;

void typeTableCreate()
{
	if(GTT != NULL)
	{
		printf("typeTable created for a second time.\n");
		exit(0);
	}

	//Tinstall("integer", 1, NULL);
	GTT = malloc(sizeof(struct typeTable));
	GTT->name = "integer";
	GTT->size = 1;
	GTT->fields = NULL;
	GTT->next = NULL;

	Tinstall("intarr", 1, NULL);
	Tinstall("boolean", 1, NULL);
	Tinstall("boolarr", 1, NULL);
	Tinstall("void", 0, NULL);
	Tinstall("null", 0, NULL);

}

struct typeTable* Tlookup(char* name)
{
	if(GTT == NULL)
	{
		printf("typeTable not initilized.\n");
		exit(0);
	}

	struct typeTable* i = GTT;
	while(i != NULL)
	{
		if(strcmp(i->name, name) == 0)	
			return i;

		i = i->next;
	}

	printf("Warning:  Tlookup came out empty for %s.\n", name);
	return NULL;
}

struct typeTable* Tinstall(char *name, int size, struct fieldList *fields)
{
	if(GTT == NULL)
	{
		printf("typeTable not initilized.\n");
		exit(0);
	}
	
	struct typeTable* i = GTT;
	while(i->next != NULL)
	{
		if(strcmp(i->name, name) == 0)
		{
			printf("Warning: multiple Tinstalls for same type.\n");
			return NULL;
		}
		i = i->next;
	}

	i->next = malloc(sizeof(struct typeTable));
	i = i->next;

	i->name = name;
	i->size = size;
	i->fields = fields;
	i->next = NULL;

	return i;
	
}
struct fieldList* Flookup(struct typeTable *type, char *name)
{
	struct fieldList *i = type->fields;

	while(i != NULL)
	{
		if(strcmp(i->name, name) == 0)
			return i;

		i = i->next;
	}

	printf("Warning Flookup failed for %s.\n", name);
	return NULL;
}

struct fieldList* Fcreate(char *name, struct typeTable *type)
{
	struct fieldList* tmp = malloc(sizeof(struct fieldList*));
	tmp->name = name;
	tmp->type = type;
	tmp->next = NULL;
}

int getSize (struct typeTable *type)
{
	return type->size;	
}
