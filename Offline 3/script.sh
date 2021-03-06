#!/usr/bin/env bash
bison -d -y 1605053.y
echo 'step 1: bison -d -y 1605047_bison.y ..... completed'
g++ -w -c -o y.o y.tab.c
echo 'step 2: g++ -w -c -o y.o y.tab.c ...... completed'
flex 1605053.l
echo 'step 3: flex 1605047_flex.l ....... completed'
#g++ -w -c -o l.o lex.yy.c
g++ -fpermissive -w -c -o l.o lex.yy.c
# if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'step 4: g++ -w -c -o l.o lex.yy.c ....... completed'
g++ -o a.out y.o l.o -lfl -ly
echo 'step 5: g++ -o a.out y.o l.o -lfl -ly ....... completed'
./a.out input1.txt
echo 'step 6: ./a.out input.c ........ completed'

