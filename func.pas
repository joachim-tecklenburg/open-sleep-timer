unit func;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles;
  procedure writeConfig(sSection: String; sName: String; sValue: String);
  procedure writeConfig(sSection: String; sName: String; iValue: Integer);
  procedure writeConfig(sSection: String; sName: String; bValue: Boolean);
  function readConfig(sSection: String; sName: String; sValue: String):String;
  function readConfig(sSection: String; sName: String; iValue: Integer):Integer;
  function readConfig(sSection: String; sName: String; bValue: Boolean):Boolean;

implementation

procedure writeConfig(sSection: String; sName: String; sValue: String);
var
  iniConfigFile: TINIFile;
begin
  iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
  try
    iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
    iniConfigFile.WriteString(sSection, sName, sValue);
  finally
    iniConfigFile.Free
  end;
end;

procedure writeConfig(sSection: String; sName: String; iValue: Integer);
var
  iniConfigFile: TINIFile;
begin
  iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
  try
    iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
    iniConfigFile.WriteInteger(sSection, sName, iValue);
  finally
    iniConfigFile.Free
  end;
end;

procedure writeConfig(sSection: String; sName: String; bValue: Boolean);
var
  iniConfigFile: TINIFile;
begin
  iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
  try
    iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
    iniConfigFile.WriteBool(sSection, sName, bValue);
  finally
    iniConfigFile.Free
  end;
end;

function readConfig(sSection: String; sName: String; sValue: String): String;
var
  iniConfigFile: TINIFile;
begin
  iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
  try
    iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
    result := iniConfigFile.ReadString(sSection, sName, sValue);
  finally
    iniConfigFile.Free
  end;
end;

function readConfig(sSection: String; sName: String; iValue: Integer): Integer;
var
  iniConfigFile: TINIFile;
begin
  iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
  try
    iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
    result := iniConfigFile.ReadInteger(sSection, sName, iValue);
  finally
    iniConfigFile.Free
  end;
end;

function readConfig(sSection: String; sName: String; bValue: Boolean): Boolean;
var
  iniConfigFile: TINIFile;
begin
  iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
  try
    iniConfigFile := TINIFile.Create(GetAppConfigFile(False));
    result := iniConfigFile.ReadBool(sSection, sName, bValue);
  finally
    iniConfigFile.Free
  end;
end;


end.

