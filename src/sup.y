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
    bool find(std::string &value, Type type) {
        Function *f = get_function();
        for (int i = 0; i < f->declarations.size(); i++) {
            Symbol *s = &f->declarations[i];
            if (s->name == value && s->type == type) {
                return true;
            }
        }
        return false;
    }
    //separate find function
    bool iterate_functions(std::string &function_name){
        for(int i = 0; i < symbol_table.size(); i++){
            Function *func = &symbol_table[i];
            if(func->name.c_str() == function_name){
                return true;
            }
        }
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

    std::string get_arg_index() {
        Function *f = get_function();
        int size = f->declarations.size();
        std::string str_size = std::to_string(size - 1);
        return str_size;
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
        std::string var;
        std::string arr_idx;
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
%type  <int_val> array_size
%type  <node>   add_fn_to_symb_tbl
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
%type  <node>   operation
%type  <node>   array_access
%type  <node>   repeat_args
%type  <node>   write
%type  <node>   return
%type  <node>   repeat_arguments



/* 'prog_start' is the start for our program */
%start prog_start

%%
    /* grammar rules go here */
    prog_start: 
        %empty {}
        | 
        functions {
            // this happens last.
            CodeNode *node = $1;
            std::string code = node->code;
            printf("\n");
            printf("%s\n", code.c_str());

            std::string main_func = "main";
            std::string fn_call_fn_error = "The function main has not been declared in the program yet\n";
            if(!iterate_functions(main_func)){
                yyerror(fn_call_fn_error.c_str());
            }
        }

    functions: 
        function {// goes to one function
            $$ = $1;
        }
        | 
        function functions { // goes to multiple functions (recursive)
            CodeNode *fn = $1;
            CodeNode *fns = $2;

            CodeNode *node = new CodeNode;
            node->code = fn->code + fns->code;
            $$ = node;
        }
    
    function: 
        add_fn_to_symb_tbl L_PARENT arguments R_PARENT INT BRACKET statements BRACKET {
            CodeNode *add_fn_to_symb_tbl_node = $1;
            CodeNode *arguments = $3;
            CodeNode *statements  = $7;

            std::string func_name = add_fn_to_symb_tbl_node->name;

            std::string code = std::string("func ") + func_name + std::string("\n");
            
            code += arguments->code;
            code += statements->code;
            code += std::string("endfunc\n");

            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node;
        }

    add_fn_to_symb_tbl:
        IDENT {
            std::string func_name = $1; 
            
            CodeNode *node = new CodeNode;
            node->code = "";
            node->name = func_name;

            add_function_to_symbol_table(func_name);
            $$ = node;
        }

    arguments: 
        %empty {
            CodeNode *node = new CodeNode;
            node->code = "";
            $$ = node;
        }
        | 
        argument repeat_arguments {
            CodeNode *arg = $1;
            CodeNode *args = $2;

            CodeNode *node = new CodeNode;
            node->code = arg->code + args->code;
            $$ = node;
        }

    repeat_arguments: 
        %empty {
            CodeNode *node = new CodeNode;
            node->code = "";
            $$ = node;
        }
        | 
        COMMA argument repeat_arguments {
            CodeNode *arg = $2;
            CodeNode *repeat_arg = $3;
            
            CodeNode *node = new CodeNode;
            node->code = arg->code + repeat_arg->code;
            $$ = node;
        }
        
    argument: 
        INT IDENT {
            std::string value = $2;
            
            Type t = Integer;
            if (!find(value, Integer)) {
                yyerror("The variable has not been declared\n");
            } else {
                add_variable_to_symbol_table(value, t);
            // add_variable_to_symbol_table(value, t);

            std::string code = std::string(". ") + value + std::string("\n");
            CodeNode *node = new CodeNode;
            node->code = code;
            node->code += std::string("= ") + value + std::string(", $") + get_arg_index() + std::string("\n"); //FIXME: make it dynamic
            $$ = node;
            }
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
        | operations {
            $$ = $1;
        }
        | read 
        | write {}
    
    declaration:
        INT INT {
            // std::string value = $2;
            // Type t = Integer;
            std::string keyword_error = "The variable int cannot have the same name as a reserved keyword\n";
            yyerror(keyword_error.c_str());
        }
        |
        INT IF {
            std::string keyword_error = "The variable sup cannot have the same name as a reserved keyword\n";
            yyerror(keyword_error.c_str());
        }
        |
        INT THEN {
            std::string keyword_error = "The variable vibin cannot have the same name as a reserved keyword\n";
            yyerror(keyword_error.c_str());
        }
        |
        INT ELSE {
            std::string keyword_error = "The variable wbu cannot have the same name as a reserved keyword\n";
            yyerror(keyword_error.c_str());
        }
        |
        INT WHILE {
            std::string keyword_error = "The variable chillin cannot have the same name as a reserved keyword\n";
            yyerror(keyword_error.c_str());
        }
        |
        INT CONTINUE {
            std::string keyword_error = "The variable yessir cannot have the same name as a reserved keyword\n";
            yyerror(keyword_error.c_str());
        }
        |
        INT BREAK {
            std::string keyword_error = "The variable stop cannot have the same name as a reserved keyword\n";
            yyerror(keyword_error.c_str());
        }
        | 
        INT READ {
            std::string keyword_error = "The variable supin cannot have the same name as a reserved keyword\n";
            yyerror(keyword_error.c_str());
        }
        |
        INT WRITE {
            std::string keyword_error = "The variable supout cannot have the same name as a reserved keyword\n";
            yyerror(keyword_error.c_str());
        }
        |
        INT RETURN {
            std::string keyword_error = "The variable return cannot have the same name as a reserved keyword\n";
            yyerror(keyword_error.c_str());
        }
        |
        INT IDENT {
            std::string value = $2;
            Type t = Integer;
            // std::string keyword_error = "The variable " + value + " cannot have the same name as a reserved keyword\n";
            // if ((value == "int") || (value == "sup") || (value == "vibin") || (value == "wbu") || (value == "chillin") || (value == "yessir") || (value == "stop") || (value == "supin") || (value == "supout") || (value == "return")) {
            //     yyerror(keyword_error.c_str());
            // }
            if (find(value, Integer)) {
                yyerror("The variable has already been declared\n");
            } else {
                add_variable_to_symbol_table(value, t);

            std::string code = std::string(". ") + value + std::string("\n");
            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node;
    }
        }
        | 
        INT IDENT L_BRACKET array_size R_BRACKET {
            std::string value = $2;
            std::string array_size = std::to_string($4);

            Type t = Array;
            if (find(value, Array)) {
                yyerror("The array has already been declared\n");
            }
            add_variable_to_symbol_table(value, t);

            std::string code = std::string(".[] ") + value + std::string(",") + array_size + std::string("\n");
            CodeNode *node = new CodeNode;
            node->code = code;
            // std::string error = "The array " + value + " has not been declared\n";
            // std::string error2 = "The array " + value + " has already been declared\n";


            // if (!find(node->name)) {
            //     yyerror(error.c_str());
            // }
            // if (find(node->name)) {
            //     yyerror(error2.c_str());
            // }
            $$ = node;
        }

    array_size: 
        %empty {
            // Handle the case when no size is specified
            $$ = 0; // Set the array size to zero or a default value
        }
        | INTEGER {
            // Handle the case when a size is specified
            int size = std::stoi($1);
            if (size < 0) {
                // Report an error for negative array size
                yyerror("Array size cannot be negative\n");
            }
            $$ = size;
        }
        | SUB INTEGER {
            int size = -std::stoi($2);
            if (size < 0) {
                // Report an error for negative array size
                yyerror("Array size cannot be negative\n");
            }
            $$ = size;
        }

    function_call: 
        IDENT L_PARENT args R_PARENT {
            std::string func_ident = $1;
            CodeNode *args = $3;

            std::string fn_call_fn_error = "The function " + func_ident + " has not been declared in the program yet\n";
            if(!iterate_functions(func_ident)){
                yyerror(fn_call_fn_error.c_str());
            }

            std::string code = std::string("call ") + func_ident;

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
        arg repeat_args {
            CodeNode *arg = $1;
            CodeNode *repeat_arg = $2;
            
            CodeNode *node = new CodeNode;
            node->code = arg->code + repeat_arg->code;
            $$ = node;
        }

    repeat_args: 
        %empty {
            CodeNode *node = new CodeNode;
            node->code = "";
            $$ = node;
        }
        | 
        COMMA arg repeat_args {
            CodeNode *arg = $2;
            CodeNode *repeat_arg = $3;
            
            CodeNode *node = new CodeNode;
            node->code = arg->code + repeat_arg->code;
            $$ = node;
        }

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
        operations {
            CodeNode *operations = $1;

            CodeNode *node = new CodeNode;
            node->code = std::string("param ") + operations->var + std::string("\n") +  operations->code;
            $$ = node;
        }

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
        WRITE INTEGER {}
        | 
        WRITE IDENT {
            std::string val = $2;

            std::string code = std::string(".> ") + val + std::string("\n");
            CodeNode *node = new CodeNode;
            node->code = code;
            $$ = node;
        }
        | 
        WRITE array_access {
            CodeNode *arr = $2;
            
            CodeNode *tmp = new CodeNode;
            Type t = Integer;
            std::string tmpName = std::string("temp" + get_arg_index());
            tmp->var = tmpName;
            tmp->code = std::string(". ") + tmpName + std::string("\n");
            add_variable_to_symbol_table(tmpName, t);

            tmp->code += std::string("=[] ") + tmpName + std::string(", ") + arr->var + std::string(", ") + arr->arr_idx + std::string("\n");
            tmp->code += std::string(".> ") + tmp->var + std::string("\n");
            $$ = tmp;
        }
    
    array_access: 
        IDENT L_BRACKET INTEGER R_BRACKET {
            std::string arr_ident = $1;
            std::string arr_idx = $3;
            std::string ident_type_error = "The variable " + arr_ident + " is not defined as an array\n";
            if (!find(arr_ident, Array)) {
                yyerror(ident_type_error.c_str());
            }
            CodeNode *node = new CodeNode;
            node->var = arr_ident;
            node->arr_idx = arr_idx;
            $$=node;
        }
    
    assignment: 
        IDENT ASSIGNMENT IDENT { 
            std::string first_var = $1;
            std::string second_var = $3;
            std::string first_var_error = "The variable " + first_var + " has not been declared yet\n";
            std::string second_var_error = "The variable " + second_var + " has not been declared yet\n";
            if (!find(first_var, Integer) && !find(first_var, Array)) {
                yyerror(first_var_error.c_str());
            } 
            else if (!find(second_var, Integer) && !find(second_var, Array)) {
                yyerror(second_var_error.c_str());
            }
            else {
            CodeNode *node = new CodeNode;
            node->code = std::string("= ") + first_var + std::string(", ") + $3 + std::string("\n");
            $$ = node;
            }
        } 
        | 
        IDENT ASSIGNMENT INTEGER {
            std::string first_var = $1;
            std::string first_var_error = "The variable " + first_var + " has not been declared yet\n";
            if (!find(first_var, Integer)) {
                yyerror(first_var_error.c_str());
            } 
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
        } */
        | 
        IDENT ASSIGNMENT operations {
            std::string dst = $1;
            CodeNode *ops = $3;

            CodeNode *node = new CodeNode;
            node->code = ops->code + std::string("= ") + dst + std::string(", ") + ops->var + std::string("\n");
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

            // Type t = Integer;
            CodeNode *node2 = new CodeNode;
            node2->code = $4->code;
            node2->code += std::string("= ") + first_var + std::string(", ") + $4->name + std::string("\n");
            $$ = node2;
        }
        | 
        IDENT ASSIGNMENT function_call {
            std::string dst = $1;
            CodeNode *function_call_node = $3;
            
            CodeNode *node = new CodeNode;
            node->code = function_call_node->code + std::string(", ") + dst + std::string("\n");
            $$ = node;
        }
        /* | 
        INT IDENT ASSIGNMENT function_call {} */
        | 
        array_access ASSIGNMENT operations {
            CodeNode *arr = $1;
            CodeNode *ops = $3;
            
            CodeNode *node = new CodeNode;
            node->code = ops->code;
            node->code += std::string("[]= ") + arr->var + std::string(", ") + arr->arr_idx + std::string(", ") + ops->var + std::string("\n");  
            $$ = node;
        }
        | 
        array_access ASSIGNMENT INTEGER {
            CodeNode *arr = $1;
            std::string integer = $3;
            
            CodeNode *node = new CodeNode;
            node->code += std::string("[]= ") + arr->var + std::string(", ") + arr->arr_idx + std::string(", ") + integer + std::string("\n");  
            $$ = node;
        }
        /*
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
            std::string ident = $1;
            std::string ident_type_error = "The variable " + ident + " is defined as an array and is missing a specified index\n";
            if (find(ident, Array)) {
                yyerror(ident_type_error.c_str());
            }
            CodeNode *node = new CodeNode;
            node->code = ident;
            node->var = ident;
            $$ = node;
        }
        | 
        INTEGER {
            std::string integer = $1;

            CodeNode *node = new CodeNode;
            node->code = integer;
            node->var = integer;
            $$ = node;
        }
        | 
        array_access {
            CodeNode *arr = $1;
            
            CodeNode *tmp = new CodeNode;
            Type t = Integer;
            std::string int_type_error = "The variable " + arr->var + " is not defined as an array so it does not have a specified index\n";
            if (find(arr->var, Integer)) {
                yyerror(int_type_error.c_str());
            }
            std::string tmpName = std::string("temp" + get_arg_index());
            tmp->var = tmpName;
            tmp->code = std::string(". ") + tmpName + std::string("\n");
            add_variable_to_symbol_table(tmpName, t);

            tmp->code += std::string("=[] ") + tmpName + std::string(", ") + arr->var + std::string(", ") + arr->arr_idx + std::string("\n");
            $$ = tmp;
        }
        | 
        L_PARENT expr operation expr R_PARENT {
            CodeNode *lhs = $2;
            CodeNode *rhs = $4;
            CodeNode *op = $3;

            CodeNode *tmp = new CodeNode;

            Type t = Integer;
            std::string tmpName = std::string("temp" + get_arg_index());
            add_variable_to_symbol_table(tmpName, t);

            tmp->code = "";
            if (lhs->code != lhs->var) {
                tmp->code += lhs->code;
            }
            if (rhs->code != rhs->var) {
                tmp->code += rhs->code;
            }

            tmp->code += std::string(". ") + tmpName + std::string("\n");
            tmp->code += op->code + tmpName + std::string(", ") + lhs->var + std::string(", ") + rhs->var + std::string("\n");

            tmp->var = tmpName;
            $$ = tmp;
        }
    
    operations: 
        expr operation expr {
            CodeNode *lhs = $1;
            CodeNode *rhs = $3;
            CodeNode *op = $2;
            std::string lhs_error = "The variable " + lhs->var + " has not been declared yet\n";
            std::string rhs_error = "The variable " + rhs->var + " has not been declared yet\n";
            CodeNode *temp = new CodeNode;
            
            Type t = Integer;
            std::string tmp = std::string("temp" + get_arg_index());            
            if (!find(lhs->var, Integer) && (!find(lhs->var, Array))) {
                yyerror(lhs_error.c_str());
            }
            else if (!find(rhs->var, Integer) && (!find(rhs->var, Array))) {
                yyerror(rhs_error.c_str());
            }
            add_variable_to_symbol_table(tmp, t);

            temp->code = std::string(". ") + tmp + std::string("\n");
            if (lhs->code != lhs->var) {
                temp->code += lhs->code;
            }
            if (rhs->code != rhs->var) {
                temp->code += rhs->code;
            }

            temp->code += op->code + tmp + std::string(", ") + lhs->var + std::string(", ") + rhs->var + std::string("\n");
            temp->var = tmp;
            $$ = temp;
        }
    
    operation: 
        ADD {
            CodeNode *add = new CodeNode;
            add->code = "+ ";
            $$ = add;
        }
        | 
        SUB {
            CodeNode *add = new CodeNode;
            add->code = "- ";
            $$ = add;
        }
        | 
        MULT {
            CodeNode *add = new CodeNode;
            add->code = "* ";
            $$ = add;
        }
        | 
        DIV {
            CodeNode *add = new CodeNode;
            add->code = "/ ";
            $$ = add;
        }
        | 
        MOD {
            CodeNode *add = new CodeNode;
            add->code = "% ";
            $$ = add;
        }

    return: 
        RETURN IDENT {}
        | 
        RETURN INTEGER {
            std::string val = $2;

            CodeNode *node = new CodeNode;
            node->code = std::string("ret ") + val + std::string("\n");
            $$ = node;
        }
        | 
        RETURN statement {
            CodeNode *stmt = $2;

            CodeNode *node = new CodeNode;
            node->code = stmt->code;
            node->code += std::string("ret ") + stmt->var + std::string("\n");
            $$ = node;
        }
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
        yyparse();
    } while(!feof(yyin));

    /* terminal input method */
    /* yyin = stdin;

    do {
        printf("Parse.\n");
        yyparse();
    } while(!feof(yyin)); */

    print_symbol_table();

    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Parse error on line %d: %s\n", line_count, s);
    exit(1);
}