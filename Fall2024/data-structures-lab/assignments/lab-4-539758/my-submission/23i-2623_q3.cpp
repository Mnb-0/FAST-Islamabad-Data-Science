#include <iostream>
using namespace std;
// Stack using linked list
class Node
{
public:
    int data;
    Node *next;

    Node()
    {
        next = nullptr;
        data = -1;
    }

    Node(int data, Node *next = nullptr)
    {
        this->data = data;
        this->next = next;
    }

    ~Node()
    {
        delete next;
    }
};

class Stack
{
public:
    Node *top;

    Stack()
    {
        top = nullptr;
    }

    bool isEmpty()
    {
        return top == nullptr;
    }

    void push(int data)
    {
        Node *newnode = new Node(data);
        newnode->next = top;
        top = newnode;
    }

    void pop()
    {
        if (top == nullptr)
        {
            cout << "Stack Empty. Deletion Not Possible\n";
            return;
        }
        Node *temp = top;
        top = top->next;
        temp->next = nullptr;
        delete temp;
    }

    void display()
    {
        Node *current = top;
        while (current != nullptr)
        {
            cout << current->data << " ";
            current = current->next;
        }
        cout << endl;
    }
};

int main()
{
    Stack stack;
    int n, value;

    cout << "Enter the number of elements to push onto the stack: ";
    cin >> n;

    cout << "Enter the elements:\n";
    for (int i = 0; i < n; ++i)
    {
        cin >> value;
        stack.push(value);
    }

    cout << "Stack elements in reverse order:\n";
    stack.display();

    return 0;
}