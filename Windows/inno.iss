;;
;; Creation of the installer for windows.
;;


[Setup]
AppName=jpm4j
AppVersion=1.1
DefaultDirName={pf}\jpm4j
DefaultGroupName=jpm4j
OutputDir=.

[Files]
Source: "..\dist\biz.aQute.jpm.run.jar"; DestDir: "{app}\misc";  Flags: ignoreversion
Source: "runner.exe"; DestDir: "{app}\misc";  Flags: ignoreversion
Source: "sjpm.exe"; DestDir: "{app}\misc";  Flags: ignoreversion
Source: "readme.txt"; DestDir: "{app}"; Flags: isreadme

[Run]
; Filename: "{code:Home}\bin\java.EXE"; Parameters: "-Djavahome=""{code:Home}"" -Dcurrentversion=""{code:Version}"" -jar ""{app}\misc\biz.aQute.jpm.run.jar"" init "
Filename: {code:JavaPath}; Parameters: "-jar ""{app}\misc\biz.aQute.jpm.run.jar"" init -k"; Flags: shellexec; Check: IsWin64 

[Registry]
Root: HKCU; Subkey: "Software\JPM4j"; Flags: uninsdeletekeyifempty
Root: HKLM32; Subkey: "Software\JPM4j"; ValueType: string; ValueName: "Home"; ValueData: "{app}"
Root: HKLM64; Subkey: "Software\JPM4j"; ValueType: string; ValueName: "Home"; ValueData: "{app}"
Root: HKLM; Subkey: "Software\JPM4j"; ValueType: string; ValueName: "Commands"; ValueData: "{app}\commands\"
Root: HKLM; Subkey: "Software\JPM4j"; ValueType: string; ValueName: "Commands"; ValueData: "{app}\commands\"
Root: HKLM32; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\Bin"; Check: NeedsAddPath(ExpandConstant('{app}\Bin'))
Root: HKLM64; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\Bin"; Check: NeedsAddPath(ExpandConstant('{app}\Bin'))

[Setup]
; Tell Windows Explorer to reload the environment
ChangesEnvironment=yes

[Code]

function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  // look for the path with leading and trailing semicolon
  // Pos() returns 0 if not found
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;


function JavaPath(Param:String) : String;
var 
  JavaVer : String;
  RegPath : String;
  JavaHome : String;
begin
    RegQueryStringValue(HKLM64, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', JavaVer);
    RegPath := Format( 'SOFTWARE\JavaSoft\Java Runtime Environment\%s', [ JavaVer ] );
    RegQueryStringValue(HKLM64, RegPath, 'JavaHome', JavaHome);
    Result := Format( '%s\bin\java.exe', [ JavaHome ] );
end;

function InitializeSetup(): Boolean;
begin
  Result:= IsWin64;
end;


