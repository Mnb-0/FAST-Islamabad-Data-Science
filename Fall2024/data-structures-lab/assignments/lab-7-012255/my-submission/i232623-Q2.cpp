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

class BinaryTree
{
    public:

    Node* root;

    BinaryTree():root(nullptr){}

    

    void inorder(Node* root)
    {
        if(root == nullptr)
        {
            return;
        }

        inorder(root->left);
        cout<<root->data<<" ";
        inorder(root->right);
    }

    void preorder(Node* root)
    {
        if(root == nullptr)
        {
            return;
        }

        cout<<root->data<<" ";
        preorder(root->left);
        preorder(root->right);
    }

    void postorder(Node* root)
    {
        if(root == nullptr)
        {
            return;
        }

        postorder(root->left);
        postorder(root->right);
        cout<<root->data<<" ";
    }
    ~BinaryTree()
    {
        delete root;
    }
};

int main()
{//main for traversal example
    BinaryTree tree;
    tree.root = new Node(1);
    tree.root->left = new Node(2);
    tree.root->right = new Node(3);
    tree.root->left->left = new Node(4);
    tree.root->left->right = new Node(5);
    tree.root->right->left = new Node(6);
    tree.root->right->right = new Node(7);
    tree.inorder(tree.root);
    cout<<endl;
    tree.preorder(tree.root);
    cout<<endl;
    tree.postorder(tree.root);
    cout<<endl;

    return 0;
}