#include <iostream>
using namespace std;

int main() {
    int dayNumber;

    cout << "Enter a number (1-7) representing the day: ";
    cin >> dayNumber;

    
    switch (dayNumber) {
        case 1:
            cout << "Friday" << endl;
            break;
        case 2:
            cout << "Saturday" << endl;
            break;
        case 3:
            cout << "Sunday" << endl;
            break;
        case 4:
            cout << "Monday" << endl;
            break;
        case 5:
            cout << "Tuesday" << endl;
            break;
        case 6:
            cout << "Wednesday" << endl;
            break;
        case 7:
            cout << "Thursday" << endl;
            break;
        default:
            cout << "Invalid input! Please enter a number from 1 to 7." << endl;
    }

    return 0;
}

