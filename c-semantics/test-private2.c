#include<stdio.h>

int main(){
	int tmp = 10;
	int i=15;
	#pragma omp parallel for private(i)
	for (int j = 0; j < 10; ++j){
		tmp = i;
	}
	printf("Outside:%d\n",  tmp);
}
