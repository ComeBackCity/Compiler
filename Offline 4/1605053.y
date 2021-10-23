%{
#include<iostream>
#include<cstdio>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<fstream>
#include<stdlib.h>
#include<bits/stdc++.h>
#include<sstream>
//#include<string>
#include "1605053_SymbolTable.h"
#define pss pair<string,string>
#define psi pair<string,int>
#define YYSTYPE SymbolInfo*


using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *errorout, *codeout, *fp;
int line_count = 1, error_count = 0;

SymbolTable table(10);

vector<SymbolInfo*> declared_vars;
vector<SymbolInfo*> func_params;
vector<SymbolInfo*> args_vec;
stack< vector<string> >check_args;
string cur_func_type;
string cur_func_name;
string loopCounter;
vector<string> func_pars;
vector<string> call_temps;
int labelCount=0;
int tempCount=0;
int scopecount=1;
int func_flag=0;
vector<psi> allIDs;
vector<string> temps;


string its(int i)
{
	ostringstream s;
	s << i;
	string st = s.str();
	return st;
}

string tempProducer()
{
	string s = "TEMP0" + its(tempCount);
	tempCount++;
	return s;
}

string labelProducer()
{
	string s = "L0" + its(labelCount);
	labelCount++;
	return s;
}

int sti(string s)
{
	int a = atoi(s.c_str());
	return a;
}

string idcreator(string name, int scope)
{
	ostringstream st;
	st << scope;
	string s = name + st.str();
	return s;
}

void printt1()
{
	for(int i=0; i<declared_vars.size(); i++)
	{
		cout << *declared_vars[i] << endl;
	}
}

vector<string> tokenizer(string line)
{
    int len = line.length();
    for(int i=0; i<len; i++)
    {
        if(line[i] == ',')
        {
            line[i] = ' ';
        }
    }
    vector < string > result;
    istringstream iss(line);
    for(string line; iss >> line; )
        result.push_back(line);

    return result;
}

void optimizer(){
	string s;
    ifstream f("1605053_code.asm");
    FILE *fl;
    vector<string> fileLines1;
    vector<string> fileLines2;
    vector<string> toWrite;
    vector<string> tokens1;
    vector<string> tokens2;

    while(getline(f,s))
    {
        if(s == "")
            continue;

        fileLines1.push_back(s);
        fileLines2.push_back(s);

    }


    for(int i=0; i<fileLines2.size(); i++)
    {
        if(i >= fileLines2.size()-1 )
        {
            toWrite.push_back(fileLines1[i]);
        }
        else
        {
            tokens1 = tokenizer(fileLines2[i]);
            tokens2 = tokenizer(fileLines2[i+1]);

            if(tokens1[0] == "MOV" && tokens2[0] == "MOV")
            {
                //cout << fileLines1[i] << endl;
                if(tokens1[1] == tokens2[2]  && tokens1[2] == tokens2[1])
                {
                    //cout << tokens1[1] << " " << tokens1[2] << "   " << tokens2[1] << " " << tokens2[2] << endl;
                    i++;
                }
                else
                {
                    //cout << "pushing " << fileLines1[i] << " line no : " << i << endl;
                    toWrite.push_back(fileLines1[i]);
                }
            }


            else
            {
                //cout << "pushing " << fileLines1[i] << " line no : " << i << endl;
                toWrite.push_back(fileLines1[i]);
            }

        }

    }


    fl= fopen("1605053_code.asm","w");
    for(int i=0; i<toWrite.size(); i++){
        fprintf(fl,"%s\n",toWrite[i].c_str());
    }
    fclose(fl);
}

void yyerror(char *s)
{
	//write your code
}




%}

//%define api.value.type { SymbolInfo* }

%token IF ELSE WHILE FOR
%token INT FLOAT VOID //type_specifier
%token RETURN PRINTLN
%token CONST_INT CONST_FLOAT
%token ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP NOT DECOP //operators
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON //punctuation
%token ID 

%left RELOP LOGICOP
%left ADDOP 
%left MULOP

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

/*%code requires{
	
}*/

/*%union{
	SymbolInfo* si;
	SymbolInfo* return_rule;
}*/




%%

start: program
				{
					$$ = new SymbolInfo();
					string st;
					string code;
					//fprintf(logout,"At line no: %d start: program\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());				
					$$->setName(st);
					//code = S1->getCode();
					if(error_count == 0)
					{
						code = ".MODEL SMALL\n.STACK 100H\n.DATA\n\n";
						for(int i=0; i<allIDs.size(); i++)
						{
							if(allIDs[i].second > 0)
							{
								//cout << allIDs[i].first << " " << allIDs[i].second << endl;
								code+= allIDs[i].first + " DW " + its(allIDs[i].second) + " DUP (?)\n";
							}
							else
							{
								//cout << allIDs[i].first << " " << allIDs[i].second << endl;
								code+= allIDs[i].first + " DW ?\n";
							}
						}

						for(int i=0; i<temps.size(); i++)
						{
							code += temps[i] + " DW ?\n";
						}

						code+= "\nVAR1 DW ?\nVAR2 DW ?\nN DW ?\nX DB ?";
						code+= "\n\n.CODE\n\n" +  $1->getCode() ;
						code+= "\n\nPRINT PROC";
						code+= "\n\n\tPUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX";
						code+= "\n\tMOV BX,10000\n\tMOV VAR1,BX\n\n\tMOV AX,N\n\tCMP AX,0\n\tJGE OUTPUTP\n\tMOV DL,'-'\n\tMOV AH,2\n\tINT 21H\n\tNEG N\n\nOUTPUTP:" ;
						code+= "\n\n\tMOV AX,VAR1\n\tMOV VAR2,AX\n\tMOV DX,0\n\tMOV AX,VAR1\n\tMOV BX,10\n\tDIV BX\n\tMOV VAR1,AX\n\tMOV DX,0" ;
						code+= "\n\tMOV BX,VAR2\n\tMOV AX,N\n\tDIV BX\n\tMOV N,DX\n\tMOV X,AL\n\tCMP AX,0\n\tJE  OUTPUTP\n\tMOV AH,2" ;
						code+= "\n\tMOV DL,X\n\tADD DL,48\n\tINT 21H\n\tMOV AX,VAR1\n\tCMP AX,0\n\tJE  NEXTLOOP\n\tJMP OUTPUTP2\n\nOUTPUTP2:" ;
						code+= "\n\n\tMOV AX,VAR1\n\tMOV VAR2,AX\n\tMOV DX,0\n\tMOV AX,VAR1\n\tMOV BX,10\n\tDIV BX\n\tMOV VAR1,AX\n\tMOV DX,0" ;
						code+= "\n\tMOV BX,VAR2\n\tMOV AX,N\n\tDIV BX\n\tMOV N,DX\n\tMOV X,AL\n\tMOV AH,2" ;
						code+= "\n\tMOV DL,X\n\tADD DL,48\n\tINT 21H\n\tMOV AX,VAR1\n\tCMP AX,0\n\tJE  NEXTLOOP\n\tJMP OUTPUTP2\n\nNEXTLOOP:" ;
						code+= "\n\n\tMOV AH,2\n\tMOV DL,0DH\n\tINT 21H\n\tMOV DL,0AH\n\tINT 21H";
						code+= "\n\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tret\n\tPRINT ENDP\nEND MAIN";

					}
					$$->setCode(code);
					fprintf(codeout,$$->getCode().c_str());
				}
	;

