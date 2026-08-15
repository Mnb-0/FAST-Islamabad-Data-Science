#include <iostream>
#include <string>
using namespace std;

class Node
{
public:
    string url;
    Node *next;
    Node *prev;

    Node(string url)
    {
        this->url = url;
        this->next = nullptr;
        this->prev = nullptr;
    }
};

class BrowserHistory
{
public:
    Node *head;    // First node in the circular list
    Node *tail;    // Last node in the circular list
    Node *current; // Pointer to the current website in history

    BrowserHistory()
    {
        head = nullptr;
        tail = nullptr;
        current = nullptr;
    }

    void visitNewSite(string url)
    {
        Node *newNode = new Node(url);
        if (head == nullptr)
        {
            head = newNode;
            tail = newNode;
            current = newNode;
            head->next = head;
            head->prev = head;
        }
        else
        {
            newNode->prev = current;
            newNode->next = current->next;
            current->next->prev = newNode;
            current->next = newNode;

            if (current == tail)
            {
                tail = newNode; // Update tail if we're adding at the end
            }

            current = newNode; // Move to the newly visited site
        }
    }

    void goBack()
    {
        if (current == nullptr)
        {
            cout << "No history available" << endl;
            return;
        }
        current = current->prev;
        cout << "Going back to: " << current->url << endl;
    }

    void goForward()
    {
        if (current == nullptr)
        {
            cout << "No history available" << endl;
            return;
        }
        current = current->next;
        cout << "Going forward to: " << current->url << endl;
    }

    void displayHistory()
    {
        if (head == nullptr)
        {
            cout << "No history available" << endl;
            return;
        }

        Node *temp = head;
        cout << "History: ";
        do
        {
            cout << temp->url << " ";
            temp = temp->next;
        } while (temp != head);
        cout << endl;
    }
};

/*1. Visit 5 websites in the following order:
○ Website 1: "google.com"
○ Website 2: "stackoverflow.com"
○ Website 3: "github.com"
○ Website 4: "reddit.com"
○ Website 5: "medium.com"
2. Go back twice.
3. Visit a new website "news.com".
4. Go forward once.
5. Display the current browsing history*/
int main()
{
    BrowserHistory history;
    history.visitNewSite("google.com");
    history.visitNewSite("stackoverflow.com");
    history.visitNewSite("github.com");
    history.visitNewSite("reddit.com");
    history.visitNewSite("medium.com");
    history.displayHistory();
    history.goBack();
    history.goBack();
    history.visitNewSite("news.com");
    history.goForward();
    history.displayHistory();
    return 0;
}
