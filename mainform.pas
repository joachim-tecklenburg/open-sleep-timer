unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Spin, Menus, ComCtrls, VolumeControl, PopUp, Math, IniFiles;

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
    procedure parseConfigFile;

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fMainform: TfMainform;
  bIsStopped: Boolean = False;
  iDurationDefault: Integer;
  iDurationSetByUser: Integer;
  dVolumeLevelAtStart: Double;
  bTestMode: Boolean;
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
  tbTargetVolume.Min := 0;
  tbTargetVolume.Max := 100;
  tbTargetVolumeChange(NIL); //Update lblShowTargetVolume.Caption
  UpdateShowCurrentVolumeLabel;
end;


//Form Show
//*****************************************
procedure TfMainform.FormShow(Sender: TObject);

begin
  parseConfigFile;

  //Set window position (otherwise would be position from IDE)
  {fMainform.Left := 300;
  fMainform.Top := 200;
  fPopUp.Left := 330;
  fPopUp.Top := 270;}

end;

//Parse Config File
//******************************************
procedure TfMainform.parseConfigFile;
var
  iniConfigFile: TINIFile;
begin
   iniConfigFile := TINIFile.Create('config.ini');
  try
    bTestMode := iniConfigFile.ReadBool('development', 'TestMode', false);
    edMinutesUntilStop.Value := iniConfigFile.ReadInteger('main', 'DurationDefault', 75);
    edMinutesUntilStop.Increment := iniConfigFile.ReadInteger('main', 'DurationIncrement', 15);
    tbTargetVolume.Position := iniConfigFile.ReadInteger('main', 'TargetVolume', 10);
    fMainform.Left := iniConfigFile.ReadInteger('main', 'MainformLeft', 300);
    fMainform.Top := iniConfigFile.ReadInteger('main', 'MainformTop', 200);
    fPopUp.Left := iniConfigFile.ReadInteger('main', 'PopUpLeft', 330);
    fPopUp.Top := iniConfigFile.ReadInteger('main', 'PopUpTop', 270);
  finally
  end;
end;

//Start Button
//******************************************
procedure TfMainform.btnStartClick(Sender: TObject);
var
  iDeciSeconds: Integer = 0;
  iDivider: Integer = 600; //one minute
  iMinutesLapsed: Integer = 0;
  bTimeIsUp: Boolean;
  bTargetVolumeReached: Boolean;
  iCurrentVolume: Integer;

begin
  bIsStopped := False;
  btnStart.Enabled := False;
  btnStop.Enabled := True;
  dVolumeLevelAtStart := VolumeControl.GetMasterVolume();
  iDurationSetByUser := edMinutesUntilStop.Value;


  //Loop until Stop Button clicked
  while True do
    begin
      sleep(100);
      iDeciSeconds := iDeciSeconds + 1;

      //check if testmode (faster contdown)
      if bTestMode = true then
        iDivider := 10;

      if iDeciSeconds mod iDivider = 0 then //every minute //one minute = 600
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


//Menu Procedures
//********************************************
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
  edMinutesUntilStop.Value := iDurationSetByUser;
  fPopUp.lblQuestion.Caption := 'Time is up. Restore volume level?';
  fPopUp.Show;
  UpdateButtons;
end;


//Update ShowCurrentVolumeLabel
procedure TfMainform.UpdateShowCurrentVolumeLabel;
begin
  fMainform.lblShowCurrentVolume.Caption := IntToStr(Trunc(VolumeControl.GetMasterVolume() * 100)) + '%';
end;

end.

