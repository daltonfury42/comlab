lex simCom.l && lex -P lt labelTranslate.l && yacc -d simCom.y && gcc -g symbolTable.c  exptree.c codeGen.c lex.yy.c lex.lt.c y.tab.c labelTranslate.c && ./a.out input
echo "Running the simulator with comiled code:"
cd xsm_expl/
./xsm -e ../xsm.out
cd ..