program: program unit 
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d program: program unit\n\n" , line_count);
					st = $1->getName() + "\n\n" + $2->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setCode($1->getCode() + $2->getCode());
				}
	| unit
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d program: unit\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setCode($1->getCode());
				}
	;
	
unit: var_declaration
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d unit: var_declaration\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
     | func_declaration
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d unit: func_declaration\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
     | func_definition
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d unit: func_definition\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setCode($1->getCode());
				}
     ;
     
func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n" , line_count);

					//checking if declared previously
					if(table.lookup($2->getName()))
					{	
						//cout << "found" << endl;
						error_count++;
						fprintf(errorout,"Error at line no: %d Multiple declaration of %s\n\n",line_count,$2->getName().c_str());
					}
					else
					{
						isFunc* f = new isFunc(true);
						for(int i = 0; i<func_params.size(); i++)
						{
							f->addParameters(make_pair(func_params[i]->getName(),func_params[i]->getDeclType()));
						}
						$2->setDecltype($1->getName());
						$2->setFunc(f);
						table.Insert($2);
					}
					
					func_params.clear();
					st = $1->getName() + " " + $2->getName() + "( " + $4->getName() + " );" ;
					//fprintf(logout,"%s\n\n",st.c_str());	
					$$->setName(st);
				}
		| type_specifier ID LPAREN RPAREN SEMICOLON
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d func_declaration: type_specifier ID LPAREN RPAREN SEMICOLON\n\n" , line_count);

					//checking if declared previously
					if(table.lookup($2->getName()))
					{	
						//cout << "found" << endl;
						error_count++;
						fprintf(errorout,"Error at line no: %d Multiple declaration of %s\n\n",line_count,$2->getName().c_str());
					}
					else
					{
						isFunc* f = new isFunc(true);
						$2->setDecltype($1->getName());
						$2->setFunc(f);
						table.Insert($2);
					}
					
					func_params.clear();
					st = $1->getName() + " " + $2->getName() + "();" ;
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
		;
		 
func_definition: type_specifier ID LPAREN parameter_list RPAREN {
									
					//checking if declared previously
					cur_func_type = $1->getName();
					cur_func_name = $2->getName();
					if(table.lookup($2->getName()))
					{	
						SymbolInfo* s1 = new SymbolInfo();
						s1 = table.lookup($2->getName());
						if(s1->getFunc()==NULL)
						{
							error_count++;
							fprintf(errorout,"Error at line no: %d Multiple declaration of %s\n\n",line_count,$2->getName().c_str());
					
						}
						else if(s1->getDeclType() != $1->getName())
						{
							error_count++;
							fprintf(errorout,"Error at line no: %d Mismatch between declaration and definition of function %s\n\n",line_count,$2->getName().c_str());
						}
						else
						{
							vector<pss> newvec = s1->getFunc()->returnPars();
							//cout << newvec.size() << endl;
							//cout << func_params.size() << endl;
							if( func_params.size() != newvec.size())
							{
								error_count++;
								fprintf(errorout,"Error at line no: %d Mismatch between number of parameters in declaration and definition of function %s\n\n",line_count,$2->getName().c_str());
							}
							else{
							for(int i=0; i<func_params.size(); i++)
							{
								
								if(func_params[i]->getDeclType() != newvec[i].second)
								{
									error_count++;
									fprintf(errorout,"Error at line no: %d Mismatch between parameters in declaration and definition of function %s\n\n",line_count,$2->getName().c_str());
									break;
								}
								else{
								
									args_vec.push_back(func_params[i]);
								}
								
															
							}
							
							}
						}
						
					}
					else
					{
						isFunc* f = new isFunc(true);
						scopecount++;
						func_flag = 1;
						f->setScope(scopecount);
						for(int i = 0; i<func_params.size(); i++)
						{
							f->addParameters(make_pair(func_params[i]->getName(),func_params[i]->getDeclType()));
							args_vec.push_back(func_params[i]);
						}
						$2->setDecltype($1->getName());
						$2->setFunc(f);
						table.Insert($2);
}}
compound_statement
				{					
					//cout << args_vec.size() << endl;
					$$ = new SymbolInfo();	
					string st,code,F_return,F_label,var;
					for(int i=0; i<func_params.size(); i++){
						//cout << 1.1 << endl;
						var = func_params[i]->getName() + its(scopecount) ;
						//cout << 1.2 << endl;
						int flag = 1;
						//cout << 1.3 << endl;
						for (int j = 0; j < temps.size(); j++)
						{
							if(temps[i] == var){
								flag = 0;
								break;
							}
						}
						//cout << 1.4 << endl;
						if(flag == 1){
							temps.push_back(var);
						}
						//cout << 1.5 << endl;
					}
					//fprintf(logout,"At line no: %d func_definition: type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n" , line_count);
					st = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + $7->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					//table.lookupall($2->getName())->getFunc()->setScope(scopecount);
					F_return = $2->getName() + "_return";
					F_label = $2->getName() + "_retlabel";
					code = $2->getName() + " PROC\n\tPUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX\n\n";
					isFunc* f =table.lookupall($2->getName())->getFunc();
					vector<pss> v= f->returnPars();
					for(int i=0; i<v.size(); i++){
						code+= "\n\tPUSH " + v[i].first + its(f->getScope()) ;
					}
					for(int i=0; i<v.size(); i++){
						code+= "\n\tMOV AX,t" + v[i].first + its(f->getScope()) + "\n\tMOV " + v[i].first + its(f->getScope()) + ",AX";
					}
					code+= $7->getCode() + "\n" + $2->getName() + "_retlabel:" ;
					for(int i=v.size()-1; i>=0; i--){
						code+= "\n\tPOP " + v[i].first + its(f->getScope()) ;
					}
					code+= "\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tret\n\n" + $2->getName() + " ENDP\n\n" ;
					temps.push_back(F_return);
					//$$->setName(st);
					$$->setCode(code);
					func_params.clear();
					
				}
		| type_specifier ID LPAREN RPAREN {
					
					cur_func_type = $1->getName();
					cur_func_name = $2->getName();
					if(table.lookup($2->getName()))
					{	
						SymbolInfo* s1 = new SymbolInfo();
						s1 = table.lookup($2->getName());
						//cout << "1a" << endl;
						if(s1->getFunc()==NULL)
						{
							error_count++;
							fprintf(errorout,"Error at line no: %d Multiple declaration of %s\n\n",line_count,$2->getName().c_str());
					
						}
						else if(s1->getDeclType() != $1->getName())
						{
							error_count++;
							fprintf(errorout,"Error at line no: %d Mismatch between declaration and definition of function %s\n\n",line_count,$2->getName().c_str());
						}
						else
						{
							//cout << "2a" << endl;
							vector<pss> newvec = s1->getFunc()->returnPars();
							//cout << newvec.size() << endl;
							if( func_params.size() != newvec.size())
							{
								error_count++;
								fprintf(errorout,"Error at line no: %d Mismatch between number of parameters in declaration and definition of function %s\n\n",line_count,$2->getName().c_str());
							}
							else{
							for(int i=0; i<func_params.size(); i++)
							{
								//cout << func_params[i]->getDeclType() << "----" << newvec[i].second << endl;
								if(func_params[i]->getDeclType() != newvec[i].second)
								{
									error_count++;
									fprintf(errorout,"Error at line no: %d Mismatch between parameters in declaration and definition of function %s\n\n",line_count,$2->getName().c_str());
									break;
								}
															
							}
							
							}
						}
						
					}
					else
					{
						isFunc* f = new isFunc(true);
						scopecount++;
						func_flag = 1;
						f->setScope(scopecount);
						for(int i = 0; i<func_params.size(); i++)
						{
							f->addParameters(make_pair(func_params[i]->getName(),func_params[i]->getDeclType()));
							args_vec.push_back(func_params[i]);
						}
						$2->setDecltype($1->getName());
						$2->setFunc(f);
						table.Insert($2);
					}
					
					//cout << args_vec.size() << endl;
					func_params.clear();
				
}

