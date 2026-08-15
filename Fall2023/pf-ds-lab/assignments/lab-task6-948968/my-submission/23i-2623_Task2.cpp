#include <iostream>
using namespace std;
int main()
{
int num1 = 0, num2 = 0;
char op = ' ';
cout<<"Menu \n____________________\n+ Addition\n- Subtraction\n * Multiplication\n / Division\n. Cancel\n";
cin>>op;
cout<<"Input two numbers one by one: \n";
cin>> num1 >> num2;
switch (op)
{
	case '+':
		cout<< num1 + num2 << " is the answer.\n";
		break;
	case '-':
		cout<< num1 - num2 << " is the answer.\n";
		break;
	case '*':
		cout<< num1 * num2 << " is the answer.\n";
		break;
	case '/':
		cout<< num1 / num2 << " is the answer.\n";
		break;
	case '.':
		cout<<"Cancelled";
		break;
}
return 0;
}
