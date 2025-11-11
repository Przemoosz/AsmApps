#include <iostream>
#include <Windows.h>

using namespace std;

extern "C" char* ToLower(char* string);

int main()
{
	char greetings[] = "HeLlO_WoRlD/124";
	printf("ToLower of string: %s \n", greetings);
	char* c = ToLower(greetings);
	printf("Result: %s", c);
	HANDLE processHeap = GetProcessHeap();
	bool isFree = HeapFree(processHeap, 0, c);
	if (!isFree)
	{
		DWORD error = GetLastError();
		std::cout << "HeapFree failed with error: " << error << std::endl;
	}
	return 0;
}