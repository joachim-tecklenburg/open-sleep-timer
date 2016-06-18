unit optionsform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Menus, IniFiles;

type

  { TfOptionsForm }

  TfOptionsForm = class(TForm)
    chkStartCountdownAutomatically: TCheckBox;
    MainMenu1: TMainMenu;
    procedure chkStartCountdownAutomaticallyChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fOptionsForm: TfOptionsForm;

implementation

{$R *.lfm}

{ TfOptionsForm }

//OnChange - Start Countdown automatically
//**********************************************
procedure TfOptionsForm.chkStartCountdownAutomaticallyChange(Sender: TObject);
var
  iniConfigFile: TINIFile;  //TODO: One function for all config read / write ops
begin
  iniConfigFile := TINIFile.Create('config.ini');
  iniConfigFile.WriteBool('options', 'StartCountdownAutomatically', chkStartCountDownAutomatically.Checked);
end;


//Form Close
//**********************************************
procedure TfOptionsForm.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
var
   iniConfigFile: TINIFile;
begin
   iniConfigFile := TINIFile.Create('config.ini');
  try
    iniConfigFile.WriteInteger('main', 'OptionsFormLeft', fOptionsForm.Left);
    iniConfigFile.WriteInteger('main', 'OptionsFormTop', fOptionsForm.Top);
  finally
    iniConfigFile.Free
  end;
end;


//Form Create
//***********************************************
procedure TfOptionsForm.FormCreate(Sender: TObject);
var
  iniConfigFile: TINIFile;  //TODO: One function for all config read / write ops;
begin
  //read config file
  iniConfigFile := TINIFile.Create('config.ini');
  chkStartCountDownAutomatically.Checked := iniConfigFile.ReadBool('options', 'StartCountdownAutomatically',  false);
end;


end.

