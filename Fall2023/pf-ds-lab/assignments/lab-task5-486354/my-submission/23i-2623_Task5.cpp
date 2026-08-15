#include <iostream>
using namespace std;
int main()
{
int fine = 0 , daysDue = 0;
bool returned = false;
cout<<"How many days has the file been due? \n";
cin>>daysDue;
if (daysDue > 0 && daysDue <= 7)
{	
	fine = fine + (daysDue * 10);
	returned = true;
}
if (daysDue > 7 && daysDue <= 14)
{
	daysDue = daysDue - 7;
	fine = (7 * 10) + (daysDue * 20);
	returned = true;
}
if (daysDue > 14 && daysDue <= 31)
{
	daysDue = daysDue - 14;
	fine = (7 * 10) + (7 * 20) + (daysDue * 50);
	returned = true;
}
if (daysDue > 31)
{
	returned = false;
	cout<<"Your membership has been cancelled\n";
}
cout<<"The fine is: ";
cout<<fine;
return 0;
}
