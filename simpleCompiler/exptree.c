#include <stdlib.h>
#include <stdio.h>
#include "exptree.h"
#include "symbolTable.h"

extern int* var[26];

struct Tnode* makeIntegerLeafNode(int n){
    struct Tnode *temp;
    temp = (struct Tnode*)malloc(sizeof(struct Tnode));
    bzero(temp, sizeof(struct Tnode));
    temp->TYPE= NUM;
    temp->NODETYPE = NUM;
    temp->VALUE = n;
    return temp;
}

struct Tnode* makeBinaryOperatorNode(int op, struct Tnode *l, struct Tnode *r){
    struct Tnode *temp;
    temp = (struct Tnode*)malloc(sizeof(struct Tnode));
    bzero(temp, sizeof(struct Tnode));
    temp->TYPE = NUM;
    temp->NODETYPE = op;
    temp->left= l;
    temp->right = r;
    return temp;
}
struct Tnode *TreeCreate(int TYPE, int NODETYPE, char* NAME, int VALUE, struct Tnode* ArgList, struct Tnode* left, struct Tnode* right, struct Tnode* middle)
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

int evaluate(struct Tnode *t){
	int ret;
    if(t->NODETYPE == NUM){
        return t->VALUE;
    }
    else{
        switch(t->NODETYPE){
            	case PLUS:
		      	return evaluate(t->left) + evaluate(t->right);
                      	break;
            	case MUL:
		      	return evaluate(t->left) * evaluate(t->right);
                      	break;
            	case EQ:
		      	return evaluate(t->left) == evaluate(t->right);
                      	break;
            	case LT:
		      	return evaluate(t->left) < evaluate(t->right);
                      	break;
            	case GT:
		      	return evaluate(t->left) > evaluate(t->right);
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
				printf("Unallocated variable");
				exit(0);
			}
			
			scanf("%d", (Glookup(t->NAME) -> BINDING));
			return VOID;
			break;
		case WRITE:
			printf("%d", evaluate(t->left));
			return VOID;
			break;
		case ID:
			if(Glookup(t->NAME)  == NULL)
			{
				printf("Unallocated variable");
				exit(0);
			}
			return *(Glookup(t->NAME) -> BINDING);
			break;
		case ASGN:
			if(Glookup(t->NAME)  == NULL)
			{
				printf("Unallocated variable");
				exit(0);
			}
			*(Glookup(t->NAME) -> BINDING) = evaluate(t->left);
			return VOID;
			break;
		case IF:
			if(evaluate(t->left))
				return evaluate(t->right);
			else if(t->middle != NULL)
				return evaluate(t->middle);
			else 
				return VOID;
			break;
		case WHILE:
			while(evaluate(t->left))
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
		default:
			printf("Oops!");
			exit(0);	
	    
        }
    }
}


