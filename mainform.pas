unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Spin, Menus, VolumeControl;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnStop: TButton;
    btnStart: TButton;
    lblMinutesUntilStop: TLabel;
    edMinutesUntilStop: TSpinEdit;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function IsStopped:Boolean;
    function AdjustVolume(iMinutesUntilStop: Integer):Boolean;
    procedure UpdateButtons;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  bIsStopped: Boolean = False;

implementation

{$R *.lfm}

{ TForm1 }

function TForm1.IsStopped: Boolean;
begin
  Application.ProcessMessages;
  Result := bIsStopped;
end;


//Form Create
//******************************************
procedure TForm1.FormCreate(Sender: TObject);
begin
  edMinutesUntilStop.Increment := 5;
  edMinutesUntilStop.Value := 60;
end;

//Start Button
//******************************************
procedure TForm1.btnStartClick(Sender: TObject);
var
  iCounter: Double = 0;
begin
  bIsStopped := False;
  btnStart.Enabled := False;
  btnStop.Enabled := True;

  //Loop until Stop Button clicked
  while True do
    begin
      sleep(100);
      iCounter := iCounter + 0.1;
      if iCounter > 60 then //every minute
      begin
        iCounter := 0;
        edMinutesUntilStop.Value := edMinutesUntilStop.Value - 1;
        if AdjustVolume(edMinutesUntilStop.Value) then begin //if Volume at final value
          bIsStopped := True;
          UpdateButtons;
          Exit;
        end;
      end;
      if IsStopped then Exit;
    end;
end;


//Stop Button
//***************************************
procedure TForm1.btnStopClick(Sender: TObject);
begin
    bIsStopped:= True;
    UpdateButtons;
end;

//Update Buttons
//***************************************
procedure TForm1.UpdateButtons;
begin
  btnStart.Enabled := bIsStopped;
  btnStop.Enabled := not bIsStopped;
end;

//Adjust Volume
//****************************************
function TForm1.AdjustVolume(iMinutesUntilStop: Integer):Boolean;
var
  dCurrentVolume: Double;
  dVolumeStepSize: Double;
  dNewVolumeLevel: Double;
begin

  //read current audio volume from system
  dCurrentVolume := VolumeControl.GetMasterVolume();

  //calculate new volume level
  if iMinutesUntilStop > 0 then
  begin
    dVolumeStepSize := dCurrentVolume / iMinutesUntilStop;
  end;
  dNewVolumeLevel := dCurrentVolume - dVolumeStepSize;

  //set new volume level
  if dNewVolumeLevel >= 0.0 then
  begin
    VolumeControl.SetMasterVolume(dNewVolumeLevel);
  end
  else begin //TODO: move "End-Detection" to StartButton procedure (Based on minutes left instead of volume)
    result := True; //at the end
  end;
end;


end.

