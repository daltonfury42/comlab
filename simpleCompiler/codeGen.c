#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "constants.h"
#include "symbolTable.h"
#include "exptree.h"
#include "codeGen.h"

int nextFreeReg = 0;
int labelTracker = 1;
extern int nextFreeLocation;
extern FILE *fp;


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
	fprintf(fp, "0\n");
	fprintf(fp, "2056\n");
	fprintf(fp, "0\n0\n0\n0\n0\n0\n");
	fprintf(fp, "MOV SP, %d\n", nextFreeLocation);
}

void printFooter()
{
	fprintf(fp, "INT 10\n");
}

int codeGen(struct Tnode* t)
{
	int r1, r2, r3, l1, l2;
	switch(t->NODETYPE){
		case CONSTANT:
			r1 = getReg();
			fprintf(fp, "MOV R%d, %d\n", r1, t->VALUE);
			return r1;
			break;
		case PLUS:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(fp, "ADD R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case SUB:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(fp, "SUB R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case DIV:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(fp, "DIV R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case MUL:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(fp, "MUL R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case EQ:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(fp, "EQ R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case GT:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(fp, "GT R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case LT:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(fp, "LT R%d, R%d\n", r1, r2);
			freeReg();
			return r1;
			break;
		case STATEMENT:
			//did not do break/continue handling as in exptree
			codeGen(t->left);
			return codeGen(t->right);
			break;
		case READ:
			r2 = getReg();  //register to store result
			fprintf(fp, "MOV R%d, %d\n", r2, Glookup(t->NAME)->BINDING);

			for(r1=0; r1<nextFreeReg; r1++)
				fprintf(fp, "PUSH R%d\n", r1);

			r1 = getReg();  //register for push/pops

			//Funct Code
			fprintf(fp, "MOV R%d,\"Read\"\n", r1);
			fprintf(fp, "PUSH R%d\n", r1);

			//Arg 1
			fprintf(fp, "MOV R%d,-1\n", r1);
			fprintf(fp, "PUSH R%d\n", r1);

			//Arg2
			fprintf(fp, "MOV R%d,SP\n", r1);
			fprintf(fp, "SUB R%d,2\n", r1);
			fprintf(fp, "MOV R%d, [R%d]\n", r1, r1);
			fprintf(fp, "PUSH R%d\n", r1);

			//Arg3
			fprintf(fp, "PUSH R%d\n", r1);

			//Return Space
			fprintf(fp, "PUSH R%d\n", r1);

			fprintf(fp, "CALL 0\n");

			fprintf(fp, "POP R%d\n", r1); //return value
			fprintf(fp, "POP R%d\n", r1); //Arg3
			fprintf(fp, "POP R%d\n", r1); //Arg2
			fprintf(fp, "POP R%d\n", r1); //Arg1
			fprintf(fp, "POP R%d\n", r1); //Funct Code

			freeReg();

			for(r1=nextFreeReg-2; r1>=0; r1--)	//pop all pushed registers
				fprintf(fp, "POP R%d\n", r1);

			
			freeReg();

			return VOID;
			break;
		case WRITE:
			r1 = codeGen(t->left);
			for(r2=0; r2<nextFreeReg; r2++)
				fprintf(fp, "PUSH R%d\n", r2);

			r2 = getReg();

			//Function Code
			fprintf(fp, "MOV R%d,\"Write\"\n", r2);
			fprintf(fp, "PUSH R%d\n", r2);

			//Arg1
			fprintf(fp, "MOV R%d,-2\n", r2);
			fprintf(fp, "PUSH R%d\n", r2);

			//Arg2
			fprintf(fp, "MOV R%d,SP\n", r2);
			fprintf(fp, "SUB R%d,2\n", r2);
			fprintf(fp, "PUSH R%d\n", r2);

			//Arg3
			fprintf(fp, "PUSH R%d\n", r2);

			//Retrun Value
			fprintf(fp, "PUSH R%d\n", r2);
			
			fprintf(fp, "CALL 0\n", r2);

			fprintf(fp, "POP R%d\n", r1); //return value
			fprintf(fp, "POP R%d\n", r2); //Arg3
			fprintf(fp, "POP R%d\n", r2); //Arg2
			fprintf(fp, "POP R%d\n", r2); //Arg1
			fprintf(fp, "POP R%d\n", r2); //Funct. Code
			
			freeReg();

			for(r2=nextFreeReg-2; r2>=0; r2--)	//pop all pushed registers
				fprintf(fp, "POP R%d\n", r2);

			freeReg();

			return VOID;
			break;
		case ID:
			r1 = getReg();
			fprintf(fp, "MOV R%d, [%d]\n", r1, Glookup(t->NAME)->BINDING);
			return r1;
			break;
		case ASGN:
			r1 = codeGen(t->left);
			fprintf(fp, "MOV [%d], R%d\n", Glookup(t->NAME)->BINDING, r1);
			freeReg();
			return VOID;
			break;
		case IF:
			if(t->middle != NULL)
			{
				r1 = codeGen(t->left);
				l1 = getLabel(); //Else
				l2 = getLabel(); //Endif
				fprintf(fp, "JZ R%d, L%d\n", r1, l1);	
				codeGen(t->right);
				fprintf(fp, "JMP L%d\n", l2);
				fprintf(fp, "L%d:\n", l1);
				codeGen(t->middle);
				fprintf(fp, "L%d:\n", l2);
			}
			else
			{
				r1 = codeGen(t->left);
				l1 = getLabel(); //Endif
				fprintf(fp, "JZ R%d, L%d\n", r1, l1);	
				codeGen(t->right);
				fprintf(fp, "L%d:\n", l1);
			}
			freeReg();
			return VOID;
			break;
		case WHILE:
			l1 = getLabel(); //start
			l2 = getLabel(); //end
			fprintf(fp, "L%d:\n",l1);
			r1 = codeGen(t->left);
			fprintf(fp, "JZ R%d, L%d\n", r1, l2);
			codeGen(t->right);
			fprintf(fp, "JMP L%d\n", l1);
			fprintf(fp, "L%d:\n", l2);
			freeReg();
			return VOID;
			break;
		case ARROP:
			r1 = codeGen(t->right);
			r2 = getReg();
			fprintf(fp, "MOV R%d, %d\n", r2, (Glookup(t->left->NAME) -> BINDING));
			fprintf(fp, "ADD R%d, R%d\n", r1, r2);
			fprintf(fp, "MOV R%d, [R%d]\n", r1, r1);
			freeReg();
			return r1;
			break;
		case ASGNARR:
			r1 = codeGen(t->left);
			r2 = getReg();
			fprintf(fp, "MOV R%d, %d\n", r2, (Glookup(t->NAME) -> BINDING));
			fprintf(fp, "ADD R%d, R%d\n", r1, r2);
			r3 = codeGen(t->right);
			
			fprintf(fp, "MOV [R%d], R%d\n", r1, r3);
			freeReg();
			freeReg();
			return r1;
			break;
		case READARR:
			r1 = getReg(); //MEM ADDR TO READ TO
			fprintf(fp, "MOV R%d, %d\n", r1, (Glookup(t->NAME) -> BINDING));
			r2 = codeGen(t->left);
			fprintf(fp, "ADD R%d, R%d\n", r1, r2);

			for(r2=0; r2<nextFreeReg; r2++)
				fprintf(fp, "PUSH R%d\n", r2);


			//Funct Code
			fprintf(fp, "MOV R%d,\"Read\"\n", r2);
			fprintf(fp, "PUSH R%d\n", r2);

			//Arg 1
			fprintf(fp, "MOV R%d,-1\n", r2);
			fprintf(fp, "PUSH R%d\n", r2);

			//Arg2
			fprintf(fp, "MOV R%d,SP\n", r2);
			fprintf(fp, "SUB R%d,3\n", r2);
			fprintf(fp, "MOV R%d, [R%d]\n", r2, r2);
			fprintf(fp, "PUSH R%d\n", r2);

			//Arg3
			fprintf(fp, "PUSH R%d\n", r1);

			//Return Space
			fprintf(fp, "PUSH R%d\n", r2);

			fprintf(fp, "CALL 0\n");

			fprintf(fp, "POP R%d\n", r2); //return value
			fprintf(fp, "POP R%d\n", r2); //Arg3
			fprintf(fp, "POP R%d\n", r2); //Arg2
			fprintf(fp, "POP R%d\n", r2); //Arg1
			fprintf(fp, "POP R%d\n", r2); //Runct Code

			freeReg(); //R2

			for(r1=nextFreeReg-1; r1>=0; r1--)	//pop all pushed registers
				fprintf(fp, "POP R%d\n", r1);
			
			freeReg();
			return VOID;
			break;
		default:
			printf("Default case(%d) executed in codeGen switch.\n", t->NODETYPE);
			exit(0);
	}
}
