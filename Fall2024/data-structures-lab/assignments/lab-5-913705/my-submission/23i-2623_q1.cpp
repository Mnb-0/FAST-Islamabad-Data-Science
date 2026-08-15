#include <iostream>
using namespace std;

class Patient
{
public:
    string name;
    int age;
    int severity;

    Patient(string name = "", int age = -1, int severity = -1)
    {
        this->name = name;
        this->age = age;
        this->severity = severity;
    }

    // copy constructor
    Patient(const Patient &p)
    {
        name = p.name;
        age = p.age;
        severity = p.severity;
    }

    void display()
    {
        cout << "Name: " << name << endl;
        cout << "Age: " << age << endl;
        cout << "Severity: " << severity << endl;
    }
};

class Node
{
public:
    Patient data;
    Node *next;

    Node(Patient p)
    {
        data = p;
        next = nullptr;
    }

    // copy constructor
    Node(const Node &n)
    {
        data = n.data;
        next = n.next;
    }

    void display()
    {
        data.display();
    }
};

class Queue
{
public:
    Node *front;
    Node *rear;
    int size;

    Queue()
    {
        front = rear = nullptr;
        size = 0;
    }

    bool isEmpty()
    {
        if (front == nullptr && rear == nullptr)
        {
            return true;
        }
        return false;
    }

    void insertAtFront(Patient p)
    {
        if (isEmpty())
        {
            Node *newNode = new Node(p);
            front = rear = newNode;
            size++;
            cout << "Added\n";
            return;
        }

        Node *newNode = new Node(p);
        newNode->next = front;
        front = newNode;
        size++;
        cout << "Added\n";
    }

    void insertAtRear(Patient p) // Enqueue
    {
        if (isEmpty() || p.severity == 9 || p.severity == 10)
        {
            insertAtFront(p);
            return;
        }

        Node *newNode = new Node(p);
        rear->next = newNode;
        rear = newNode;
        size++;
        cout << "Added\n";
    }

    void deleteAtFront() // Dequeue
    {
        if (isEmpty())
        {
            cout << "Queue is empty\n";
            return;
        }

        cout << "Deleted Patient:\n";
        front->data.display();
        Node *temp = front;

        front = front->next;
        delete temp;
        size--;
    }

    void deleteAtRear()
    {
        if (isEmpty())
        {
            cout << "Queue is empty\n";
            return;
        }
        Node *temp = front;
        while (temp->next != rear)
        {
            temp = temp->next;
        }
        delete rear;
        rear = temp;
        rear->next = nullptr;
        size--;
        cout << "Deleted\n";
    }

    void display()
    {
        if (isEmpty())
        {
            cout << "Queue is empty\n";
            return;
        }

        Node *temp = front;
        while (temp != nullptr)
        {
            temp->display();
            temp = temp->next;
        }
    }

    void peekFront()
    {
        if (isEmpty())
        {
            cout << "Queue is empty\n";
            return;
        }

        cout << "Front Patient:\n";
        front->data.display();
    }
};

int main()
{
    Queue q;
    Patient p1("John", 20, 8);
    Patient p2("Alice", 25, 10);
    Patient p3("Bob", 30, 6);
    Patient p4("Daisy", 35, 9);

    q.insertAtRear(p1);
    q.insertAtRear(p2);
    q.insertAtRear(p3);
    q.insertAtRear(p4);

    q.display();

    q.deleteAtFront();
    q.peekFront();
    q.display();
}