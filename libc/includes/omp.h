#ifndef _KCC_OMP_H
#define _KCC_OMP_H
#include <kcc_settings.h>

int omp_get_thread_num();

int omp_get_num_threads();

void omp_set_num_threads(int i);

#endif