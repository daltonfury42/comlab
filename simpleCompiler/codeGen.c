#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "constants.h"
#include "symbolTable.h"
#include "exptree.h"
#include "codeGen.h"

int nextFreeReg = 0;
int labelTracker = 1;

int getReg()
{
	nextFreeReg++;
	if (nextFreeReg > 20)
	{
		printf("Register Leak Detected!\n");
		exit(0);
	}
	return nextFreeReg - 1;
}
void freeReg()
{

	nextFreeReg--;
	if(nextFreeReg < 0)
	{
		printf("Too many calls to freeReg()\n");
		exit(0);
	}
}

int getLabel()
{
	return labelTracker++;
}

void printHeader()
{
	fprintf(stdout, "MAGIC\n");
	fprintf(stdout, "2048\n");
	fprintf(stdout, "0\n0\n0\n0\n0\n0\n");
	fprintf(stdout, "START\n");
}

void printFooter()
{
	fprintf(stdout, "HALT\n");
}

int codeGen(struct Tnode* t)
{
	int r1, r2, r3, l1, l2;
	switch(t->NODETYPE){
		case CONSTANT:
			r1 = getReg();
			fprintf(stdout, "MOV R%d, %d\n", r1, t->VALUE);
			return r1;
			break;
		case PLUS:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(stdout, "ADD R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case SUB:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(stdout, "SUB R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case DIV:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(stdout, "DIV R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case MUL:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(stdout, "MUL R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case EQ:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(stdout, "EQ R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case GT:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(stdout, "GT R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case LT:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(stdout, "LT R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case STATEMENT:
			//did not do break/continue handling as in exptree
			codeGen(t->left);
			return codeGen(t->right);
			break;
		case READ:
			r1 = getReg();
			fprintf(stdout, "IN R%d\n", r1);
			fprintf(stdout, "MOV [%d], R%d\n", Glookup(t->NAME)->BINDING, r1);
			freeReg();
			return VOID;
			break;
		case WRITE:
			r1 = codeGen(t->left);
			fprintf(stdout, "OUT R%d\n", r1);
			freeReg();
			return VOID;
			break;
		case ID:
			r1 = getReg();
			fprintf(stdout, "MOV R%d, [%d]\n", r1, Glookup(t->NAME)->BINDING);
			return r1;
			break;
		case ASGN:
			r1 = codeGen(t->left);
			fprintf(stdout, "MOV [%d], R%d\n", Glookup(t->NAME)->BINDING, r1);
			freeReg();
			return VOID;
			break;
		case IF:
			if(t->middle != NULL)
			{
				r1 = codeGen(t->left);
				l1 = getLabel(); //Else
				l2 = getLabel(); //Endif
				fprintf(stdout, "JZ R%d, L%d\n", r1, l1);	
				codeGen(t->right);
				fprintf(stdout, "JMP L%d\n", l2);
				fprintf(stdout, "L%d:\n", l1);
				codeGen(t->middle);
				fprintf(stdout, "L%d:\n", l2);
			}
			else
			{
				r1 = codeGen(t->left);
				l1 = getLabel(); //Endif
				fprintf(stdout, "JZ R%d, L%d\n", r1, l1);	
				codeGen(t->right);
				fprintf(stdout, "L%d:\n", l1);
			}
			freeReg();
			return VOID;
			break;
		case WHILE:
			l1 = getLabel(); //start
			l2 = getLabel(); //end
			fprintf(stdout, "L%d:\n",l1);
			r1 = codeGen(t->left);
			fprintf(stdout, "JZ R%d, L%d\n", r1, l2);
			codeGen(t->right);
			fprintf(stdout, "L%d\n", l2);
			freeReg();
			return VOID;
			break;
		case ARROP:
			r1 = codeGen(t->right);
			r2 = getReg();
			fprintf(stdout, "MOV R%d, %d\n", r2, (Glookup(t->left->NAME) -> BINDING));
			fprintf(stdout, "ADD R%d, R%d\n", r1, r2);
			fprintf(stdout, "MOV R%d, [R%d]\n", r1, r1);
			freeReg();
			return r1;
			break;
		case ASGNARR:
			r1 = codeGen(t->left);
			r2 = getReg();
			fprintf(stdout, "MOV R%d, %d\n", r2, (Glookup(t->NAME) -> BINDING));
			fprintf(stdout, "ADD R%d, R%d\n", r1, r2);
			r3 = codeGen(t->right);
			fprintf(stdout, "MOV [R%d], R%d\n", r1, r3);
			freeReg();
			freeReg();
			return r1;
			break;
		default:
			printf("Default case(%d) executed in codeGen switch.\n", t->NODETYPE);
			exit(0);
	}
}
