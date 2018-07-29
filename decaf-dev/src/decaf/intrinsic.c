#include <defs.h>
#include <stdio.h>
#include <ulib.h>
#include <file.h>

#define BUFSIZE 4096

void* myAlloc(int size) {
    static char buf[BUFSIZE];
    static int cur_size = 0;
    char *ret = buf + cur_size;
    size += (4 - (size & 3)) & 3;
    cur_size += size;
    if (cur_size > BUFSIZE) {
        cprintf("full of memory\n");
        exit(0);
    }
    return ret;
}

char* myReadLine() {
    static char total_buffer[BUFSIZE];
    static last_pos = 0;
    char* bufPtr = total_buffer + last_pos;
    int ret, index = 0;
    while (1) {
        char c;
        if ((ret = read(0, &c, sizeof(char))) < 0) {
            return NULL;
        }
        else if (ret == 0) {
            if (index > 0) {
                bufPtr[index] = '\0';
                break;
            }
            return NULL;
        }
        if (c == 3) {
            return NULL;
        }
        else if (c >= ' ' && index < BUFSIZE - 1) {
            cprintf("%c", c);
            bufPtr[index ++] = c;
        }
        else if (c == '\b' && index > 0) { //backspace
            cprintf("%c", c);
            index --;
        }
        else if (c == '\n' || c == '\r') { //new line
            cprintf("\n\r");
            bufPtr[index] = '\0';
            break;
        }
    }
    last_pos += index + 1;
    return bufPtr;
}

int myReadInteger() {
    char *str = myReadLine();
    int ret = 0;
    while (*str) {
        ret = (ret << 3) + (ret << 1) + (*str - '0'); // ret = ret*10 + *str-'0'
        str++;
    }
    return ret;
}


void myPrintInt(int x) {
    cprintf("%d", x);
}

void myPrintString(const char* x) {
    cprintf("%s", x);
}

void myPrintBool(bool x) {
    if (x)
        cprintf("true");
    else
        cprintf("false");
}

void __noreturn myHalt(void) {
    exit(0);
}

int myDiv(int x, int y)
{
    int shang = 0;
    int yu = 0;
    int abs_x = x > 0? x: -x;
    int abs_y = y > 0? y: -y;
    int i;
    for (i = 8 * sizeof(int) - 1; i >= 0; --i) {
        yu <<= 1;
        yu |= abs_x >> i & 1;
        if (yu >= abs_y)
            yu -= abs_y, shang |= 1 << i;
    }
    return ((x > 0 && y > 0) || (x < 0 && y < 0))? shang: -shang;
}

int myRem(int x, int y)
{
  int shang = 0;
  int yu = 0;
  int abs_x = x > 0? x: -x;
  int abs_y = y > 0? y: -y;
  int i;
  for (i = 8 * sizeof(int) - 1; i >= 0; --i) {
    yu <<= 1;
    yu |= abs_x >> i & 1;
    if (yu >= abs_y)
      yu -= abs_y, shang |= 1 << i;
  }
  return x > 0? yu: -yu;
}