compound_statement
				{
					$$ = new SymbolInfo();
					string st;
					string code,F_return,F_label;
					//fprintf(logout,"At line no: %d func_definition: type_specifier ID LPAREN RPAREN compound_statement\n\n" , line_count);
					st = $1->getName() + " " + $2->getName() + "(" + ")" + $6->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					if($2->getName() == "main")
						{
							code = "MAIN PROC\n\n\tMOV AX,@DATA\n\tMOV DS,AX";
							code+= "\n\n" + $6->getCode();					
							code+= "\n\n\tMOV AH,4CH\n\tINT 21H\n\n\tMAIN ENDP";
							temps.push_back("main_return");
						}
					else {
						F_return = $2->getName() + "_return";
						F_label = $2->getName() + "_retlabel";
						code = $2->getName() + " PROC\n\tPUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX\n\n";
						code+= $6->getCode() + "\n" + $2->getName() + "_retlabel:" ;
						code+= "\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tret\n\n" + $2->getName() + " ENDP\n\n" ;
						temps.push_back(F_return);
					}
					$$->setName(st);
					$$->setCode(code);
					table.lookupall($2->getName())->getFunc()->setScope(scopecount);

				}
 		;				


parameter_list: parameter_list COMMA type_specifier ID
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d parameter_list: parameter_list COMMA type_specifier ID\n\n" , line_count);
					st = $1->getName() + " , " + $3->getName() + " " + $4->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$4->setDecltype($3->getName())	;				
					func_params.push_back($4);					
					$$->setName(st);
				}
		| parameter_list COMMA type_specifier
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d parameter_list: parameter_list COMMA type_specifier\n\n" , line_count);
					st = $1->getName() + " , " + $3->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					func_params.push_back(new SymbolInfo("","ID", $3->getName()));					
					$$->setName(st);
				}
 		| type_specifier ID
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d parameter_list: type_specifier ID\n\n" , line_count);
					st = $1->getName() + " " + $2->getName() ;
					//fprintf(logout,"%s\n\n",st.c_str());
					$2->setDecltype($1->getName())	;				
					func_params.push_back($2);					
					$$->setName(st);
				}
		| type_specifier
					{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d parameter_list: type_specifier\n\n" , line_count);
					st = $1->getName() ;
					//fprintf(logout,"%s\n\n",st.c_str());
					func_params.push_back(new SymbolInfo("","ID", $1->getName()));
					$$->setName(st);
				}
 		;

 		
compound_statement: LCURL new_Scope statements RCURL
				{
					$$ = new SymbolInfo();
					string st;
					//cout << "Here6.1" << endl;
					//fprintf(errorout,"At line no: %d compound_statement: LCURL statements RCURL\n\n" , line_count);
					//cout << "Here6.2" << endl;
					st = "{\n\n" + $3->getName() + "\n\n}" ;
					//cout << "Here6.3" << endl;
					//cout << $3->getName() << endl;
					//fprintf(logout,"%s\n\n",st.c_str());
					//cout << "Here6.4" << endl;
					$$->setName(st);
					//cout << "Here6.5" << endl;
					$$->setDecltype($3->getDeclType());
					/*table.lookupall(cur_func_name)->getFunc()->setScope(scopecount);
					cout << "Setting the id of current func " << cur_func_name << " as " << scopecount << endl;
					cout << cur_func_name << " " << table.lookupall(cur_func_name)->getFunc()->getScope() << endl;*/
					//cout << "Here6.6" << endl;
					$$->setCode($3->getCode());
					//cout << "Here6.7" << endl;
					/*fclose(logout);
					table.printAll();
					table.exitScope();
					logout = fopen("1605053_log.txt","a");*/
					//cout << "lol" << endl;
					

				}
 		    | LCURL new_Scope RCURL
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d compound_statement: LCURL RCURL\n\n" , line_count);
					st = "{}" ;
					//cout << st << endl;
					//fprintf(logout,"%s\n\n",st.c_str());
					/*table.lookupall(cur_func_name)->getFunc()->setScope(scopecount);
					cout << "Setting the id of current func " << cur_func_name << " as " << scopecount << endl;
					cout << cur_func_name << " " << table.lookupall(cur_func_name)->getFunc()->getScope() << endl;*/
					$$->setName(st);
					/*fclose(logout);
					table.printAll();
					table.exitScope();
					logout = fopen("1605053_log.txt","a");	*/	
					cout << "Here7" << endl;					
				}
 		    ;
			
new_Scope: /*epsilon*/ 	
				{	
					$$ = new SymbolInfo();
					table.newScope();
					for(int i=0; i<args_vec.size(); i++)
					{
						table.Insert(args_vec[i]);
					}
					args_vec.clear();
					if(!func_flag){
						scopecount++;
					}
					else
					{
						func_flag = 0;
					}
					
					//cout << "Here sc;" << scopecount << endl;
				}
			
			;
			
