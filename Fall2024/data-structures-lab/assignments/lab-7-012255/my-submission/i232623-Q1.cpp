#include <iostream>
using namespace std;

class Node
{
    public:

    Node* left;
    Node* right;
    int data;

    Node(int data):left(nullptr),right(nullptr),data(data){}
    ~Node()
    {
        delete left;
        delete right;
    }
};

class BinarySearch
{
    public:

    Node* root;

    BinarySearch():root(nullptr){}

    void levelOrder(Node* root)
    {
        if(root == nullptr)
        {
            return;
        }

        int h = height(root);

        for(int i = 1; i <= h; i++)
        {
            printLevel(root, i);
        }
    }

    int height(Node* root)
    {
        if(root == nullptr)
        {
            return 0;
        }

        int lheight = height(root->left);
        int rheight = height(root->right);

        if(lheight > rheight)
        {
            return lheight + 1;
        }
        else
        {
            return rheight + 1;
        }
    }

    void printLevel(Node* root, int level)
    {
        if(root == nullptr)
        {
            return;
        }

        if(level == 1)
        {
            cout<<root->data<<" ";
        }
        else if(level > 1)
        {
            printLevel(root->left, level - 1);
            printLevel(root->right, level - 1);
        }
    }

};

int main()
{
    BinarySearch tree;
    //hard code tree
    tree.root = new Node(1);
    tree.root->left = new Node(2);
    tree.root->right = new Node(3);
    tree.root->left->left = new Node(4);
    tree.root->left->right = new Node(5);
    tree.root->right->left = new Node(6);
    tree.root->right->right = new Node(7);
    tree.levelOrder(tree.root);

    return 0;
}