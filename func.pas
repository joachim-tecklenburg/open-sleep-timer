unit func;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, LazUTF8;
  procedure writeConfig(sSection: String; sName: String; sValue: String);
  procedure writeConfig(sSection: String; sName: String; iValue: Integer);
  procedure writeConfig(sSection: String; sName: String; bValue: Boolean);
  function readConfig(sSection: String; sName: String; sValue: String):String;
  function readConfig(sSection: String; sName: String; iValue: Integer):Integer;
  function readConfig(sSection: String; sName: String; bValue: Boolean):Boolean;
  function GetOSConfigPath(Filename: String):String;

implementation

function CreateConfigFile():TINIFile;
begin
  Result := TINIFile.Create(WinCPToUTF8(GetAppConfigFile(False)));
end;

procedure writeConfig(sSection: String; sName: String; sValue: String);
var
  iniConfigFile: TINIFile;
begin
  try
    iniConfigFile := CreateConfigFile;
    iniConfigFile.WriteString(sSection, sName, sValue);
  finally
    iniConfigFile.Free
  end;
end;

procedure writeConfig(sSection: String; sName: String; iValue: Integer);
var
  iniConfigFile: TINIFile;
begin
  try
    iniConfigFile := CreateConfigFile;
    iniConfigFile.WriteInteger(sSection, sName, iValue);
  finally
    iniConfigFile.Free
  end;
end;

procedure writeConfig(sSection: String; sName: String; bValue: Boolean);
var
  iniConfigFile: TINIFile;
begin
  try
    iniConfigFile := CreateConfigFile;
    iniConfigFile.WriteBool(sSection, sName, bValue);
  finally
    iniConfigFile.Free
  end;
end;

function readConfig(sSection: String; sName: String; sValue: String): String;
var
  iniConfigFile: TINIFile;
begin
  try
    iniConfigFile := CreateConfigFile;
    Result := iniConfigFile.ReadString(sSection, sName, sValue);
  finally
    iniConfigFile.Free
  end;
end;

function readConfig(sSection: String; sName: String; iValue: Integer): Integer;
var
  iniConfigFile: TINIFile;
begin
  try
    iniConfigFile := CreateConfigFile;
    Result := iniConfigFile.ReadInteger(sSection, sName, iValue);
  finally
    iniConfigFile.Free
  end;
end;

function readConfig(sSection: String; sName: String; bValue: Boolean): Boolean;
var
  iniConfigFile: TINIFile;
begin
  try
    iniConfigFile := CreateConfigFile;
    Result := iniConfigFile.ReadBool(sSection, sName, bValue);
  finally
    iniConfigFile.Free
  end;
end;

//Get Config Path of Operating System
//*******************************
function GetOSConfigPath(Filename: String):String;
var
  sPath: String;
begin
  //Windows: make sure special characters in path are treated correctly
  sPath := WinCPToUTF8(GetAppConfigDir(False));
  if not FileExists(sPath + Filename) then //create if file does not exist
    FileClose(FileCreate(sPath + Filename));
  Result := sPath + Filename;
end;


end.

