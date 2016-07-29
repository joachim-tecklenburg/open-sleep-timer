unit popup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, func, DefaultTranslator, Types;

type

  { TfPopUp }

  TfPopUp = class(TForm)
    bntRestoreVolume: TButton;
    lblQuestion: TLabel;
    procedure bntRestoreVolumeClick(Sender: TObject);
    procedure FormClose(Sender: TObject);
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
procedure TfPopUp.FormClose(Sender: TObject);
begin
  func.writeConfig('main', 'PopUpLeft', fPopUp.Left);
  func.writeConfig('main', 'PopUpTop', fPopUp.Top);
end;


end.