var_declaration: type_specifier declaration_list SEMICOLON
				{
					
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d var_declaration : type_specifier declaration_list SEMICOLON\n\n" , line_count);
					
					
					//type_checking
					if($1->getName() == "void")
					{
						error_count++;
						fprintf(errorout,"Error at line no: %d Declaration type cannot be void\n\n",line_count);
					}
					
					//checking if declared previously
					for(int i = 0; i<declared_vars.size(); i++)
					{
						//cout << declared_vars[i]->getName() << endl;
						if(table.lookup(declared_vars[i]->getName()))
						{	
							//cout << "found" << endl;
							error_count++;
							fprintf(errorout,"Error at line no: %d Multiple declaration of %s\n\n",line_count,declared_vars[i]->getName().c_str());
							continue;
						}
						else
						{
							//cout<< "bal";
							declared_vars[i]->setDecltype($1->getName());
							//cout<< "bal2";
							table.Insert(declared_vars[i]);
							//allIDs.push_back(make_pair(idcreator($1->getName(),table.lookupScopeID($1->getName()))))
							string asmID = idcreator(declared_vars[i]->getName(),table.lookupScopeID(declared_vars[i]->getName()));
							//cout << asmID << endl;
							isarray *ar = new isarray;
							ar = table.lookup(declared_vars[i]->getName())->getArr();
							if(ar == NULL)
							{
								allIDs.push_back(make_pair(asmID,0));
							}
							else
							{
								allIDs.push_back(make_pair(asmID,ar->getSize()));
							}
						}
						
					}
					
					declared_vars.clear();
					//table.printAll();
					st = $1->getName() + " " + $2->getName() + " ;" ;
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
 		 ;
 		 
type_specifier: INT
				{
					$$ = new SymbolInfo();
					//fprintf(logout, "At line no: %d type_specifier  : INT\n\nint\n\n" , line_count);
					$$->setName("int");
				}
 		| FLOAT
		 		{ 
					$$ = new SymbolInfo();
					//fprintf(logout, "At line no: %d type_specifier  : FLOAT\n\nfloat\n\n" , line_count);
					$$->setName("float");
				}
 		| VOID	
		 		{ 
					$$ = new SymbolInfo();
					//fprintf(logout, "At line no: %d type_specifier  : VOID\n\nvoid\n\n" , line_count);
					$$->setName("void");
				}
 		;
 		
declaration_list: declaration_list COMMA ID
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d declaration_list  :  declaration_list COMMA ID\n\n" , line_count);
					st = $1->getName() + "," + $3->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					declared_vars.push_back($3);
					//$$->setidCur($3->getName());
					$$->setName(st);
					//cout << "lol" << endl;
					
				}
 		| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		   		{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d declaration_list  :  declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n" , line_count);
					st = $1->getName() + "," + $3->getName() + "[" + $5->getName() + "]" ;
					$3->setArr(new isarray( true , sti($5->getName())));
					//fprintf(logout,"%s\n\n",st.c_str());
					declared_vars.push_back($3);
					//$$->setidCur($3->getName());
					$$->setName(st);
				}
 		| ID	{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d declaration_list  :  ID\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					declared_vars.push_back($1);
					//$$->setidCur(st);
					$$->setName(st);
					
				}
 		| ID LTHIRD CONST_INT RTHIRD
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d declaration_list  :  ID LTHIRD CONST_INT RTHIRD\n\n" , line_count);
					st = $1->getName() + "[" + $3->getName() + "]" ;
					$1->setArr(new isarray( true , sti($3->getName())));
					//fprintf(logout,"%s\n\n",st.c_str());
					declared_vars.push_back($1);
					//$$->setidCur(st);
					//printt1();
					//cout << "----" << endl;
					$$->setName(st);
					//cout << "lol" << endl;
				}
			;
 		  
statements: statement
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(errorout,"At line no: %d statements: statement\n\n" , line_count);
					st = $1->getName();
					//cout << $1->getName() << endl;
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					$$->setCode($1->getCode());
					cout << "Here4" << endl;
					
				}
	   | statements statement
	   			{
					$$ = new SymbolInfo();
					string st;
					//fprintf(errorout,"At line no: %d statements: statements statement\n\n" , line_count);
					st = $1->getName() + "\n" + $2->getName();
					//cout << st << endl;
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setCode($1->getCode() +"\n\n" + $2->getCode());
					tempCount = 0;
					//$$->setDecltype($1->getDeclType());

				}
	   ;
	   
statement: var_declaration
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d statement: var_declaration\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	  | expression_statement
	  			{
					$$ = new SymbolInfo();
					string st;
					//fprintf(errorout,"At line no: %d statement: expression_statement\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setCode($1->getCode());
					$$->setDecltype($1->getDeclType());
					//cout << "Here3" << endl;
				}
	  | compound_statement
	  			{
					$$ = new SymbolInfo();
					string st;
					//fprintf(errorout,"At line no: %d statement: compound_statement\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setCode($1->getCode());
				}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
				{
					$$ = new SymbolInfo();
					string st,code,label1,label2,temp;
					//fprintf(logout,"At line no: %d statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n" , line_count);
					st = "for (" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					label1 = labelProducer();
					label2 = labelProducer();
					/*code = "\n" + $3->getCode() + "\n" + label1 + ":\n\t" + $7->getCode() + "\n\t" + $4->getCode() + "\n\n\tMOV AX," + $4->getidCur() ;
					code+= "\n\tCMP AX,0\n\tJE  " + label2 + "\n\n\t" + $5->getCode() + "\n\tJMP " + label1 + "\n" + label2 + ":\n" ;*/
					code = "\n" + $3->getCode() + "\n" + label1 + ":\n" + $4->getCode() + "\n\n\tMOV AX," + $4->getidCur() + "\n\tCMP AX,0\n\tJE  " + label2 + "\n\n\t"  ;
					code+= $7->getCode() + "\n\n\t" + $5->getCode() + "\n\tJMP " + label1 + "\n" + label2 + ":\n" ;
					$$->setCode(code); 
				}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  			{
					$$ = new SymbolInfo();
					string st,code,temp,label1,label2;
					//fprintf(errorout,"At line no: %d statement: IF LPAREN expression RPAREN statement\n\n" , line_count);
					st = "if (" + $3->getName() + ")\n\t" + $5->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					label1 = labelProducer();
					code = $3->getCode();
					temp = $3->getidCur();
					//cout << temp << endl;
					code += "\n\n\tMOV AX,"+ temp + "\n\tCMP AX,0\n\tJE  " + label1 + "\n\n" + $5->getCode() + "\n" + label1 + ":"; 
					$$->setCode(code);
				}
	  | IF LPAREN expression RPAREN statement ELSE statement
	  			{
					$$ = new SymbolInfo();
					string st,code,temp,label1,label2;
					//fprintf(errorout,"At line no: %d statement: IF LPAREN expression RPAREN statement ELSE statement\n\n" , line_count);
					st = "if (" + $3->getName() + ")\n\t" + $5->getName() + "\nelse\n\t" + $7->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					//cout << S_temp.top() << endl;
					code = $3->getCode();
					temp = $3->getidCur();
					//cout << temp << endl;
					label1 = labelProducer();
					label2 = labelProducer();
					//cout << label1 << " " << label2 << endl;
					code += "\n\n\tMOV AX," + temp + "\n\tCMP AX,1\n\tJE  " + label1 + "\n\n" + $7->getCode() + "\n\tJMP " + label2 + "\n" + label1 + ":\n\t" + $5->getCode() + "\n" + label2 + ":" ;
					$$->setCode(code);
				}
	  | WHILE LPAREN expression RPAREN statement
	  			{
					$$ = new SymbolInfo();
					string st,code,label1,label2,temp;
					//fprintf(logout,"At line no: %d statement: WHILE LPAREN expression RPAREN statement\n\n" , line_count);
					st = "while (" + $3->getName() + ")" + $5->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					label1 = labelProducer();
					label2 = labelProducer();
					temp = tempProducer();
					$$->setName(st);
					code = label2 + ":\n" + $3->getCode() + "\n\n\tMOV AX," + $3->getidCur() + "\n\tCMP AX,0\n\tJE  " + label1 + "\n" + $5->getCode();
					code+= "\n\tJMP " + label2 + "\n\n" + label1 + ":\n" ;
					$$->setCode(code);

				}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  			{
					$$ = new SymbolInfo();
					string st,code="";
					//fprintf(logout,"At line no: %d statement: PRINTLN LPAREN ID RPAREN SEMICOLON\n\n" , line_count);
					st = "println (" + $3->getName() + ");"  ;
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					code+= "\n\tMOV AX," + $3->getName() + its(table.lookupScopeID($3->getName())) + "\n\tMOV N,AX\n\n\tCALL PRINT" ; 
					$$->setCode(code);
				}
	  | RETURN expression SEMICOLON
	  			{
					
					$$ = new SymbolInfo();
					string st,code="";
					//fprintf(logout,"At line no: %d statement: RETURN expression SEMICOLON\n\n" , line_count);
					st = "return " + $2->getName() + ";";
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					//cout << $2->getDeclType() << endl;
					$$->setDecltype($2->getDeclType());
					/*cout << $$->getDeclType() << endl;
					cout << cur_func_type << endl;*/
					//cout << cur_func_name << endl;
					if( cur_func_type == "void" )
					{
						error_count++;
						fprintf(errorout,"Error at line no: %d void function cannot have return statement\n\n",line_count);
						
					}
					else if( cur_func_type != $$->getDeclType() )
					{
					//cout << "f" << endl;
						error_count++;
						fprintf(errorout,"Error at line no: %d Mismatch between return type and return statement of function %s\n\n",line_count,cur_func_name.c_str());
						
					}

					code+= $2->getCode() + "\n\tMOV AX," + $2->getidCur() + "\n\tMOV " + cur_func_name + "_return,AX" ; 
					if(cur_func_name != "main"){
						//cout << cur_func_name << endl;
						code+= "\n\tJMP " + cur_func_name + "_retlabel";
					}
					
					
					$$->setCode(code);
				} 
	  ;
	  
