#include <iostream>
using namespace std;

struct TreeNode
{
    int num;
    TreeNode *left;
    TreeNode *right;
    int height;

    TreeNode(int num = -1)
    {
        this->num = num;
        left = nullptr;
        right = nullptr;
        height = 1;
    }
};

class Tree
{
    TreeNode *root;

public:
    Tree() { root = nullptr; }

    ~Tree() { clear(root); }

    // Destructor helper function
    void clear(TreeNode *node)
    {
        if (node == nullptr)
            return;
        clear(node->left);
        clear(node->right);
        delete node;
    }

    int getHeight(TreeNode *node)
    {
        return node == nullptr ? 0 : node->height;
    }

    int getBalanceFactor(TreeNode *node)
    {
        if (node == nullptr)
            return 0;
        return getHeight(node->left) - getHeight(node->right);
    }

    TreeNode *rightRotate(TreeNode *y)
    {
        TreeNode *x = y->left;
        TreeNode *T2 = x->right;

        // Perform rotation
        x->right = y;
        y->left = T2;

        // Update heights
        y->height = max(getHeight(y->left), getHeight(y->right)) + 1;
        x->height = max(getHeight(x->left), getHeight(x->right)) + 1;

        // Return new root
        return x;
    }

    TreeNode *leftRotate(TreeNode *x)
    {
        TreeNode *y = x->right;
        TreeNode *T2 = y->left;

        // Perform rotation
        y->left = x;
        x->right = T2;

        // Update heights
        x->height = max(getHeight(x->left), getHeight(x->right)) + 1;
        y->height = max(getHeight(y->left), getHeight(y->right)) + 1;

        // Return new root
        return y;
    }

    TreeNode *insert(TreeNode *node, int num)
    {
        // Standard BST insertion
        if (node == nullptr)
            return new TreeNode(num);

        if (num < node->num)
            node->left = insert(node->left, num);
        else if (num > node->num)
            node->right = insert(node->right, num);
        else // Duplicate nums not allowed
            return node;

        // Update height of this ancestor node
        node->height = 1 + max(getHeight(node->left), getHeight(node->right));

        // Get the balance factor
        int balance = getBalanceFactor(node);

        // If the node becomes unbalanced, then there are 4 cases

        // Left Left Case
        if (balance > 1 && num < node->left->num)
            return rightRotate(node);

        // Right Right Case
        if (balance < -1 && num > node->right->num)
            return leftRotate(node);

        // Left Right Case
        if (balance > 1 && num > node->left->num)
        {
            node->left = leftRotate(node->left);
            return rightRotate(node);
        }

        // Right Left Case
        if (balance < -1 && num < node->right->num)
        {
            node->right = rightRotate(node->right);
            return leftRotate(node);
        }

        // Return the unchanged node pointer
        return node;
    }

    void insert(int num)
    {
        root = insert(root, num);
    }

    bool search(TreeNode *node, int num)
    {
        if (node == nullptr)
            return false;
        if (num == node->num)
            return true;
        if (num < node->num)
            return search(node->left, num);
        return search(node->right, num);
    }

    bool search(int num)
    {
        return search(root, num);
    }

    void printInOrder(TreeNode *node)
    {
        if (node == nullptr)
            return;
        printInOrder(node->left);
        cout << node->num << " ";
        printInOrder(node->right);
    }

    void printInOrder()
    {
        printInOrder(root);
        cout << endl;
    }

    TreeNode* deleteNode(TreeNode* node, int num)
    {
        if (node == nullptr)
            return node;

        if (num < node->num)
            node->left = deleteNode(node->left, num);
        else if (num > node->num)
            node->right = deleteNode(node->right, num);
        else
        {
            if (node->left == nullptr || node->right == nullptr)
            {
                TreeNode *temp = node->left ? node->left : node->right;

                if (temp == nullptr)
                {
                    temp = node;
                    node = nullptr;
                }
                else
                    *node = *temp;

                delete temp;
            }
            else
            {
                TreeNode *temp = node->right;
                while (temp->left != nullptr)
                    temp = temp->left;

                node->num = temp->num;
                node->right = deleteNode(node->right, temp->num);
            }
        }

        if (node == nullptr)
            return node;

        node->height = 1 + max(getHeight(node->left), getHeight(node->right));

        int balance = getBalanceFactor(node);


        // Left Left Case
        if (balance > 1 && getBalanceFactor(node->left) >= 0)
            return rightRotate(node);

        // Left Right Case
        if (balance > 1 && getBalanceFactor(node->left) < 0)
        {
            node->left = leftRotate(node->left);
            return rightRotate(node);
        }

        // Right Right Case
        if (balance < -1 && getBalanceFactor(node->right) <= 0)
            return leftRotate(node);

        // Right Left Case
        if (balance < -1 && getBalanceFactor(node->right) > 0)
        {
            node->right = rightRotate(node->right);
            return leftRotate(node);
        }

        return node;
    }

    void deleteNode(int num)
    {
        root = deleteNode(root, num);
    }
};


int main()
{
    Tree tree;

    tree.insert(10);
    tree.insert(20);
    tree.insert(30);
    tree.insert(25);
    tree.insert(28);
    tree.insert(27);
    tree.insert(5);
    tree.insert(15);
    tree.insert(40);
    tree.insert(50);
    tree.printInOrder();

    int listInt[] = {40,15,35,28};
    for(int i = 0 ; i < 4; i++)
    {
        tree.deleteNode(listInt[i]);
        tree.printInOrder();
    }
    return 0;
}
