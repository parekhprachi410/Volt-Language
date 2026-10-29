%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;
#define MAX_SYMBOLS 100
typedef struct
{
char name[50];
int value;
} Symbol;
Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;
int bill = 0; /* running electricity bill */
/* ---------------- SYMBOL TABLE FUNCTIONS ---------------- */
int findSymbol(const char *name)
{
int i;
for (i = 0; i < symbolCount; i++)
{
if (strcmp(symbolTable[i].name, name) == 0)
return i;
}
return -1;
}
void declareVariable(const char *name)
{
if (findSymbol(name) != -1)
{
printf("Semantic Error: Variable '%s' already declared.\n", name);
return;
}
strcpy(symbolTable[symbolCount].name, name);
symbolTable[symbolCount].value = 0;
symbolCount++;
}
void inputVariable(const char *name)
{
int index = findSymbol(name);
if (index == -1)
{
printf("Semantic Error: Variable '%s' not declared.\n", name);
return;
}
printf("Enter value for %s: ", name);
scanf("%d", &symbolTable[index].value);
}
void assignVariable(const char *name, int value)
{
int index = findSymbol(name);
if (index == -1)
{
printf("Semantic Error: Variable '%s' not declared.\n", name);
return;
}
symbolTable[index].value = value;
}
int getVariableValue(const char *name)
{
int index = findSymbol(name);
if (index == -1)
{
printf("Semantic Error: Variable '%s' not declared.\n", name);
return 0;
}
return symbolTable[index].value;
}
%}
/* ---------------- YACC DECLARATIONS ---------------- */
%union
{
int num;
char *str;
}
%token METER SCAN SHOW CHARGE REBATE TAX TOTALBILL
%token <num> NUMBER
%token <str> ID
%token <str> STRING
%type <num> expression term factor
%left '+' '-'
%left '*' '/'
%%
/* ---------------- GRAMMAR ---------------- */
program:
statements
{
printf("\n===== VOLT PROGRAM FINISHED =====\n");
}
;
statements:
statements statement
| statement
;
statement:
declaration
| input_statement
| output_statement
| assignment
| charge_statement
| rebate_statement
| tax_statement
| total_statement
;
declaration:
METER ID ';'
{
declareVariable($2);
free($2);
}
;
input_statement:
SCAN ID ';'
{
inputVariable($2);
free($2);
}
;
output_statement:
SHOW STRING ';'
{
printf("%s\n", $2);
free($2);
}
| SHOW expression ';'
{
printf("%d\n", $2);
}
;
assignment:
ID '=' expression ';'
{
assignVariable($1, $3);
free($1);
}
;
charge_statement:
CHARGE expression ';'
{
bill = bill + $2;
printf("[+] Charge added : %d\n", $2);
}
;
rebate_statement:
REBATE expression ';'
{
bill = bill - $2;
printf("[-] Rebate given : %d\n", $2);
}
;
tax_statement:
TAX expression ';'
{
int t = bill * $2 / 100;
bill = bill + t;
printf("[+] Tax (%d%%) : %d\n", $2, t);
}
;
total_statement:
TOTALBILL ';'
{
printf("-----------------------------\n");
printf("TOTAL BILL = Rs. %d\n", bill);
printf("-----------------------------\n");
}
;
expression:
expression '+' term { $$ = $1 + $3; }
| expression '-' term { $$ = $1 - $3; }
| term { $$ = $1; }
;
term:
term '*' factor { $$ = $1 * $3; }
| term '/' factor
{
if ($3 == 0)
{
printf("Semantic Error: Division by zero.\n");
$$ = 0;
}
else
{
$$ = $1 / $3;
}
}
| factor { $$ = $1; }
;
factor:
NUMBER { $$ = $1; }
| ID { $$ = getVariableValue($1); free($1); }
| '(' expression ')' { $$ = $2; }
;
%%
/* ---------------- C FUNCTIONS ---------------- */
void yyerror(const char *s)
{
printf("\nSyntax Error: %s\n", s);
}
int main(int argc, char *argv[])
{
printf("====================================\n");
printf(" VOLT - ELECTRICITY BILL LANGUAGE \n");
printf("====================================\n\n");
if (argc > 1)
{
yyin = fopen(argv[1], "r");
if (yyin == NULL)
{
printf("Cannot open file: %s\n", argv[1]);
return 1;
}
}
yyparse();
if (argc > 1)
fclose(yyin);
return 0;
}