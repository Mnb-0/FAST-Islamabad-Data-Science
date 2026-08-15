#include <iostream>
using namespace std;

bool check(int **&arr, int row, int col, int &size);
bool solve(int **&arr, int row, int size);
bool secondary(int **&arr, int row, int col, int size);
void printArr(int **arr, int size);

int main()
{
    int size;
    cout << "Enter size of the arr: ";
    cin >> size;
    if (size >= 8 && size % 2 == 0)
    {
        int **arr = new int *[size];
        for (int i = 0; i < size; ++i)
        {
            arr[i] = new int[size]();
        }

        if (secondary(arr, 0, 0, size))
        {
            printArr(arr, size);
        }
        else
        {
            cout << "No solution found." << endl;
        }

        for (int i = 0; i < size; ++i)
        {
            delete[] arr[i];
        }
        delete[] arr;
    }
    else
    {
        cout<<"\nInvalid size.\n";
    }
    

    return 0;
}

// Function to print the arr
void printArr(int **arr, int size)
{
    for (int i = 0; i < size; ++i)
    {
        for (int j = 0; j < size; ++j)
        {
            cout << (arr[i][j] ? '*' : ' ') << " ";
        }
        cout << endl;
    }
}
// Function to check if position is valid
bool check(int **&arr, int row, int col, int &size)
{
    for (int i = 0; i < size; i++)
    {
        if (arr[i][col] == 1)
            return false;
        if (row - i >= 0 && col - i >= 0 && arr[row - i][col - i] == 1)
            return false;
        if (row - i >= 0 && col + i < size && arr[row - i][col + i] == 1)
            return false;
    }
    return true;
}
// recursive function to attempt to place asterisk
bool solve(int **&arr, int row, int size)
{
    if (row >= size)
    {
        return true; // if solution found
    }
    for (int col = 0; col < size; col++)
    {
        if (check(arr, row, col, size))
        {
            arr[row][col] = 1;
            if (solve(arr, row + 1, size))
            {
                return true; // if solution found
            }
            arr[row][col] = 0; // backtrack
        }
    }
    return false; // no solution found
}

bool secondary(int **&arr, int row, int col, int size)
{
    return solve(arr, row, size);
}
