unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Spin, Menus, VolumeControl, PopUp;

type

  { TfMainform }

  TfMainform = class(TForm)
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
    procedure TimeIsUp;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fMainform: TfMainform;
  bIsStopped: Boolean = False;
  iDefaultMinutes: Integer = 60;
  iMinutesAtStart: Integer;
  dVolumeLevelAtStart: Double;
  //TODO: Default values as constants


implementation

{$R *.lfm}

{ TfMainform }

function TfMainform.IsStopped: Boolean;
begin
  Application.ProcessMessages;
  Result := bIsStopped;
end;


//Form Create
//******************************************
procedure TfMainform.FormCreate(Sender: TObject);
begin
  edMinutesUntilStop.Increment := 15;
  edMinutesUntilStop.Value := 60;
end;

//Start Button
//******************************************
procedure TfMainform.btnStartClick(Sender: TObject);
var
  iCounter: Double = 0;
begin
  bIsStopped := False;
  btnStart.Enabled := False;
  btnStop.Enabled := True;
  dVolumeLevelAtStart := VolumeControl.GetMasterVolume();
  iMinutesAtStart := edMinutesUntilStop.Value;

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
          TimeIsUp;
          Exit;
        end;
      end;
      if IsStopped then Exit;
    end;
end;


//Stop Button
//***************************************
procedure TfMainform.btnStopClick(Sender: TObject);
begin
    bIsStopped:= True;
    UpdateButtons;
end;

//Update Buttons
//***************************************
procedure TfMainform.UpdateButtons;
begin
  btnStart.Enabled := bIsStopped;
  btnStop.Enabled := not bIsStopped;
end;

//Adjust Volume
//****************************************
function TfMainform.AdjustVolume(iMinutesUntilStop: Integer):Boolean;
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

//TimeIsUp
//****************************************
procedure TfMainform.TimeIsUp;
begin
  edMinutesUntilStop.Value := iMinutesAtStart;
  fPopUp.Show;

end;

end.

