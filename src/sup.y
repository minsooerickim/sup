%{
    #include <stdio.h>
    #include <string>
    #include <vector>
    #include <string.h>
    #include <stdlib.h>

    // int yylineno = 1;
    extern int line_count;
    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(const char* s);

    // phase 3
    char *identToken;
    int numberToken;
    
    enum Type { Integer, Array };

    struct Symbol {
        std::string name;
        Type type;
    };

    struct Function {
        std::string name;
        std::vector<Symbol> declarations;
    };

    // SYMBOL TABLE STUFF
    std::vector <Function> symbol_table;

    // remember that Bison is a bottom up parser: that it parses leaf nodes first before
    // parsing the parent nodes. So control flow begins at the leaf grammar nodes
    // and propagates up to the parents.
    Function *get_function() {
        int last = symbol_table.size()-1;
        if (last < 0) {
            printf("***Error. Attempt to call get_function with an empty symbol table\n");
            printf("Create a 'Function' object using 'add_function_to_symbol_table' before\n");
            printf("calling 'find' or 'add_variable_to_symbol_table'");
            exit(1);
        }
        return &symbol_table[last];
    }

    // find a particular variable using the symbol table.
    // grab the most recent function, and linear search to
    // find the symbol you are looking for.
    // you may want to extend "find" to handle different types of "Integer" vs "Array"
    bool find(std::string &value) {
        Function *f = get_function();
        for(int i=0; i < f->declarations.size(); i++) {
            Symbol *s = &f->declarations[i];
            if (s->name == value) {
            return true;
            }
        }
        return false;
    }

    // when you see a function declaration inside the grammar, add
    // the function name to the symbol table
    void add_function_to_symbol_table(std::string &value) {
        Function f; 
        f.name = value; 
        symbol_table.push_back(f);
    }

    // when you see a symbol declaration inside the grammar, add
    // the symbol name as well as some type information to the symbol table
    void add_variable_to_symbol_table(std::string &value, Type t) {
        Symbol s;
        s.name = value;
        s.type = t;
        Function *f = get_function();
        f->declarations.push_back(s);
    }

    // a function to print out the symbol table to the screen
    // largely for debugging purposes.
    void print_symbol_table(void) {
        printf("symbol table:\n");
        printf("--------------------\n");
        for(int i=0; i<symbol_table.size(); i++) {
            printf("function: %s\n", symbol_table[i].name.c_str());
            for(int j=0; j<symbol_table[i].declarations.size(); j++) {
            printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
            }
        }
        printf("--------------------\n");
    }

    struct CodeNode {
        std::string code; // generated code as a string.
        std::string name;
    };
%}

%define parse.error verbose

%union {
    int int_val;
    char *op_val;
    struct CodeNode *node;
}

/* INCLUDE ALL tokens used in the .lex file here (all tokens from our README) */
%token INT ARRAY SEMICOLON BRACKET COMMA QUOTE SUB ADD MULT DIV MOD ASSIGNMENT NEQ LT GT LTE GTE EQ IF THEN ELSE WHILE CONTINUE BREAK READ WRITE RETURN L_BRACKET R_BRACKET L_PARENT R_PARENT MULTILINE_COMMENT

%token <op_val> INTEGER 
%token <op_val> IDENT
%type  <op_val> array_size
%type  <node>   declaration
%type  <node>   functions
%type  <node>   function
%type  <node>   function_call
%type  <node>   statements
%type  <node>   statement
%type  <node>   read
%type  <node>   arguments
%type  <node>   argument
%type  <node>   assignment
%type  <node>   args
%type  <node>   arg
%type  <node>   expr
%type  <node>   operations
%type  <node>   array_access



/* 'prog_start' is the start for our program */
%start prog_start

