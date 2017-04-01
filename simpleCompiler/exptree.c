#include <stdlib.h>
#include <stdio.h>
#include "exptree.h"
#include "codeGen.h"
#include "symbolTable.h"
#include "constants.h"


struct Tnode* makeLeafNode(int n, struct typeTable* TYPE){
    struct Tnode *temp;
    temp = (struct Tnode*)malloc(sizeof(struct Tnode));
    bzero(temp, sizeof(struct Tnode));
    temp->TYPE= TYPE;
    temp->NODETYPE = CONSTANT;
    temp->VALUE = n;
    return temp;
}

struct Tnode* makeBinaryOperatorNode(int op, struct Tnode *l, struct Tnode *r, struct typeTable* TYPE){
    struct Tnode *temp;
    temp = (struct Tnode*)malloc(sizeof(struct Tnode));
    bzero(temp, sizeof(struct Tnode));
    temp->TYPE = TYPE;
    temp->NODETYPE = op;
    temp->left= l;
    temp->right = r;
    return temp;
}
struct Tnode *TreeCreate(struct typeTable* TYPE, int NODETYPE, char* NAME, int VALUE, struct Tnode* ArgList, struct Tnode* left, struct Tnode* right, struct Tnode* middle)
{
    struct Tnode *temp;
    temp = (struct Tnode*)malloc(sizeof(struct Tnode));
    bzero(temp, sizeof(struct Tnode));
    temp->TYPE = TYPE;	
    temp->NODETYPE= NODETYPE;	
    temp->NAME = NAME;	
    temp->VALUE = VALUE;	
    temp->ArgList = ArgList;	
    temp->left = left;	
    temp->right = right;	
    temp->middle = middle;	
}

int LTOA(int l)
{
	if(l == TRUE)
		return 1;
	else if(l == FALSE)
		return 0;
}

int ATOL(int a)
{
	if(a == 0)
		return FALSE;

	return TRUE;
}

int evaluate(struct Tnode *t){
	codeGen(t);
}

	/*
	int ret;
    if(t->NODETYPE == CONSTANT){
        return t->VALUE;
    }
    else{
        switch(t->NODETYPE){
            	case PLUS:
		      	return evaluate(t->left) + evaluate(t->right);
                      	break;
            	case SUB:
		      	return evaluate(t->left) - evaluate(t->right);
                      	break;
            	case MUL:
		      	return evaluate(t->left) * evaluate(t->right);
                      	break;
            	case DIV:
		      	return evaluate(t->left) / evaluate(t->right);
                      	break;
            	case EQ:
		      	return ATOL(evaluate(t->left) == evaluate(t->right));
                      	break;
            	case LT:
		      	return ATOL(evaluate(t->left) < evaluate(t->right));
                      	break;
            	case GT:
		      	return ATOL(evaluate(t->left) > evaluate(t->right));
                      	break;
	    	case STATEMENT:
			ret = evaluate(t->left);
			if (ret == BREAK)
				return BREAK;
			else if (ret == CONTINUE)
				return CONTINUE;
		      	return evaluate(t->right);
		      	break;
	    	case READ:
			if(Glookup(t->NAME)  == NULL)
			{
				printf("Unallocated variable '%s'", t->NAME);
				exit(0);
			}
			
			if(!scanf("%d", (Glookup(t->NAME) -> BINDING)))
			{
				printf("Runtime type checker warning!");
			}
			return VOID;
			break;
	    	case READARR:
			if(Glookup(t->NAME)  == NULL)
			{
				printf("Unallocated variable '%s'", t->NAME);
				exit(0);
			}
			ret = evaluate(t->left);
			if(!scanf("%d", (Glookup(t->NAME) -> BINDING)+ret))
			{
				printf("Runtime type checker warning!");
			}
			return VOID;
			break;
		case WRITE:
			ret = evaluate(t->left);
			if (ret == TRUE)
				printf("TRUE\n");
			else if (ret == FALSE)
				printf("FALSE");
			else
				printf("%d\n", ret);
			return VOID;
			break;
		case ID:
			if(Glookup(t->NAME)  == NULL)
			{
				printf("Unallocated variable %s.\n", t->NAME);
				exit(0);
			}
			return *(Glookup(t->NAME) -> BINDING);
			break;
		case ASGN:
			if(Glookup(t->NAME)  == NULL)
			{
				printf("Unallocated variable '%s'", t->NAME);
				exit(0);
			}
			*(Glookup(t->NAME) -> BINDING) = evaluate(t->left);
			return VOID;
			break;
		case ASGNARR:
			if(Glookup(t->NAME)  == NULL)
			{
				printf("Unallocated variable '%s'", t->NAME);
				exit(0);
			}
			*(Glookup(t->NAME) -> BINDING + evaluate(t->left)) = evaluate(t->right);
			return VOID;
			break;

		case IF:
			if(LTOA(evaluate(t->left)))
				return evaluate(t->right);
			else if(t->middle != NULL)
				return evaluate(t->middle);
			else 
				return VOID;
			break;
		case WHILE:
			while(LTOA(evaluate(t->left)))
			{
				ret = evaluate(t->right);
				if(ret == BREAK)
					break;
				else if (ret == CONTINUE)
					continue;
			}
			return VOID;
			break;
		case BREAK:
			return BREAK;
			break;		
		case CONTINUE:
			return CONTINUE;
			break;		
		case ARROP:
			ret = evaluate(t->right);
			return *((Glookup(t->left->NAME) -> BINDING) + ret);
			break;
		default:
			printf("Oops!");
			exit(0);	
	    
        }
    }
}

*/
