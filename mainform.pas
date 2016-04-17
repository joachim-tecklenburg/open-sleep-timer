unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Spin, Menus, ComCtrls, VolumeControl, PopUp;

type

  { TfMainform }

  TfMainform = class(TForm)
    btnStop: TButton;
    btnStart: TButton;
    edMinutesUntilStart: TSpinEdit;
    lblCurrentVolume: TLabel;
    lblShowCurrentVolume: TLabel;
    lblShowTargetVolume: TLabel;
    lblTargetVolume: TLabel;
    lblMinutesUntilStop: TLabel;
    edMinutesUntilStop: TSpinEdit;
    lblMinutesUntilStart: TLabel;
    tbTargetVolume: TTrackBar;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function IsStopped:Boolean;
    function AdjustVolume(iMinutesUntilStop: Integer; iTargetVolume: Integer):Boolean;
    procedure tbTargetVolumeChange(Sender: TObject);
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
var
  iTargetVolume: Integer = 20;
begin
  edMinutesUntilStop.Increment := 15;
  edMinutesUntilStop.Value := 60;
  tbTargetVolume.Min := 0;
  tbTargetVolume.Max := 100;
  tbTargetVolume.Position := iTargetVolume;
  lblShowTargetVolume.Caption := IntToStr(iTargetVolume);
  lblShowCurrentVolume.Caption := IntToStr(Trunc(VolumeControl.GetMasterVolume() * 100));
end;

//Start Button
//******************************************
procedure TfMainform.btnStartClick(Sender: TObject);
var
  iDeciSeconds: Integer = 0;
  iMinutesLapsed: Integer = 0;
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
      iDeciSeconds := iDeciSeconds + 1;

      if iDeciSeconds mod 10 = 0 then //every minute //one minute = 600
      begin
        edMinutesUntilStop.Value := edMinutesUntilStop.Value - 1; //Count Minutes until stop
        iMinutesLapsed := iMinutesLapsed + 1; //Count Minutes since start

        if iMinutesLapsed > edMinutesUntilStart.Value then // if Start of vol red. reached)
        begin
          //edMinutesUntilStop.Value := edMinutesUntilStop.Value - 1;

          if AdjustVolume(edMinutesUntilStop.Value, tbTargetVolume.Position) then //if Volume at final value
            begin
              bIsStopped := True;
              //UpdateButtons;
              TimeIsUp;
              Exit;
            end;
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
    TimeIsUp;
    //UpdateButtons;
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
function TfMainform.AdjustVolume(iMinutesUntilStop: Integer; iTargetVolume: Integer):Boolean;
var
  dCurrentVolume: Double;
  dVolumeStepSize: Double;
  dNewVolumeLevel: Double;
  dNewVolumeLevelPerCent: Double;
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
  dNewVolumeLevelPerCent := dNewVolumeLevel * 100;

  //check if end reached
  //TODO: move "End-Detection" to StartButton procedure (Based on minutes left instead of volume)

  if Trunc(dNewVolumeLevelPerCent) >= iTargetVolume then //if current vol is still higher than target vol.
  begin
    VolumeControl.SetMasterVolume(dNewVolumeLevel);
    lblShowCurrentVolume.Caption := IntToStr(Trunc(dNewvolumeLevel * 100));
  end
  else begin
    result := True; //Volume at final level: stop!
  end;
  result := False; //Not finished, yet. Keep running!
end;



//tbTargetVolumeChange - Update Display of Target Volume near Slider
//****************************************************
procedure TfMainform.tbTargetVolumeChange(Sender: TObject);
begin
  lblShowTargetVolume.Caption := IntToStr(tbTargetVolume.Position);
end;

//TimeIsUp
//****************************************
procedure TfMainform.TimeIsUp;
begin
  edMinutesUntilStop.Value := iMinutesAtStart;
  fPopUp.Show;
  UpdateButtons;


end;

end.

