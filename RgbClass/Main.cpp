#include <iostream>
#include <stdio.h>

using namespace std;

extern "C" void RgbToString(int* pointer);
extern "C" int* CreateRGB(int R, int G, int B);
extern "C" bool FreeRgbInstance(int* pointer);

int main()
{
	printf("Hello \n");
	int* first = CreateRGB(10, 11, 12);
	int* second = CreateRGB(13, 14, 15);
	RgbToString(first);
	bool success = FreeRgbInstance(second);
	cout << success;
	//int* second = CreateRGB(13, 14, 15);
	//RgbToString(second);
}