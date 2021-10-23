#include<bits/stdc++.h>

using namespace std;

vector < string > tokenizer(string s)
{
    vector < string > result;
    istringstream iss(s);
    for(string s; iss >> s; )
        result.push_back(s);

    return result;

}

class SymbolInfo
{
    string name;
    string type;
    SymbolInfo *next;

public:

    SymbolInfo(string s1, string s2);
    void setName(string s1);
    void setType(string s2);
    void setNext(SymbolInfo *s);
    string getName();
    string getType();
    SymbolInfo* getNext();
    friend ostream& operator<<(ostream& os, const SymbolInfo& rhs);


};

SymbolInfo::SymbolInfo(string s1, string s2)
{
    name = s1;
    type = s2;
    next = NULL;
}

void SymbolInfo::setName(string s1)
{
    name = s1;
}

void SymbolInfo::setType(string s2)
{
    type = s2;
}

void SymbolInfo::setNext(SymbolInfo *s)
{
    next = s;
}

string SymbolInfo::getName()
{
    return name;
}

string SymbolInfo::getType()
{
    return type;
}

SymbolInfo* SymbolInfo::getNext()
{
    return next;
}

ostream& operator<<(ostream& os, const SymbolInfo& rhs)
{
    os << " < " << rhs.name << " : " << rhs.type << ">";
    return os;
}

class ScopeTable
{
    int len, ID;
    SymbolInfo* *bucketArray;
    ScopeTable *parentScope;


public:

    ScopeTable();
    ScopeTable(int n, int id);
    void setparentScope(ScopeTable* p);
    ScopeTable* getparentScope();
    int HashFunction(string key);
    bool Insert(string k, string v);
    SymbolInfo* lookup(string k);
    SymbolInfo* lookup2(string k);
    bool Delete(string s);
    void print();
    ~ScopeTable();

};

ScopeTable::ScopeTable()
{
    len = 0;
}

ScopeTable::ScopeTable(int n, int id)
{
    len = n;
    ID = id;
    bucketArray = new SymbolInfo* [len];

    for (int i=0; i<len; i++)
    {
        bucketArray[i] = NULL;
    }

    parentScope = NULL;
}

int ScopeTable::HashFunction(string key)
{
    int x=0;

    for(int i=0; i<key.size(); i++)
    {
        x=(53*x+(int)key[i])%len;
    }

    return x%len;
}

void ScopeTable::setparentScope(ScopeTable* p)
{
    this->parentScope = p;
}

ScopeTable* ScopeTable::getparentScope()
{
    return this->parentScope;
}

bool ScopeTable::Insert(string k, string v)
{
    if(this->lookup2(k)!=NULL)
    {
        cout << "Already in scopetable" << endl;
        return false;
    }

    int idx= HashFunction(k) % len;
    int c = 0;

    SymbolInfo *temp;
    SymbolInfo *cur;

    temp = new SymbolInfo(k,v);

    cur=bucketArray[idx];

    if(cur==NULL)
    {
        bucketArray[idx] = temp;
    }
    else
    {
        while(cur->getNext()!=NULL)
        {
            cur = cur->getNext();
            c++;
        }

        cur->setNext(temp);
        c++;
    }

    cout << "Inserted in ScopeTable# " << ID << " at position " << idx << "," << c << endl;
    return true;

}

SymbolInfo* ScopeTable::lookup2(string s)
{
    int idx= HashFunction(s) % len;
    int c = 0;

    SymbolInfo *cur;
    cur = bucketArray[idx];

    while(cur!=NULL)
    {
        if(cur->getName()==s)
        {
            return cur;
        }
        else
        {
            cur = cur -> getNext();
            c++;
        }
    }

    return NULL;

}

SymbolInfo* ScopeTable::lookup(string s)
{
    int idx= HashFunction(s) % len;
    int c = 0;

    SymbolInfo *cur;
    cur = bucketArray[idx];

    while(cur!=NULL)
    {
        if(cur->getName()==s)
        {
            cout << "Found in ScopeTable# " << ID << " at position " << idx << "," << c << endl;
            return cur;
        }
        else
        {
            cur = cur -> getNext();
            c++;
        }
    }

    cout << "Not found" << endl;

    return NULL;

}

