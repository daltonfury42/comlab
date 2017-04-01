struct typeTable{
    char *name;                 //type name
    int size;                   //size of the type
    struct fieldList *fields;   //pointer to the head of fields list
    struct typeTable *next;     // pointer to the next type table entry
};

struct fieldList{
  char *name;              //name of the field
  int fieldIndex;          //the position of the field in the field list
  struct typeTable *type;  //pointer to type table entry of the field's type
  struct fieldList *next;  //pointer to the next field
};

void typeTableCreate();
struct typeTable* Tlookup(char* name);
struct typeTable* Tinstall(char *name, int size, struct fieldList *fields);
struct fieldList* Flookup(struct typeTable *type, char *name);
struct fieldList* Fcreate(char *name, struct typeTable *type);
int getSize (struct typeTable * type);
