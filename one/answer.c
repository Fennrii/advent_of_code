#include <stdio.h>
#include <stdlib.h>

void enforce_bounds(int *position, int *min, int *max, int *zero_count){
  while (*max < *position || *position < *min) {
    printf("Bad Position: %d; Old Zero Count: %d\n", *position, *zero_count);
    if (*position < *min)
      *position = (*max + 1) + *position;
    if (*position > *max)
      *position = *position - (*max + 1);
    *zero_count = *zero_count + 1;
    printf("New Zero Count: %d\n", *zero_count);
  }
}

void rotate_dial(int *position, char *direction, int *distance, int *zero_count){
  int min, max;
  const int left = (int)'L';
  const int right = (int)'R';
  min = 0;
  max = 99;
  printf("Input: %c%d\n", *direction, *distance);
  switch ( (int) *direction) {
    case left:
      /* subtract */
      *position = *position - *distance;
      enforce_bounds(position, &min, &max, zero_count);
      break;
    case right:
      /* add */
      *position = *position + *distance;
      enforce_bounds(position, &min, &max, zero_count);
      break;
    default:
      printf("Bad Input: %c\n", *direction);
  
  }
}

int main(int argc, char *argv[]) {
  int position, distance, zero_count;
  char direction;
  FILE *file_pointer;
  position = 50;
  zero_count = 0;
  file_pointer = fopen("input.txt", "r");

  while (fscanf(file_pointer, "%c%d\n", &direction, &distance) != EOF){
    rotate_dial(&position, &direction, &distance, &zero_count);
    printf("New Position: %d\n", position);
    if (position == 0){
      zero_count++;
      printf("Zero Hits: %d\n", zero_count);
    }
  }

  fclose(file_pointer);
  printf("Final position: %d\n", position);
  printf("Zero Count: %d\n", zero_count);
  return EXIT_SUCCESS;
}


