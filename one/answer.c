#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void enforce_min(int *position, int *min, int *max){
  while (*position < *min) 
    *position = (*max + 1) + *position;
}

void rotate_dial(int *position, char direction, int distance){
  const int left = (int)'L';
  const int right = (int)'R';
  switch ( (int) direction) {
    case left:
      /* subtract */
      *position = *position - distance;
      break;
    case right:
      /* add */
      *position = *position + distance;
      break;
    default:
      printf("Bad Input: %c\n", direction);
  }
}

void i_hate_my_life(int *position, char direction, int distance, int *zeros_hit, int max){
  int hits;
  int curr_zeros = *zeros_hit; 
  printf("Movement: %c%d\n", direction, distance);
  while (distance > 0){
    rotate_dial(position, direction, 1);
    if (*position == 0)
      *zeros_hit = *zeros_hit + 1;
    else if (*position == -1)
      *position = 99;
    else if (*position == 100){
      *position = 0;
      *zeros_hit = *zeros_hit + 1;

    }

    distance--;
  }
  hits = *zeros_hit - curr_zeros;
  if (hits > 0){
    
    printf("Old Hits: %d; Zeros hit: %d; Current Hits: %d\n", curr_zeros, hits, *zeros_hit);
  }
}

int main(int argc, char *argv[]) {
  int position, distance, max, zeros_hit;
  char direction;
  FILE *file_pointer;
  zeros_hit = 0;
  position = 50;
  max = 99;
  file_pointer = fopen("input.txt", "r");


  while (fscanf(file_pointer, "%c%d\n", &direction, &distance) != EOF){
    i_hate_my_life(&position, direction, distance, &zeros_hit, max);
    /* rotate_dial(&position, direction, distance);
    zeros_hit += abs((int)floorf(position/99));
    printf("Mid position: %d\n", position);
    if (position > 0)
      position = position % max;
    else
      enforce_min(&position, &min, &max); */
    
    printf("New Position: %d\n", position);
  }

  fclose(file_pointer);
  printf("Final position: %d\n", position);
  printf("Zero Count: %d\n", zeros_hit);
  printf("-4 / 99 = %d\n", -4 / 99);
  printf("-100 / 99 = %d\n", -100 / 99);
  return EXIT_SUCCESS;
}
