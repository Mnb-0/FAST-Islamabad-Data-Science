#include <iostream>
using namespace std;
int main() {
    int num1, num2;

    
    cout << "Enter the first integer: ";
    cin >> num1;
    cout << "Enter the second integer: ";
    cin >> num2;

    
    switch (num1 > num2) {
        case true:
            cout << num1 << " is greater than " << num2 << endl;
            break;
        case false:
            cout << num1 << " is not greater than " << num2 << endl;

            
            switch (num1 < num2) {
                case true:
                    cout << num2 << " is greater than " << num1 << endl;
                    break;
                case false:
                    cout << num2 << " is equal to " << num1 << endl;
                    break;
            }
            break;
    }

    return 0;
}

