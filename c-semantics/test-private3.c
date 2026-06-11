#include<stdio.h>

int main(){
	int tmp = 10;
	int i=15;
	#pragma omp parallel for firstprivate(i)
	for (int j = 0; j < 10; ++j){
		tmp += i;
	}
	return tmp;
}
