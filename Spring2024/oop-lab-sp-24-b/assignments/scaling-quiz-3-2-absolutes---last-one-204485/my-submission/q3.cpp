#include <iostream>
#include <stdexcept>

using namespace std;

class Matrix
{
private:
    int **matrix;
    int rows;
    int cols;

    // Helper function to allocate memory
    void allocateMatrix(int rows, int cols)
    {
        this->rows = rows;
        this->cols = cols;
        matrix = new int *[rows];
        for (int i = 0; i < rows; ++i)
        {
            matrix[i] = new int[cols];
        }
    }

    // Helper function to deallocate memory
    void deallocateMatrix()
    {
        for (int i = 0; i < rows; ++i)
        {
            delete[] matrix[i];
        }
        delete[] matrix;
    }

public:
    // Constructor
    Matrix(int rows, int cols)
    {
        allocateMatrix(rows, cols);
    }

    // Destructor
    ~Matrix()
    {
        deallocateMatrix();
    }

    // Function to initialize the matrix
    void initalizeMatrix(int startingValue)
    {
        for (int i = 0; i < this->rows; ++i)
        {
            for (int j = 0; j < this->cols; ++j)
            {
                matrix[i][j] = startingValue++;
            }
        }
    }

    // Function to print the matrix
    void printMatrix()
    {
        for (int i = 0; i < rows; ++i)
        {
            for (int j = 0; j < cols; ++j)
            {
                cout << matrix[i][j] << " ";
            }
            cout << endl;
        }
    }

    // Function to find and display all pairs that add up to a target value
    void findPairsWithSum(int target)
    {
        for (int i = 0; i < rows; ++i)
        {
            for (int j = 0; j < cols; ++j)
            {
                iterate(i, j, target);
            }
        }
    }
    void iterate(int row, int col, int target)
    {
        for (int k = row; k < rows; ++k)
        {
            int start_col;
            if (k == row)
            {
                start_col = col + 1;
            }
            else
            {
                start_col = 0;
            }
            for (int l = start_col; l < cols; ++l)
            {
                checkPair(row, col, k, l, target);
            }
        }
    }

    void checkPair(int i, int j, int k, int l, int target)
    {
        if (matrix[i][j] + matrix[k][l] == target)
        {
            printPair(i, j, k, l);
        }
    }
    void printPair(int i, int j, int k, int l)
    {
        cout << matrix[i][j] << " and " << matrix[k][l] << endl;
    }
};

int main()
{

    Matrix mat1(4, 4); // already implemented
    cout << endl
         << "Displaying the matrix " << endl;
    mat1.initalizeMatrix(1); // already implemented, initialize matrix with 1..16
    mat1.printMatrix();      // already implemented

    // TASK 1: Display all pairs that add up to a target value
    cout << endl
         << "testing code for target value = 12" << endl;
    mat1.findPairsWithSum(12); // target value = 12

    cout << endl
         << "testing code for target value = 7" << endl;
    mat1.findPairsWithSum(7); // target value = 7

    cout << endl
         << "testing code for target value = 18" << endl;
    mat1.findPairsWithSum(18); // target value = 18

    return 0;
}
