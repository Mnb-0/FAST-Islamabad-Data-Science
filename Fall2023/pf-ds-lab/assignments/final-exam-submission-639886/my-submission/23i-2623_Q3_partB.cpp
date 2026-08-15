#include <iostream>
using namespace std;
void Encrypt(int [] , int);
void Decrypt(int [] , int);
int main()
{
	int array[10] = {1,2,3,4,5,6,7,8,9,10};
	int sizeofarray = sizeof(array)/sizeof(array[0]);
	Encrypt(array, sizeofarray);
	Decrypt(array, sizeofarray);
	return 0;
}
void Encrypt(int arr[] , int size)
{
	for(int i = 0 ; i < size ; i++)
	{
		arr[i] = arr[i] << 10;
	}
	cout<<"Encrypted Array: \n";
	for (int i = 0 ; i < size ; i++)
	{
		cout<<arr[i]<<endl;
	}
	
}
void Decrypt(int arr[] , int size)
{
	for(int i = 0 ; i < size ; i++)
	{
		arr[i] = arr[i] >> 10;
	}
	cout<<"Decrypted Array: \n";
	for (int i = 0 ; i < size ; i++)
	{
		cout<<arr[i]<<endl;
	}
	
}

