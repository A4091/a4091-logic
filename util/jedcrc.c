#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define STX 0x02
#define ETX 0x03

int main(int argc, char** argv) {
  FILE* src = NULL;
  uint16_t sum = 0;
  int c;
  bool start = false;
  bool end = false;

  if (argc != 2) {
    fprintf(
        stderr,
        "usage: %s PATH\n\n"
        "Calculate the checksum of the data in a JEDEC .jed file.\n"
        "If PATH is -, read from stdin instead.\n",
        argv[0]);
    return 1;
  }

  if (strlen(argv[1]) == 1 && argv[1][0] == '-') {
    src = stdin;
  } else {
    src = fopen(argv[1], "rb");
    if (!src) {
      perror(argv[1]);
      return 1;
    }
  }

  while (!((c = fgetc(src)) & ~0x7F)) {
    if (!start && c == STX) {
      start = true;
    }

    if (start && !end) {
      sum += (uint16_t)c;
    }

    if (!end && c == ETX) {
      end = true;
      break;
    }
  }

  if (src != stdin) {
    fclose(src);
  }

  if (start && end) {
    printf("Checksum: %04hX\n", sum);
  } else if (!start) {
    fprintf(stderr, "No STX byte found\n");
    return 1;
  } else if (!end) {
    fprintf(stderr, "No ETX byte found\n");
    return 1;
  }

  return 0;
}
