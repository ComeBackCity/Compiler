%option noyywrap

%{
#include<cstdio>
#include<cstdlib>
#include"1605053_SymbolTable.h"

int line_count=1;
int error_count=0;

FILE *logout;
FILE *tokenout;
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
			fprintf(tokenout,"<IF> ");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n\n",line_count,yytext);
		}

"else"		{
			fprintf(tokenout,"<ELSE> ");
			fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n\n",line_count,yytext);
		}

"for"		{
			fprintf(tokenout,"<FOR> ");
			fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n\n",line_count,yytext);
		}

"while"		{
			fprintf(tokenout,"<WHILE> ");
			fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n\n",line_count,yytext);
		}
"do"		{
			fprintf(tokenout,"<DO> ");
			fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n\n",line_count,yytext);
		}
"break"		{
			fprintf(tokenout,"<BREAK> ");
			fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n\n",line_count,yytext);
		}

"int"		{
			fprintf(tokenout,"<INT> ");
			fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n\n",line_count,yytext);
		}

"char"		{
			fprintf(tokenout,"<CHAR> ");
			fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n\n",line_count,yytext);
		}

"float"		{
			fprintf(tokenout,"<FLOAT> ");
			fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n\n",line_count,yytext);
		}

"double"	{
			fprintf(tokenout,"<DOUBLE> ");
			fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n\n",line_count,yytext);
		}

"void"		{
			fprintf(tokenout,"<VOID> ");
			fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n\n",line_count,yytext);
		}

"return"	{
			fprintf(tokenout,"<RETURN> ");
			fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n\n",line_count,yytext);
		}

"switch"	{
			fprintf(tokenout,"<SWITCH> ");
			fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n\n",line_count,yytext);
		}

"case"		{
			fprintf(tokenout,"<CASE> ");
			fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n\n",line_count,yytext);
		}

"default"	{
			fprintf(tokenout,"<DEFAULT> ");
			fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n\n",line_count,yytext);
		}

"continue"	{
			fprintf(tokenout,"<CONTINUE> ");
			fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n\n",line_count,yytext);
		}

"+"|"-"		{
			fprintf(tokenout,"<ADDOP,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n\n",line_count,yytext);
		}

{DIGIT}*(([.]{DIGIT}+)*([E][+-]?{DIGIT}+[.]{DIGIT}+)+)+ {error_count++;
			fprintf(logout,"Error at line no %d: Ill formed number %s\n\n",line_count,yytext);	}
			
[0-9]+([A-Za-z_]+[0-9]*)+	{error_count++;
			fprintf(logout,"Error at line no %d: Invalid prefix on ID or invalid suffix on Number %s\n\n",line_count,yytext);	}

{DIGIT}+ 	{
			fprintf(tokenout,"<CONST_INT,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "CONST_INT");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

{DIGIT}*([.]{DIGIT}+)?([Ee][+-]?{DIGIT}+)?  {	fprintf(tokenout,"<CONST_FLOAT,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "CONST_FLOAT");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

[']{LETTER}[']  {	fprintf(tokenout,"<CONST_CHAR,%c> ",retChar(yytext));
			fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "CONST_CHAR");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}
		
['][\\][nt\\afrbv0']['] {	fprintf(tokenout,"<CONST_CHAR,%c> ",const_litfunc(yytext));
			fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "CONST_CHAR");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}


[a-zA-Z_][a-zA-Z0-9_]* {	fprintf(tokenout,"<ID,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "ID");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

[*/%]		{
			fprintf(tokenout,"<MULOP,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "MULOP");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

"++"|"--"	{
			fprintf(tokenout,"<INCOP,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "INCOP");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

"<"|"<="|">"|">="|"=="|"!="	{
			fprintf(tokenout,"<RELOP,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "RELOP");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

"="		{
			fprintf(tokenout,"<ASSIGNOP,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <ASSIGNCOP> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "ASSIGNCOP");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

"&&"|"||"       {
			fprintf(tokenout,"<LOGICCOP,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICCOP> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "LOGICCOP");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

"&"|"|"|"<<"|">>" {
			fprintf(tokenout,"<BITOP,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "BITOP");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

"!"		{	
			fprintf(tokenout,"<NOTOP,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <NOTOP> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "NOTOP");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

"("		{	
			fprintf(tokenout,"<LPARENOP,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <LPARENOP> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "LPARENOP");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

")"		{	
			fprintf(tokenout,"<RPARENOP,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <RPARENOP> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "RPARENOP");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}
"{"		{	
			fprintf(tokenout,"<LCURL,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "LCURL");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

"}"		{	
			fprintf(tokenout,"<RCURL,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "RCURL");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

"["		{	
			fprintf(tokenout,"<LTHIRD,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "LTHIRD");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

"]"		{	
			fprintf(tokenout,"<RTHIRD,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "RTHIRD");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

","		{	
			fprintf(tokenout,"<COMMA,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "COMMA");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

";"		{	
			fprintf(tokenout,"<SEMICOLON,%s> ",yytext);
			fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool a = s.Insert(yytext, "SEMICOLON");
			if(a){s.printCur();}
			logout= fopen("1605053_log.txt","a");
		}

	
[\"](([\\]*[^(\"\n\\)+])*(([\\][\\])*[\\][\n])*)*[\"]	{	fprintf(tokenout,"<STRING,%s> ",subs(yytext).c_str());
			fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n\n",line_count,yytext);
			line_count+=newlineCount(yytext);

		}
([\/][\/].*(([\\][\n]).*)*)|([\/][\*](.|\n)*[\*][\/]) {	
			fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n",line_count,yytext);
			line_count+=newlineCount(yytext);
		}

{DIGIT}*([.]{DIGIT}*)+		{error_count++;
			fprintf(logout,"Error at line no %d: Too many decimal point %s\n\n",line_count,yytext);	}

['][a-zA-Z0-9\t ][a-zA-Z0-9\t ]+[']		{error_count++;
			fprintf(logout,"Error at line no %d: Multi character constant error %s\n\n",line_count,yytext);	}

['][a-zA-Z0-9]?|['][\\][']?		{error_count++;
			fprintf(logout,"Error at line no %d: Unterminated character %s\n\n",line_count,yytext);	}

['][']		{error_count++;
			fprintf(logout,"Error at line no %d: Empty character constant error \n\n",line_count);	}

[\"]([^(\"\n)]*([\\][\n])*)*	{error_count++;
			fprintf(logout,"Error at line no %d: Unterminated string %s\n\n",line_count,yytext);
			line_count+=newlineCount(yytext);
			}
			
[\/][\*][^\/]*	{error_count++;
			fprintf(logout,"Error at line no %d: Unterminated comment %s\n\n",line_count,yytext);	
			line_count+=newlineCount(yytext);
			}

[ \t]		{	fprintf(tokenout," ");
		}
		
.       {error_count++;
		fprintf(logout,"Error at line no %d: Unrecognized character %s\n\n",line_count,yytext);	}

%%

int main(int argc,char *argv[]){

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	logout= fopen("1605053_log.txt","w");
	tokenout= fopen("1605053_token.txt","w");

	yyin= fin;
	yylex();
	fprintf( logout,"Total Lines : %d",line_count);
	fprintf( logout,"\nTotal Errors : %d",error_count);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}