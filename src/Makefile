all: phase3
sup.tab.c sup.tab.h:	sup.y
	bison -t -v -d sup.y
lex.yy.c: sup.lex sup.tab.h
	flex sup.lex 
phase3: lex.yy.c sup.tab.c sup.tab.h
	g++ -g -std=c++11 -o phase3 sup.tab.c lex.yy.c -lfl
clean:
	rm phase3 sup.tab.c lex.yy.c sup.tab.h sup.output
