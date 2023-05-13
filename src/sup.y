%{
    #include <stdio.h>
    #include <stdlib.h>
    // int yylineno = 1;
    extern int line_count;
    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(const char* s);
%}

%define parse.error verbose
/* INCLUDE ALL tokens used in the .lex file here (all tokens from our README) */
%token INT INTEGER ARRAY SEMICOLON BRACKET COMMA QUOTE SUB ADD MULT DIV MOD ASSIGNMENT NEQ LT GT LTE GTE EQ IF THEN ELSE WHILE CONTINUE BREAK READ WRITE RETURN L_BRACKET R_BRACKET L_PARENT R_PARENT IDENT MULTILINE_COMMENT

/* 'prog_start' is the start for our program */
%start prog_start

%%
    /* grammar rules go here */
    prog_start: %empty
                | functions
                | statements
    functions: function // goes to one function
                | function functions // goes to multiple functions (recursive)
    function: IDENT L_PARENT arguments R_PARENT INT BRACKET statements BRACKET //define arguments and statements later
    arguments: %empty
                | argument repeat_arguments
    repeat_arguments: %empty
                    | COMMA argument repeat_arguments 
    argument: INT IDENT 
    statements: %empty 
                | statement SEMICOLON statements 
                | ifs statements
                | whiles statements
    statement:  %empty 
                | declaration 
                | function_call 
                | return 
                | array_access 
                | assignment 
                | operations 
                | read 
                | write 
    declaration: INT IDENT 
                | INT IDENT L_BRACKET array_size R_BRACKET 
    array_size: %empty 
                | INTEGER 
    function_call: IDENT L_PARENT args R_PARENT 
    args: %empty 
        | arg repeat_args 
    repeat_args: %empty 
                | COMMA arg repeat_args 
    arg: %empty 
        | IDENT 
        | operations 
    ifs: IF L_PARENT comparison R_PARENT BRACKET THEN BRACKET statements terminals BRACKET else BRACKET 
    else: %empty 
        | ELSE BRACKET statements terminals BRACKET 
    whiles: WHILE L_PARENT comparison R_PARENT BRACKET statements terminals BRACKET 
    comparison: IDENT compare IDENT 
                | IDENT compare INTEGER 
                | INTEGER compare IDENT 
                | INTEGER compare INTEGER 
    compare: EQ 
            | GT 
            | LT 
            | GTE 
            | LTE 
            | NEQ 
    terminals: %empty 
            | BREAK SEMICOLON
            | CONTINUE SEMICOLON
    read: READ IDENT 
    write: WRITE INTEGER 
            | WRITE IDENT 
            | WRITE array_access 
    array_access: IDENT L_BRACKET INTEGER R_BRACKET
    assignment: IDENT ASSIGNMENT IDENT 
                | IDENT ASSIGNMENT INTEGER 
                | INT IDENT ASSIGNMENT IDENT 
                | INT IDENT ASSIGNMENT INTEGER 
                | IDENT ASSIGNMENT operations 
                | INT IDENT ASSIGNMENT operations 
                | IDENT ASSIGNMENT function_call 
                | INT IDENT ASSIGNMENT function_call 
                | array_access ASSIGNMENT operations 
                | array_access ASSIGNMENT INTEGER 
                | array_access ASSIGNMENT IDENT 
    expr: IDENT 
        | INTEGER 
        | array_access 
        | L_PARENT expr operation expr R_PARENT 
    operations: expr operation expr 
    operation: ADD 
                | SUB 
                | MULT 
                | DIV 
                | MOD 
    return: RETURN IDENT 
            | RETURN INTEGER 
            | RETURN statement 
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

    /* int c;
    while ((c = fgetc(yyin)) != EOF) { // count newlines in input file
        if (c == '\n') {
            line_count++;
        }
    } */
    rewind(yyin); // reset file pointer to beginning of file

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
  fprintf(stderr, "Parse error on line %d: %s\n", line_count, s);
  exit(1);
}