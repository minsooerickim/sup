%{
    #include <stdio.h>
    #include <stdlib.h>

    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(const char* s);
%}

/* INCLUDE ALL tokens used in the .lex file here (all tokens from our README) */
%token INT INTEGER ARRAY SEMICOLON BRACKET COMMA QUOTE SUB ADD MULT DIV MOD ASSIGNMENT NEQ LT GT LTE GTE EQ IF THEN ELSE WHILE CONTINUE BREAK READ WRITE NEWLINE RETURN L_BRACKET R_BRACKET L_PARENT R_PARENT IDENT MULTILINE_COMMENT

/* 'prog_start' is the start for our program */
%start prog_start

%%
    /* grammar rules go here */
    prog_start: %empty {printf("prog_start -> epsilon\n");}
                | functions {printf("prog_start -> functions\n"); }
                | statements {printf("prog_start -> statements\n");}
    functions: function {printf("functions -> function\n");} // goes to one function
                | function functions {printf("functions -> function functions\n");} // goes to multiple functions (recursive)
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
                | return {printf("statement -> return\n");}
                | array_access {printf("statement -> array_access\n");}
                | assignment {printf("statement -> assignment\n");}
                | operations {printf("statement -> operations\n");}
                | ifs {printf("statement -> ifs\n");}
                | whiles {printf("statement -> whiles\n");}
                | read {printf("statement -> read\n");}
                | write {printf("statement -> write\n");}
    declaration: INT IDENT {printf("declaration -> INT IDENT\n");}
                | INT IDENT L_BRACKET array_size R_BRACKET {printf("declaration -> INT IDENT L_BRACKET array_size R_BRACKET SEMICOLON\n");}
    array_size: %empty {printf("array_size -> epsilon\n");}
                | INTEGER {printf("array_size -> INTEGER\n");}
    function_call: IDENT L_PARENT args R_PARENT {printf("function_call -> IDENT L_PARENT args R_PARENT\n");}
    args: %empty {printf("args -> epsilon\n");}
        | arg repeat_args {printf("args -> IDENT repeat_args\n");}
    repeat_args: %empty {printf("repeat_args -> epsilon\n");}
                | COMMA arg repeat_args {printf("repeat_args -> COMMA arg repeat_args\n");}
    arg: %empty {printf("arg -> epsilon\n");}
        | IDENT {printf("arg -> IDENT\n");}
    ifs: if {printf("ifs -> if\n");}
        | if ifs {printf("ifs -> if ifs\n");} //nested if statements
    if: IF L_PARENT comparison R_PARENT BRACKET THEN BRACKET ifactions BRACKET ELSE BRACKET ifactions BRACKET BRACKET {printf("if -> IF L_PARENT comparison R_PARENT BRACKET THEN BRACKET ifactions BRACKET ELSE BRACKET ifactions BRACKET BRACKET\n");}
    whiles: while {printf("whiles -> while\n");}
            | while whiles {printf("whiles -> while whiles\n");} //nested while loops
    while: WHILE L_PARENT comparison R_PARENT BRACKET ifactions BRACKET {printf("while -> WHILE L_PARENT comparison R_PARENT BRACKET ifactions BRACKET\n");}
    comparison: IDENT compare IDENT {printf("comparison -> IDENT compare IDENT\n");}
                | IDENT compare INTEGER {printf("comparison -> IDENT compare INTEGER\n");}
                | INTEGER compare IDENT {printf("comparison -> INTEGER compare IDENT\n");}
                | INTEGER compare INTEGER {printf("comparison -> INTEGER compare INTEGER\n");}
    compare: EQ {printf("compare -> EQ\n");}
            | GT {printf("compare -> GT\n");}
            | LT {printf("compare -> LT\n");}
            | GTE {printf("compare -> GTE\n");}
            | LTE {printf("compare -> LTE\n");}
            | NEQ {printf("compare -> NEQ\n");}
    ifactions: statements {printf("ifactions -> statements\n");}
                | statements BREAK SEMICOLON {printf("ifactions -> statements BREAK SEMICOLON\n");}
                | statements CONTINUE SEMICOLON {printf("ifactions -> statements CONTINUE SEMICOLON\n");}
                | BREAK SEMICOLON {printf("ifactions -> BREAK SEMICOLON\n");}
                | CONTINUE SEMICOLON {printf("ifactions -> CONTINUE SEMICOLON\n");}
    read: READ IDENT SEMICOLON {printf("read -> READ IDENT SEMICOLON\n");}
    write: WRITE QUOTE content QUOTE SEMICOLON {printf("write -> WRITE QUOTE content QUOTE SEMICOLON\n");}
            | WRITE IDENT content SEMICOLON {printf("read -> READ IDENT content SEMICOLON\n");}
    content: %empty {printf("content -> epsilon\n");}
            | NEWLINE {printf("content -> NEWLINE\n");}
    array_access: IDENT L_BRACKET INTEGER R_BRACKET
    assignment: IDENT ASSIGNMENT IDENT {printf("assignment -> IDENT EQ IDENT\n");}
                | IDENT ASSIGNMENT INTEGER {printf("assignment -> IDENT EQ INTEGER\n");}
                | INT IDENT ASSIGNMENT IDENT {printf("assignment -> INT IDENT EQ IDENT\n");}
                | INT IDENT ASSIGNMENT INTEGER {printf("assignment -> INT IDENT EQ INTEGER\n");}
                | IDENT ASSIGNMENT operations {printf("assignment -> IDENT EQ operations\n");} //there is no operation without assignment
                | INT IDENT ASSIGNMENT operations {printf("assignment -> INT IDENT EQ operations\n");} //int a = 3+4
    operations: IDENT operation IDENT {printf("operations -> IDENT operation IDENT\n");}
                | IDENT operation INTEGER {printf("operations -> IDENT operation INTEGER\n");}
                | INTEGER operation IDENT {printf("operations -> INTEGER operation IDENT\n");}
                | INTEGER operation INTEGER {printf("operations -> INTEGER operation INTEGER\n");}
    operation: ADD {printf("operation -> ADD\n");}
                | SUB {printf("operation -> SUB\n");}
                | MULT {printf("operation -> MULT\n");}
                | DIV {printf("operation -> DIV\n");}
                | MOD {printf("operation -> MOD\n");}
    return: RETURN IDENT {printf("return -> RETURN IDENT\n");} //for right now we can only return a variable
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