%%
    /* grammar rules go here */
    prog_start: 
        %empty
        | 
        functions {
            // this happens last.
            CodeNode *node = $1;
            std::string code = node->code;
            printf("Generated code:\n");
            printf("%s\n", code.c_str());
        }
        | 
        statements {
            // this happens last.
            CodeNode *node = $1;
            std::string code = node->code;
            printf("Generated code:\n");
            printf("%s\n", code.c_str());
        }

    functions: 
        function // goes to one function
        | 
        function functions // goes to multiple functions (recursive)
    
    function: 
        IDENT L_PARENT arguments R_PARENT INT BRACKET statements BRACKET {
            std::string func_name = $1;
            CodeNode *arguments = $3;
            CodeNode *statements  = $7;
            add_function_to_symbol_table(func_name);

            std::string code = std::string("func ") + func_name + std::string("\n");
            
            code += arguments->code;
            code += statements->code;
            code += std::string("endfunc\n");

            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node;
        }

    arguments: 
        %empty {
            CodeNode *node = new CodeNode;
            $$ = node;
            node->code = "";
        }
        | 
        argument repeat_arguments

    repeat_arguments: 
        %empty
        | 
        COMMA argument repeat_arguments 
        
    argument: 
        INT IDENT {
            std::string value = $2;
            
            Type t = Integer;
            add_variable_to_symbol_table(value, t);

            std::string code = std::string(". ") + value + std::string("\n");
            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node;
        }
    
    statements: 
        %empty {
            CodeNode *node = new CodeNode;
            node->code = "";
            $$ = node;
        }
        | 
        statement SEMICOLON statements {
            CodeNode *stmt1 = $1;
            CodeNode *stmt2 = $3;
            CodeNode *node = new CodeNode;
            node->code = stmt1->code + stmt2->code;
            $$ = node;
        };
        | 
        ifs statements {}
        | 
        whiles statements {}

    statement:  
        %empty {
            CodeNode *node = new CodeNode;
            node->code = "";
            $$ = node;
        }
        | declaration 
        | function_call 
        | return {}
        | array_access 
        | assignment 
        | operations 
        | read 
        | write {}
    
    declaration: 
        INT IDENT {
            std::string value = $2;
            Type t = Integer;
            add_variable_to_symbol_table(value, t);

            std::string code = std::string(". ") + value + std::string("\n");
            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node;
        } 
        | 
        INT IDENT L_BRACKET array_size R_BRACKET {
            std::string value = $2;
            std::string array_size = $4;

            Type t = Array;
            add_variable_to_symbol_table(value, t);

            std::string code = std::string(".[] ") + value + std::string(",") + array_size + std::string("\n");
            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node;
        }

    array_size: 
        %empty {}
        | 
        INTEGER 

    function_call: 
        IDENT L_PARENT args R_PARENT {
            std::string value = $1;
            CodeNode *args = $3;

            // TODO: syntax on https://www.cs.ucr.edu/~dtan004/proj3/mil.html is a bit different, you need ', dst' but idk how we're supposed to grab that in this grammar
            std::string code = std::string("call ") + value + std::string("\n");
            CodeNode *node = new CodeNode;

            node->code = args->code + code;
            $$ = node;
        }
    
    args: 
        %empty {
            CodeNode *node = new CodeNode;
            node->code = "";
            $$ = node;
        }
        | 
        arg repeat_args

    repeat_args: 
        %empty 
        | 
        COMMA arg repeat_args 

    arg: 
        %empty {
            CodeNode *node = new CodeNode;
            node->code = "";
            $$ = node;
        }
        | 
        IDENT {
            std::string value = $1;
            std::string code = std::string("param ") + value + std::string("\n");

            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node;
        }
        | 
        operations 

    ifs: 
        IF L_PARENT comparison R_PARENT BRACKET THEN BRACKET statements terminals BRACKET else BRACKET 
    
    else: 
        %empty 
        | 
        ELSE BRACKET statements terminals BRACKET 
    
    whiles: 
        WHILE L_PARENT comparison R_PARENT BRACKET statements terminals BRACKET 
    
    comparison: 
        IDENT compare IDENT 
        | 
        IDENT compare INTEGER 
        | 
        INTEGER compare IDENT 
        | 
        INTEGER compare INTEGER 

    compare: 
        EQ 
        | 
        GT 
        | 
        LT 
        | 
        GTE 
        | 
        LTE 
        | 
        NEQ

    terminals: 
        %empty 
        | 
        BREAK SEMICOLON
        | 
        CONTINUE SEMICOLON
    
    read: 
        READ IDENT {
            std::string value = $2;

            std::string code = std::string(".< ") + value + std::string("\n");
            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node;
        }
    
    write: 
        WRITE INTEGER 
        | 
        WRITE IDENT 
        | 
        WRITE array_access 
    
    array_access: 
        IDENT L_BRACKET INTEGER R_BRACKET {
            
        }
    
    assignment: 
        IDENT ASSIGNMENT IDENT { 
            std::string first_var = $1;
            std::string second_var = $3;

            CodeNode *node = new CodeNode;
            node->code = std::string("= ") + first_var + std::string(", ") + $3 + std::string("\n");
            $$ = node;
        } 
        | 
        IDENT ASSIGNMENT INTEGER {
            std::string first_var = $1;
            
            CodeNode *node = new CodeNode;
            node->code = std::string("= ") + first_var + std::string(", ") + $3 + std::string("\n");
            $$ = node;
        } 
        /*
        | 
            INT IDENT ASSIGNMENT IDENT { 
            std::string first_var = $2;
            Type t = Integer;
            add_variable_to_symbol_table(first_var, t);

            std::string code = std::string(". ") + first_var + std::string("\n");
            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node; 

            Type t = Integer;
            CodeNode *node = new CodeNode;
            node->code = $4->code;
            node->code = std::string("= ") + first_var + std::string(", ") + $4->name + std::string("\n");
            $$ = node;
        }
        |*/ 
        /* INT IDENT ASSIGNMENT INTEGER {
            std::string first_var = $2;
            Type t = Integer;
            add_variable_to_symbol_table(first_var, t);

            std::string code = std::string(". ") + first_var + std::string("\n");
            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node; 

            Type t = Integer;
            CodeNode *node = new CodeNode;
            node->code = $4->code;
            node->code = std::string("= ") + first_var + std::string(", ") + $4->name + std::string("\n");
            $$ = node;
        }
        | 
        IDENT ASSIGNMENT operations {
            std::string first_var = $1;
            CodeNode *node = new CodeNode;
            node->code = $3->code;
            node->code += std::string("= ") + first_var + std::string(", ") + $3->name + std::string("\n");
            $$ = node;
        }
        | 
        INT IDENT ASSIGNMENT operations {
            std::string first_var = $2;
            Type t = Integer;
            add_variable_to_symbol_table(first_var, t);

            std::string code = std::string(". ") + first_var + std::string("\n");
            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node; 

            Type t = Integer;
            CodeNode *node = new CodeNode;
            node->code = $4->code;
            node->code += std::string("= ") + first_var + std::string(", ") + $4->name + std::string("\n");
            $$ = node;
        }
        | 
        IDENT ASSIGNMENT function_call {}
        | 
        INT IDENT ASSIGNMENT function_call {} */
        /* | 
        array_access ASSIGNMENT operations {
            std::string first_var = $1;
            
            CodeNode *node = new CodeNode;
            node->code = $6->code           //Q: we are not allowing expressions for array index right?
            node->code += std::string("[] ") + std::string($1) + std::string(", ") + $3->name + std::string(", ") + $6->name + std::string("/n");  
            $$ = node;
        }
        | 
        array_access ASSIGNMENT INTEGER {
            std::string first_var = $1;
            
            CodeNode *node = new CodeNode;
            node->code = $6->code          
            node->code = std::string("[] ") + std::string($1) + std::string(", ") + $3->name + std::string(", ") + $6->name + std::string("/n");  
            $$ = node;
        }
        | 
        array_access ASSIGNMENT IDENT {
            std::string first_var = $1;
            
            CodeNode *node = new CodeNode;
            node->code = $6->code          
            node->code = std::string("[] ") + std::string($1) + std::string(", ") + $3->name + std::string(", ") + $6->name + std::string("/n");  
            $$ = node;
        } */
        
    expr: 
        IDENT {
            // CodeNode *declaration = $1;
            // CodeNode *node = new CodeNode;
            // node->code = declaration->code;
            // $$ = node;
        }
        | 
        INTEGER {}
        | 
        array_access {}
        | 
        L_PARENT expr operation expr R_PARENT {}
    
    operations: 
        expr operation expr 
    
    operation: 
        ADD 
        | 
        SUB 
        | 
        MULT 
        | 
        DIV 
        | 
        MOD 

    return: 
        RETURN IDENT 
        | 
        RETURN INTEGER 
        | 
        RETURN statement 
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

    print_symbol_table();

    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Parse error on line %d: %s\n", line_count, s);
    exit(1);
}