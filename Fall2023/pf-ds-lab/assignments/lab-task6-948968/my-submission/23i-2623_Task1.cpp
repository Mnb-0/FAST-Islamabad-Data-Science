#include <iostream>
using namespace std;
int main() {
    int gpa;

    
    cout << "Enter your GPA (1 to 4): ";
    cin >> gpa;

    
    switch (gpa) {
        case 4:
            cout << "Your letter grade is: A+" << endl;
            break;
        case 3:
            cout << "Your letter grade is: A" << endl;
            break;
        case 2:
            cout << "Your letter grade is: B" << endl;
            break;
        case 1:
            cout << "Your letter grade is: C" << endl;
            break;
        default:
            cout << "Invalid GPA. GPA should be between 1 and 4." << endl;
            break;
    }

    return 0;
}

