/*
*  Basic I/O functions for 141L processors.
*  Assumes serial port is at 0xffff0000 and follows SPIM register definitions
*
*  Change Log:
* 	1/18/2012 - Adrian Caulfield - Initial Implementation
*	2/11/2012 - Sundaram Bhaskaran - Division q>=d bug fix
* 	4/22/2013 - Raymond Paseman - Added Non-Restoring Division and Modified Booth's 
*	multiplication functions since they're better stress tests for shifts and branches
*/


#include "lib141.h"
void func1(int test, int (*funcPtr) (int), int (*funcPtr2)(int,int,int*)){
	int sqrtNum = funcPtr(test);
	
	int result1;
	int result2;
	
	funcPtr2(sqrtNum, sqrtNum, &result1);
	funcPtr2(test, sqrtNum, &result2);
	if (funcPtr2 == &nonRestoringDivision){
		if (result2 == sqrtNum) print("Works");
		else print("Fails");
	}
	if (funcPtr2 == &modifiedBoothsMultiplication){
		if (result1 == test) print("Works");
		else print("Fails");
	}
	
}


int nonRestoringDivision(int dividend, int divisor, int * a)
{
	int partialRemainder = 0;
	int i;
	*a = 0;
	for (i = 31; i >= 0; --i){
		partialRemainder = 
			(partialRemainder << 1) | ((dividend >> i) & 0x1);
		partialRemainder = partialRemainder < 0 ? 
			partialRemainder + divisor: partialRemainder - divisor;
		*a = partialRemainder >= 0 ? (*a << 1) | 0x1 : *a << 1;
	}
	partialRemainder = partialRemainder < 0 ? 
		partialRemainder + divisor : partialRemainder;
	return partialRemainder;
}

int modifiedBoothsMultiplication(int md, int mr, int * p)
{
	int op[] = {1,0,0,1,1,-1,-1,1};
	int nextDummy[] = {0,0,0,1,0,1,1,1};
	*p = 0;
	
	int i;
	int dummybit = 0;
	
	for (i = 0; i < 31; i++)
	{
		int mask = ((mr & 0x3) << 1) | dummybit;
		int currOp = op[mask];
		if (currOp != 1)
		{
			int adjustedMd = (currOp ^ md) - currOp;
			*p = *p + (adjustedMd << i);
		}
		
		dummybit = nextDummy[mask];
		mr = mr >> 1;
	}
	
	return *p;
}

int strlen(char *string) {
	char *s;

	s = string;
	while (*s)
		s++;
	return s - string;
}

char *strrev(char *str) {
	char *p1, *p2;
	
	for (p1 = str, p2 = str + strlen(str) - 1; p2 > p1; ++p1, --p2) {
		*p1 ^= *p2;
		*p2 ^= *p1;
		*p1 ^= *p2;
	}

	return str;
}

char *int_to_string(int n, char *s, int b) {
	char digits[10];
	digits[0] = '0';
	digits[1] = '1';
	digits[2] = '2';
	digits[3] = '3';
	digits[4] = '4';
	digits[5] = '5';
	digits[6] = '6';
	digits[7] = '7';
	digits[8] = '8';
	digits[9] = '9';
	int i=0, rem, a;
	
	s[i++] = '\n';
	
	do {
		rem = nonRestoringDivision(n,b,&a);
		s[i++] = digits[rem];
		n = a;
	} while (n > 0);

	s[i] = '\0';

	return strrev(s);
}

void runme()
{
	main();
}

void SendByte(char Byte)
{
	volatile unsigned int* tx_ready = (volatile unsigned int*)0xffff0008;
	volatile unsigned int* tx_data = (volatile unsigned int*)0xffff000c;
	while(((*tx_ready) & 0x00000001) == 0) {}
	*tx_data = Byte;
}

char GetByte() {
	char data;
	volatile unsigned int* rx_ready = (volatile unsigned int*)0xffff0000;
	volatile unsigned int* rx_data = (volatile unsigned int*)0xffff0004;
	while(((*rx_ready) & 0x00000001) == 0) {}
	data = (*rx_data) & 0xff;

	return data;
}

