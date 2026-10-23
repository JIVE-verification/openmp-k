/*
* @@name:	ploop.1c
* @@type:	C
* @@compilable:	yes
* @@linkable:	no
* @@expect:	success
*/
void simple(int n, float *a, float *b)
{
    int i;

#pragma omp parallel for
    for (i=1; i<n; i++) /* i is private by default */
        b[i] = (a[i] + a[i-1]) / 2.0;
}

int main(void)
{
    int n = 5;
    float a[] = {10, 20, 30, 40, 50};
    float b[5];

    simple(n, a, b);

    for (int i = 1; i < n; i++)
        printf("b[%d] = %.2f\n", i, b[i]);

    return 0;
}
