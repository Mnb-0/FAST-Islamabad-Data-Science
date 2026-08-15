#include <iostream>
#include <string>
using namespace std;
int main()
{
	int strLength = 10;
	int count = 0;
	char Arr2[strLength] = {' '};
	char Arr[strLength] = {' '};
	string Line = "";
	cout<<"Enter a string: ";
	cin.getline(Arr, 10);
	for(int i = 0 ; i < strLength-1; i++)
	{
		int j = 0;
		if(Arr[i] != Arr[i+1])//Running loop for 1 less iteration than normal to avoid conflict in this line
		{
			count = count + 1;
			Arr2[j] = Arr[i];
			j++;
		}
		else
		{
			count = 0;//Reset the counter
			j = 0;
		}
	}
	cout<<count<<endl;
return 0;
}
