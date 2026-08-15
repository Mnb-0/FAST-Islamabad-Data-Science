#include <iostream>
#include <string>
#include <ctime>
using namespace std;
int main()
{
	srand(time(0));
	char random = (rand() % (122-97)) + 97;
	cout<< random<<endl;
	int sizeS=10;
	int sizeT = sizeS + 1;
	char arr1[sizeS];
	char arr2[sizeT];
	cout<<"Enter a string: ";
	cin.getline(arr1 , sizeS);
	for(int i = 0; i < sizeS ; i++) //Random copying of s into t
	{
		int k = rand() % 11;
		arr2[k] = arr1[i];
		
	}
	for(int i = 0; i<sizeT; i++)
	{
		if(arr2[i] == ' ')
		{
			arr2[rand() % 12] == random;
		}
	}
	for(int i = 0; i <sizeS; i++)
		cout<<arr1[i];
		cout<<endl;
	for(int i = 0; i <sizeS; i++)
		cout<<arr2[i];
return 0;
}
