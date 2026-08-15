#include <iostream>
using namespace std;
int main()
{
int currentNumber = 0;
int newNumber = 0;
cout<<"Enter a number: ";
cin>>currentNumber;
if (currentNumber % 5 == 0)
{
	newNumber = (currentNumber * 3) + 1;
}
else 
{
	newNumber = (currentNumber / 2);
}
cout<<"New number is:";
cout<<newNumber;
cout<<"\n";

return 0;
}
