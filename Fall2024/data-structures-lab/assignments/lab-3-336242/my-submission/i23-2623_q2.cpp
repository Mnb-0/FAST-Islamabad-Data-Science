#include <iostream>
using namespace std;

class Node
{
public:
    int data;
    Node *next;

    Node()
    {
        next = NULL;
        data = -1;
    }

    Node(int data, Node *next = NULL)
    {
        this->data = data;
        this->next = next;
    }

    ~Node()
    {
        delete next;
    }
};

class LinkedList
{
public:
    Node *head;

    LinkedList()
    {
        this->head = NULL;
    }

    void insertAtHead(int data)
    {
        Node *newnode = new Node(data);
        newnode->next = head;
        head = newnode;
    }

    void insertAtEnd(int data)
    {
        if(head==NULL)
        {
            insertAtHead(data);
        }
        Node *newnode = new Node(data);
        Node *current = head;
        while (current->next != NULL)
        {
            current = current->next;
        }
        current->next = newnode;
        newnode->next = NULL;
    }
    // after
    bool insertAtPosition(int position, int data)
    {
        if(head==NULL)
        {
            insertAtHead(data);
        }
        Node *newnode = new Node(data);
        Node *current = head;
        while (current->next != NULL && position >= 0)
        {
            current = current->next;
            position--;
        }
        if (position < 0)
        {
            return false;
        }
        newnode->next = current->next;
        current->next = newnode;
        return true;
    }

    bool insertAfterValue(int value, int data)
    {
        if (head == NULL)
        {
            return false;
        }
        Node *current = head;
        while (current != NULL && current->data != value)
        {
            current = current->next;
        }
        if (current == NULL)
        {
            return false;
        }
        Node *newnode = new Node(data);
        newnode->next = current->next;
        current->next = newnode;
        return true;
    }

    void printList()
    {
        Node *current = head;
        while (current != NULL)
        {
            cout << current->data << " ";
            current = current->next;
        }
        cout << endl;
    }
};

int main()
{
    LinkedList list;
    list.insertAtHead(1);
    list.insertAtHead(2);
    list.insertAtHead(3);
    list.insertAtHead(4);
    list.insertAtHead(5);
    list.insertAtEnd(6);
    list.insertAtEnd(7);
    list.insertAtEnd(8);
    list.insertAtEnd(9);
    list.insertAtEnd(10);
    list.insertAtPosition(5, 10);
    list.insertAtPosition(5, 11);
    list.insertAtPosition(5, 12);
    list.insertAtPosition(5, 13);
    list.insertAfterValue(5, 14);
    list.insertAfterValue(5, 15);
    list.insertAfterValue(5, 16);
    list.insertAfterValue(5, 17);
    list.printList();
    return 0;
}