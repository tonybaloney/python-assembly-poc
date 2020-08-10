//
// Created by Anthony Shaw on 10/8/20.
//

#include <stdio.h>
#include <string.h>

extern int rarea(int, int);

int main() {
    int total = rarea(10, 100);
    printf("%d x %d = %d", 10, 100, total);
    return 0;
}