%{
    #include <stdio.h>
    #include <stdlib.h>

    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(const char* s);
%}

/* INCLUDE ALL tokens used in the .lex file here (all tokens from our README) */
%token INT INTEGER ARRAY SEMICOLON BRACKET COMMA SUB ADD MULT DIV MOD ASSIGNMENT NEQ LT GT LTE GTE EQ IF THEN ELSE WHILE CONTINUE BREAK READ WRITE NEWLINE RETURN L_BRACKET R_BRACKET L_PARENT R_PARENT IDENT MULTILINE_COMMENT

/* 'prog_start' is the start for our program */
%start prog_start

%%
    /* grammar rules go here */
    prog_start: %empty {printf("prog_start -> epsilon\n");}
                | functions {printf("prog_start -> functions\n"); };
    functions: function {printf("functions -> function\n");} // goes to one function
                | function functions {printf("functions -> function functions\n");}; // goes to multiple functions (recursive)
    function: IDENT L_PARENT arguments R_PARENT INT BRACKET statements BRACKET { printf("function -> IDENT L_PARENT arguments R_PARENT INT BRACKET statements BRACKET\n");} //define arguments and statements later
    arguments: %empty {printf("arguments -> epsilon\n");}
                | argument repeat_arguments {printf("arguments -> argument repeat_arguments\n");}
    repeat_arguments: %empty {printf("repeat_arguments -> epsilon\n");}
                    | COMMA argument repeat_arguments {printf("repeat_arguments -> COMMA argument repeat_arguments\n");}
    argument: %empty {printf("argument -> epsilon\n");}
                | INT IDENT {printf("argument -> INT IDENT\n");}
    statements: %empty {printf("statements -> epsilon\n");}
                | statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
    statement:  %empty {printf("statement -> epsilon\n");}
                | declaration {printf("statement -> declaration\n");}
                | function_call {printf("statement -> function_call\n");}
    declaration: INT IDENT {printf("declaration -> INT IDENT\n");}
    function_call: IDENT L_PARENT args R_PARENT {printf("function_call -> IDENT L_PARENT args R_PARENT\n");}
    args: %empty {printf("args -> epsilon\n");}
        | arg repeat_args {printf("args -> IDENT repeat_args\n");}
    arg: %empty {printf("arg -> epsilon\n");}
        | IDENT {printf("arg -> IDENT\n");}
    repeat_args: %empty {printf("repeat_args -> epsilon\n");}
                | COMMA arg repeat_args {printf("repeat_args -> COMMA arg repeat_args");}
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

    /* terminal input method */
    /* yyin = stdin;

    do {
        printf("Parse.\n");
        yyparse();
    } while(!feof(yyin)); */
    
    printf("Parsing done!\n");
    return 0;
}

void yyerror(const char* s) {
  fprintf(stderr, "Parse error: %s.", s);
  exit(1);
}