#include <bits/stdc++.h>
#include<fstream>
#define pss pair<string,string>

using namespace std;

class isarray
{
    bool isArr;
    int size;

public:
    isarray()
    {
        isArr = false;
    }

    isarray(bool b, int s)
    {
        isArr = b;
        size = s;
    }

    void setisArr(bool b)
    {
        isArr = b;
    }

    void setSize(int s)
    {
        size = s;
    }

    bool getisArr()
    {
        return isArr;
    }

    int getSize()
    {
        return size;
    }

};

class isFunc{
    vector< pss > parameters;
    bool isFunc_b;
    int own_scope;

public:
    isFunc()
    {
        isFunc_b = false;
    }

    isFunc( bool b=false )
    {
        isFunc_b = true;
    }

    void set_isFunc(bool b)
    {
        isFunc_b = b;
    }

    bool get_isFunc()
    {
        return isFunc_b;
    }

    void addParameters(pss p)
    {
        parameters.push_back(p);
    }

    vector<pss> returnPars()
    {
        return parameters;
    }

    void setScope(int x){
        own_scope = x;
    } 

    int getScope()
    {
        return own_scope;
    }
};

class SymbolInfo
{
    string name;
    string type;
    string Decltype;
    string idCur, idArr;
    isarray* arr;
    isFunc* Func;
    SymbolInfo *next;
	string code;

public:
    SymbolInfo()
    {
        next = NULL;
        arr = NULL;
        Func = NULL;
    }
    SymbolInfo(string s1, string s2, string s3="", string s4="",string s5="")
    {
        name = s1;
        type = s2;
        Decltype = s3;
        next = NULL;
        code = s4;
        idCur = s5;
    }
    void setName(string s1)
    {
        name = s1;
    }
    void setType(string s2)
    {
        type = s2;
    }
    void setDecltype(string s3)
    {
        Decltype = s3;
    }
    void setNext(SymbolInfo *s)
    {
        next = s;
    }
    void setArr(isarray* Arr)
    {
        arr = Arr;
    }
    void setFunc(isFunc* fun)
    {
        Func = fun;
    }
	void setCode(string s)
	{
		code = s;
	}
    void setidCur(string s)
    {
        idCur = s;
    }
    void setidArr(string s)
    {
        idArr = s;
    }
    string getName()
    {
        return name;
    }
    string getType()
    {
        return type;
    }
    string getDeclType()
    {
        return Decltype;
    }
    SymbolInfo *getNext()
    {
        return next;
    }
    isarray* getArr()
    {
        return arr;
    }
    isFunc* getFunc()
    {
        return Func;
    }
	string getCode()
	{
		return code;
	}
    string getidCur()
    {
        return idCur;
    }
    string getidArr()
    {
        return idArr;
    }
    friend ostream &operator<<(ostream &os, const SymbolInfo &rhs)
    {
        os << " < " << rhs.name << " : " << rhs.type << ">";
        return os;
    }
};

class ScopeTable
{
    int len, sID;
    SymbolInfo **bucketArray;
    ScopeTable *parentScope;
	string scope_type;

public:
    ScopeTable()
    {
        len = 0;
    }
    ScopeTable(int n, int id)
    {
        len = n;
        sID = id;
        bucketArray = new SymbolInfo *[len];

        for (int i = 0; i < len; i++)
        {
            bucketArray[i] = NULL;
        }

        parentScope = NULL;
    }
	void setScope_type(string s){
		scope_type = s;
	}
	
	string getScope_type(){
		return scope_type;
	}
	
    void setparentScope(ScopeTable *p)
    {
        this->parentScope = p;
    }

    ScopeTable *getparentScope()
    {
        return this->parentScope;
    }

    int HashFunction(string key)
    {
        int x = 0;

        for (int i = 0; i < key.size(); i++)
        {
            x = (53 * x + (int)key[i]) % len;
        }

        return x % len;
    }

    bool Insert(string k, string v)
    {
        if (this->lookup2(k) != NULL)
        {
            //cout << "Already in scopetable" << endl;
            return false;
        }

        int idx = HashFunction(k) % len;
        int c = 0;

        SymbolInfo *temp;
        SymbolInfo *cur;

        temp = new SymbolInfo(k, v);

        cur = bucketArray[idx];

        if (cur == NULL)
        {
            bucketArray[idx] = temp;
        }
        else
        {
            while (cur->getNext() != NULL)
            {
                cur = cur->getNext();
                c++;
            }

            cur->setNext(temp);
            c++;
        }

        //cout << "Inserted in ScopeTable# " << ID << " at position " << idx << "," << c << endl;
        return true;
    }

    bool Insert(SymbolInfo* s)
    {
        int idx = HashFunction(s->getName()) % len;
        int c=0;
        SymbolInfo *cur;
		
		cur = bucketArray[idx];

        if (cur == NULL)
        {
            bucketArray[idx] = s;
        }
        else
        {
            while (cur->getNext() != NULL)
            {
                cur = cur->getNext();
                c++;
            }

            cur->setNext(s);
            c++;
        }

        return true;

    }

