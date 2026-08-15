#include <iostream>
using namespace std;
int main()
{
int angle1,angle2,angle3;
cout<<"Enter 3 angles one by one\n";
cin>>angle1;
cin>>angle2;
cin>>angle3;

if (angle1 + angle2 + angle3 == 180)
{
cout<<"This is a valid triangle";
}
else 
{
cout<<"Not a valid triangle";
}

return 0;

}
