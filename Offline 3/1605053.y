%{
#include<iostream>
#include<cstdio>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<fstream>
#include<stdlib.h>
#include<bits/stdc++.h>
#include "1605053_SymbolTable.h"
#define pss pair<string,string>
#define YYSTYPE SymbolInfo*


using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *errorout, *logout, *fp;
int line_count = 1, error_count = 0;

SymbolTable table(10);

vector<SymbolInfo*> declared_vars;
vector<SymbolInfo*> func_params;
vector<SymbolInfo*> args_vec;
stack< vector<string> >check_args;
string cur_func_type;
string cur_func_name;

int sti(string s)
{
	int a = atoi(s.c_str());
	return a;
}

void printt1()
{
	for(int i=0; i<declared_vars.size(); i++)
	{
		cout << *declared_vars[i] << endl;
	}
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
					fprintf(logout,"At line no: %d start: program\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());				
					$$->setName(st);
				}
	;

program: program unit 
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d program: program unit\n\n" , line_count);
					st = $1->getName() + "\n\n" + $2->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	| unit
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d program: unit\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	;
	
unit: var_declaration
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d unit: var_declaration\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
     | func_declaration
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d unit: func_declaration\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
     | func_definition
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d unit: func_definition\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
     ;
     
func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n" , line_count);

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
					fprintf(logout,"%s\n\n",st.c_str());	
					$$->setName(st);
				}
		| type_specifier ID LPAREN RPAREN SEMICOLON
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d func_declaration: type_specifier ID LPAREN RPAREN SEMICOLON\n\n" , line_count);

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
					fprintf(logout,"%s\n\n",st.c_str());
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
					string st;
					func_params.clear();
					fprintf(logout,"At line no: %d func_definition: type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n" , line_count);
					st = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + $7->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
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
					fprintf(logout,"At line no: %d func_definition: type_specifier ID LPAREN RPAREN compound_statement\n\n" , line_count);
					st = $1->getName() + " " + $2->getName() + "(" + ")" + $6->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
 		;				


parameter_list: parameter_list COMMA type_specifier ID
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d parameter_list: parameter_list COMMA type_specifier ID\n\n" , line_count);
					st = $1->getName() + " , " + $3->getName() + " " + $4->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$4->setDecltype($3->getName())	;				
					func_params.push_back($4);					
					$$->setName(st);
				}
		| parameter_list COMMA type_specifier
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d parameter_list: parameter_list COMMA type_specifier\n\n" , line_count);
					st = $1->getName() + " , " + $3->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					func_params.push_back(new SymbolInfo("","ID", $3->getName()));					
					$$->setName(st);
				}
 		| type_specifier ID
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d parameter_list: type_specifier ID\n\n" , line_count);
					st = $1->getName() + " " + $2->getName() ;
					fprintf(logout,"%s\n\n",st.c_str());
					$2->setDecltype($1->getName())	;				
					func_params.push_back($2);					
					$$->setName(st);
				}
		| type_specifier
					{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d parameter_list: type_specifier\n\n" , line_count);
					st = $1->getName() ;
					fprintf(logout,"%s\n\n",st.c_str());
					func_params.push_back(new SymbolInfo("","ID", $1->getName()));
					$$->setName(st);
				}
 		;

 		
compound_statement: LCURL new_Scope statements RCURL
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d compound_statement: LCURL statements RCURL\n\n" , line_count);
					st = "{\n\n" + $3->getName() + "\n\n}" ;
					//cout << $3->getName() << endl;
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($3->getDeclType());
					fclose(logout);
					table.printAll();
					table.exitScope();
					logout = fopen("1605053_log.txt","a");
					//cout << "lol" << endl;

				}
 		    | LCURL new_Scope RCURL
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d compound_statement: LCURL RCURL\n\n" , line_count);
					st = "{}" ;
					//cout << st << endl;
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					fclose(logout);
					table.printAll();
					table.exitScope();
					logout = fopen("1605053_log.txt","a");					
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
				}
			
			;
			
var_declaration: type_specifier declaration_list SEMICOLON
				{
					
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d var_declaration : type_specifier declaration_list SEMICOLON\n\n" , line_count);
					
					
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
						}
						
					}
					
					declared_vars.clear();
					//table.printAll();
					st = $1->getName() + " " + $2->getName() + " ;" ;
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
 		 ;
 		 
type_specifier: INT
				{
					$$ = new SymbolInfo();
					fprintf(logout, "At line no: %d type_specifier  : INT\n\nint\n\n" , line_count);
					$$->setName("int");
				}
 		| FLOAT
		 		{ 
					$$ = new SymbolInfo();
					fprintf(logout, "At line no: %d type_specifier  : FLOAT\n\nfloat\n\n" , line_count);
					$$->setName("float");
				}
 		| VOID	
		 		{ 
					$$ = new SymbolInfo();
					fprintf(logout, "At line no: %d type_specifier  : VOID\n\nvoid\n\n" , line_count);
					$$->setName("void");
				}
 		;
 		