expression_statement: SEMICOLON	
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"expression_statement: SEMICOLON\n\n" , line_count);
					st = ";";
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}		
			| expression SEMICOLON
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(errorout,"At line no: %d expression_statement: expression SEMICOLON\n\n" , line_count);
					st = $1->getName() + ";";
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setCode($1->getCode());
					//clear_stack();
					//tempCount = 0;
					//cout << "Here1" << endl;
					$$->setidCur($1->getidCur());
					$$->setidArr("");
					
				} 
			;
	  
variable: ID 	
				{
					//cout<<"Hi8"<<endl;
					$$ = new SymbolInfo();
					string st, var;
					//fprintf(logout,"At line no: %d variable: ID\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					
					//cout << st << endl;
					//checking if declared before
					if(table.lookupall(st) == NULL)//---------------------------------------------------
					{
						error_count++;
						fprintf(errorout,"Error at line no: %d Variable %s has not been declared\n\n",line_count,$1->getName().c_str());
					}
					else{
					//cout << "where" << endl;
					//checking if it is array
					//cout << table.lookupall(st)->getArr() << endl;
					if(table.lookupall(st)->getArr() )
					{
						error_count++;
						fprintf(errorout,"Error at line no: %d Variable %s is an array\n\n",line_count,$1->getName().c_str());
						$$->setDecltype(table.lookupall(st)->getDeclType());
						//cout << st << endl;
					}
					else
					{
						/*cout << st << " 11" << endl;
						cout << table.lookupall(st)->getDeclType() << endl;*/
						$$->setDecltype(table.lookupall(st)->getDeclType());
						
					}} 
					$$->setName(st);
					//cout << table.lookupScopeID(st) << endl;
					var = st + its(table.lookupScopeID(st));
					//cout << var << endl;
					//cur_asm_ID.push(var);
					//cout << var << 2 <<endl;
					//array_extra_code.push("");
					//cout << var << 3 << endl;
					$$->setDecltype(table.lookupall($1->getName())->getDeclType());
					$$->setidCur(var);
					$$->setidArr("");
					//cout << var << 4 << endl;
					/*cout << table.lookup($1->getName())->getDeclType() << endl;*/
					//cout<<"Hi9"<<endl;
				}	
	 | ID LTHIRD expression RTHIRD 
	 			{
					$$ = new SymbolInfo();
					string st, var,exCode;
					//fprintf(logout,"At line no: %d variable: ID LTHIRD expression RTHIRD\n\n" , line_count);
					cout << 1 << endl;
					st = $1->getName() + "[" + $3->getName() + "]";
					//fprintf(logout,"%s\n\n",st.c_str());
					
					//checking if declared before
					if(table.lookupall($1->getName()) == NULL)
					{
						error_count++;
						fprintf(errorout,"Error at line no: %d Array %s has not been declared\n\n",line_count,$1->getName().c_str());
					}
					else{
					//cout << "Hi69" << endl;
					if($3->getDeclType() != "int" )
					{
						//cout << "Hi690" << endl;
						error_count++;
						fprintf(errorout,"Error at line no: %d Array index is not integer\n\n",line_count,$1->getName().c_str());
						//cout << st << endl;
					}
					else
					{
						//cout <<  << endl;
						$$->setDecltype($3->getDeclType());
						//cout << st << " 11" << endl;
					}}
					$$->setName(st);
					$$->setDecltype(table.lookupall($1->getName())->getDeclType());
					var = $1->getName() + its(table.lookupScopeID($1->getName()));
					exCode = $3->getCode() + "\n\n\tMOV AX,"+$3->getidCur()+"\n\tMOV BX,2\n\tMUL BX\n\tMOV BX,AX";
					$$->setidCur(var);
					$$->setidArr(exCode);
					//cout << array_extra_code << endl;
				}
	 ;
	 
 expression: logic_expression
				{
					//cout << "Hi80" << endl;
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d expression: logic_expression\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					$$->setCode($1->getCode());
					$$->setidCur($1->getidCur());
					$$->setidArr("");
					//cout << $$->getDeclType() << endl;
				}
	   | variable ASSIGNOP logic_expression 
	   			{
					$$ = new SymbolInfo();
					string st,code;
					string temp,temp1,temp2;
					//fprintf(errorout,"At line no: %d expression: variable ASSIGNOP logic_expression\n\n" , line_count);
					st = $1->getName() + " = " + $3->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					
					//checking consistency of assignment
					
					
					if($3->getDeclType() == "void")
					{
						error_count++;
						fprintf(errorout,"Error at line no: %d Type Mismatch (Attempt at void type assignment)\n\n",line_count);
					}
					else if($1->getDeclType() != $3->getDeclType())
					{
						//cout << $1->getDeclType() << "  " << $3->getDeclType();
						error_count++;
						fprintf(errorout,"Warning at line no: %d Type Mismatch\n\n",line_count);
					}
					
					$$->setName(st);
					if($1->getidArr()== "")
					{
						//temp = S_temp.top();
						//cout << temp << endl;
						//S_temp.pop();
						//tempCount--;
						code = $3->getCode()+"\n\n\tMOV AX,"+$3->getidCur()+"\n\tMOV "+$1->getidCur()+",AX";
						$$->setCode(code);
						
					}
					else
					{
						
						code = $3->getCode();
						code += "\n\n" + $1->getidArr() ;
						code += "\n\n\tMOV AX,"+$3->getidCur()+"\n\tMOV "+$1->getidCur()+"[BX],AX";
						$$->setCode(code);
						
					}

					$$->setidCur($1->getidCur());
					$$->setidArr("");

					//cout << "Here" << endl;
				}	
	   ;
			
