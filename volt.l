%{
#include "volt.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}
%option noyywrap
%%
"METER" { return METER; }
"SCAN" { return SCAN; }
"SHOW" { return SHOW; }
"CHARGE" { return CHARGE; }
"REBATE" { return REBATE; }
"TAX" { return TAX; }
"TOTALBILL" { return TOTALBILL; }
[0-9]+ { yylval.num = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return ID; }
\"[^\"\n]*\" {
int len = strlen(yytext);
char *s = (char *)malloc(len - 1);
strncpy(s, yytext + 1, len - 2);
s[len - 2] = '\0';
yylval.str = s;
return STRING;
}
"//".* ;
[ \t\r\n]+ ;
"=" { return '='; }
";" { return ';'; }
"+" { return '+'; }
"-" { return '-'; }
"*" { return '*'; }
"/" { return '/'; }
"(" { return '('; }
")" { return ')'; }
. { printf("Lexical Error: Unknown character '%s'\n", yytext); }
%%