declaration_list: declaration_list COMMA ID
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d declaration_list  :  declaration_list COMMA ID\n\n" , line_count);
					st = $1->getName() + "," + $3->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					declared_vars.push_back($3);
					$$->setName(st);
					//cout << "lol" << endl;
					
				}
 		| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		   		{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d declaration_list  :  declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n" , line_count);
					st = $1->getName() + "," + $3->getName() + "[" + $5->getName() + "]" ;
					$3->setArr(new isarray( true , sti($5->getName())));
					fprintf(logout,"%s\n\n",st.c_str());
					declared_vars.push_back($3);
					$$->setName(st);
				}
 		| ID	{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d declaration_list  :  ID\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					declared_vars.push_back($1);
					$$->setName(st);
					
				}
 		| ID LTHIRD CONST_INT RTHIRD
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d declaration_list  :  ID LTHIRD CONST_INT RTHIRD\n\n" , line_count);
					st = $1->getName() + "[" + $3->getName() + "]" ;
					$1->setArr(new isarray( true , sti($3->getName())));
					fprintf(logout,"%s\n\n",st.c_str());
					declared_vars.push_back($1);
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
					fprintf(logout,"At line no: %d statements: statement\n\n" , line_count);
					st = $1->getName();
					//cout << $1->getName() << endl;
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());

					
				}
	   | statements statement
	   			{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d statements: statements statement\n\n" , line_count);
					st = $1->getName() + "\n" + $2->getName();
					//cout << st << endl;
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					//$$->setDecltype($1->getDeclType());

				}
	   ;
	   
statement: var_declaration
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d statement: var_declaration\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	  | expression_statement
	  			{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d statement: expression_statement\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	  | compound_statement
	  			{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d statement: compound_statement\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n" , line_count);
					st = "for (" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  			{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d statement: IF LPAREN expression RPAREN statement\n\n" , line_count);
					st = "if (" + $3->getName() + ")\n\t" + $5->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	  | IF LPAREN expression RPAREN statement ELSE statement
	  			{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d statement: IF LPAREN expression RPAREN statement ELSE statement\n\n" , line_count);
					st = "if (" + $3->getName() + ")\n\t" + $5->getName() + "\nelse\n\t" + $7->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	  | WHILE LPAREN expression RPAREN statement
	  			{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d statement: WHILE LPAREN expression RPAREN statement\n\n" , line_count);
					st = "while (" + $3->getName() + ")" + $5->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  			{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d statement: PRINTLN LPAREN ID RPAREN SEMICOLON\n\n" , line_count);
					st = "println (" + $3->getName() + ");"  ;
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	  | RETURN expression SEMICOLON
	  			{
					
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d statement: RETURN expression SEMICOLON\n\n" , line_count);
					st = "return " + $2->getName() + ";";
					fprintf(logout,"%s\n\n",st.c_str());
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
				} 
	  ;
	  
expression_statement: SEMICOLON	
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"expression_statement: SEMICOLON\n\n" , line_count);
					st = ";";
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}		
			| expression SEMICOLON
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d expression_statement: expression SEMICOLON\n\n" , line_count);
					st = $1->getName() + ";";
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				} 
			;
	  
variable: ID 	
				{
					//cout<<"Hi8"<<endl;
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d variable: ID\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					
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
					/*$$->setDecltype(table.lookup($1->getName())->getDeclType());
					cout << table.lookup($1->getName())->getDeclType() << endl;*/
					//cout<<"Hi9"<<endl;
				}	
	 | ID LTHIRD expression RTHIRD 
	 			{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d variable: ID LTHIRD expression RTHIRD\n\n" , line_count);
					cout << 1 << endl;
					st = $1->getName() + "[" + $3->getName() + "]";
					fprintf(logout,"%s\n\n",st.c_str());
					
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
				}
	 ;
	 
 expression: logic_expression
				{
					//cout << "Hi80" << endl;
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d expression: logic_expression\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					//cout << $$->getDeclType() << endl;
				}
	   | variable ASSIGNOP logic_expression 
	   			{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d expression: variable ASSIGNOP logic_expression\n\n" , line_count);
					st = $1->getName() + " = " + $3->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					
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
					
				}	
	   ;
			
logic_expression: rel_expression 
				{
					//cout<<"Hi5"<<endl;
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d logic_expression: rel_expression\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					//cout << $$->getDeclType() << endl;
				}	
		 | rel_expression LOGICOP rel_expression
		 		{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d logic_expression: rel_expression LOGICOP rel_expression\n\n" , line_count);
					st = $1->getName() + $2->getName() + $3->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype("int");
				} 	
		 ;
			
rel_expression: simple_expression 
				{
					//cout<<"Hi4"<<endl;
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d rel_expression: simple_expression\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					//cout << $$->getDeclType() << endl;
				}
		| simple_expression RELOP simple_expression	
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d rel_expression: simple_expression RELOP simple_expression\n\n" , line_count);
					st = $1->getName() + $2->getName() + $3->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype("int");
				}
		;
				
simple_expression: term 
				{
					//cout<<"Hi3"<<endl;
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d simple_expression : term \n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					//cout << $$->getDeclType() << endl;

				}
		  | simple_expression ADDOP term 
				{
					//cout<<"Hii2"<<endl;
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d simple_expression  : simple_expression ADDOP term\n\n" , line_count);
					st = $1->getName() + $2->getName() + $3->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					
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
					
				}
		  ;
					
term:	unary_expression
				{
					//cout<<"Hi1"<<endl;
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d term  : unary_expression\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					//cout << $$->getDeclType() << endl;
					//cout << $$->getDeclType() << endl;

				}
     |  term MULOP unary_expression
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d term  : term MULOP unary_expression\n\n" , line_count);
					st = $1->getName() + $2->getName() + $3->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					
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
}
				}
     ;

