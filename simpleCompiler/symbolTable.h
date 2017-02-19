

struct Gsymbol {

	char *NAME; // Name of the Identifier

	int TYPE; // TYPE can be T_INT or T_BOOL

	/***The TYPE field must be a TypeStruct if user defined types are allowed***/

	int SIZE; // Size field for arrays

	int BINDING; // Address of the Identifier in Memory

//	ArgStruct *ARGLIST; // Argument List for functions

	/***Argstruct must store the name and type of each argument ***/

	struct Gsymbol *NEXT; // Pointer to next Symbol Table Entry */

};

struct Gsymbol *Glookup(char *NAME); // Look up for a global identifier

void Ginstall(char *NAME, int TYPE, int SIZE); // Installation
