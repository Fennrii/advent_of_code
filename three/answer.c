#include <stdio.h>

#define ARRAY_LEN 100

int main(int argc, char *argv[])
{


  char line[ARRAY_LEN];
  int joltage[ARRAY_LEN];
  int jolt;
  long int max_joltage;
  FILE *fp;

  max_joltage = 0;
  fp = fopen("input.txt", "r");
  
  while (fscanf(fp, "%s\n", line ) != EOF){
    printf("Line: %s\n", line);
    for (int i = 0; i < ARRAY_LEN; i++){
      sscanf(&line[i], "%1d", &jolt);
      printf("Value: %d\n", jolt);
      joltage[i] = jolt;
    }

  }

  fclose(fp);

  return 1;
}