logic_expression: rel_expression 
				{
					//cout<<"Hi5"<<endl;
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d logic_expression: rel_expression\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					$$->setCode($1->getCode());
					$$->setidCur($1->getidCur());
					$$->setidArr("");
					//cout << $$->getDeclType() << endl;
				}	
		 | rel_expression LOGICOP rel_expression
		 		{
					$$ = new SymbolInfo();
					string st,code,temp,temp1,temp2,label1,label2,label3,sc,op,inv;
					int flag1 = 0, flag2 = 0;
					//fprintf(logout,"At line no: %d logic_expression: rel_expression LOGICOP rel_expression\n\n" , line_count);
					st = $1->getName() + $2->getName() + $3->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype("int");
					label1 = labelProducer();
					label2 = labelProducer();
					
					if($2->getName() == "&&")
					{
						sc = "0";
						op = "JE  " ;
						inv = "1" ;
					}	
					else 
					{
						sc = "1";
						op = "JGE " ;
						inv = "0";
					}
					
					code = $1->getCode() + "\n\n" + $3->getCode() + "\n\n\tMOV AX," + $3->getidCur() + "\n\tMOV BX," + $1->getidCur() + "\n\tCMP BX," + sc;
					code += "\n\t" + op + label1 + "\n\tCMP AX," + sc + "\n\t" + op + label1 + "\n\tMOV AX," + inv + "\n\tJMP " + label2 ;
					code += "\n" + label1 + ":\n\tMOV AX," + sc + "\n" + label2 + ":\n\tMOV " + $1->getidCur() + ",AX" ;
					
					$$->setCode(code);
					$$->setName(st);
					$$->setidCur($1->getidCur());
					$$->setidArr("");
					//cout << S_temp.top() << endl;
				} 	
		 ;
			
rel_expression: simple_expression 
				{
					//cout<<"Hi4"<<endl;
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d rel_expression: simple_expression\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					$$->setCode($1->getCode());
					$$->setidCur($1->getidCur());
					$$->setidArr("");
					//cout << $$->getDeclType() << endl;
				}
		| simple_expression RELOP simple_expression	
				{
					$$ = new SymbolInfo();
					int flag = 0;
					string st,code,temp1,temp2,label1,label2,t1,op;
					//fprintf(logout,"At line no: %d rel_expression: simple_expression RELOP simple_expression\n\n" , line_count);
					st = $1->getName() + $2->getName() + $3->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype("int");
					label1 = labelProducer();
					label2 = labelProducer();
					
					if($2->getName() == "<")
						op = "JL ";
					else if($2->getName() == "<=")
						op = "JLE";
					else if($2->getName() == ">")
						op = "JG ";
					else if($2->getName() == ">=")
						op = "JGE";
					else if($2->getName() == "==")
						op = "JE ";
					else if($2->getName() == "!=")
						op = "JNE";
					
					code = $1->getCode() + "\n\n" + $3->getCode() + "\n\n\tMOV AX," + $3->getidCur() + "\n\tCMP " + $1->getidCur() + ",AX\n\t" + op + " " + label1 + "\n\tMOV AX,0\n\tJMP " + label2;
					code += "\n" + label1 + ":" + "\n\tMOV AX,1\n" + label2 + ":\n\tMOV " + $1->getidCur() +",AX"; 
					
					$$->setCode(code);
					$$->setName(st);
					$$->setidCur($1->getidCur());
					$$->setidArr("");

				}
		;
				
simple_expression: term 
				{
					//cout<<"Hi3"<<endl;
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d simple_expression : term \n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					$$->setCode($1->getCode());
					$$->setidCur($1->getidCur());
					$$->setidArr("");
					//cout << $$->getDeclType() << endl;

				}
		  | simple_expression ADDOP term 
				{
					//cout<<"Hii2"<<endl;
					$$ = new SymbolInfo();
					int flag =0 ;
					string st, code, op;
					string temp1, temp2, t1, t2;
					//fprintf(logout,"At line no: %d simple_expression  : simple_expression ADDOP term\n\n" , line_count);
					st = $1->getName() + $2->getName() + $3->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					
					if($1->getDeclType() == "void" || $3->getDeclType() == "void")
					{
						error_count++;
						fprintf(errorout,"Error at line no: %d Function with return type void cannot be called as part of statement\n\n", line_count);
						$$->setDecltype("void");
					}
					else if($1->getDeclType() == "float" || $3->getDeclType() == "float")
					{
						$$->setDecltype("float");
					}
					else
					{
						$$->setDecltype("int");
					}
					
					$$->setName(st);
					
					
					if($2->getName() == "+")
						op = "ADD";
					else
						op = "SUB";

					code = $1->getCode() + "\n\n" + $3->getCode() + "\n\n\tMOV AX," + $3->getidCur() + "\n\t" + op + " " + $1->getidCur() + ",AX" ; 

					$$->setCode(code);
					$$->setName(st);
					$$->setidCur($1->getidCur());
					$$->setidArr("");
				}
		  ;
					
