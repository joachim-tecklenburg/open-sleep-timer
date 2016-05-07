unit Unit1;

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


procedure TForm1.chkStartCountdownAutomaticallyChange(Sender: TObject);
var
  iniConfigFile: TINIFile;
begin
  iniConfigFile := TINIFile.Create('config.ini');
  iniConfigFile.WriteBool('options', 'StartCountdownAutomatically', chkStartCountDownAutomatically.Checked);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;


end.

