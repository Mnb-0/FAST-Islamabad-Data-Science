#include <iostream>
#include <string>
using namespace std;

string clean(string data);

class Node
{
public:
    string data;
    Node* next;
};

class Stack
{
public:
    Node* top;
    Stack() 
    {
        top = NULL;
    }
    void push(string x)
    {
        Node* temp = new Node();
        temp->data = x;
        temp->next = top;
        top = temp;
    }
    void pop()
    {
        Node* temp = top;
        if (top == NULL) 
        {
            cout << "Stack is empty" << endl;
            return;
        }
        top = top->next;
        delete temp;
    }
    void display()
    {
        Node* temp = top;
        while (temp != NULL) 
        {
            cout << temp->data << " ";
            temp = temp->next;
        }
        cout << endl;
    }

    void stringReversal()
    {
        while (top != NULL)
        {
            cout << top->data << " ";
            pop();
        }
    }
};

int main()
{
    Stack strStack;
    string inStr;
    cout << "Enter a string: \n";
    getline(cin, inStr);
    inStr = clean(inStr);
    string temp = "";
    for (int i = 0; i < inStr.length(); i++)
    {
        if (inStr[i] == ' ')
        {
            if (!temp.empty())
            {
                strStack.push(temp);
                temp = "";
            }
        }
        else
        {
            temp += inStr[i];
        }
    }
    if (!temp.empty())
    {
        strStack.push(temp);
    }

    strStack.stringReversal();

    return 0;
}

string clean(string data)
{
    string newStr = "";
    for (int i = 0; i < data.length(); i++)
    {
        if (data[i] >= 'A' && data[i] <= 'Z' || data[i] >= 'a' && data[i] <= 'z' || data[i] == ' ')
        {
            newStr += data[i];
        }
        else
        {
            continue;
        }
    }

    return newStr;
}
//submission 12 59