term:	unary_expression
				{
					//cout<<"Hi1"<<endl;
					$$ = new SymbolInfo();
					string st,CODE;
					//fprintf(logout,"At line no: %d term  : unary_expression\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					$$->setCode($1->getCode());
					$$->setidCur($1->getidCur());
					$$->setidArr("");
					//cout << $$->getDeclType() << endl;
					//cout << $$->getDeclType() << endl;

				}
     |  term MULOP unary_expression
				{
					$$ = new SymbolInfo();
					string st, code, op, reg;
					string temp1, temp2, t1;
					///fprintf(logout,"At line no: %d term  : term MULOP unary_expression\n\n" , line_count);
					st = $1->getName() + $2->getName() + $3->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					
					if($1->getDeclType() == "void" || $3->getDeclType() == "void")
					{
						error_count++;
						fprintf(errorout,"Error at line no: %d Function with return type void cannot be called as part of statement\n\n", line_count);
						$$->setDecltype("void");
					}
					else {
					if($2->getName() == "%")
					{
						if($1->getDeclType() != "int" || $3->getDeclType() != "int")
						{
							error_count ++;
							fprintf(errorout,"Error at line no: %d Both the operands of modulus need to be integer\n\n",line_count);
							$$->setDecltype("int");
						}
						else
						{
							$$->setDecltype("int");
						}
					}
					else if($2->getName() == "//" )
					{
						if($1->getDeclType() == "float" || $3->getDeclType() == "float")
						{	
							$$->setDecltype("float");
						}
						else
						{
							$$->setDecltype("int");
						}
					}
					else 
					{
						if($1->getDeclType() == "float" || $3->getDeclType() == "float")
						{	
							$$->setDecltype("float");
						}
						else
						{
							$$->setDecltype("int");
						}
					}

					$$->setName(st);
					//temp2 = S_temp.top();
					//S_temp.pop();
					//temp1 = S_temp.top();

					if($2->getName() == "/")
					{
						op = "IDIV";
						reg = "AX";
					}	
					else if ($2->getName() == "*")
					{
						op = "IMUL";
						reg = "AX";
					}
					else if($2->getName() == "%")
					{
						op = "IDIV";
						reg = "DX";
					}

					if(op == "IMUL"){
					code = $1->getCode() + "\n\n" + $3->getCode() + "\n\n\tMOV AX," + $1->getidCur() + "\n\tMOV BX," + $3->getidCur() + "\n\t" + op +" BX\n\tMOV " + $1->getidCur() + "," + reg;
					}
					else{
					code = $1->getCode() + "\n\n" + $3->getCode() + "\n\n\tMOV AX," + $1->getidCur() + "\n\tCWD\n\tMOV BX," + $3->getidCur() + "\n\t" + op +" BX\n\tMOV " + $1->getidCur() + "," + reg;	
					}
					$$->setCode(code);
					$$->setName(st);
					$$->setidCur($1->getidCur());
					$$->setidArr("");					
}
				}
     ;

unary_expression: ADDOP unary_expression
				{
					//cout<<"Hi5"<<endl;
					$$ = new SymbolInfo();
					string st,code;
					//fprintf(logout,"At line no: %d unary_expression : ADDOP unary_expression\n\n" , line_count);
					st = $1->getName() + $2->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($2->getDeclType());
					if($1->getName() == "+"){
						$$->setCode($2->getCode());
					}
					else{
						code = $2->getCode() + "\n\tNEG " + $2->getidCur() ;
						$$->setCode(code);
					}
					$$->setidCur($2->getidCur());
				}
		 | NOT unary_expression 
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d unary_expression : NOT unary_expression\n\n" , line_count);
					st = "!" + $2->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype("int");					
				}
		 | factor
				{
					//cout<<"Hi6"<<endl;
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d unary_expression :  factor\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					$$->setCode($1->getCode());
					$$->setidCur($1->getidCur());
					$$->setidArr("");
					//cout << $$->getDeclType() << endl;

				}
		 ;
	
