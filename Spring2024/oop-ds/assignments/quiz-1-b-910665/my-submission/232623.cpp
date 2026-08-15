#include <iostream>
#include <string>
using namespace std;

int main()
{
    string inString = "Exercises Practice Solution";
    string outString;
    int stringLen = 0, i = 0;
    while(inString[i++] != '\0')
    {
        stringLen++;
    }
    cout<<stringLen<<endl;//Doesn't include the terminator
    int arrayLen = stringLen+1;//Accounting for terminator
    i = 0;
    int wordLen = 0;
    for(int j = 0; j < arrayLen-1; j++)
    {
        
        while(inString[i] != ' ')
        {
            wordLen++;
            i++;
        }
        //cout<<wordLen<<' ';
        
        if(wordLen % 2 != 0)
        {
            outString[j] = inString[i--];
        }
    }
    cout<<inString;
    cout<<outString;
    return 0;
}
