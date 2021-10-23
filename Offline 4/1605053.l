%option noyywrap

%{
#include<cstdio>
#include<cstdlib>
#include"1605053_SymbolTable.h"
#ifndef YYSTYPE
#define YYSTYPE SymbolInfo*
#endif
#include "y.tab.h"


extern int line_count;
extern int error_count;

extern YYSTYPE yylval;
extern SymbolTable table;
//extern FILE *errorout;
extern vector<SymbolInfo*> args_vec;
//FILE *tokenout;
extern FILE *errorout;
extern FILE *codeout;
SymbolTable s(10);
SymbolInfo *si;

string substring(string s)
{
    int l = s.length();

    string sub = s.substr(1,l-2);
	
	cout << sub << endl;

    return sub;
}

char retChar(string s)
{
	if(s[1]!='\\')
		return s[1];
}

int newlineCount(string s)
{
    int c=0;
    for(int i=0; i<s.length(); i++)
    {
        if(s[i]=='\n')
           c++;
    }

    return c;
}

char const_litfunc(char *s)
{
	if(s[2]=='n') return '\n';
	else if(s[2]=='t') return '\t';
	else if(s[2]=='\\') return '\\';
	else if(s[2]=='\'') return '\'';
	else if(s[2]=='a') return '\a';
	else if(s[2]=='f') return '\f';
	else if(s[2]=='r') return '\r';
	else if(s[2]=='b') return '\b';
	else if(s[2]=='v') return '\v';
	else if(s[2]=='0') return '\0';

}
string subs(string s)
{
    string sub = "";
    for(int i=0; i<s.length(); i++)
    {
        if(s[i]=='\"') {}
        else if(i+1 < s.length() && s[i]=='\\')
        {
            if(s[i+1]=='\n')
            {
				sub+=' ';
                i++;
            }
            else if(s[i+1]=='t')
            {
                sub+='\t';
                i++;
            }
            else if(s[i+1]=='b')
            {
                sub+='\b';
                i++;
            }
            else if(s[i+1]=='r')
            {
                sub+='\r';
                i++;
            }
            else if(s[i+1]=='v')
            {
                sub+='\v';
                i++;
            }
            else if(s[i+1]=='a')
            {
                sub+='\a';
                i++;
            }
            else if(s[i+1]=='f')
            {
                sub+='\f';
                i++;
            }
            else if(s[i+1]=='0')
            {
                sub+='\0';
                i++;
            }
			else if(s[i+1]=='\\')
            {
                sub+='\\';
                i++;
            }
			else
			{
				i++;
			}

        }
        else
            sub+=s[i];

    }

    return sub;
}

string replacer(string s)
{
    for(int i=0; i<s.length(); i++)
    {

        if(s[i]=='\n')
        {
            s[i]=' ';

        }

    }

    return s;
}



%}

WHITESPACE [ \t\f\r\v]+
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n

%%

{NEWLINE} {line_count++;}

"if"		{
			return IF;
		}

"else"		{
			return ELSE;
		}

"for"		{
			return FOR;
		}

"while"		{
			return WHILE;
		}
"do"		{
			
		}
"break"		{
			
		}

"int"		{
			return INT;
		}

"char"		{
			
		}

"float"		{
			return FLOAT;
		}

"double"	{
			
		}

"void"		{
			return VOID;
		}

"return"	{
			//cout<<"Hiiiiiiiiiiiiiii"<<endl;
			return RETURN;
		}

"switch"	{
			
		}

"case"		{

		}

"default"	{
			
		}

"continue"	{
			
		}

"println" {
			return PRINTLN;
}

"+"|"-"		{
			SymbolInfo *sinf = new SymbolInfo(yytext,"ADDOP")	;
			yylval = (YYSTYPE) sinf;
			return ADDOP;
		}

{DIGIT}*(([.]{DIGIT}+)*([E][+-]?{DIGIT}+[.]{DIGIT}+)+)+ {	}
			
[0-9]+([A-Za-z_]+[0-9]*)+	{}

{DIGIT}+ 	{
			SymbolInfo *sinf = new SymbolInfo(yytext,"CONST_INT")	;
			yylval = (YYSTYPE) sinf;
			return CONST_INT;
			}

