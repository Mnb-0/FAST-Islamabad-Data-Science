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

    void deleteAtHead()
    {
        if (head == NULL)
        {
            return;
        }
        Node *temp = head;
        head = head->next;
        temp->next = NULL;
        delete temp;
    }

    void deleteAtEnd()
    {
        if(head == NULL)
        {
            return;
        }
        Node *temp = head;
        while(temp->next->next!=NULL)
        {
            temp = temp->next;
        }
        delete temp->next;
        temp->next = NULL;
    }

    void deleteByVal(int data)
    {
        if(head == NULL)
        {
            return;
        }
        if(head->data == data)
        {
            deleteAtHead();
            return;
        }
        Node *temp = head;
        while(temp->next != NULL && temp->next->data != data)
        {
            temp = temp->next;
        }
        if(temp->next == NULL)
        {
            return;
        }
        Node *nodeToDelete = temp->next;
        temp->next = temp->next->next;
        nodeToDelete->next = NULL;
        delete nodeToDelete;
    }

};

int main()
{
    LinkedList list;
    list.insertAtHead(10); // List: 10
    list.insertAtEnd(20);  // List: 10 -> 20
    list.insertAtEnd(30);  // List: 10 -> 20 -> 30
    list.insertAtEnd(40);  // List: 10 -> 20 -> 30 -> 40
    list.printList();      // Output: 10 20 30 40
    list.deleteAtHead();   // List: 20 -> 30 -> 40
    list.printList();      // Output: 20 30 40
    list.deleteAtEnd();    // List: 20 -> 30
    list.printList();      // Output: 20 30
    list.deleteByVal(20);  // List: 30
    list.printList();      // Output: 30
    return 0;
}