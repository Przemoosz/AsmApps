#include <iostream>
#include <stdio.h>

using namespace std;

extern "C" void RgbToString(int* pointer);
extern "C" int* CreateRGB(int R, int G, int B);

int main()
{
	printf("Hello \n");
	int* first = CreateRGB(10, 11, 12);
	RgbToString(first);
	int* second = CreateRGB(13, 14, 15);
	RgbToString(second);
}