bool ScopeTable::Delete(string s)
{
    int idx= HashFunction(s) % len;
    int c = 0;

    SymbolInfo *cur, *cur2;
    cur = bucketArray[idx];
    cur2 = NULL;

    while(cur!=NULL)
    {
        if(cur->getName()==s)
        {
            cout << "Found in ScopeTable# " << ID << " at position " << idx << "," << c << endl;

            if(cur2==NULL)
            {
                cout << "Deleted entry " << idx << "," << c << " from current scopetable" << endl;
                bucketArray[idx] = cur -> getNext();
                return true;
            }
            else
            {
                cur2->setNext(cur->getNext());
                cout << "Deleted entry " << idx << "," << c << " from current scopetable" << endl;
                return true;
            }
        }
        else
        {
            cur2 = cur;
            cur = cur -> getNext();
            c++;
        }
    }

    cout << "Not found" << endl;
    return false;
}

void ScopeTable::print()
{
    cout << "ScopeTable # " << ID << endl;
    for(int i=0; i<len; i++)
    {
        cout << i << "--> " ;
        SymbolInfo *cur;
        cur = bucketArray[i];

        while(cur!=NULL)
        {
            cout << *cur ;
            cur = cur -> getNext();
        }
        cout << endl;
    }
}

ScopeTable::~ScopeTable()
{
    for(int i=0; i<len; i++)
    {
        SymbolInfo *temp;
        temp = bucketArray[i];
        while(temp!=0)
        {
            SymbolInfo *cur = temp;
            temp = temp->getNext();
            delete cur;
        }
    }
    delete bucketArray;
}


class SymbolTable
{
    ScopeTable *st;
    int curID;
    int length;

public:

    SymbolTable();
    SymbolTable(int n);
    void newScope();
    void exitScope();
    bool Insert(string k, string v);
    bool Remove(string k);
    SymbolInfo* lookup(string k);
    void printCur();
    void printAll();
};

SymbolTable::SymbolTable()
{
    curID = 0;
    length = 0;
    st = NULL;
}

SymbolTable::SymbolTable(int n)
{
    curID = 1;
    length = n;
    st = new ScopeTable(length,curID);
}

void SymbolTable::newScope()
{
    curID++;
    ScopeTable *temp;
    temp = new ScopeTable(length,curID);
    temp->setparentScope(st);
    st = temp;
    cout << "ScopeTable with id " << curID << " was created" << endl;
}

void SymbolTable::exitScope()
{
    st = st->getparentScope();
    cout << "ScopeTable with id " << curID << " was removed" << endl;
    curID--;
}

bool SymbolTable::Insert(string k, string v)
{
    bool a = st->Insert(k,v);
    return a;
}

bool SymbolTable::Remove(string s)
{
    bool a = st->Delete(s);
    return a;
}

SymbolInfo* SymbolTable::lookup(string k)
{
    return st->lookup(k);
}

void SymbolTable::printCur()
{
    st->print();
}

void SymbolTable::printAll()
{
    ScopeTable* temp;
    temp = st;

    while(temp!=NULL)
    {
        temp->print();
        temp = temp->getparentScope();

    }
}


int main()
{
    ifstream fin("input.txt");
    int n;
    fin >> n;

    SymbolTable s(n);
    SymbolInfo *si;
    bool a;

    string line, ar[3];

    fin.ignore(numeric_limits<streamsize>::max(), '\n');

    while(getline( fin, line ))
    {
        cout << line << endl << endl ;
        vector< string > v;
        v = tokenizer(line);

        if(v[0] == "I")
        {
            bool a = s.Insert(v[1],v[2]);
        }

        else if(v[0] == "L")
        {
            si = s.lookup(v[1]);
        }

        else if(v[0] == "D")
        {
            bool a = s.Remove(v[1]);
        }

        else if(v[0] == "P")
        {
            if(v[1] == "C")
                s.printCur();
            else if(v[1] == "A");
                s.printAll();
        }

        else if(v[0] == "S")
        {
            s.newScope();
        }

        else if(v[0] == "E")
        {
            s.exitScope();
        }

        cout << endl;
    }

    return 0;
}
