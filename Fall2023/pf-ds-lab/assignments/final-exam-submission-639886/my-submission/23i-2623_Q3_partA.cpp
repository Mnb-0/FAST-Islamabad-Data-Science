#include <iostream>
using namespace std;
int& swap(int a1 , int a2)
{
	int temp;
	temp = a1;
	a1 = a2;
	a2 = temp;
}
int main()
{
	int var1;
	int var2;
	int* p1 = &var1;
	int* p2 = &var2;
	cout<<"Enter a number 1: "<<endl;
	cin>> var1;
	cout<<"Enter a number 2: "<<endl;
	cin>> var2;
	cout<<"Before swapping: " << var1 << " " << var2 <<endl;
	swap(p1 , p2);
	cout<<"After swapping: " << var1 << " " << var2<<endl;
	return 0;
}

