#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  int position;
  char direction;
  int distance;
  FILE *file_pointer;
  position = 50;
  file_pointer = fopen("input.txt", "r");

  while (fscanf(file_pointer, "%c%d", ) != EOF){

  }

  fclose(file_pointer);
  return EXIT_SUCCESS;
}

int rotate_dial(int *position, char *direction, int *distance){
  int min, max;
  min = 0;
  max = 99;
  switch (direction) {
    case "L":

    case "R":

  
  }
  return EXIT_SUCCESS
}
