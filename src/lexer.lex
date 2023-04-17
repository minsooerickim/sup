%{
// c code here.
#include <stdio.h>
%}

DIGIT [0-9]
ALPHA [a-zA-Z]
VARIABLE ALPHA(ALPHA|DIGIT)*
%%

{DIGIT}+ { printf("INTEGER: %s\n", yytext); }
{ALPHA}+ { printf("WORD: %s\n", yytext); }
{VARIABLE}+ { printf("VARIABLE: %s\n", yytext); }
"["      { printf("L_BRACKET\n"); }
"]"      { printf("R_BRACKET\n"); }
"("     {printf("L_PARENT\n"); }
")"     {printf("R_PARENT\n"); }
"#"     {printf("BRACKET\n"); }
"="      { printf("ASSIGNMENT\n"); }
"+"      { printf("ADD\n"); }
"-"      { printf("SUB\n"); }
"*"      { printf("MULT\n"); }
"/"      { printf("DIV\n"); }
"%"      { printf("MOD\n"); }
"@"      { printf("SEMICOLON\n"); }
","      { printf("COMMA\n"); }
"!="      { printf("NEQ\n"); }
"<"      { printf("LT\n"); }
">"      { printf("GT\n"); }
"<="      { printf("LTE\n"); }
">="      { printf("GTE\n"); }
"=="      { printf("EQ\n"); }
"sup"      { printf("IF\n"); }
"vibing"      { printf("THEN\n"); }
"wbu"      { printf("ELSE\n"); }
"chillin"      { printf("WHILE\n"); }
"yessir"      { printf("CONTINUE\n"); }
"stop"      { printf("BREAK\n"); }
"supin ->"      { printf("READ\n"); }
"supout <-"      { printf("WRITE\n"); }
"return"        { printf("RETURN\n"); }
"next"      { printf("NEWLINE\n"); }
" " //do not print anything
";)".* //do nothing single line comment

.        { printf("**Error. Unidentified token '%s'\n", yytext); }

%%

int main(void) {

    printf("Ctrl+D to quit\n");
    yylex();

}
