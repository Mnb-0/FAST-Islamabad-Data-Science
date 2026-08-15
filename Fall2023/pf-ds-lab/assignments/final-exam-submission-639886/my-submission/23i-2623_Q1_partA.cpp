#include <iostream>
using namespace std;
int main()
{	
	int m , n = 0;
	cout<<"Enter a value for m: "<<endl;
	cin>>m;
	cout<<"Enter a value for n: "<<endl;
	cin>>n;
	int arr[m][n];
	
	for(int k = 0; k < m ; k++)
	{
		for(int u = 0; u < n ; u++)
		{
			cout<<"Enter an element: \n";
			cin>>arr[m][n];
		}
	}
	int i = 0, j = 0;
	while(i != m-1 && j != n - 1)
	{
		cout<<arr[i][j];
		i++;
		j++;
	}
return 0;
}
