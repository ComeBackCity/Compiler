#include<bits/stdc++.h>

using namespace std;

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
        //cout << "Already in scopetable" << endl;
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

    //cout << "Inserted in ScopeTable# " << ID << " at position " << idx << "," << c << endl;
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
            //cout << "Found in ScopeTable# " << ID << " at position " << idx << "," << c << endl;
            return cur;
        }
        else
        {
            cur = cur -> getNext();
            c++;
        }
    }

    //cout << "Not found" << endl;

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
            //cout << "Found in ScopeTable# " << ID << " at position " << idx << "," << c << endl;

            if(cur2==NULL)
            {
                //cout << "Deleted entry " << idx << "," << c << " from current scopetable" << endl;
                bucketArray[idx] = cur -> getNext();
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
            cur = cur -> getNext();
            c++;
        }
    }

    //cout << "Not found" << endl;
    return false;
}

void ScopeTable::print()
{
    freopen("1605053_log.txt","a",stdout);
    cout << " ScopeTable # " << ID << endl;
    for(int i=0; i<len; i++)
    {

        SymbolInfo *cur;
        cur = bucketArray[i];
        if(cur == NULL)
        {

        }
        else
        {
            cout << " " << i << "--> " ;
            while(cur!=NULL)
            {
                cout << *cur ;
                cur = cur -> getNext();
            }
            cout << endl;
        }
    }

    cout << endl;

    fclose(stdout);
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
    //cout << "ScopeTable with id " << curID << " was created" << endl;
}

void SymbolTable::exitScope()
{
    st = st->getparentScope();
    //cout << "ScopeTable with id " << curID << " was removed" << endl;
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
        cout << endl;

    }
}


