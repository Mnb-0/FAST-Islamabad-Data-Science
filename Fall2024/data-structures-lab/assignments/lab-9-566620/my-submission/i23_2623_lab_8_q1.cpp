#include <iostream>
using namespace std;

struct ExpressionTreeNode
{
    char value;
    ExpressionTreeNode *left;
    ExpressionTreeNode *right;

    ExpressionTreeNode(char val) : value(val), left(nullptr), right(nullptr) {}
};

struct TreeNodeStackNode
{
    ExpressionTreeNode *data;
    TreeNodeStackNode *next;
    TreeNodeStackNode(ExpressionTreeNode *node) : data(node), next(nullptr) {}
};

struct OperatorStackNode
{
    char data;
    OperatorStackNode *next;
    OperatorStackNode(char ch) : data(ch), next(nullptr) {}
};

class ExpressionTreeNodeStack
{
private:
    TreeNodeStackNode *top;

public:
    ExpressionTreeNodeStack() : top(nullptr) {}

    void push(ExpressionTreeNode *node)
    {
        TreeNodeStackNode *newNode = new TreeNodeStackNode(node);
        newNode->next = top;
        top = newNode;
    }

    ExpressionTreeNode *pop()
    {
        if (top == nullptr)
            return nullptr;
        ExpressionTreeNode *node = top->data;
        TreeNodeStackNode *temp = top;
        top = top->next;
        delete temp;
        return node;
    }

    bool isEmpty() const
    {
        return top == nullptr;
    }

    ~ExpressionTreeNodeStack()
    {
        while (!isEmpty())
        {
            pop();
        }
    }
};

class OperatorStack
{
private:
    OperatorStackNode *top;

public:
    OperatorStack() : top(nullptr) {}

    void push(char ch)
    {
        OperatorStackNode *newNode = new OperatorStackNode(ch);
        newNode->next = top;
        top = newNode;
    }

    char pop()
    {
        if (top == nullptr)
            return '\0';
        char ch = top->data;
        OperatorStackNode *temp = top;
        top = top->next;
        delete temp;
        return ch;
    }

    char peek() const
    {
        if (top == nullptr)
            return '\0';
        return top->data;
    }

    bool isEmpty() const
    {
        return top == nullptr;
    }

    ~OperatorStack()
    {
        while (!isEmpty())
        {
            pop();
        }
    }
};

class ExpressionTree
{
public:
    //function to build the expression tree from an infix expression
    ExpressionTreeNode *buildTree(const string &expression)
    {
        ExpressionTreeNodeStack operands; //stack for operands (nodes)
        OperatorStack operators;          //stack for operators (characters)

        for (char ch : expression)
        {
            if (ch == '(')
            {
                // Ignore opening parentheses
                continue;
            }
            else if (ch >= '0' && ch <= '9')
            {
                // create a node and push it to the operands stack
                operands.push(new ExpressionTreeNode(ch));
            }
            else if (ch == '+' || ch == '-' || ch == '*' || ch == '/')
            {
                operators.push(ch);
            }
            else if (ch == ')')
            {
                // pop operator and build a subtree
                char op = operators.pop();

                ExpressionTreeNode *right = operands.pop();
                ExpressionTreeNode *left = operands.pop();

                ExpressionTreeNode *newNode = new ExpressionTreeNode(op);
                newNode->left = left;
                newNode->right = right;

                operands.push(newNode);
            }
        }

        return operands.pop();
    }

    void printPrefix(ExpressionTreeNode *node)
    {
        if (node == nullptr)
            return;
        cout << node->value << ' ';
        printPrefix(node->left);
        printPrefix(node->right);
    }

    void printPostfix(ExpressionTreeNode *node)
    {
        if (node == nullptr)
            return;
        printPostfix(node->left);
        printPostfix(node->right);
        cout << node->value << ' ';
    }

    void deleteTree(ExpressionTreeNode *node)
    {
        if (node == nullptr)
            return;
        deleteTree(node->left);
        deleteTree(node->right);
        delete node;
    }
};

int main()
{
    ExpressionTree exprTree;
    string infixExpr;

    cout << "Enter a fully parenthesized infix expression: ";
    cin >> infixExpr;

    ExpressionTreeNode *root = exprTree.buildTree(infixExpr);

    cout << "Prefix expression: ";
    exprTree.printPrefix(root);
    cout << endl;

    cout << "Postfix expression: ";
    exprTree.printPostfix(root);
    cout << endl;

    exprTree.deleteTree(root);

    return 0;
}
