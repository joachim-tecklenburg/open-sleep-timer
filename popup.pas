unit popup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, VolumeControl, IniFiles;

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
  mainform;

{$R *.lfm}

{ TfPopUp }

procedure TfPopUp.bntRestoreVolumeClick(Sender: TObject);
begin
  VolumeControl.SetMasterVolume(mainform.dVolumeLevelAtStart); //TODO: There should be one function, that does SetMasterVolume && lbl.ShowCurrentCaption
  fMainform.lblShowCurrentVolume.Caption := (IntToStr(Trunc(VolumeControl.GetMasterVolume() * 100)));
  fPopUp.Close;

end;

procedure TfPopUp.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
   iniConfigFile: TINIFile;
begin
   iniConfigFile := TINIFile.Create('config.ini');
  try
    //fPopUp.Left := iniConfigFile.WriteString('main', 'PopUpLeft', IntToStr(fPopUp.Left));
    //fPopUp.Top := iniConfigFile.WriteInteger('main', 'PopUpTop', fPopUp.Top);
  finally
    iniConfigFile.Free
  end;
end;

end.

