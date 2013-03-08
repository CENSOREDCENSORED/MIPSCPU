

struct node{
	int lowlimit;
	int highlimit;
	int free;
	struct node * next; 
};

typedef struct node NODE;

NODE * mallochead = 0;

int main(){
	mallochead = 0;
	int * x = myMalloc(sizeof(int) * 4);
	x[1] = 200;
	return x;
}

int myMalloc(int size){
	NODE * currNode;
	if (mallochead == 0){
		int i = 0x10040000;
		mallochead = (NODE *) i;
		mallochead->lowlimit = 0x10040000 + sizeof(NODE);
		mallochead->highlimit = mallochead->lowlimit + size;
		currNode = mallochead;
	}
	else{
		NODE * prevNode = mallochead;
		currNode = mallochead;
		while (currNode != 0 || (currNode->free && currNode->highlimit - currNode->lowlimit < size)){
			prevNode = currNode;
			currNode = currNode->next;
		}
		currNode = prevNode->highlimit + 4;
		currNode->lowlimit = prevNode->highlimit + sizeof(NODE);
		
	}
	return currNode->lowlimit;
}

/*int genLinkedList(ListNode * front, int size){
	
}*/
/*
int countOnes(int i){
	int count = 0;
	while (i != 0){
		count += i & 1;
		i = i >> 1;
	}
	return count;
}
*/