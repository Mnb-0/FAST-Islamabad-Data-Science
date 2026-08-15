#include <iostream>
using namespace std;

struct Node
{
    int num;
    int supplies;
    bool baseCamp;
    bool treasure;

    Node() : num(0), supplies(0), baseCamp(0), treasure(0) {}

    Node(int num, int supplies, bool base = false, bool treasure = false)
    {
        this->num = num;
        this->supplies = supplies;
        this->baseCamp = base;
        this->treasure = treasure;
    }
};

struct Edge
{
    Node start;
    Node end;
    int difficulty;
    int wait;
    bool blocked;

    Edge() : difficulty(0), wait(0), blocked(0) {}
    Edge(Node start, Node end, int difficulty, int wait, bool blocked) : start(start), end(end), difficulty(difficulty), wait(wait), blocked(blocked) {}
};

class Graph
{
    int **adjMatrix;
    int N;
    int E;

public:
    Graph(int n = 0)
    {
        this->N = n;
        if (n <= 0)
        {
            return;
        }
        adjMatrix = new int *[N];
        for (int i = 0; i < n; i++)
        {
            adjMatrix[i] = new int[N];
            for (int j = 0; j < n; j++)
            {
                adjMatrix[i][j] = 0;
            }
        }
    }

    void populateGraph(Edge edge)
    {
        if (adjMatrix == nullptr)
        {
            return;
        }

        adjMatrix[edge.start.num - 1][edge.end.num - 1] = edge.difficulty; //-1 to account for 1 based indexes in the nodes
        adjMatrix[edge.end.num - 1][edge.start.num - 1] = edge.difficulty;
    }

    void printGraph()
    {
        for (int i = 0; i < N; i++)
        {
            for (int j = 0; j < N; j++)
            {
                cout << adjMatrix[i][j] << " ";
            }
            cout << endl;
        }
    }

//consider first element as a valid minheap
    void heapifyUp(int arr[],int n)
    {
        while(n < sizeof(arr)/sizeof(arr[0]))
        {
            if (arr[n] > arr[n/2])
            {
                swap(arr[n],arr[n/2]);
                n = n/2;
            }
        }

    }


    int Dijkstra(Node start, Node end)
    {
        int priority_queue[E];
    }
};



int main()
{
    int n = 6, e = 7, k = 4;
    int supplies[] = {2, 0, 3, 0, 1, 0};
    Node node1(1, supplies[0], true);
    Node node2(2, supplies[1]);
    Node node3(3, supplies[2]);
    Node node4(4, supplies[3]);
    Node node5(5, supplies[4]);
    Node node6(6, supplies[5], false, true);

    Node arrNode[] = {node1, node2, node3, node4, node5, node6};

    Edge edge1(node1, node2, 3, 0, false);
    Edge edge2(node1, node3, 5, 2, true);
    Edge edge3(node2, node3, 2, 0, false);
    Edge edge4(node2, node4, 4, 0, false);
    Edge edge5(node3, node5, 7, 3, true);
    Edge edge6(node4, node5, 1, 0, false);
    Edge edge7(node5, node6, 6, 1, true);

    Edge arrEdge[] = {edge1,edge2,edge3,edge4,edge5,edge6,edge7};

    Graph graph(n);

    for (int i = 0; i < 7; i++)
    {
        graph.populateGraph(arrEdge[i]);
    }

    graph.printGraph();
    return 0;
}