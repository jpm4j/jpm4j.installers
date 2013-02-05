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
    
    SECURITY_ATTRIBUTES securityAttrs;
    securityAttrs.nLength = sizeof(securityAttrs);
    securityAttrs.lpSecurityDescriptor = NULL;
    securityAttrs.bInheritHandle = TRUE;
    
//    BOOL WINAPI CreateProcess(
//                              _In_opt_     LPCTSTR lpApplicationName,
//                              _Inout_opt_  LPTSTR lpCommandLine,
//                              _In_opt_     LPSECURITY_ATTRIBUTES lpProcessAttributes,
//                              _In_opt_     LPSECURITY_ATTRIBUTES lpThreadAttributes,
//                              _In_         BOOL bInheritHandles,
//                              _In_         DWORD dwCreationFlags,
//                              _In_opt_     LPVOID lpEnvironment,
//                              _In_opt_     LPCTSTR lpCurrentDirectory,
//                              _In_         LPSTARTUPINFO lpStartupInfo,
//                              _Out_        LPPROCESS_INFORMATION lpProcessInformation
//                              );
    
    PROCESS_INFORMATION process;
    STARTUPINFO si;
    memset(&process, 0, sizeof(process));
    memset(&si, 0, sizeof(si));
    si.cb = sizeof(si);
    
    if (CreateProcess(
        path,
        cmdline,
        &securityAttrs, // security
        &securityAttrs, // threads
        TRUE,           // inherit handles
        CREATE_NO_WINDOW,              // Creation flags
        NULL,           // environment
        NULL,           // directory
        &si,            // startup info
        &process
                        ) ) {
        printf("startedx\n");
        WaitForSingleObject( process.hProcess, INFINITE );
        DWORD exitcode;
    
        GetExitCodeProcess(process.hProcess, &exitcode);
        printf("exit %d\n", exitcode);
        char c;
        do {
            c = getch();
        }
        while (c != '\n' && c != '\r');
        
        return exitcode;
    } else {
        return GetLastError();
    }
    
//    HINSTANCE h = ShellExecute(NULL, "runas", s, cmdline, NULL, SW_HIDE );
//    if ( h > 32 )
//        return 0;
//
//    printf("Error  %d\n", h);
//    return h == 0? -1 : h;
}
