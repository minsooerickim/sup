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
int line_count = -4;

%}

DIGIT [0-9]
ALPHA [a-zA-Z]
SPECIALCHARS [$%~<>`^*&?.\"\'\s;:!{}]
UNDERSCORE _
IDENT {ALPHA}({ALPHA}|{DIGIT})*
INVALID_IDENTIFIER ({ALPHA}|{DIGIT}|{UNDERSCORE}|{SPECIALCHARS})*

%option yylineno

%x COMMENT

%%
";)".* 

":)"      { BEGIN(COMMENT); }
<COMMENT>[^:]+      { /* do nothing */ }
<COMMENT>":"        { /* do nothing */ }
<COMMENT>":("       { BEGIN(INITIAL); printf("MULTILINE_COMMENT\n"); return MULTILINE_COMMENT; }

"int"[^_]      { return INT; }
{DIGIT}+ { integer_count++; return INTEGER; }
"sup"[^_]      { return IF; }
"vibing"[^_]      { return THEN; }
"wbu"[^_]      { return ELSE; }
"chillin"[^_]      { return WHILE; }
"yessir"[^_]      { return CONTINUE; }
"stop"[^_]      { return BREAK; }
"supin ->"      { return READ; }
"supout <-"      { return WRITE; }
"return"[^_]        { return RETURN; }
"["      { lbracket_count++; return L_BRACKET; }
"]"      { rbracket_count++; return R_BRACKET; }
"("      { parenthesis_count++; return L_PARENT; }
")"      { parenthesis_count++; return R_PARENT; }
"#"      { hashtag_count++; return BRACKET; }
"="      { equal_count++; return ASSIGNMENT; }
"+"      { operator_count++; return ADD; }
"-"      { operator_count++; return SUB; }
"*"      { operator_count++; return MULT; }
"/"      { operator_count++; return DIV; }
"%"      { return MOD; }
"@"      { return SEMICOLON; }
","      { return COMMA; }
"!="      { return NEQ; }
"<"      { return LT; }
">"      { return GT; }
"<="      { return LTE; }
">="      { return GTE; }
"=="      { return EQ; }
" "      { /* do nothing */ }
"\n"  { line_count++; }

{IDENT}+ { return IDENT; }
{INVALID_IDENTIFIER} { printf("**Error (line %d, column %d): Invalid identifier '%s'\n", yylineno, yyline_start + strlen(yytext)+2, yytext); }
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
