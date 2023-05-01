%{
    #include <stdio.h>
    #include <stdlib.h>

    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(const char* s);
%}

/* INCLUDE ALL tokens used in the .lex file here (all tokens from our README) */
%token INTEGER ARRAY SEMICOLON BRACKET COMMA SUB ADD MULT DIV MOD ASSIGNMENT NEQ LT GT LTE GTE EQ IF THEN ELSE WHILE CONTINUE BREAK READ WRITE NEWLINE RETURN L_BRACKET R_BRACKET L_PARENT R_PARENT VARIABLE WORD MULTILINE_COMMENT

/* 'prog_start' is the start for our program */
%start prog_start

%%
    /* grammar rules go here */
    prog_start: %empty {printf("prog_start -> epsilon\n");}
                | functions {printf("prog_start -> functions\n"); };
    functions: function {printf("functions -> function");} // goes to one function
                | function functions {printf("functions -> function functions");}; // goes to multiple functions (recursive)
    function: VARIABLE L_PARENT arguments R_PARENT INTEGER BRACKET statements BRACKET { printf("function -> INT IDENT LPR arguments RPR LBR statements RBR\n");} //define arguments and statements later
    arguments: %empty {printf("arguments -> epsilon\n");}
                | argument repeat_arguments {printf("arguments -> argument repeat_arguments");}
    repeat_arguments: %empty {printf("repeat_arguments -> epsilon");}
                    | COMMA argument repeat_arguments {printf("repeat_arguments -> COMMA argument repeat_arguments");}
    argument: %empty {printf("argument -> epsilon");}
                | INTEGER VARIABLE {printf("argument -> INTEGER VARIABLE");}

    statements: %empty {printf("argument -> epsilon");}
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

    do {
        printf("Parse.\n");
        yyparse();
    } while(!feof(yyin));
    
    printf("Parsing done!\n");
    return 0;
}

void yyerror(const char* s) {
  fprintf(stderr, "Parse error: %s.", s);
  exit(1);
}