;;
;; Creation of the installer for windows.
;;


[Setup]
AppName=JPM4J
AppVersion=1.2
DefaultDirName={sd}\JPM4J
DefaultGroupName=jpm4j
OutputDir=.

[Files]
Source: "..\dist\biz.aQute.jpm.run.jar"; DestDir: "{app}\misc";  Flags: ignoreversion

[Run]
Filename: {code:JavaPath}; Parameters: "-jar ""{app}\misc\biz.aQute.jpm.run.jar"" -ekh ""{app}"" init"; Flags: shellexec 
                                                                                                 
[UnInstallRun]
Filename: {code:JavaPath}; Parameters: "-jar ""{app}\misc\biz.aQute.jpm.run.jar"" -ekh ""{app}"" deinit"; Flags: shellexec 
                                                                                                 
[Registry]
Root: HKLM32; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\bin"; Check: NeedsAddPath(ExpandConstant('{app}\Bin'))
Root: HKLM64; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\bin"; Check: NeedsAddPath(ExpandConstant('{app}\Bin')) and IsWin64

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


