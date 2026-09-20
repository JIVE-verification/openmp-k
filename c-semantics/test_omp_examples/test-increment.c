#include <stdio.h>

int counter = 0;

void increment() {
    counter++;
}

int main() {
    for(int i=0; i< 10; i++){
    	int tmp = 0;
    	increment();
    }
    return counter;
}
