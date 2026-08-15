#include <iostream>
using namespace std;


struct Node
{
    int key;
    int value;
    Node *next;

    Node(int key, int value)
    {
        this->key = key;
        this->value = value;
        this->next = nullptr;
    }
};

class HashTable
{
private:
    Node **table;
    int capacity;

    // Hash function
    int hash(int key)
    {
        return key % capacity;
    }

public:
    HashTable(int capacity)
    {
        this->capacity = capacity;
        table = new Node *[capacity];
        for (int i = 0; i < capacity; i++)
        {
            table[i] = nullptr;
        }
    }

    ~HashTable()
    {
        for (int i = 0; i < capacity; i++)
        {
            Node *current = table[i];
            while (current)
            {
                Node *temp = current;
                current = current->next;
                delete temp;
            }
        }
        delete[] table;
    }

    void insert(int key, int value)
    {
        int index = hash(key);
        Node *newNode = new Node(key, value);
        
        newNode->next = table[index];
        table[index] = newNode;
    }

    int search(int key)
    {
        int index = hash(key);
        Node *temp = table[index];

        while (temp != nullptr)
        {
            if (temp->key == key)
            {
                return temp->value;
            }
            temp = temp->next;
        }
        return -1;
    }

    void remove(int key)
    {
        int index = hash(key);
        Node *temp = table[index];
        Node *prev = nullptr;

        while (temp != nullptr)
        {
            if (temp->key == key)
            {
                if (prev == nullptr)
                {
                    table[index] = temp->next;
                }
                else
                {
                    prev->next = temp->next;
                }
                delete temp;
                return;
            }
            prev = temp;
            temp = temp->next;
        }

        cout << "Key " << key << " not found in the hash table." << endl;
    }

    void display()
    {
        for (int i = 0; i < capacity; i++)
        {
            cout << i << ": ";
            Node *temp = table[i];
            while (temp != nullptr)
            {
                cout << "(" << temp->key << ", " << temp->value << ") ";
                temp = temp->next;
            }
            cout << "null" << endl;
        }
    }
};

int main()
{
    HashTable ht(10);

    ht.insert(10, 100);
    ht.insert(15, 150);
    ht.insert(34,320);
    ht.insert(20, 250);

    cout << "Hash table after inserts:" << endl;
    ht.display();

    cout << "Search for key 10: " << ht.search(10) << endl;
    cout << "Search for key 15: " << ht.search(15) << endl;

    ht.remove(10);
    cout << "Hash table after removing key 10:" << endl;
    ht.display();

    cout << "Search for key 20: " << ht.search(20) << endl;
    cout << "Search for key 30: " << ht.search(30) << endl;

    return 0;
}