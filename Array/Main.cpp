#include <iostream>

using namespace std;

extern "C" long long AddElementAt(long long index, long long value);

extern "C" long long GetElementFrom(long long index);

extern "C" void SetUpArray(long long size);

int main()
{
    SetUpArray(15);
    AddElementAt(5, 52);
    AddElementAt(0, 2);

    long long a = GetElementFrom(5);
    cout << "Element at index 0:" << GetElementFrom(0) << endl;
    cout << "Element at index 5:" << GetElementFrom(5) << endl;

    long long b = AddElementAt(42, 987);
    if (b == -1)
    {
    	cout << "Error: Index out of bounds" << endl;
	}
	else
	{
		cout << "Element at index 42:" << GetElementFrom(42) << endl;
    }
}

