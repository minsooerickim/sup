%{
// c code here.
#include <stdio.h>
%}

DIGIT [0-9]

%%

{DIGIT}+ { printf("INTEGER: %s\n", yytext); }
"["      { printf("L_BRACKET\n"); }
"]"      { printf("R_BRACKET\n"); }
"="      { printf("EQUAL\n"); }
"+"      { printf("PLUS\n"); }
"-"      { printf("MINUS\n"); }
"*"      { printf("MULT\n"); }
"/"      { printf("DIV\n"); }

.        { printf("**Error. Unidentified token '%s'\n", yytext); }

%%

int main(void) {

    printf("Ctrl+D to quit\n");
    yylex();

}
