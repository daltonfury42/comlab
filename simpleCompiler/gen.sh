lex simCom.l && lex -P lt labelTranslate.l && yacc -d simCom.y && gcc -g symbolTable.c  exptree.c codeGen.c lex.yy.c lex.lt.c y.tab.c labelTranslate.c typeTable.c -g  && ./a.out input
if [ $? -eq 0 ] 
then
echo "Running the simulator with comiled code:"
cd xsm_expl/
./xsm -l lib.xsm -e ../xsm.out
cd ..
fi
