#include <iostream>
using namespace std;
int main()
{
int a, b, result;
char op;
cout<<"Enter an operator:\n";
cin>> op;
cout<<"Enter the two numbers you wish to perform this operation on:\n";
cin>>a;
cin>>b;
if (op == '+')
{	
	result = a + b;
}
if (op == '-')
{
	result = a - b;
}
if (op == '*')
{
	result = a * b;
}
if (op == '/')
{	
	result = a / b;
}

cout<<result;
return 0;
}

