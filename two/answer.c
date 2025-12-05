#include <math.h>
#include <stdio.h>
#include <stdlib.h>


int getsize(long int value){
  int size = 20;
  while ( (value % (long int)pow(10,size)) == value){
    size--;
  }
  return size+1;
}

int main(int argc, char *argv[]) {
  int size, second_half;
  long int start, end, total;
  FILE *file_pointer;
  file_pointer = fopen("input.txt", "r");
  total = 0;


  while (fscanf(file_pointer, "%ld-%ld,", &start, &end) != EOF){
    printf("Start: %ld; End: %ld\n", start, end);

    for (long int i = start; i <= end; i++){
      size = getsize(i);
      second_half = i % (long int)pow(10, size/2);
      if ((second_half * pow(10, size/2) + second_half) == i){
        total += i;
      }
    }
  }

  fclose(file_pointer);
  printf("Result: %ld\n", total);
  return EXIT_SUCCESS;
}
