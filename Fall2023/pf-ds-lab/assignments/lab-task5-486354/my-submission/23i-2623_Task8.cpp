#include <iostream>
using namespace std;
int main()
{
int minutes;
cout<<"Enter time in minutes:\n";
cin>>minutes;

if (minutes <= 0 || minutes >= 60)
{
	cout<<"Invalid minutes";
}
return 0;
}
