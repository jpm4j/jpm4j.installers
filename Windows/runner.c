#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <windows.h>

#define INFO_BUFFER_SIZE 32767
void printError( TCHAR* msg );

int main(int argc, char * argv[])
{
    HKEY hKey;
    LONG lResult;
    char  data[INFO_BUFFER_SIZE];
    DWORD length = sizeof data;


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

    char * exe = argv[0];

    int i = strlen(exe)-1;
    while ( i >= 0  ) {
        if ( exe[i] == '\\' || exe[i] == '/') {
            exe = exe+i+1;
            break;
        }
        i--;
    }
    i = strlen(exe)-4;

    if ( stricmp(exe+i, ".exe") == 0)
        exe[i]=0;

    lResult = RegOpenKeyEx(
            HKEY_LOCAL_MACHINE,
            TEXT("SOFTWARE\\JPM4J"),
            0,
            KEY_QUERY_VALUE,
            &hKey );

    if (lResult != ERROR_SUCCESS)
    {
        printf("Cannot find JPM key in registry, pleasse reinstall jpm %ld\n", lResult);
        exit(1);
    }
    lResult = RegQueryValueEx(
            hKey,
            "Commands",
            NULL, NULL,
            (LPBYTE) &data,
            &length
            );

    if (lResult != ERROR_SUCCESS)
    {
        printf("Cannot find JPM value in registry, pleasse reinstall jpm %ld\n", lResult);
        exit(1);
    }

    char path[1000];
    strncpy(path, data, sizeof(path));
    strncat(path, exe, sizeof(path));
    strncat(path, ".jpm", sizeof(path));

	FILE *file = fopen ( path, "rb" );
	if ( file == NULL) {
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
