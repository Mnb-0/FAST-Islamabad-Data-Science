#include <iostream>
using namespace std;

// class template
template <typename T>
class List
{
private:
    T *list;      // Dynamic array to store the list elements
    int capacity; // Maximum capacity of the list
    int length;   // Current number of elements in the list

    void resize()
    {
        // Resize the array to double its current size
        T *newList = new T[capacity * 2];
        for (int i = 0; i < length; i++)
        {
            newList[i] = list[i];
        }
        delete[] list;
        list = newList;
        capacity *= 2;
    }

public:
    // Constructor to initialize the list with a fixed capacity
    List(int initialSize = 100)
    {
        capacity = initialSize;
        list = new T[capacity];
        length = 0;
    }

    // Destructor to free the dynamically allocated memory
    ~List()
    {
        delete[] list;
    }

    // Insert an element at a specific position (0-based index)
    void insert(int position, T value)
    {
        if (position < 0 || position > length)
        {
            cout << "Invalid position" << endl;
            return;
        }
        if (length == capacity)
        {
            resize();
        }
        for (int i = length; i > position; i--)
        {
            list[i] = list[i - 1];
        }
        list[position] = value;
        length++; // Update the length after insertion
    }

    // Delete an element by its value (first occurrence)
    bool deleteByValue(T value)
    {
        bool found = false;
        int pos = -1;
        // write code
        for (int i = 0; i < length; i++)
        {
            if (value == list[i])
            {
                found = true;
                pos = i;
            }
        }

        if (found == true)
        {
            for (int i = pos; i < length; i++)
            {
                list[i] = list[i + 1];
            }
        }

        return found;
    }

    // Delete an element by its position (0-based index)
    bool deleteByPosition(int position)
    {

        // write code
        if (position < 0 || position > length)
        {
            cout << "Invalid position" << endl;
            return false;
        }

        for (int i = position; i < length; i++)
        {
            list[i] = list[i + 1];
        }

        return true;
    }

    // Search for an element by its value, return the position if found, otherwise -1
    int search(T value)
    {

        // write code
        for (int i = 0; i < length; i++)
        {
            if (list[i] == value)
            {
                return i;
            }
        }

        return -1;
    }

    // Access an element by its position (0-based index)
    T access(int position)
    {

        // write code
        if (position < 0 || position > length)
        {
            cout << "Invalid position" << endl;
            return -1;
        }
        return list[position];
    }

    // Return the current number of elements in the list
    int size()
    {

        // write code
        return length;
    }

    // Check if the list is empty
    bool isEmpty()
    {

        // write code
        if (length == 0)
        {
            return true;
        }
        return false;
    }

    // Display the elements of the list
    void display()
    {

        // write code
        for (int i = 0; i < length; i++)
        {
            cout << list[i] << " ";
        }
        cout << endl;
    }
};

int main()
{

    // write code to test functionalities
    List<int> list;
    list.insert(0, 1);
    list.insert(1, 2);
    list.insert(2, 3);
    list.insert(3, 4);
    list.insert(4, 5);
    list.deleteByValue(4);
    list.deleteByPosition(2);
    list.display();
    cout << "Position of element 3: " << list.search(3) << endl;
    cout << "Element at position 2: " << list.access(2) << endl;
    cout << "Current size of the list: " << list.size() << endl;

    return 0;
}
