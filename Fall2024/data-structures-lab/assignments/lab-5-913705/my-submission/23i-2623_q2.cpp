#include <iostream>
using namespace std;

// Carriage management using doubly linked list
class Carriage
{
public:
    int id;
    int capacity;
    Carriage *next;
    Carriage *prev;

    Carriage(int id = -1, int capacity = -1) : id(id), capacity(capacity)
    {
        next = prev = nullptr;
    }
};

class Train
{
public:
    Carriage *front;
    Carriage *rear;

    Train()
    {
        front = rear = nullptr;
    }

    bool isEmpty()
    {
        return front == nullptr;
    }

    void insertAtFront(int id, int capacity)
    {
        Carriage *newC = new Carriage(id, capacity);

        if (isEmpty())
        {
            front = rear = newC;
            return;
        }

        front->prev = newC;
        newC->next = front;
        front = newC;
    }

    void insertAtRear(int id, int capacity)
    {
        Carriage *newC = new Carriage(id, capacity);

        if (isEmpty())
        {
            front = rear = newC;
            return;
        }

        rear->next = newC;
        newC->prev = rear;
        rear = newC;
    }

    void deleteAtFront()
    {
        if (isEmpty())
        {
            cout << "Train is empty\n";
            return;
        }

        Carriage *temp = front;
        if (front == rear) // Only one carriage
        {
            front = rear = nullptr;
        }
        else
        {
            front = front->next;
            front->prev = nullptr;
        }
        delete temp;
    }

    void deleteAtRear()
    {
        if (isEmpty())
        {
            cout << "Train is empty\n";
            return;
        }

        Carriage *temp = rear;
        if (front == rear) // Only one carriage
        {
            front = rear = nullptr;
        }
        else
        {
            rear = rear->prev;
            rear->next = nullptr;
        }
        delete temp;
    }

    void displayAll()
    {
        if (isEmpty())
        {
            cout << "Train is empty\n";
            return;
        }

        Carriage *temp = front;
        while (temp != nullptr)
        {
            cout << "Carriage ID: " << temp->id << " Capacity: " << temp->capacity << endl;
            temp = temp->next;
        }
    }

    void searchID(int id)
    {
        if (isEmpty())
        {
            cout << "Train is empty\n";
            return;
        }

        Carriage *temp = front;
        while (temp != nullptr)
        {
            if (temp->id == id)
            {
                cout << "Carriage ID: " << temp->id << " Capacity: " << temp->capacity << endl;
                return;
            }
            temp = temp->next;
        }
        cout << "ID not found\n";
    }
};

int main()
{
    Train t;
    t.insertAtRear(101, 50);
    t.insertAtRear(102, 75);
    t.insertAtFront(100, 100);

    t.displayAll();

    t.deleteAtFront();

    t.displayAll();

    t.searchID(102);
    t.deleteAtRear();
    t.displayAll();
    return 0;
}