    SymbolInfo *lookup(string k)
    {
        int idx = HashFunction(k) % len;
        int c = 0;

        SymbolInfo *cur;
        cur = bucketArray[idx];

        while (cur != NULL)
        {
            if (cur->getName() == k)
            {
                //cout << "Found in ScopeTable# " << ID << " at position " << idx << "," << c << endl;
                return cur;
            }
            else
            {
                cur = cur->getNext();
                c++;
            }
        }

        //cout << "Not found" << endl;

        return NULL;
    }

    SymbolInfo *lookup2(string k)
    {
        int idx = HashFunction(k) % len;
        int c = 0;

        SymbolInfo *cur;
        cur = bucketArray[idx];

        while (cur != NULL)
        {
            if (cur->getName() == k)
            {
                return cur;
            }
            else
            {
                cur = cur->getNext();
                c++;
            }
        }

        return NULL;
    }

    bool Delete(string s)
    {
        int idx = HashFunction(s) % len;
        int c = 0;

        SymbolInfo *cur, *cur2;
        cur = bucketArray[idx];
        cur2 = NULL;

        while (cur != NULL)
        {
            if (cur->getName() == s)
            {
                //cout << "Found in ScopeTable# " << ID << " at position " << idx << "," << c << endl;

                if (cur2 == NULL)
                {
                    //cout << "Deleted entry " << idx << "," << c << " from current scopetable" << endl;
                    bucketArray[idx] = cur->getNext();
                    return true;
                }
                else
                {
                    cur2->setNext(cur->getNext());
                    //cout << "Deleted entry " << idx << "," << c << " from current scopetable" << endl;
                    return true;
                }
            }
            else
            {
                cur2 = cur;
                cur = cur->getNext();
                c++;
            }
        }

        //cout << "Not found" << endl;
        return false;
    }

    void print()
    {
		
        /*ofstream of;
		of.open("1605053_log.txt",ofstream::out| ofstream::app);
        of << " ScopeTable # " << sID << endl;*/
        for (int i = 0; i < len; i++)
        {

            SymbolInfo *cur;
            cur = bucketArray[i];
            if (cur == NULL)
            {
            }
            else
            {
                //of << " " << i << "--> ";
                while (cur != NULL)
                {
                    //of << *cur;
                    cur = cur->getNext();
                }
               // of << endl;
            }
        }

        //of << endl;
		
		//of << "bal" << endl;
		
		//of.close();
        //fclose(stdout);
		
		//cout << "bal" << endl;
    }

    ~ScopeTable()
    {
        for (int i = 0; i < len; i++)
        {
            SymbolInfo *temp;
            temp = bucketArray[i];
            while (temp != 0)
            {
                SymbolInfo *cur = temp;
                temp = temp->getNext();
                delete cur;
            }
        }
        delete bucketArray;
    }
};

class SymbolTable
{
    ScopeTable *st;
    int curID;
    int length;

public:
    SymbolTable()
    {
        curID = 0;
        length = 0;
        st = NULL;
    }
    SymbolTable(int n)
    {
        curID = 1;
        length = n;
        st = new ScopeTable(length, curID);
		//st->setparentScope(NULL);
    }
    void newScope()
    {
        curID++;
        ScopeTable *temp;
        temp = new ScopeTable(length, curID);
        temp->setparentScope(st);
        st = temp;
        //cout << "ScopeTable with id " << curID << " was created" << endl;
    }
    void exitScope()
    {
        st = st->getparentScope();
        //cout << "ScopeTable with id " << curID << " was removed" << endl;
        //curID--;
    }
    bool Insert(string k, string v)
    {
        bool a = st->Insert(k, v);
        return a;
    }
    bool Insert(SymbolInfo* s)
    {
        bool a = st->Insert(s);
        return a;
    }

    bool Remove(string k)
    {
        bool a = st->Delete(k);
        return a;
    }
    SymbolInfo *lookup(string k)
    {
        return st->lookup(k);
    }

    SymbolInfo *lookupall(string k)
    {
		//cout << "1" << endl;
        SymbolInfo* temp;
        ScopeTable* cur;
		//cout << "1.1" << endl;
        cur = st;
		//cout << "1.2" << endl;
		
        while (cur)
        {
			//cout << 1.3 << endl;
            temp = cur->lookup(k);
			//cout<<"In lookupall"<<endl;
            if(temp != NULL )
                return temp;
			//cout << "2" << endl;
            cur = cur->getparentScope();

        }
		
		//cout << "3" << endl;

        return NULL;

    }

    int lookupScopeID(string k)
    {
        SymbolInfo* temp;
        ScopeTable* cur;
        int IDno = curID;
        //cout << IDno << endl;
        cur = st;
		
        while (cur)
        {
			//cout << 1.3 << endl;
            //cout << IDno << endl;
            temp = cur->lookup(k);
			//cout<<"In lookupall"<<endl;
            if(temp != NULL )
                return IDno;
			//cout << "2" << endl;
            cur = cur->getparentScope();
            IDno--;
            //cout << IDno << endl;

        }
		
		//cout << "3" << endl;

        return 0;
    }

    void printCur()
    {
        st->print();
    }
    void printAll()
    {
		//cout << 2 << endl;
        ScopeTable *temp;
		//cout << 22 << endl;
        temp = st;
		//cout << 222 << endl;

        while (temp != NULL)
        {
			//cout << 1 << endl;
            temp->print();
			//cout << 11 << endl;
            temp = temp->getparentScope();
			//cout << 111 << endl;
            cout << endl;
        }
    }
};