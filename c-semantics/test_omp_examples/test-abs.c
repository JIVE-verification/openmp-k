#include <stdio.h>
int main() {
    int val = -5;
    if (val < 0) {
    	val = -1 * val; 	
    }
    return val;
}
