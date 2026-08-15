#include <iostream>
#include <fstream>
#include <chrono>
#include <string>
using namespace std;
using namespace std::chrono;

void readFromFile(const string &filename, int *A, int size)
{
    ifstream file(filename);
    for (int i = 0; i < size; i++)
    {
        file >> A[i];
    }
}

int findMax(int *A, int n)
{
    int max = A[0];
    for (int i = 1; i < n; i++)
    {
        if (A[i] > max)
        {
            max = A[i];
        }
    }
    return max;
}

void selectionSort(int *arr, int n)
{
    for (int i = 0; i < n - 1; i++)
    {
        int minIndex = i;
        for (int j = i + 1; j < n; j++)
        {
            if (arr[j] < arr[minIndex])
            {
                minIndex = j;
            }
            swap(arr[i], arr[minIndex]);
        }
    }
}

int countTriplets(int *arr, int n)
{
    int count = 0;
    for (int i = 0; i < n; i++)
    {
        for (int j = i + 1; j < n; j++)
        {
            for (int k = j + 1; k < n; k++)
            {
                count = count + 1;
            }
        }
    }
    return count;
}

void merge(int *arr, int left, int mid, int right)
{
    int n1 = mid - left + 1;
    int n2 = right - mid;
    int *L = new int[n1];
    int *R = new int[n2];

    for (int i = 0; i < n1; i++)
    {
        L[i] = arr[left + i];
    }
    for (int j = 0; j < n2; j++)
    {
        R[j] = arr[mid + 1 + j];
    }
    int i = 0;
    int j = 0;
    int k = left;

    while (i < n1 && j < n2)
    {
        if (L[i] <= R[j])
        {
            arr[k] = L[i];
            i = i + 1;
        }
        else
        {
            arr[k] = R[j];
            j = j + 1;
        }
        k = k + 1;
    }
    while (i < n1)
    {
        arr[k] = L[i];
        i = i + 1;
        k = k + 1;
    }

    while (j < n2)
    {
        arr[k] = R[j];
        j = j + 1;
        k = k + 1;
    }
}

void mergeSort(int *arr, int left, int right)
{
    if (left < right)
    {
        int mid = left + (right - left) / 2;
        mergeSort(arr, left, mid);
        mergeSort(arr, mid + 1, right);
        merge(arr, left, mid, right);
    }
}

int binarySearch(int *A, int n, int x)
{
    int left = 0;
    int right = n - 1;
    while (left <= right)
    {
        int mid = left + (right - left) / 2;
        if (A[mid] == x)
        {
            return mid;
        }
        else if (A[mid] < x)
        {
            left = mid + 1;
        }
        else
        {
            right = mid - 1;
        }
    }
    return -1;
}

int main()
{
    int *f1;
    int *f2;
    int *f3;
    int *f4;

    f1 = new int[100];
    f2 = new int[1000];
    f3 = new int[5000];
    f4 = new int[10000];
    readFromFile("data_100.txt", f1, 100);
    readFromFile("data_1000.txt", f2, 1000);
    readFromFile("data_5000.txt", f3, 5000);
    readFromFile("data_10000.txt", f4, 10000);

    ofstream file("result.txt");

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    file << "findMax\n";
    auto start = high_resolution_clock::now();
    file << findMax(f1, 100) << endl;
    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    file << findMax(f2, 1000) << endl;
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    file << findMax(f3, 5000) << endl;
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    file << findMax(f4, 10000) << endl;
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    file << "\nSelection Sort\n";
    start = high_resolution_clock::now();
    selectionSort(f1, 100);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    selectionSort(f2, 1000);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    selectionSort(f3, 5000);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    selectionSort(f4, 10000);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    file << "\nCount Triplets\n";
    start = high_resolution_clock::now();
    countTriplets(f1, 100);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    countTriplets(f2, 1000);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    // start = high_resolution_clock::now();
    // countTriplets(f3, 5000);
    // stop = high_resolution_clock::now();
    // duration = duration_cast<nanoseconds>(stop - start);
    // file << duration.count() << " ns" << endl;

    // start = high_resolution_clock::now();
    // countTriplets(f4, 10000);
    // stop = high_resolution_clock::now();
    // duration = duration_cast<nanoseconds>(stop - start);
    // file << duration.count() << " ns" << endl;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    file << "\nMerge Sort\n";
    start = high_resolution_clock::now();
    mergeSort(f1, 0, 100);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    mergeSort(f2, 0, 1000);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    mergeSort(f3, 0, 5000);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    mergeSort(f4, 0, 10000);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    file << "\nBinary Search\n";
    start = high_resolution_clock::now();
    binarySearch(f1, 100, 10);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    binarySearch(f2, 1000, 10);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    binarySearch(f3, 5000, 10);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    start = high_resolution_clock::now();
    binarySearch(f4, 10000, 10);
    stop = high_resolution_clock::now();
    duration = duration_cast<nanoseconds>(stop - start);
    file << duration.count() << " ns" << endl;

    file.close();
}