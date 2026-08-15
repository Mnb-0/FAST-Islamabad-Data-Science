#include <iostream>
using namespace std;
int main()
{
int a , b , c;
cout<<"Enter 3 numbers one by one:\n";
cin>>a;
cin>>b;
cin>>c;

if (a < b && a < c)
{
	cout<<"Smallest is a";
}	
if (b < a && b < c)
{
	cout<<"Smallest is b";
}
if (c < a && c < b)
{
	cout<<"Smallest is c";
}	
return 0;

}
