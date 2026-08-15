#include <iostream>
using namespace std;

class Graph
{
    private:
        int n;
        int **A;

    public:
        Graph(int size = 2);
        ~Graph();
        void addEdge(int from, int to, int weight);
        void addVertex();
        void printGraph();
};

Graph::Graph(int size)
{
    int i, j;
    n = size;
    A = new int*[n];
    for (i = 0; i < n; i++)
    {
        A[i] = new int[n];
    }
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < n; j++)
        {
            A[i][j] = 0;
        }
    }
}

Graph::~Graph()
{
    for (int i = 0; i < n; i++)
    {
        delete[] A[i];
    }
    delete[] A;
}

void Graph::addEdge(int from, int to, int weight)
{
    A[from][to] = weight;
}

void Graph::addVertex()
{
    int i, j;
    int **B = new int*[n + 1];
    for (i = 0; i < n + 1; i++)
    {
        B[i] = new int[n + 1];
    }
    for (i = 0; i < n + 1; i++)
    {
        for (j = 0; j < n + 1; j++)
        {
            B[i][j] = 0;
        }
    }
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < n; j++)
        {
            B[i][j] = A[i][j];
        }
    }
    for (i = 0; i < n; i++)
    {
        delete[] A[i];
    }
    delete[] A;
    A = B;
    n++;
}

void Graph::printGraph()
{
    int i, j;
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < n; j++)
        {
            cout << A[i][j] << " ";
        }
        cout << endl;
    }
}

int main()
{
    Graph G(3);
    G.addEdge(0, 1, 1);
    G.addEdge(1, 2, 2);
    G.addEdge(2, 0, 3);
    G.printGraph();
    G.addVertex();
    G.addEdge(3, 0, 4);
    G.addEdge(3, 1, 5);
    G.addEdge(3, 2, 6);
    G.addEdge(0, 3, 7);
    G.printGraph();
    return 0;
}