#include <iostream>
using namespace std;

int main() {
    double units, bill, additionalAmount;

    cout << "Enter the number of units consumed: ";
    cin >> units;

    bill = (units <= 50) ? (units * 0.50) :
           (units <= 150) ? (units * 0.75) :
           (units <= 250) ? (units * 1.2) :
                            (units * 1.5);

    additionalAmount = 0.20 * bill;
    
    if (units > 250)
{   bill += additionalAmount;
}
    cout << "Electricity Bill: Rs. " << bill << endl;

    return 0;
}

