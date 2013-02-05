#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <windows.h>

#define INFO_BUFFER_SIZE 32767

int main(int argc, char * argv[]) {
    char path[1000];
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

    
    GetModuleFileName(NULL, path, sizeof(path)-10);
    printf("Path: %s\n", path);
    
    char * s = strstr(path, "sjpm.exe");
    if ( s == NULL) {
        printf("Not sjpm %s\n", path);
        return -1;
    }
    strcpy(s, "jpm.exe");
    printf( "Cmd %s - %s\n", path, cmdline);
    
    SHELLEXECUTEINFO si;
    memset(&si, 0, sizeof(si));
    si.cbSize = sizeof(si);
    si.fMask= SEE_MASK_NO_CONSOLE;
    si.lpVerb = "runas";
    
    HINSTANCE h = ShellExecute(NULL, "runas", s, cmdline, NULL, 0 );
    if ( h > 32 ) {
        printf("Hit the any key\n");
        getch();
        return 0;
    }

    printf("Error  %d, hit the any key\n", h);
    getch();
    return h == 0? -1 : h;
}
