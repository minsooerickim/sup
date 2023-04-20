all:
	flex sup.lex
	bison -v -d --file-prefix=y sup.y
	gcc -o parser lex.yy.c y.tab.c -lfl

clean:
	rm -f lexer parser lex.yy.c y.tab.c y.tab.h y.output