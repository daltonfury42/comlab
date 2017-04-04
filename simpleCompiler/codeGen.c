#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"
#include "constants.h"
#include "symbolTable.h"
#include "typeTable.h"
#include "exptree.h"
#include "codeGen.h"

int nextFreeReg = 0;
int labelTracker = 1;
int funLabel = 1;
extern int nextFreeLocation;
extern FILE *fp;
extern struct Gsymbol* LST;


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
	fprintf(fp, "MOV SP, %d\n", nextFreeLocation-1);
	fprintf(fp, "MOV BP, %d\n", nextFreeLocation);
	fprintf(fp, "MOV R0,-1\n" );
	fprintf(fp, "MOV [BP],R0\n" );
	fprintf(fp, "ADD SP,5\n" );
	fprintf(fp, "CALL 0\n" );
	fprintf(fp, "SUB SP,5\n" );
	
	fprintf(fp, "JMP MAIN\n");
}

void printFooter()
{
	fprintf(fp, "INT 10\n");
}

void codeGenField(int r, struct Tnode* t)
{
	if(t->left == NULL)
		return;
	
	fprintf(fp, "ADD R%d, %d\n", r, Flookup(Llookup(t->NAME)->TYPE, t->left->NAME)->fieldIndex);
	if(t->left->left != NULL)
		fprintf(fp, "MOV R%d, [R%d]\n", r, r);
	codeGenField(r, t->left);
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
		case NEQ:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(fp, "NE R%d, R%d\n", r1, r2);
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
		case LE:
			r1 = codeGen(t->left);
			r2 = codeGen(t->right);
			fprintf(fp, "LE R%d, R%d\n", r1, r2);
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
			fprintf(fp, "MOV R%d, %d\n", r2, Llookup(t->NAME)->BINDING);
			if(Llookup(t->NAME)->BINDING < 4000)
				fprintf(fp, "ADD R%d, BP\n", r2);

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

			fprintf(fp, "INT 6\n");

			fprintf(fp, "POP R%d\n", r1); //return value
			fprintf(fp, "POP R%d\n", r1); //Arg3
			fprintf(fp, "POP R%d\n", r1); //Arg2
			fprintf(fp, "POP R%d\n", r1); //Arg1
			fprintf(fp, "POP R%d\n", r1); //Funct Code

			freeReg();

			for(r1=nextFreeReg-1; r1>=0; r1--)	//pop all pushed registers
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
			
			fprintf(fp, "INT 7\n", r2);

			fprintf(fp, "POP R%d\n", r1); //return value
			fprintf(fp, "POP R%d\n", r2); //Arg3
			fprintf(fp, "POP R%d\n", r2); //Arg2
			fprintf(fp, "POP R%d\n", r2); //Arg1
			fprintf(fp, "POP R%d\n", r2); //Funct. Code
			
			freeReg();

			for(r2=nextFreeReg-1; r2>=0; r2--)	//pop all pushed registers
				fprintf(fp, "POP R%d\n", r2);

			freeReg();

			return VOID;
			break;
		case ID:
			if(t->left == NULL)
			{
				r1 = getReg();
				fprintf(fp, "MOV R%d, %d\n", r1, Llookup(t->NAME)->BINDING);
				if(Llookup(t->NAME)->BINDING < 4000)
					fprintf(fp, "ADD R%d, BP\n", r1);
				fprintf(fp, "MOV R%d, [R%d]\n", r1, r1);
				return r1;
			}
			else
			{
				r1 = getReg();
				fprintf(fp, "MOV R%d, %d\n", r1, Llookup(t->NAME)->BINDING);
				if(Llookup(t->NAME)->BINDING < 4000)
					fprintf(fp, "ADD R%d, BP\n", r1);
				fprintf(fp, "MOV R%d, [R%d]\n", r1, r1);
				codeGenField(r1, t);		//NOTE: pass t not pass t->left
				return r1;
			}
			break;
		case ASGN:
			r1 = codeGen(t->left);
			r2 = getReg();
			fprintf(fp, "MOV R%d, %d\n", r2, Llookup(t->NAME)->BINDING);
			if(Llookup(t->NAME)->BINDING < 4000)
				fprintf(fp, "ADD R%d, BP\n", r2);
			fprintf(fp, "MOV [R%d], R%d\n", r2, r1);
			freeReg();
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
			fprintf(fp, "MOV R%d, %d\n", r2, (Llookup(t->left->NAME) -> BINDING));
			if(Llookup(t->left->NAME)->BINDING < 4000)
				fprintf(fp, "ADD R%d, BP\n", r2);
			fprintf(fp, "ADD R%d, R%d\n", r1, r2);
			fprintf(fp, "MOV R%d, [R%d]\n", r1, r1);
			freeReg();
			return r1;
			break;
		case ASGNARR:
			r1 = codeGen(t->left);
			r2 = getReg();
			fprintf(fp, "MOV R%d, %d\n", r2, (Llookup(t->NAME) -> BINDING));
			if(Llookup(t->NAME)->BINDING < 4000)
				fprintf(fp, "ADD R%d, BP\n", r2);
			fprintf(fp, "ADD R%d, R%d\n", r1, r2);
			r3 = codeGen(t->right);
			
			fprintf(fp, "MOV [R%d], R%d\n", r1, r3);
			freeReg();
			freeReg();
			return r1;
			break;
		case READARR:
			r1 = getReg(); //MEM ADDR TO READ TO
			fprintf(fp, "MOV R%d, %d\n", r1, (Llookup(t->NAME) -> BINDING));
			if(Llookup(t->NAME)->BINDING < 4000)
				fprintf(fp, "ADD R%d, BP\n", r1);
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

			fprintf(fp, "INT 6\n");

			fprintf(fp, "POP R%d\n", r2); //return value
			fprintf(fp, "POP R%d\n", r2); //Arg3
			fprintf(fp, "POP R%d\n", r2); //Arg2
			fprintf(fp, "POP R%d\n", r2); //Arg1
			fprintf(fp, "POP R%d\n", r2); //Runct Code


			for(r1=nextFreeReg-1; r1>=0; r1--)	//pop all pushed registers
				fprintf(fp, "POP R%d\n", r1);
			
			freeReg(); //R2
			
			freeReg();
			return VOID;
			break;
		case RETURN:
			r1 = codeGen(t->left);
			r2 = getReg();
			fprintf(fp, "MOV R%d, BP\n", r2);
			fprintf(fp, "SUB R%d, 2\n", r2);
			fprintf(fp, "MOV [R%d], R%d\n", r2, r1);
			freeReg();
			freeReg();
			return VOID;
			break;

		case FUNDEF:
			if(strcmp(t->NAME, "main") != 0)
			{
				Llookup(t->NAME)->flabel = funLabel;
				fprintf(fp, "F%d:\n", funLabel);
				funLabel++;
			}
			else
			{
				fprintf(fp, "MAIN:\n");
			}

			//Set BP, saving old BP on stack
			fprintf(fp, "PUSH BP\n");
			fprintf(fp, "MOV BP, SP\n");

			//SPACE for local variables in stack
			struct Gsymbol *i = LST;
			int size = 0;
			while(i != NULL)
			{
				if(i->BINDING >= 0)
					size++;
				i = i->NEXT;
			}
			fprintf(fp, "ADD SP, %d\n", size);

			//Generate code for the function
			codeGen(t->left);

			//Deallocate local variables, restore BP and return
			if(strcmp(t->NAME, "main") != 0)
			{
				fprintf(fp, "SUB SP, %d\n", size);
				fprintf(fp, "POP BP\n");
				fprintf(fp, "RET\n");
			}

			return VOID;
			break;
		case FUNCALL:
			//save machine registers
			for(r2=0; r2<nextFreeReg; r2++)
				fprintf(fp, "PUSH R%d\n", r2);

			//Push Arguments
			int argCount = 0;
			for(struct Tnode* ti = t->left; ti != NULL; ti = ti->ArgList)
			{
				r2 = evaluate(ti);
				fprintf(fp, "PUSH R%d\n", r2);
				freeReg();
				argCount ++;
			}

			//push space for return value
			r2 = getReg();
			fprintf(fp, "PUSH R%d\n", r2);
			freeReg();

			//CALL
			fprintf(fp, "CALL F%d\n", Glookup(t->NAME)->flabel);

			//save retrun value
			r1 = getReg();
			fprintf(fp, "POP R%d\n", r1);
			
			//POP out arguments
			fprintf(fp, "SUB SP, %d\n", argCount);

			
			//Restore machine registers
			for(r2=nextFreeReg-2; r2>=0; r2--)
				fprintf(fp, "POP R%d\n", r2);

			return r1;
			break;
		case BREAKPOINT:
			fprintf(fp, "BRKP\n", r2);
			return VOID;
			break;
		case ASGNFLD:
			r1 = codeGen(t->left);	//reference to the field
			r2 = codeGen(t->right); // exaluated result of expression to be assigned
			fprintf(fp, "MOV [R%d], R%d\n", r1, r2);
			freeReg();
			freeReg();
			return VOID;
			break;
		case EXPRFLD:
			r1 = codeGen(t->left);	//reference to the field
			fprintf(fp, "MOV R%d, [R%d]\n", r1, r1);
			return r1;
			break;
		case ALLOC:
			r2 = getReg();
			for(r1=0; r1<nextFreeReg-1; r1++)		//I don't want r2 to be saved, hence -1
				fprintf(fp, "PUSH R%d\n", r1);
			//Funct Code
			fprintf(fp, "MOV R%d,-2\n", r2);
			fprintf(fp, "PUSH R%d\n", r2);

			//Arg 1
			fprintf(fp, "MOV R%d,8\n", r2);
			fprintf(fp, "PUSH R%d\n", r2);

			fprintf(fp, "ADD SP, 3\n");

			fprintf(fp, "CALL 0\n");

			fprintf(fp, "POP R%d\n", r2); //return value
			fprintf(fp, "SUB SP, 4\n");

			for(r1=nextFreeReg-2; r1>=0; r1--)	//-2 because I don't want r2 to be restored
				fprintf(fp, "POP R%d\n", r1);
		
			if(t->left->left == NULL)
			{
				r1 = getReg();
				fprintf(fp, "MOV R%d, %d\n", r1, Llookup(t->left->NAME)->BINDING);
				if(Llookup(t->left->NAME)->BINDING < 4000)
					fprintf(fp, "ADD R%d, BP\n", r1);
			}
			else
				r1 = codeGen(t->left);	//reference to the field

			fprintf(fp, "MOV [R%d], R%d\n", r1, r2);

			freeReg();
			freeReg();

			return VOID;
			break;
		case NULLC:
			if (t->left != NULL) 	//(part of an asignment)
			{
				if (t->left->left != NULL)		//lvalue is a field 
					r1 = codeGen(t->left);
				else					//lvalue is a ID 
				{
					r1 = getReg();
					fprintf(fp, "MOV R%d, %d\n", r1, Llookup(t->left->NAME)->BINDING);
					if(Llookup(t->left->NAME)->BINDING < 4000)
						fprintf(fp, "ADD R%d, BP\n", r1);
				}
				
				fprintf(fp, "MOV [R%d], -1\n", r1);
				freeReg();
				return VOID;
			}
			else
			{
				r1 = getReg();
				fprintf(fp, "MOV R%d, -1\n", r1);
				return r1;
			}
			break;
		default:
			printf("Default case(%d) executed in codeGen switch.\n", t->NODETYPE);
			exit(0);
	}
}