factor: variable 
				{
					//cout<<"Hi7"<<endl;
					$$ = new SymbolInfo();
					string st,code,temp;
					int flag = 0;
					string newtemp = tempProducer();
					//fprintf(logout,"At line no: %d factor  :  variable\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					if($1->getidArr() == "")
					{
						//cout << "Hi" << endl;
						code = "\n\n\tMOV AX,"+$1->getidCur()+"\n\tMOV "+newtemp+",AX";
						//cout << code << endl;
						$$->setCode(code);
						//cout << $$->getCode() << endl;
						//cur_asm_ID.pop();
						//array_extra_code.pop();
						//cout << "geez" << endl;
					}
					else
					{
						//cout << array_extra_code << endl;
						//temp = S_temp.top();
						//S_temp.pop();
						//tempCount--;
						//cout << temp << endl;
						code = $1->getidArr() ;
						code += "\n\n\tMOV AX,"+$1->getidCur()+"[BX]\n\tMOV "+newtemp+",AX";
						$$->setCode(code);
						//cur_asm_ID.pop();
						//array_extra_code.pop();
						//cout << "geez" << endl;
					}
					
					$$->setidCur(newtemp);
					$$->setidArr("");

					for(int i=0; i<temps.size(); i++)
					{
						if(temps[i]==newtemp)
							flag = 1;
					}
					if(flag == 0)
						temps.push_back(newtemp);
					
				}
	| ID LPAREN {
		check_args.push(vector<string>());
	} argument_list RPAREN
				{
					$$ = new SymbolInfo();
					string st,code="",temp;
					int flag = 0;
					//fprintf(logout,"At line no: %d factor  :  ID LPAREN argument_list RPAREN\n\n" , line_count);
					st = $1->getName() + "(" + $4->getName() + ")";;
					//fprintf(logout,"%s\n\n",st.c_str());		
					
					isFunc* f = table.lookupall($1->getName())->getFunc();
					
					//cout << f << endl;
					
					if(f == NULL)
					{
						
						error_count++;
						fprintf(errorout,"Error at line no: %d %s is not a function\n\n" , line_count, $1->getName().c_str());
					}
					else{
					
					/*cout << 1 << endl;
					;*/
					
					vector<pss> vecc = f->returnPars();
					
					if(check_args.top().size() < vecc.size())
					{
						error_count++;
						fprintf(errorout,"Error at line no: %d Not enough arguments\n\n", line_count);
					}
					else if(check_args.top().size() > vecc.size())
					{
						//cout << check_args.size() << " " << vecc.size() << endl;
						error_count++;
						fprintf(errorout,"Error at line no: %d Too many arguments\n\n", line_count);
					}
					else{
						
						code+="\n" + $4->getCode();
						for(int i=0; i<vecc.size(); i++)
						{
							if(check_args.top()[i] != vecc[i].second)
							{
								error_count++;
								fprintf(errorout,"Error at line no: %d Mismatch in argument types", line_count);
								break;
							}
							
							cout << "size:" << func_pars.size() << endl;
							//cout << "scopecount:" << scopecount << endl;
							//cout << "scopecount2:" << its(scopecount) << endl;
							if(func_pars.size() != 0){
								//cout << table.lookupall($1->getName())->getFunc()->getScope() << " func scope" << endl;
								//cout << " func: " << cur_func_name <<  table.lookupall($1->getName())->getFunc()->getScope() << endl;
								//code+="\n" + $4->getCode() ;
								/*cout << $4->getCode() ;*/
								code+="\n\tMOV AX," +  func_pars[i]  +"\n\tMOV t" + vecc[i].first + its(table.lookupall($1->getName())->getFunc()->getScope()) + ",AX";
								call_temps.push_back("t" + vecc[i].first + its(table.lookupall($1->getName())->getFunc()->getScope()) );
							}
							
						}
						
						code+= "\n\tCALL " + $1->getName();
						temp = tempProducer();
						code+= "\n\tMOV AX," + $1->getName() + "_return\n\tMOV " + temp + ",AX";
						
						for(int i=0; i<call_temps.size(); i++){
							int flag1 = 0;
							for(int j=0; j<temps.size(); j++){
								if(call_temps[i] == temps[j]){
									flag1  =1;
								}
							}

							if(flag1 == 0){
								temps.push_back(call_temps[i]);
							}
						}
						
					}
					
					}

					for(int i=0; i<temps.size(); i++)
					{
						if(temps[i]==temp)
							flag = 1;
					}
					if(flag == 0)
						temps.push_back(temp);
					$$->setCode(code);
					$$->setDecltype(table.lookupall($1->getName())->getDeclType());
					$$->setName(st);
					$$->setidCur(temp);
					check_args.pop();
					func_pars.clear();
				}
				
	| LPAREN expression RPAREN
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout, "At line no: %d factor  :  LPAREN expression RPAREN\n\n" , line_count);
					st = "(" + $2->getName() + ")";
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($2->getDeclType());
					$$->setCode($2->getCode());
					$$->setidCur($2->getidCur());
					$$->setidArr("");
				}
	| CONST_INT
				{
					$$ = new SymbolInfo();
					int flag=0;
					string st;
					string code;
					string temp = tempProducer();
					//fprintf(logout,"At line no: %d factor  :  CONST_INT\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype("int");
					code = "\n\tMOV AX,"+$1->getName()+"\n\tMOV "+temp+",AX\n";
					$$->setCode(code);
					$$->setidCur(temp);
					$$->setidArr("");
					for(int i=0; i<temps.size(); i++)
					{
						if(temps[i]==temp)
							flag = 1;
					}
					if(flag == 0)
						temps.push_back(temp);
					
					//cout << " " << $$->getDeclType() << endl;
					

				}
	| CONST_FLOAT
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d factor  :  CONST_FLOAT\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype("float");
					
				}

	| variable INCOP 
				{
					$$ = new SymbolInfo();
					string st,code,temp;
					int flag = 0;
					string newtemp = tempProducer();
					//fprintf(logout,"At line no: %d factor  :  variable INCOP\n\n" , line_count);
					st = $1->getName() + "++";
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					//cout << 1.1 << endl;
					if($1->getidArr() == "")
					{
						//cout << 1.2 << endl;
						code = "\n\n\tMOV AX," + $1->getidCur() +  "\n\tMOV " + newtemp + ",AX\n\tINC "+$1->getidCur();
						//cout << 1.3 << endl;
						//cout << code << endl;
						$$->setCode(code);
						//cout << 1.4 << endl;
					}
					else
					{
						//cout << array_extra_code << endl;
						//temp = S_temp.top();
						//S_temp.pop();
						//tempCount--;
						//cout << temp << endl;
						code = $1->getidArr();
						//code += "\n\n\tMOV AX,"+cur_asm_ID.top()+"[BX]\n\tMOV "+newtemp+",AX";
						code += "\n\n\tMOV AX," + $1->getidCur() + "[BX]\n\tMOV " + newtemp + ",AX\n\tINC "+ $1->getidCur() +"[BX]";
						$$->setCode(code);

					}

					//cout << 1.5 << endl;
					//assignmentFlag = 1;

					$$->setidCur(newtemp);
					$$->setidArr("");

				for(int i=0; i<temps.size(); i++)
					{
						if(temps[i]==newtemp)
							flag = 1;
					}
					if(flag == 0)
						temps.push_back(newtemp);
					
					
				}
	| variable DECOP
				{
					$$ = new SymbolInfo();
					string st,temp,code;
					int flag = 0;
					string newtemp = tempProducer();
					//fprintf(logout,"At line no: %d factor  :  variable INCOP\n\n" , line_count);
					st = $1->getName() + "--";
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					if($1->getidArr() == "")
					{
						//cout << 1.2 << endl;
						code = "\n\n\tMOV AX," + $1->getidCur() +  "\n\tMOV " + newtemp + ",AX\n\tDEC "+$1->getidCur();
						//cout << 1.3 << endl;
						//cout << code << endl;
						$$->setCode(code);
						//cout << 1.4 << endl;
					}
					else
					{
						//cout << array_extra_code << endl;
						//temp = S_temp.top();
						//S_temp.pop();
						//tempCount--;
						//cout << temp << endl;
						code = $1->getidArr();
						//code += "\n\n\tMOV AX,"+cur_asm_ID.top()+"[BX]\n\tMOV "+newtemp+",AX";
						code += "\n\n\tMOV AX," + $1->getidCur() + "[BX]\n\tMOV " + newtemp + ",AX\n\tDEC "+ $1->getidCur() +"[BX]";
						$$->setCode(code);

					}

					//cout << 1.5 << endl;
					//assignmentFlag = 1;

					$$->setidCur(newtemp);
					$$->setidArr("");

					for(int i=0; i<temps.size(); i++)
					{
						if(temps[i]==newtemp)
							flag = 1;
					}
					if(flag == 0)
						temps.push_back(newtemp);
					
				}
	;
	
argument_list: arguments
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d argument_list  : arguments\n\n" , line_count);
					st = $1->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setCode($1->getCode());
				}
			  |	/*epsilon*/
			  	{
					$$ = new SymbolInfo();
					//fprintf(logout,"At line no: %d argument_list  : \n\n" , line_count);
					$$->setName("");
			  	}
			  ;
	
arguments: arguments COMMA logic_expression
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d arguments : arguments COMMA logic_expression\n\n" , line_count);
					st = $1->getName() + "," + $3->getName();
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					check_args.top().push_back($3->getDeclType());
					func_pars.push_back($3->getidCur());
					$$->setCode($1->getCode() + $3->getCode());
					/*cout << "J" << endl;
					cout << $1->getCode() + $3->getCode() << endl;*/
				}
	      | logic_expression
				{
					$$ = new SymbolInfo();
					string st;
					//fprintf(logout,"At line no: %d arguments : logic_expression\n\n" , line_count);
					st = $1->getName() ;
					//fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					check_args.top().push_back($1->getDeclType());
					func_pars.push_back($1->getidCur());
					$$->setCode($1->getCode());
					/*cout << "k" << endl;
					cout << $$->getCode() << endl;*/
				}
	      ;
 

%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	yyin=fp;
	errorout = fopen ("1605053_log.txt","w");
	codeout = fopen ("1605053_code.asm","w");
	yyparse();
	fclose(codeout);
	optimizer();
	fprintf(errorout,"\n\nTotal Errors: %d",error_count);
	fprintf(errorout,"\nTotal Lines: %d",line_count);
	
	fclose(fp);
	fclose(errorout);
	//fclose(codeout);
	
	return 0;
}

