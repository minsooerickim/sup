%{
// c code here.
#include <stdio.h>
char *yyline_start;

int integer_count = 0;
int operator_count = 0;
int parenthesis_count = 0;
int equal_count = 0;
int lbracket_count = 0;
int rbracket_count = 0;
int hashtag_count = 0;

%}

DIGIT [0-9]
ALPHA [a-zA-Z]
UNDERSCORE _
VARIABLE ALPHA(ALPHA|DIGIT|UNDERSCORE)*ALPHA(DIGIT|ALPHA)?
INVALID_IDENTIFIER {VARIABLE}_+

%option yylineno

%%

{DIGIT}+ { printf("INTEGER: %s\n", yytext); integer_count++; }
{ALPHA}+ { printf("WORD: %s\n", yytext); }
{VARIABLE}+ { printf("VARIABLE: %s\n", yytext); }
{INVALID_IDENTIFIER} { printf("**Error (line %d, column %d): Invalid identifier '%s'\n", yylineno, (int)(yytext - yyline_start + 1), yytext); }
"["      { printf("L_BRACKET\n"); lbracket_count++; }
"]"      { printf("R_BRACKET\n"); rbracket_count++; }
"("      { printf("L_PARENT\n"); parenthesis_count++; }
")"      { printf("R_PARENT\n"); parenthesis_count++; }
"#"      { printf("BRACKET\n"); hashtag_count++; }
"="      { printf("ASSIGNMENT\n"); equal_count++; }
"+"      { printf("ADD\n"); operator_count++; }
"-"      { printf("SUB\n"); operator_count++; }
"*"      { printf("MULT\n"); operator_count++; }
"/"      { printf("DIV\n"); operator_count++; }
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

.        { printf("**Error (line %d, column %d): Unidentified token '%s'\n", yylineno, (int)(yytext - yyline_start + 1), yytext); }

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
    while (yylex()) {
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
