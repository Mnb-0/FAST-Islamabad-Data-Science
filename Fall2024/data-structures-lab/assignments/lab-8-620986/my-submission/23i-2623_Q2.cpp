#include <iostream>
using namespace std;

class Node
{
public:
    int employeeID;
    Node *left;
    Node *right;

    Node(int employeeID = -1)
    {
        this->employeeID = employeeID;
        left = right = NULL;
    }
};

class BinarySearchTree
{
public:
    Node *root;

    BinarySearchTree()
    {
        root = NULL;
    }

    Node *insertEmployee(Node *root, int employeeID)
    {
        if (root == NULL)
        {
            root = new Node(employeeID);
            return root;
        }

        if (employeeID < root->employeeID)
            root->left = insertEmployee(root->left, employeeID);
        else if (employeeID > root->employeeID)
            root->right = insertEmployee(root->right, employeeID);

        return root;
    }

    bool searchEmployee(Node* node, int employeeID)
    {
        if (node == NULL)
            return false;

        if (node->employeeID == employeeID)
            return true;

        if (employeeID < node->employeeID)
            return searchEmployee(node->left, employeeID);
        else
            return searchEmployee(node->right, employeeID);
    }

    void printTree(Node *root)
    {
        if (root == NULL)
            return;

        printTree(root->left);
        cout << root->employeeID << " ";
        printTree(root->right);
    }

    ~BinarySearchTree()
    {
        delete root;
    }
};

int main()
{
    BinarySearchTree bst;
    bst.root = bst.insertEmployee(bst.root, 5001);
    bst.root = bst.insertEmployee(bst.root, 3002);
    bst.root = bst.insertEmployee(bst.root, 4500);
    bst.root = bst.insertEmployee(bst.root, 2100);
    bst.root = bst.insertEmployee(bst.root, 3200);
    bst.root = bst.insertEmployee(bst.root, 7100);
    bst.root = bst.insertEmployee(bst.root, 6000);

    if (bst.searchEmployee(bst.root, 3200))
        cout << "Employee found" << endl;
    else
        cout << "Employee not found" << endl;

    if (bst.searchEmployee(bst.root, 8000))
    {
        cout << "Employee found" << endl;
    }
    else
    {
        cout << "Employee not found" << endl;
    }

    return 0;
}
