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
    // Constructors
    Matrix(int rows, int cols)
    {
        allocateMatrix(rows, cols);
    }

    Matrix()
    {
        allocateMatrix(0, 0);
    }

    // Destructor
    ~Matrix()
    {
        deallocateMatrix();
    }

    Matrix(const Matrix &other)
    {
        this->rows = other.rows;
        this->cols = other.cols;
        this->allocateMatrix(this->rows, this->cols);
        for (int i = 0; i < this->rows; i++)
        {
            for (int j = 0; j < this->cols; j++)
            {
                this->matrix[i][j] = other.matrix[i][j];
            }
        }
    }

    Matrix operator=(const Matrix &other)
    {
        this->deallocateMatrix();
        this->rows = other.rows;
        this->cols = other.cols;
        this->allocateMatrix(this->rows, this->cols);
        for (int i = 0; i < this->rows; i++)
        {
            for (int j = 0; j < this->cols; j++)
            {
                this->matrix[i][j] = other.matrix[i][j];
            }
        }
        return *this;
    }

    // Function to set value at specific position
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
    void print()
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

    Matrix operator*(const Matrix &other)
    {
        if (this->cols != other.rows)
        {
            cout << "Invalid dimensions this matrix cannot be multiplied.\n";
            return *this;
        }

        Matrix temp(this->rows, other.cols);
        for (int i = 0; i < this->rows; i++)
        {
            for (int j = 0; j < other.cols; j++)
            {
                temp.matrix[i][j] = 0;
                for (int k = 0; k < this->cols; k++)
                {
                    temp.matrix[i][j] += this->matrix[i][k] * other.matrix[k][j];
                }
            }
        }
        return temp;
    }
};

int main()
{

    // Create two matrices
    Matrix mat1(2, 3);
    Matrix mat2(3, 2);

    // Set values for mat1
    mat1.initalizeMatrix(1); // starting value = 1, initialize matrix with 1..6
    mat2.initalizeMatrix(7); // starting value = 7, initialize matrix with 7..12

    // Print matrices
    cout << "Matrix 1:" << endl;
    mat1.print();

    cout << "Matrix 2:" << endl;
    mat2.print();

    // Multiply matrices (overload * operator)
    Matrix mat3 = mat1 * mat2;

    // Print result
    cout << "Matrix 1 * Matrix 2:" << endl;
    mat3.print();

    Matrix mat4;
    mat4 = mat1;

    cout << "Matrix 4:" << endl;
    mat4.print();

    Matrix mat5 = mat2;
    cout << "Matrix 5:" << endl;
    mat5.print();

    return 0;
}
