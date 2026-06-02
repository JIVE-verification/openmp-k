#include<stdio.h>
#define N 100
int main(){
	int i;
	double step = 1.0 / (double) N; 
	double pi, sum = 0.0;
	#pragma omp parallel for reduction(+:sum)
	for (i = 0; i < N; i++){
		double x = (i + 0.5) * step;
		sum = sum + 4.0/(1.0 + x * x);
		printf("%lf,%lf \n ", x, sum);
	}
	pi = sum * step;
	printf("pi:%lf\n",  pi);
}