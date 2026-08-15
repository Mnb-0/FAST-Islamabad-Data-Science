#include <iostream>
#include <cstdlib>
#include <ctime>

#define TABLE_SIZE 10

using namespace std;

struct HashEntry
{
    int key;
    bool occupied;
    HashEntry() : key(-1), occupied(false) {}
};

class HashTable
{
private:
    HashEntry table[TABLE_SIZE];
    int hashFunction(int key)
    {
        return key % TABLE_SIZE;
    }

    int randomProbe(int currentIndex)
    {
        return rand() % TABLE_SIZE;
    }

public:
    HashTable()
    {
        srand(time(0));
    }

    void insertLinear(int key)
    {
        int index = hashFunction(key);
        int originalIndex = index;
        while (table[index].occupied)
        {
            index = (index + 1) % TABLE_SIZE;
            if (index == originalIndex)
            {
                cout << "Table is full! Cannot insert key: " << key << endl;
                return;
            }
        }
        table[index].key = key;
        table[index].occupied = true;
        cout << "Key " << key << " inserted at index " << index << " using Linear Probing.\n";
    }

    void insertQuadratic(int key)
    {
        int index = hashFunction(key);
        int i = 1;
        while (table[index].occupied)
        {
            index = (index + i * i) % TABLE_SIZE;
            i++;
            if (i > TABLE_SIZE)
            {
                cout << "Table is full! Cannot insert key: " << key << endl;
                return;
            }
        }
        table[index].key = key;
        table[index].occupied = true;
        cout << "Key " << key << " inserted at index " << index << " using Quadratic Probing.\n";
    }

    void insertRandom(int key)
    {
        int index = hashFunction(key);
        int originalIndex = index;
        while (table[index].occupied)
        {
            index = randomProbe(index);
            if (index == originalIndex)
            {
                cout << "Table is full! Cannot insert key: " << key << endl;
                return;
            }
        }
        table[index].key = key;
        table[index].occupied = true;
        cout << "Key " << key << " inserted at index " << index << " using Random Probing.\n";
    }

    void search(int key)
    {
        int index = hashFunction(key);
        int originalIndex = index;
        int i = 0;
        while (table[index].occupied && table[index].key != key)
        {
            index = (index + 1) % TABLE_SIZE;
            if (index == originalIndex || i++ > TABLE_SIZE)
            {
                cout << "Key " << key << " not found.\n";
                return;
            }
        }
        if (table[index].occupied && table[index].key == key)
            cout << "Key " << key << " found at index " << index << ".\n";
        else
            cout << "Key " << key << " not found.\n";
    }

    void display()
    {
        for (int i = 0; i < TABLE_SIZE; i++)
        {
            if (table[i].occupied)
                cout << "Index " << i << ": Key " << table[i].key << endl;
            else
                cout << "Index " << i << ": Empty\n";
        }
    }
};

int main()
{
    HashTable ht;
    int choice, key;

    while (true)
    {
        cout << "\nMenu:\n1. Insert (Linear Probing)\n2. Insert (Quadratic Probing)\n3. Insert (Random Probing)\n4. Search\n5. Display\n6. Exit\nEnter your choice: ";
        cin >> choice;

        switch (choice)
        {
        case 1:
            cout << "Enter key to insert using Linear Probing: ";
            cin >> key;
            ht.insertLinear(key);
            break;
        case 2:
            cout << "Enter key to insert using Quadratic Probing: ";
            cin >> key;
            ht.insertQuadratic(key);
            break;
        case 3:
            cout << "Enter key to insert using Random Probing: ";
            cin >> key;
            ht.insertRandom(key);
            break;
        case 4:
            cout << "Enter key to search: ";
            cin >> key;
            ht.search(key);
            break;
        case 5:
            cout << "Hash Table:\n";
            ht.display();
            break;
        case 6:
            return 0;
        default:
            cout << "Invalid choice! Try again.\n";
        }
    }
}
