#include <stdlib.h>
#include <stdio.h>
#include "exptree.h"

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
		      	evaluate(t->left);
		      	evaluate(t->right);
		      	return VOID;
		      	break;
	    	case READ:
		      	if(var[*(t->NAME) - 'a'] == NULL)
			      var[*(t->NAME) - 'a'] = malloc(sizeof(int));
			scanf("%d", var[*(t->NAME) - 'a']);
			return VOID;
			break;
		case WRITE:
			printf("%d", evaluate(t->left));
			return VOID;
			break;
		case ID:
			if(var[*(t->NAME) - 'a'] == NULL)
			{
				printf("Unallocated variable");
				exit(0);
			}
			return *var[*(t->NAME) - 'a'];
			break;
		case ASGN:
			if(var[*(t->NAME) - 'a'] == NULL)
			{
			      var[*(t->NAME) - 'a'] = malloc(sizeof(int));
			}
			*var[*(t->NAME) - 'a'] = evaluate(t->left);
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
				evaluate(t->right);
			return VOID;
			break;
			

		default:
			printf("Oops!");
			exit(0);	
	    
        }
    }
}


