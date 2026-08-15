#include <iostream>
#include <queue>
#include <stack>
using namespace std;

class Graph
{
private:
    struct Node
    {
        int id;
        Node *next;

        Node(int id) : id(id), next(nullptr) {}
    };

    Node **adjList;
    int size;

public:
    Graph(int size) : size(size)
    {
        adjList = new Node *[size];
        for (int i = 0; i < size; ++i)
        {
            adjList[i] = nullptr;
        }
    }

    void addEdge(int from, int to)
    {
        if (from < 0 || from >= size || to < 0 || to >= size)
        {
            cout << "Invalid edge (" << from << ", " << to << ")." << endl;
            return;
        }

        Node *newNode = new Node(to);
        newNode->next = adjList[from];
        adjList[from] = newNode;
    }

    void printAdjList()
    {
        for (int i = 0; i < size; ++i)
        {
            cout << "Node " << i << " is connected to: ";
            Node *temp = adjList[i];
            while (temp != nullptr)
            {
                cout << temp->id << " ";
                temp = temp->next;
            }
            cout << endl;
        }
    }

    void bfs(int start)
    {
        if (start < 0 || start >= size)
        {
            cout << "Invalid start node for BFS." << endl;
            return;
        }

        bool *visited = new bool[size]{false};
        queue<int> q;

        q.push(start);
        visited[start] = true;

        while (!q.empty())
        {
            int current = q.front();
            q.pop();
            cout << current << " ";

            Node *temp = adjList[current];
            while (temp != nullptr)
            {
                if (!visited[temp->id])
                {
                    q.push(temp->id);
                    visited[temp->id] = true;
                }
                temp = temp->next;
            }
        }
        cout << endl;

        delete[] visited;
    }

    void dfs(int start)
    {
        if (start < 0 || start >= size)
        {
            cout << "Invalid start node for DFS." << endl;
            return;
        }

        bool *visited = new bool[size]{false};
        stack<int> stk;

        stk.push(start);

        while (!stk.empty())
        {
            int current = stk.top();
            stk.pop();

            if (!visited[current])
            {
                cout << current << " ";
                visited[current] = true;

                Node *temp = adjList[current];
                while (temp != nullptr)
                {
                    if (!visited[temp->id])
                    {
                        stk.push(temp->id);
                    }
                    temp = temp->next;
                }
            }
        }
        cout << endl;

        delete[] visited;
    }

    ~Graph()
    {
        for (int i = 0; i < size; ++i)
        {
            Node *current = adjList[i];
            while (current != nullptr)
            {
                Node *temp = current;
                current = current->next;
                delete temp;
            }
        }
        delete[] adjList;
    }
};

int main()
{
    Graph g(5);
    g.addEdge(0, 1);
    g.addEdge(0, 2);
    g.addEdge(1, 3);
    g.addEdge(1, 4);

    cout << "Adjacency List:" << endl;
    g.printAdjList();

    cout << "BFS Traversal starting from node 0: ";
    g.bfs(0);

    cout << "DFS Traversal starting from node 0: ";
    g.dfs(0);

    return 0;
}
