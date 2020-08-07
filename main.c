// serial.c

#include <stdio.h>
#include <string.h>

void cause_trouble(char* input){
    char output[10];
    memset(output, '\0', 10);
    strcpy(output, input);
    strncpy(output, input, 9); // + null terminator
}


void return_input(){
    char test[1];
    gets(test);
    printf("%s\n", test);
}

int main( int argc, char *argv[] )
{
    return_input();
    return 0;
}
