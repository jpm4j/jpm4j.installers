#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <windows.h>

#define INFO_BUFFER_SIZE 32767
void printError( TCHAR* msg );

int main(int argc, char * argv[]) {
    int i ;

    char * cmdline = GetCommandLine();
    while ( *cmdline != 0 && *cmdline == ' ')
        cmdline++;

    if ( cmdline[0] == '"') {
        cmdline++;
        while ( cmdline[0] != 0 && cmdline[0] != '"') {
            cmdline++;
        }
    } else {
        while ( *cmdline != 0 && *cmdline != ' ')
            cmdline++;
    }
    if ( *cmdline!=0)
        cmdline++;

    char path[1000];
    strncpy(path, argv[0], sizeof(path));
    strncat(path, ".jpm", sizeof(path));

    FILE *file = fopen ( path, "rb" );
    if ( file == NULL) {
        printf("Path: %s\n", path);
        perror("Cannot find jpm command file");
        exit(-1);
    }

    fseek(file, 0L, SEEK_END);
    long sz = ftell(file);
    fseek(file, 0L, SEEK_SET);
    size_t size = strlen(cmdline) + sz + 1000;
    char *total = malloc( size );
    memset(total,0, size);
    fread(total,1,sz, file);
    i = strlen(total);
    strcat(total, cmdline );
    char * p = total;
    while ( *p ) {
        if (*p == '\n' || *p == '\r')
            *p = ' ';
        p++;
    }
    return system(total);
}
