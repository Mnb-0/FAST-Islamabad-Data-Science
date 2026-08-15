#include <iostream>
using namespace std;

struct Node
{
	int data;
	Node* next;


    Node(int data) :data(data), next(nullptr) {}
};


class Queue 
{
public:
    Node* front;
    Node* rear;
    int size;

    Queue() 
    {
        size = 1;
        front = rear = NULL;
    }

    int getsize()
    {
        return size;
    }

    void enqueue(int x) 
    {
        Node* temp = new Node(x);
        temp->next = NULL;
        if (front == NULL && rear == NULL) 
        {
            front = rear = temp;
            return;
        }
        rear->next = temp;
        rear = temp;
        size++;
    }

    void dequeue() 
    {
        Node* temp = front;
        if (front == NULL) 
        {
            return;
        }
        if (front == rear) 
        {
            front = rear = NULL;
        }
        else 
        {
            front = front->next;
        }
        delete temp;
        size--;
    }

    void print() 
    {
        Node* temp = front;
        while (temp != NULL) 
        {
            cout << temp->data << " ";
            temp = temp->next;
        }
        cout << endl;
    }

    Queue createSubqueue(int startPos, int endPos)
    {

        if (front == rear)
        {
            cout << "Queue Empty\n";
            return *this;
        }
        Node* temp = front;
        Node* temp2 = rear;
        Queue newQueue;

        for (int i = 0; i < startPos && temp->next != nullptr; i++)
        {
            temp = temp->next;

        }

    
        for (int i = startPos; i < endPos && temp != nullptr; i++)
        {
            newQueue.enqueue(temp->data);
            temp = temp->next;
        }

        return newQueue;

    }

    Queue* createNqueues(int n)
    {
        if (front == rear)
        {
            cout << "Queue Empty\n";
            return this;
        }

        int subSize = this->size / n;

        if (subSize <= 0)
        {
            cout << "Invalid number of subqueues";
            return this;
        }
        Node* temp = front;
        for (int i = 0; i < subSize && temp->next != nullptr; i++)
        {

        }
        Queue* queues = new Queue[n];
        
        for (int i = 0; i < n; i++) 
        {
            queues[i].front = temp;
        
        for (int j = 0; j < subSize && temp != nullptr; j++) 
        {
            temp = temp->next;
        }
        queues[i].rear = temp;
        if (temp != nullptr) 
        {
            Node* nextTemp = temp->next;
            temp->next = nullptr;
            temp = nextTemp;
        }
    }
        return queues;

    }
};




int main()
{
    int N;
	cout << "Enter the number of subqueues(N): \n";
    cin >> N;
    //hardcoding original queue
    Queue original;
    for (int i = 0; i < 8; i++)
    {
        original.enqueue(i);
    }
    cout << "Original Queue: " << endl;
    original.print();
    cout <<"Size: " << original.getsize() << "\n";
    Queue* arrQ = original.createNqueues(2);
    //print subqueues
    for (int i = 0; i < N; i++)
    {
        arrQ[i].print();
        cout << endl;
    }

    

	return 0;
}
