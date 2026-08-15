#include <iostream>
using namespace std;

struct Node
{
    int data;
    Node *left;
    Node *right;

    Node(int data) : data(data), left(nullptr), right(nullptr) {}

    ~Node()
    {
        delete left;
        delete right;
    }
};

class BST
{
public:
    Node *root;

    BST() : root(nullptr) {}

    Node *insert(Node *root, int data)
    {
        if (root == nullptr)
        {
            Node *newNode = new Node(data);
            return newNode;
        }
        if (data > root->data)
        {
            root->right = insert(root->right, data);
        }
        else if (data < root->data)
        {
            root->left = insert(root->left, data);
        }
        else
        {
            cout << "Duplicate Value\n";
        }
        return root;
    }

    Node *search(Node *root, int data)
    {
        if (root == nullptr || root->data == data)
        {
            return root; // found or not found
        }
        if (data > root->data)
        {
            return search(root->right, data);
        }
        else
        {
            return search(root->left, data);
        }
    }
    Node* inOrderSuccessor(Node* root)
    {
        if(root->left == nullptr)
        {
            return root;
        }
        else
        {
            return inOrderSuccessor(root->left);
        }
    }

    Node* bstDelete(Node* root, int key)
    {
        if(key>root->data)
        {
            root->right = bstDelete(root->right, key);
        }
        else if(key < root->data)
        {
            root->left = bstDelete(root->left, key);
        }
        else
        {
            if(root->left == nullptr)
            {
                Node* temp = root->right;
                delete root;
                return temp;
            }
            else if(root->right == nullptr)
            {
                Node* temp = root->left;
                delete root;
                return temp;
            }

            Node* temp = root->right;
            while(temp && temp->left != nullptr)
            {
                temp = temp->left;
            }
            root->data = temp->data;

            root->right = bstDelete(root->right, key);
        }
        return root;
    }
};

int main()
{
    BST tree;
    tree.root = tree.insert(tree.root, 1);
    tree.root = tree.insert(tree.root, 3);
    tree.root = tree.insert(tree.root, 4);
    tree.root = tree.insert(tree.root, 5);

    int data;
    cout<<"Enter data\n";
    cin >> data;
    tree.bstDelete(tree.root,5);
    Node *temp = tree.search(tree.root, data);
    if (temp == nullptr)
    {
        cout << "not found\n";
    }
    else
    {
        cout << "found\n";
    }

    return 0;
}