unary_expression: ADDOP unary_expression
				{
					//cout<<"Hi5"<<endl;
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d unary_expression : ADDOP unary_expression\n\n" , line_count);
					st = $1->getName() + $2->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($2->getDeclType());
				}
		 | NOT unary_expression 
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d unary_expression : NOT unary_expression\n\n" , line_count);
					st = "!" + $2->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype("int");					
				}
		 | factor
				{
					//cout<<"Hi6"<<endl;
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d unary_expression :  factor\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
					//cout << $$->getDeclType() << endl;

				}
		 ;
	
factor: variable 
				{
					//cout<<"Hi7"<<endl;
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d factor  :  variable\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
				}
	| ID LPAREN {
		check_args.push(vector<string>());
	} argument_list RPAREN
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d factor  :  ID LPAREN argument_list RPAREN\n\n" , line_count);
					st = $1->getName() + "(" + $4->getName() + ")";;
					fprintf(logout,"%s\n\n",st.c_str());
					
					
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
						
						for(int i=0; i<vecc.size(); i++)
						{
							if(check_args.top()[i] != vecc[i].second)
							{
								error_count++;
								fprintf(errorout,"Error at line no: %d Mismatch in argument types", line_count);
								break;
							}
						}
					
					}
					
					}
					$$->setDecltype(table.lookupall($1->getName())->getDeclType());
					$$->setName(st);
					check_args.pop();
				}
	| LPAREN expression RPAREN
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d factor  :  LPAREN expression RPAREN\n\n" , line_count);
					st = "(" + $2->getName() + ")";
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
	| CONST_INT
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d factor  :  CONST_INT\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype("int");
					//cout << " " << $$->getDeclType() << endl;

				}
	| CONST_FLOAT
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d factor  :  CONST_FLOAT\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype("float");
				}

	| variable INCOP 
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d factor  :  variable INCOP\n\n" , line_count);
					st = $1->getName() + "++";
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
				}
	| variable DECOP
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d factor  :  variable INCOP\n\n" , line_count);
					st = $1->getName() + "--";
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					$$->setDecltype($1->getDeclType());
				}
	;
	
argument_list: arguments
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d argument_list  : arguments\n\n" , line_count);
					st = $1->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
				}
			  |	/*epsilon*/
			  	{
					$$ = new SymbolInfo();
					fprintf(logout,"At line no: %d argument_list  : \n\n" , line_count);
					$$->setName("");
			  	}
			  ;
	
arguments: arguments COMMA logic_expression
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d arguments : arguments COMMA logic_expression\n\n" , line_count);
					st = $1->getName() + "," + $3->getName();
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					check_args.top().push_back($3->getDeclType());
				}
	      | logic_expression
				{
					$$ = new SymbolInfo();
					string st;
					fprintf(logout,"At line no: %d arguments : logic_expression\n\n" , line_count);
					st = $1->getName() ;
					fprintf(logout,"%s\n\n",st.c_str());
					$$->setName(st);
					check_args.top().push_back($1->getDeclType());
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
	errorout = fopen ("1605053_error.txt","w");
	logout = fopen ("1605053_log.txt","w");
	yyparse();
	
	fprintf(errorout,"\n\nTotal Errors: %d",error_count);
	
	fprintf(logout,"Symbol Table:\n");
	fclose(logout);
	table.printAll();
	logout = fopen ("1605053_log.txt","a");
	fprintf(logout,"\n\nTotal Lines: %d",line_count);
	fprintf(logout,"\n\nTotal Errors: %d",error_count);
	
	fclose(fp);
	fclose(errorout);
	fclose(logout);
	
	return 0;
}

