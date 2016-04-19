unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Spin, Menus, ComCtrls, VolumeControl, PopUp, Math;

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
    mnMainMenu: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    miAbout: TMenuItem;
    tbTargetVolume: TTrackBar;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function IsStopped:Boolean;
    procedure AdjustVolume(iMinutesUntilStop: Integer; iTargetVolume: Integer);
    procedure miAboutClick(Sender: TObject);
    procedure tbTargetVolumeChange(Sender: TObject);
    procedure UpdateButtons;
    procedure TimeIsUp;
    procedure UpdateShowCurrentVolumeLabel;

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
  //lblShowTargetVolume.Caption := IntToStr(iTargetVolume);
  tbTargetVolumeChange(NIL); //Update lblShowTargetVolume.Caption
  UpdateShowCurrentVolumeLabel;
end;

procedure TfMainform.FormShow(Sender: TObject);
begin
  //Set window position (otherwise would be last position in IDE)
  fMainform.Left := 300;
  fMainform.Top := 200;
  fPopUp.Left := 330;
  fPopUp.Top := 270;
end;

//Start Button
//******************************************
procedure TfMainform.btnStartClick(Sender: TObject);
var
  iDeciSeconds: Integer = 0;
  iMinutesLapsed: Integer = 0;
  bTimeIsUp: Boolean;
  bTargetVolumeReached: Boolean;
  iCurrentVolume: Integer;
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

        //Check current parameters
        bTimeIsUp := edMinutesUntilStop.Value <= 0;
        iCurrentVolume := Trunc(VolumeControl.GetMasterVolume() * 100);
        bTargetVolumeReached := iCurrentVolume <= tbTargetVolume.Position;

        if iMinutesLapsed > edMinutesUntilStart.Value then // if Start of vol red. reached)
        begin
          if bTimeIsUp or bTargetVolumeReached then
          //if AdjustVolume(edMinutesUntilStop.Value, tbTargetVolume.Position) then //if Volume at final value
            begin
              bIsStopped := True;
              TimeIsUp;
              Exit;
            end;
          //AdjustVolume(edMinutesUntilStop.Value);
          AdjustVolume(edMinutesUntilStop.Value, tbTargetVolume.Position);
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
    fPopUp.lblQuestion.Caption := 'Stopped. Restore volume level?';
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
procedure TfMainform.AdjustVolume(iMinutesUntilStop: Integer; iTargetVolume: Integer);
var
  dCurrentVolume: Double;
  dVolumeStepSize: Double;
  dNewVolumeLevel: Double;
  dVolumeStepsTotal: Double;
begin

  //read current audio volume from system
  dCurrentVolume := VolumeControl.GetMasterVolume();

  //calculate new volume level
  if iMinutesUntilStop > 0 then
  begin
    dVolumeStepsTotal := dCurrentVolume * 100 - iTargetVolume;
    dVolumeStepSize := (dVolumeStepsTotal / iMinutesUntilStop) / 100;
  end;
  dNewVolumeLevel := max((dCurrentVolume - dVolumeStepSize), 0);

  //Set new Volume
  VolumeControl.SetMasterVolume(dNewVolumeLevel);

  //Update Label
  UpdateShowCurrentVolumeLabel;
  //lblShowCurrentVolume.Caption := IntToStr(Trunc(dNewvolumeLevel * 100)) + '%';

end;

procedure TfMainform.miAboutClick(Sender: TObject);
begin
  showmessage('Open Sleep Timer - https://github.com/achim-tecklenburg/open-sleep-timer');
end;



//tbTargetVolumeChange - Update Display of Target Volume near Slider
//****************************************************
procedure TfMainform.tbTargetVolumeChange(Sender: TObject);
begin
  lblShowTargetVolume.Caption := IntToStr(tbTargetVolume.Position) + '%';
end;

//TimeIsUp
//****************************************
procedure TfMainform.TimeIsUp;
begin
  edMinutesUntilStop.Value := iMinutesAtStart;
  fPopUp.lblQuestion.Caption := 'Time is up. Restore volume level?';
  fPopUp.Show;
  UpdateButtons;
end;

//Update Show Current Volume Label
procedure TfMainform.UpdateShowCurrentVolumeLabel;
begin
  fMainform.lblShowCurrentVolume.Caption := IntToStr(Trunc(VolumeControl.GetMasterVolume() * 100)) + '%';
end;

end.

