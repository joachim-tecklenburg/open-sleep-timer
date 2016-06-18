unit popup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, IniFiles;

type

  { TfPopUp }

  TfPopUp = class(TForm)
    bntRestoreVolume: TButton;
    lblQuestion: TLabel;
    procedure bntRestoreVolumeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fPopUp: TfPopUp;

implementation

uses
  mainform;  //to avoid circular reference, "mainform" is referenced from here

{$R *.lfm}

{ TfPopUp }

//OK Button
//******************************************************
procedure TfPopUp.bntRestoreVolumeClick(Sender: TObject);
begin
  fMainform.tbCurrentVolume.Position := Round(mainform.dVolumeLevelAtStart * 100);
  fPopUp.Close;

end;


//Form Close
//*******************************************************
procedure TfPopUp.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
   iniConfigFile: TINIFile;
begin
   iniConfigFile := TINIFile.Create('config.ini');
  try
    iniConfigFile.WriteInteger('main', 'PopUpLeft', fPopUp.Left);
    iniConfigFile.WriteInteger('main', 'PopUpTop', fPopUp.Top);
  finally
    iniConfigFile.Free
  end;
end;

end.

