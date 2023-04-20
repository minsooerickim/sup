%{
    
%}

/* INCLUDE ALL tokens used in the .lex file here (all tokens from our README) */
%token INTEGER, ARRAY, SEMICOLON, BRACKET, COMMA, SUB, ADD, MULT, DIV, MOD, ASSIGNMENT, NEQ, LT, GT, LTE, GTE, EQ, IF, THEN, ELSE, WHILE, CONTINUE, BREAK, READ, WRITE, NEWLINE, RETURN

/* 'prog_start' is the start for our program */
%start prog_start

%%
    /* grammar rules go here */
    prog_start: %empty {printf("prog_start -> epsilon\n");}
                | functions {printf("prog_start -> functions\n"); };
%%