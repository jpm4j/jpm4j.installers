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
Source: "readme.html"; DestDir: "{app}"; Flags: isreadme

[Run]
Filename: {code:JavaPath}; Parameters: "-jar ""{app}\misc\biz.aQute.jpm.run.jar"" -etk init"; Flags: shellexec 
                                                                                                 
[UnInstallRun]
Filename: {code:JavaPath}; Parameters: "-jar ""{app}\misc\biz.aQute.jpm.run.jar"" -etk deinit"; Flags: shellexec 
                                                                                                 
[Registry]
Root: HKCU; Subkey: "Software\JPM4j"; Flags: uninsdeletekeyifempty
Root: HKLM32; Subkey: "Software\JPM4j"; ValueType: string; ValueName: "Home"; ValueData: "{app}"
Root: HKLM64; Subkey: "Software\JPM4j"; ValueType: string; ValueName: "Home"; ValueData: "{app}"; Check: IsWin64
Root: HKLM32; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\Bin"; Check: NeedsAddPath(ExpandConstant('{app}\Bin'))
Root: HKLM64; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\Bin"; Check: NeedsAddPath(ExpandConstant('{app}\Bin')) and IsWin64

[Setup]
; Tell Windows Explorer to reload the environment
ChangesEnvironment=yes

[Code]

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
	if IsWin64 then 
	begin
	  	//MsgBox('Installing in 64 bit mode', mbInformation, MB_OK);
	    RegQueryStringValue(HKLM64, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', JavaVer);
	    RegPath := Format( 'SOFTWARE\JavaSoft\Java Runtime Environment\%s', [ JavaVer ] );
	    RegQueryStringValue(HKLM64, RegPath, 'JavaHome', JavaHome);
	    Result := Format( '%s\bin\java.exe', [ JavaHome ] );
    end else
    begin
	  	//MsgBox('Installing in 32 bit mode', mbInformation, MB_OK);
	    RegQueryStringValue(HKLM32, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', JavaVer);
	    RegPath := Format( 'SOFTWARE\JavaSoft\Java Runtime Environment\%s', [ JavaVer ] );
	    RegQueryStringValue(HKLM32, RegPath, 'JavaHome', JavaHome);
	    Result := Format( '%s\bin\java.exe', [ JavaHome ] );
    end
end;

function InitializeSetup(): Boolean;
var
  ErrorCode: Integer;
  JavaInstalled : Boolean;
begin
  JavaInstalled := RegKeyExists(HKLM,'SOFTWARE\JavaSoft\Java Runtime Environment');
  if not JavaInstalled then
  begin
      if MsgBox('This tool requires Java Runtime Environment version 1.6 or newer to run. Please download and install the JRE and run this setup again. Do you want to download it now?',
        mbConfirmation, MB_YESNO) = idYes then
      begin
        ShellExec('open','http://www.java.com','','',SW_SHOWNORMAL,ewNoWait,ErrorCode);
      end;
      Result := false;
  end else
  begin
      Result:= true;
  end;
end;


