#include <iostream>
using namespace std;
#include <string>
int main()
{
    int score;
    string grade;

    cout << "Enter the student's score: ";
    cin >> score;

    
    grade = (score >= 90) ? "A+" :
            (score >= 80) ? "A":
            (score >= 70) ? "B" :
            (score >= 60) ? "C" :
            (score >= 50) ? "D" : "F" ;

    cout << "The student's grade is: " << grade << endl;

    return 0;
}

