unit optionsform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Menus, IniFiles;

type

  { TForm1 }

  TForm1 = class(TForm)
    chkStartCountdownAutomatically: TCheckBox;
    MainMenu1: TMainMenu;
    procedure chkStartCountdownAutomaticallyChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

//OnChange - Start Countdown automatically
//**********************************************
procedure TForm1.chkStartCountdownAutomaticallyChange(Sender: TObject);
var
  iniConfigFile: TINIFile;  //TODO: One function for all config read / write ops
begin
  iniConfigFile := TINIFile.Create('config.ini');
  iniConfigFile.WriteBool('options', 'StartCountdownAutomatically', chkStartCountDownAutomatically.Checked);
end;


//Form Create
//***********************************************
procedure TForm1.FormCreate(Sender: TObject);
var
  iniConfigFile: TINIFile;  //TODO: One function for all config read / write ops;
begin
  //read config file
  iniConfigFile := TINIFile.Create('config.ini');
  chkStartCountDownAutomatically.Checked := iniConfigFile.ReadBool('options', 'StartCountdownAutomatically',  false);
end;


end.

