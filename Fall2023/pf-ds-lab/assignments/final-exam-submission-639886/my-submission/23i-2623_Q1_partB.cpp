#include <iostream>
using namespace std;
int main()
{	
	bool toeplitz = false;
	int m , n = 0;
	cout<<"Enter a value for m: "<<endl;
	cin>>m;
	cout<<"Enter a value for n: "<<endl;
	cin>>n;
	int arr[m][n] = {0};
	for(int k = 0; k < m ; k++)
	{
		for(int u = 0; u < n ; u++)
		{
			cout<<"Enter an element: \n";
			cin>>arr[k][u];
		}
	}
	for(int i = 0; i < m ;)
	{
		for(int j = 0; j < n; j++)
		{
			cout<<arr[i][j]<<endl;
			i++;	  
		}
	}
	
return 0;
}
