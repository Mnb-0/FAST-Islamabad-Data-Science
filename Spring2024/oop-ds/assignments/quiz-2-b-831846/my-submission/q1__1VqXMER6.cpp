#include <iostream>
using namespace std;

void printDiamond(int start, int end) 
{
    if(start <= end )
    {
    
        cout<<'*';
        printDiamond(start - 1, end + 1);
        cout<<endl;
    }
    else
    {
        cout<<" ";
        
    }
}

int main() 
{
    int rows;
    cout << "Enter odd rows for the filled Diamond Pattern: ";
    cin >> rows;
    printDiamond(rows/2,rows/2);
    return 0;
}
