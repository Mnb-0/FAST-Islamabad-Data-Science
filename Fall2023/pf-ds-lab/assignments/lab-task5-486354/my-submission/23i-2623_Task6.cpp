#include <iostream>
using namespace std;
int main()
{
int a, b;
cout<<"Enter a number you want to test:\n";
cin>> a;
b =  a % 2;
if (b == 0) 
{
cout<<"Your number is even.\n";
}
else 
{
cout<<"Your number is odd.\n";
}
return 0;
}
