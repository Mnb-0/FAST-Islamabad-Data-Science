#include <iostream>
using namespace std;

class Stack
{
private:
    int *arr;
    int top;
    int size;

public:
    Stack() : arr(nullptr), top(-1), size(0) {}

    Stack(int size) : size(size)
    {
        arr = new int[size];
        for (int i = 0; i < size; i++)
        {
            arr[i] = 0;
        }
        top = -1;
    }

    ~Stack()
    {
        delete[] arr;
    }

    bool isFull()
    {
        if (top == size-1)
        {
            return true;
        }
        return false;
    }

    bool isEmpty()
    {
        if (top == -1)
        {
            return true;
        }
        return false;
    }

    void push(int id)
    {
        if (isFull())
        {
            cout << "Stack Full. Insertion Not Possible\n";
            return;
        }
        arr[++top] = id;
    }

    void pop()
    {
        if (isEmpty())
        {
            cout << "Stack Empty. Cannot pop\n";
            return;
        }
        top--;
    }

    int peek()
    {
        if (isEmpty())
        {
            cout << "Stack Empty.\n";
            return INT_MIN;
        }
        return arr[top];
    }

    void displayStack()
    {
        if(isEmpty())
        {
            cout<<"Stack Empty.\n";
            return;
        }
        cout<<"Stack\n";
        cout<<"--------------------\n";
        for(int i = top; i>=0;i--)
        {
            cout<<arr[i]<<endl;
        }
    }
};

int main()
{
    Stack s(5);

    s.push(10);
    s.push(20);
    s.push(30);
    s.push(40);
    s.push(50);

    s.displayStack();

    cout << "Peek: " << s.peek() << endl;

    s.pop();
    s.pop();

    s.displayStack();

    cout << "Peek: " << s.peek() << endl;

    s.pop();
    s.pop();
    s.pop();
    s.pop();

    return 0;
}