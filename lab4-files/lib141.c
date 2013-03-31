/*
*  Basic I/O functions for 141L processors.
*  Assumes serial port is at 0xffff0000 and follows SPIM register definitions
*
*  Change Log:
* 	1/18/2012 - Adrian Caulfield - Initial Implementation
*
*/


#include "lib141.h"

int division(int q, int d, int *a)
{
	*a = 0;	
	while (q > d) {
		*a = *a + 1;
		q = q - d;
	}
	return q; 
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
		rem = division(n,b,&a);
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

