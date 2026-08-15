#include <iostream>
using namespace std;

struct Node
{
    int id;
    int latency;
    Node *left;
    Node *right;

    Node(int id = -1, int latency = 0)
    {
        this->id = id;
        this->latency = latency;
        left = nullptr;
        right = nullptr;
    }
};

class AVL
{
    Node *root;

    void leftRotate()
    {
        Node *temp = root;
        root = root->right;
        root->left = temp;
    }

    void rightRotate()
    {
        Node *temp = root;
        root = root->left;
        root->right = temp;
    }

    int height()
    {
        int heightL = 0;
        int heightR = 0;
        Node *temp1 = root;
        Node *temp2 = root;
        while (temp1 != nullptr)
        {
            temp1 = temp1->left;
            heightL++;
        }
        while (temp2 != nullptr)
        {
            temp2 = temp2->right;
            heightL++;
        }

        return max(heightL, heightR);
    }

public:
    AVL(Node *root = nullptr) : root(root) {}

    Node *addRouter(Node *root, int id, int latency)
    {

        Node *newNode = new Node(id, latency);
        if (id == root->id)
        {
            return nullptr;
        }
        if (root == nullptr) // Empty
        {
            root = newNode; // new root
            if (height() >= 1)
            {
                leftRotate();
            }
            if (height() <= 1)
            {
                rightRotate();
            }
            return root;
        }

        if (latency < root->latency && root != nullptr)
        {
            root = addRouter(root->left, id, latency);
        }
        else if (latency > root->latency && root != nullptr)
        {
            root = addRouter(root->right, id, latency);
        }
    }

    Node *removeRouter(int id)
    {
    }

    /*
    inorder
    */

    // preorder left root right
    Node *updateLatency(Node *root, int id, int newLatency)
    {
        if (root == nullptr)
        {
            return root;
        }
        if (id == root->id)
        {
            root->latency = newLatency;
        }

        if (root->left != nullptr)
        {
            root = updateLatency(root->left, id, newLatency);
        }
        if (root->right != nullptr)
        {
            root = updateLatency(root->right, id, newLatency);
        }
    }

    void updateLatency(int id, int newLatency)
    {
        root = updateLatency(root, id, newLatency);
    }
    int minLatB;

    Node *findBest(Node *root, int threshold)
    {
        if (root == nullptr)
        {
            return root;
        }
        if (root->latency >= threshold)
        {
            minLatB = root->latency;
        }

        if (root->right != nullptr && threshold < root->latency)
        {
            root = findBest(root->right, threshold);
        }
        if (root->left != nullptr && threshold < root->latency)
        {
            root = findBest(root->left, threshold);
        }
    }

    void addRouterHelp(int id, int latency)
    {
        root = addRouter(root, id, latency);
    }

    int findBest(int threshold)
    {
        root = findBest(root, threshold);
        return minLatB;
    }
};

int main()
{
    AVL avl;
    avl.addRouterHelp(10, 50);
    avl.addRouterHelp(20, 30);
    avl.addRouterHelp(15, 40);
    cout << avl.findBest(35) << '\n';
    avl.updateLatency(15, 25);
    avl.findBest(35);
    avl.removeRouter(20);
    return 0;
}