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
	FreeRgbInstance(first);
	int* third = CreateRGB(255,255,255);
	int* fourth = CreateRGB(48,48,48);
	cout << first << endl;
	cout << second << endl;
	cout << third << endl;
	cout << fourth << endl;
	RgbToString(second);
	RgbToString(third);
	RgbToString(fourth);
	RgbToString(first);

	//int* second = CreateRGB(13, 14, 15);
	//RgbToString(second);
}