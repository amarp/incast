#include <math.h>
#include <stdio.h>
#include <time.h>
#include <vector>
using namespace std;

#define N 8

int main() {
	
	srand(time(NULL));
	vector<int> *l = new vector<int>;

	for (int i = 0; i < N; i++) {
		l->push_back(i);
	}
	
	int n = N;
    	for (int i = 0; i < n; i++) {
        	int r = rand() % (n-i);
        	int temp;
       		temp = (*l)[r];
        	(*l)[r] = (*l)[n-i-1];
        	(*l)[n-i-1] = temp;
    	}

	printf("[");
	for (int i = 0; i < N; i++) {
		printf("%d ", (*l)[i]);
	}
	printf("]\n");


	return 0;
}
