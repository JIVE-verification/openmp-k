#include<stdio.h>

int main(){
	int tmp = 10;
	#pragma omp parallel for private(tmp)
	for (int j = 0; j < 10; ++j){
		//tmp = 5;
		printf("Inside:%d\n",  tmp);
	}
	printf("Outside:%d\n",  tmp);
}
