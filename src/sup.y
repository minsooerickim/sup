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

#include <stdlib.h>

int main(int argc, char *argv[]) {
    FILE *inputFile;

    if (argc > 1) {
        inputFile = fopen(argv[1], "r");
        if (!inputFile) {
            fprintf(stderr, "Error opening input file: %s\n", argv[1]);
            exit(1);
        }
        yyin = inputFile;
    }

    printf("Ctrl+D to quit\n");

    yyline_start = yytext;
    while (yyparse()) {
        yyline_start = yytext;
    }

    if (inputFile) {
        fclose(inputFile);
    }

    printf("\nSummary:\n");
    printf("Integers encountered: %d\n", integer_count);
    printf("Operators encountered: %d\n", operator_count);
    printf("Parentheses encountered: %d\n", parenthesis_count);
    printf("Equal signs encountered: %d\n", equal_count);
    printf("left bracket encounterd: %d\n", lbracket_count);
    printf("right bracket encounterd: %d\n", rbracket_count);
    printf("hashtags encounterd: %d\n", hashtag_count);

    return 0;
}