{DIGIT}*([.]{DIGIT}+)?([Ee][+-]?{DIGIT}+)?  {
			SymbolInfo *sinf = new SymbolInfo(yytext,"CONST_FLOAT")	;
			yylval = (YYSTYPE) sinf;
			return CONST_FLOAT;
			}

[']{LETTER}[']  {	

		}
		
['][\\][nt\\afrbv0']['] {	

		}


[a-zA-Z_][a-zA-Z0-9_]* {
			SymbolInfo *sinf = new SymbolInfo(yytext,"ID")	;
			yylval = (YYSTYPE ) sinf;
			return ID;

		}

[*/%]		{
			SymbolInfo *sinf = new SymbolInfo(yytext,"MULOP")	;
			yylval = (YYSTYPE ) sinf;
			return MULOP;
		}

"++"	{
			return INCOP;
		}

"--"	{
			return DECOP;
		}

"<"|"<="|">"|">="|"=="|"!="	{
			SymbolInfo *sinf = new SymbolInfo(yytext,"RELOP")	;
			yylval = (YYSTYPE ) sinf;
			return RELOP;
		}

"="		{
			return ASSIGNOP;
		}

"&&"|"||"       {
			SymbolInfo *sinf = new SymbolInfo(yytext,"LOGICOP")	;
			yylval = (YYSTYPE ) sinf;
			return LOGICOP;
		}

"&"|"|"|"<<"|">>" {
		
		}

"!"		{	
			return NOT;
		}

"("		{	
			return LPAREN;
		}

")"		{	
			return RPAREN;
		}

"{"		{	
			//fclose(errorout);
			//table.newScope();
			//table.printAll();
			//errorout = fopen("1605053_errorout.txt","a");
			return LCURL;
		}

"}"		{	
			//table.printAll();
			//table.exitScope();
			//cout<< args_vec.size() << endl;
			return RCURL;
		}

"["		{	
			return LTHIRD;
		}

"]"		{	
			return RTHIRD;
		}

","		{	
			return COMMA;
		}

";"		{	
			return SEMICOLON;
		}

	
[\"](([\\]*[^(\"\n\\)+])*(([\\][\\])*[\\][\n])*)*[\"]	{	

		}
		
([\/][\/].*(([\\][\n]).*)*)|([\/][\*](.|\n)*[\*][\/]) {	

		}

{DIGIT}*([.]{DIGIT}*)+		{error_count++;
			fprintf(errorout,"Error at line no %d: Too many decimal point %s\n\n",line_count,yytext);	}

['][a-zA-Z0-9\t ][a-zA-Z0-9\t ]+[']		{error_count++;
			fprintf(errorout,"Error at line no %d: Multi character constant error %s\n\n",line_count,yytext);	}

['][a-zA-Z0-9]?|['][\\][']?		{error_count++;
			fprintf(errorout,"Error at line no %d: Unterminated character %s\n\n",line_count,yytext);	}

['][']		{error_count++;
			fprintf(errorout,"Error at line no %d: Empty character constant error \n\n",line_count);	}

[\"]([^(\"\n)]*([\\][\n])*)*	{error_count++;
			fprintf(errorout,"Error at line no %d: Unterminated string %s\n\n",line_count,yytext);
			line_count+=newlineCount(yytext);
			}
			
[\/][\*][^\/]*	{error_count++;
			fprintf(errorout,"Error at line no %d: Unterminated comment %s\n\n",line_count,yytext);	
			line_count+=newlineCount(yytext);
			}

[ \t]		{	//fprintf(tokenout," ");
		}
		
.       {error_count++;
		fprintf(errorout,"Error at line no %d: Unrecognized character %s\n\n",line_count,yytext);	}

%%

/*int main(int argc,char *argv[]){

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	errorout= fopen("1605053_log.txt","w");
	tokenout= fopen("1605053_token.txt","w");

	yyin= fin;
	yylex();
	fprintf( errorout,"Total Lines : %d",line_count);
	fprintf( errorout,"\nTotal Errors : %d",error_count);
	fclose(yyin);
	fclose(tokenout);
	fclose(errorout);
	return 0;
}*/