#include <stdlib.h>

void *
bdSolMalloc(int size) {
    return malloc(size);
}

void
bdSolFree(void *p) {
    free(p);
}

char *
bdSolStrCast(void *s) {
    return (char *) s;
}
