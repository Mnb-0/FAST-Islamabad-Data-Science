#include <iostream>
using namespace std;

struct Node
{
    int data;
    Node *left;
    Node *right;

    Node(int data = 0)
    {
        this->data = data;
        left = nullptr;
        right = nullptr;
    }
};

class BinarySearchTree
{
private:
    Node *root;

    Node *insert(Node *root, int data)
    {
        Node *newNode = new Node(data);
        if (root == nullptr) // Empty
        {
            root = newNode; // new root
            return root;
        }

        if (data < root->data && root != nullptr)
        {
            root = insert(root->left, data);
        }
        else if (data > root->data && root != nullptr)
        {
            root = insert(root->right, data);
        }
        return root;
    }

    Node *print(Node *root)
    {
        if (root == nullptr)
        {
            return root;
        }

        if (root->left != nullptr)
        {
            root=print(root->left);
        }
        cout<<root->data<<" ";
        if (root->right != nullptr)
        {
            root = print(root->right);
        }
    }

    Node *convertToGreater(Node *root, int data)
    {
        Node *newNode = new Node(data);
        if (root == nullptr) // Empty
        {
            root = newNode; // new root
            return root;
        }
        if (data < root->data && root != nullptr)
        {
            root = convertToGreater(root->left, data + root->data); // recursively increase value while traversing
        }
        else if (data > root->data && root != nullptr)
        {
            root = convertToGreater(root->right, data); // do not increase value as data > root
        }
        return root;
    }

public:
    BinarySearchTree()
    {
        root = nullptr;
    }

    BinarySearchTree(Node *root)
    {
        this->root = root;
    }

    void insertWrap(int data)
    {
        root = insert(root, data);
    }

    void convertWrap(int data)
    {
        root = convertToGreater(root, data);
    }
    void printTree()
    {
        root = print(root);
    }
};

int main()
{
    BinarySearchTree bst;
    BinarySearchTree bst2;
    int inArr[] = {4, 1, 6, 0, 2, 5, 7, 3, 8};
    for (int i = 0; i < sizeof(inArr) / sizeof(inArr[0]); i++)
    {
        bst.insertWrap(inArr[i]);
        bst2.convertWrap(inArr[i]);
    }

    bst.printTree();
    cout<<endl;
    bst2.printTree();
}