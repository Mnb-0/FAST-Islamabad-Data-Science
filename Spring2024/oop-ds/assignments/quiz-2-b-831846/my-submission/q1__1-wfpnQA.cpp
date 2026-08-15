#include <iostream>
using namespace std;

void printSpaces(int n) {
    if (n > 0) {
        cout << " ";
        printSpaces(n - 1);
    }
}

void printStars(int n) {
    if (n > 0) {
        cout << "* ";
        printStars(n - 1);
    }
}

void printLine(int spaces, int stars) {
    if (spaces > 0) {
        printSpaces(spaces);
        printStars(stars);
        cout << endl;
        printLine(spaces - 1, stars + 2);
    }
}

void printDiamond(int n) {
    printLine(n / 2, 1);
    if (n % 2 == 0) {
        printLine(1, n - 2);
    } else {
        printLine(0, n - 2);
    }
}

int main() {
    int rows;
    cout << "Enter odd rows for the filled Diamond Pattern: ";
    cin >> rows;
    rows = (rows % 2 == 0) ? rows + 1 : rows;
    printDiamond(rows);
    return 0;
}
