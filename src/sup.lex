%{
// c code here
#include <stdio.h>

#define YY_DECL int yylex(void)
#include "y.tab.h"

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
<COMMENT>":("       { BEGIN(INITIAL); printf("MULTILINE_COMMENT\n"); return MULTILINE_COMMENT; }

{DIGIT}+ { printf("INTEGER: %s\n", yytext); integer_count++; return INTEGER; }
{INVALID_IDENTIFIER} { printf("**Error (line %d, column %d): Invalid identifier '%s'\n", yylineno, yyline_start + strlen(yytext)+2, yytext); }
"sup"[^_]      { printf("IF\n"); return IF; }
"vibing"[^_]      { printf("THEN\n"); return THEN; }
"wbu"[^_]      { printf("ELSE\n"); return ELSE; }
"chillin"[^_]      { printf("WHILE\n"); return WHILE; }
"yessir"[^_]      { printf("CONTINUE\n"); return CONTINUE; }
"stop"[^_]      { printf("BREAK\n"); return BREAK; }
"supin ->"      { printf("READ\n"); return READ; }
"supout <-"      { printf("WRITE\n"); return WRITE; }
"return"[^_]        { printf("RETURN\n"); return RETURN; }
"next"[^_]      {printf("NEWLINE\n"); return NEWLINE; }
"["      { printf("L_BRACKET\n"); lbracket_count++; return L_BRACKET; }
"]"      { printf("R_BRACKET\n"); rbracket_count++; return R_BRACKET; }
"("      { printf("L_PARENT\n"); parenthesis_count++; return L_PARENT; }
")"      { printf("R_PARENT\n"); parenthesis_count++; return R_PARENT; }
"#"      { printf("BRACKET\n"); hashtag_count++; return BRACKET; }
"="      { printf("ASSIGNMENT\n"); equal_count++; return ASSIGNMENT; }
"+"      { printf("ADD\n"); operator_count++; return ADD; }
"-"      { printf("SUB\n"); operator_count++; return SUB; }
"*"      { printf("MULT\n"); operator_count++; return MULT; }
"/"      { printf("DIV\n"); operator_count++; return DIV; }
"%"      { printf("MOD\n"); return MOD; }
"@"      { printf("SEMICOLON\n"); return SEMICOLON; }
","      { printf("COMMA\n"); return COMMA; }
"!="      { printf("NEQ\n"); return NEQ; }
"<"      { printf("LT\n"); return LT; }
">"      { printf("GT\n"); return GT; }
"<="      { printf("LTE\n"); return LTE; }
">="      { printf("GTE\n"); return GTE; }
"=="      { printf("EQ\n"); return EQ; }
" "      { /* do nothing */ }

{VARIABLE}+ { printf("VARIABLE: %s\n", yytext); return VARIABLE; }
{ALPHA}+ { printf("WORD: %s\n", yytext); return WORD; }

.        { printf("**Error (line %d, column %d): Unidentified token '%s'\n", yylineno, strlen(yytext)+ 5, yytext); }

%%

// #include <stdlib.h>

// int main(int argc, char *argv[]) {
//     FILE *inputFile;

//     if (argc > 1) {
//         inputFile = fopen(argv[1], "r");
//         if (!inputFile) {
//             fprintf(stderr, "Error opening input file: %s\n", argv[1]);
//             exit(1);
//         }
//         yyin = inputFile;
//     }

//     printf("Ctrl+D to quit\n");

//     yyline_start = yytext;
//     while (yylex()) {
//         yyline_start = yytext;
//     }

//     if (inputFile) {
//         fclose(inputFile);
//     }

//     printf("\nSummary:\n");
//     printf("Integers encountered: %d\n", integer_count);
//     printf("Operators encountered: %d\n", operator_count);
//     printf("Parentheses encountered: %d\n", parenthesis_count);
//     printf("Equal signs encountered: %d\n", equal_count);
//     printf("left bracket encounterd: %d\n", lbracket_count);
//     printf("right bracket encounterd: %d\n", rbracket_count);
//     printf("hashtags encounterd: %d\n", hashtag_count);

//     return 0;
// }
