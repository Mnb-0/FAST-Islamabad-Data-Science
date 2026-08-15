#include <iostream>
using namespace std;
int main()
{
int marks = 0;

cout<<"Enter your marks:";
cin>>marks;

if (marks >= 90)
{
	cout<<"A+\n";
}
if (marks >= 80 && marks < 90)
{
	cout<<"A\n";
}
if (marks >= 70 && marks < 80)
{
	cout<<"B\n";
}
if (marks >= 60 && marks < 70)
{
	cout<<"C\n";
}
if (marks >= 50 && marks < 60)
{
	cout<<"D\n";
}
if (marks < 50)
{
	cout<<"F\n";
}

return 0;
}
