%{
// c code here
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
VARIABLE ALPHA(ALPHA|DIGIT)*
INVALID_IDENTIFIER ({VARIABLE})*{UNDERSCORE}({VARIABLE})*

%option yylineno

%x COMMENT

%%
";)".* 

":)"      { BEGIN(COMMENT); }
<COMMENT>[^:]+      { /* do nothing */ }
<COMMENT>":"        { /* do nothing */ }
<COMMENT>":("       { BEGIN(INITIAL); printf("MULTILINE_COMMENT\n"); }

{DIGIT}+ { printf("INTEGER: %s\n", yytext); integer_count++; }
{INVALID_IDENTIFIER} { printf("**Error (line %d, column %d): Invalid identifier '%s'\n", yylineno, yyline_start + strlen(yytext)+2, yytext); }
"sup"[^_]      { printf("IF\n"); }
"vibing"[^_]      { printf("THEN\n"); }
"wbu"[^_]      { printf("ELSE\n"); }
"chillin"[^_]      { printf("WHILE\n"); }
"yessir"[^_]      { printf("CONTINUE\n"); }
"stop"[^_]      { printf("BREAK\n"); }
"supin ->"      { printf("READ\n"); }
"supout <-"      { printf("WRITE\n"); }
"return"[^_]        { printf("RETURN\n"); }
"next"[^_]      {printf("NEWLINE\n"); }
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
" " //do not print anything

{ALPHA}+ { printf("WORD: %s\n", yytext); }
{VARIABLE}+ { printf("VARIABLE: %s\n", yytext); }

.        { printf("**Error (line %d, column %d): Unidentified token '%s'\n", yylineno, strlen(yytext)+ 5, yytext); }

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
