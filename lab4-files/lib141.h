/*
*  Basic I/O functions for 141L processors.
*  Assumes serial port is at 0xffff0000 and follows SPIM register definitions
*
*  Change Log:
* 	1/18/2012 - Adrian Caulfield - Initial Implementation
*
*
*
*  Don't forget to include lib141.o in your sources list for your application
*/


#ifndef MIPS_H
#define MIPS_H

int division(int,int,int*);
int strlen(char *);
char *strrev(char *);
char *int_to_string(int, char *, int);
void runme();
int main();
void SendByte(char Byte);
char GetByte();


#endif
