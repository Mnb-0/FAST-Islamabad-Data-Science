#include <iostream>
using namespace std;

class Node
{
public:
    int songID;
    string songName;
    Node *next;
    Node(int id = -1, string name = "")
    {
        songID = id;
        songName = name;
        next = NULL;
    }
};

class LinkedList
{
public:
    Node *head;
    LinkedList()
    {
        head = NULL;
    }

    void addSong(int songID, string songName)
    {
        Node *newNode = new Node(songID, songName);
        if (head == NULL)
        {
            head = newNode;
            newNode->next = head;
            return;
        }
        Node *temp = head;
        while (temp->next != head)
        {
            temp = temp->next;
        }
        temp->next = newNode;
        newNode->next = head;
    }

    void removeSong(int songID)
    {
        if (head == NULL)
        {
            cout << "Playlist is empty." << endl;
            return;
        }

        Node *curr = head;
        Node *prev = NULL;

        if (head->songID == songID)
        {
            Node *last = head;
            while (last->next != head)
            {
                last = last->next;
            }

            if (head == last)
            {
                delete head;
                head = NULL;
            }
            else
            {
                last->next = head->next;
                Node *temp = head;
                head = head->next;
                delete temp;
            }
            return;
        }

        while (curr->songID != songID)
        {
            prev = curr;
            curr = curr->next;
            if (curr == head)
            {
                cout << "Song not found." << endl;
                return;
            }
        }

        prev->next = curr->next;
        delete curr;
    }

    void displayPlaylist()
    {
        if (head == NULL)
        {
            cout << "Playlist is empty." << endl;
            return;
        }

        Node *temp = head;
        do
        {
            cout << temp->songName << " -> ";
            temp = temp->next;
            if(temp == head)
            {
                cout<<"NULL";
            }
        } while (temp != head);
        cout << endl;
    }

    void playNextNSongs(string songName, int n)
    {
        if (head == NULL)
        {
            cout << "Playlist is empty." << endl;
            return;
        }

        Node *temp = head;
        do
        {
            if (temp->songName == songName)
            {
                for (int i = 0; i < n; i++)
                {
                    temp = temp->next;
                    cout << "Playing Next Song: " << temp->songName << endl;
                }
                return;
            }
            temp = temp->next;
        } while (temp != head);

        cout << "Song not found in the playlist." << endl;
    }
};

int main()
{
    LinkedList playlist;
    playlist.addSong(101, "Song A");
    playlist.addSong(102, "Song B");
    playlist.addSong(103, "Song C");
    playlist.addSong(104, "Song D");
    playlist.addSong(105, "Song E");

    playlist.displayPlaylist();

    playlist.removeSong(103);

    playlist.playNextNSongs("Song A", 3);

    playlist.displayPlaylist();

    return 0;
}
