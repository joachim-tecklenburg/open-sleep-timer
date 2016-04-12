unit popup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, VolumeControl;

type

  { TfPopUp }

  TfPopUp = class(TForm)
    bntRestoreVolume: TButton;
    lblQuestion: TLabel;
    procedure bntRestoreVolumeClick(Sender: TObject);
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
  VolumeControl.SetMasterVolume(mainform.dVolumeLevelAtStart);
  fPopUp.Close;

end;

end.
