

struct Gsymbol {

	char *NAME; // Name of the Identifier

	struct typeTable* TYPE; // TYPE can be T_INT or T_BOOL

	/***The TYPE field must be a TypeStruct if user defined types are allowed***/

	int SIZE; // Size field for arrays

	int BINDING; // Address of the Identifier in Memory

	struct ArgStruct *ARGLIST; // Argument List for functions

	/***Argstruct must store the name and type of each argument ***/

	struct Gsymbol *NEXT; // Pointer to next Symbol Table Entry */

	int flabel;

};

struct ArgStruct {
	char* ARGNAME;
	struct typeTable* TYPE;
	struct ArgStruct *NEXT;
};

void appendArg(struct Gsymbol* symTableEntry, char *NAME, struct typeTable* TYPE);

struct Gsymbol *Glookup(char *NAME); // Look up for a global identifier
struct Gsymbol *Llookup(char *NAME); // Look up for a global identifier

void Ginstall(char *NAME, struct typeTable* TYPE, int SIZE); // Installation
void Linstall(char *NAME, struct typeTable* TYPE, int SIZE); // Installation

void freeLST();
