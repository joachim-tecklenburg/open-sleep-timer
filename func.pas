{ Open Sleep Timer

  Copyright (c) 2016 Joachim Tecklenburg

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
}

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

