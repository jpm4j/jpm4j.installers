;;
;; Creation of the installer for windows.
;;


[Setup]
AppName=jpm4j
AppVersion=1.1
DefaultDirName={pf}\jpm4j
DefaultGroupName=jpm4j
OutputDir=.
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "..\dist\biz.aQute.jpm.run.jar"; DestDir: "{app}\misc";  Flags: ignoreversion
Source: "runner.exe"; DestDir: "{app}\misc";  Flags: ignoreversion
Source: "sjpm.exe"; DestDir: "{app}\misc";  Flags: ignoreversion
Source: "readme.txt"; DestDir: "{app}"; Flags: isreadme

[Run]
Filename: {code:JavaPath}; Parameters: "-jar ""{app}\misc\biz.aQute.jpm.run.jar"" init -k"; Flags: shellexec 

[Registry]
Root: HKCU; Subkey: "Software\JPM4j"; Flags: uninsdeletekeyifempty
Root: HKLM32; Subkey: "Software\JPM4j"; ValueType: string; ValueName: "Home"; ValueData: "{app}"
Root: HKLM64; Subkey: "Software\JPM4j"; ValueType: string; ValueName: "Home"; ValueData: "{app}"; 
Root: HKLM; Subkey: "Software\JPM4j"; ValueType: string; ValueName: "Commands"; ValueData: "{app}\commands\"
Root: HKLM; Subkey: "Software\JPM4j"; ValueType: string; ValueName: "Commands"; ValueData: "{app}\commands\"
Root: HKLM32; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\Bin"; Check: NeedsAddPath(ExpandConstant('{app}\Bin'))
Root: HKLM64; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\Bin"; Check: NeedsAddPath(ExpandConstant('{app}\Bin'))

[Setup]
; Tell Windows Explorer to reload the environment
ChangesEnvironment=yes

[Tasks]
Name: force32; Description:"Force 32 bit installation";  Flags: unchecked;

[Code]
var 
	Force32: Boolean;
	
	
// 
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectTasks then
  begin
    if WizardForm.TasksList.Checked[1] then
    begin
      MsgBox('First task has been checked.', mbInformation, MB_OK);
    end
    else
    begin
      MsgBox('First task has NOT been checked.', mbInformation, MB_OK);
    end
  end;
end;

function NeedsAddPath(Param: string): boolean;
var
  OrigPath: String;
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
	if not(Force32) and IsWin64 then 
	begin
	  	MsgBox('Installing in 64 bit mode', mbInformation, MB_OK);
	    RegQueryStringValue(HKLM64, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', JavaVer);
	    RegPath := Format( 'SOFTWARE\JavaSoft\Java Runtime Environment\%s', [ JavaVer ] );
	    RegQueryStringValue(HKLM64, RegPath, 'JavaHome', JavaHome);
	    Result := Format( '%s\bin\java.exe', [ JavaHome ] );
    end else
    begin
	  	MsgBox('Installing in 32 bit mode', mbInformation, MB_OK);
	    RegQueryStringValue(HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', JavaVer);
	    RegPath := Format( 'SOFTWARE\JavaSoft\Java Runtime Environment\%s', [ JavaVer ] );
	    RegQueryStringValue(HKLM, RegPath, 'JavaHome', JavaHome);
	    Result := Format( '%s\bin\java.exe', [ JavaHome ] );
    end
end;

function InitializeSetup(): Boolean;
begin
  Result:= true;
end;


