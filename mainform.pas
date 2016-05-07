unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Spin, Menus, ComCtrls, VolumeControl, PopUp, Unit1, Math, IniFiles;

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
    MenuItem2: TMenuItem;
    mnMainMenu: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    miAbout: TMenuItem;
    tbTargetVolume: TTrackBar;
    tbCurrentVolume: TTrackBar;
    tmrWaitForStop: TTimer;
    tmrCountDown: TTimer;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
   // function IsStopped:Boolean;
    procedure AdjustVolume(iMinutesUntilStop: Integer; iTargetVolume: Integer);
    procedure MenuItem2Click(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure tbTargetVolumeChange(Sender: TObject);
    procedure tbCurrentVolumeChange(Sender: TObject);
    procedure tmrWaitForStopStopTimer(Sender: TObject);
    procedure tmrWaitForStopTimer(Sender: TObject);
    procedure tmrCountDownStopTimer(Sender: TObject);
    procedure tmrCountDownTimer(Sender: TObject);
    procedure UpdateButtons;
    procedure StopCountDown;
    procedure UpdateShowCurrentVolumeLabel;
    procedure parseConfigFile;
    procedure saveSettings;

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


//Form Create
//******************************************
procedure TfMainform.FormCreate(Sender: TObject);

begin
  tbTargetVolume.Min := 0;
  tbTargetVolume.Max := 100;
  tbTargetVolume.PageSize := 5;
end;


//Form Show
//*****************************************
procedure TfMainform.FormShow(Sender: TObject);
var
  iniConfigFile: TINIFile; //TODO: Move config.ini access to func
  bStartCountdownAutomatically: Boolean;
begin
  tmrWaitForStop.Enabled := False;
  parseConfigFile;
    tbTargetVolumeChange(NIL); //Update lblShowTargetVolume.Caption
  //TODO: move trackbar change to form show?
  UpdateShowCurrentVolumeLabel;

  //if iniConfigFile.ReadBool('options', 'StartCountdownAutomatically', false)

    //Check if Countdown should start immedately
  iniConfigFile := TINIFile.Create('config.ini'); //TODO: Move config.ini access to func
  bStartCountdownAutomatically := iniConfigFile.ReadBool('options', 'StartCountdownAutomatically', False);
  if bStartCountdownAutomatically then
    btnStartClick(Application);
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
    edMinutesUntilStop.Increment := iniConfigFile.ReadInteger('main', 'MinutesIncrement', 15);
    edMinutesUntilStart.Value := iniConfigFile.ReadInteger('main', 'DelayDefault', 20);
    edMinutesUntilStart.Increment:= iniConfigFile.ReadInteger('main', 'MinutesIncrement', 15);
    tbTargetVolume.Position := iniConfigFile.ReadInteger('main', 'TargetVolume', 10);
    tbCurrentVolume.Position := iniConfigFile.ReadInteger('main', 'DefaultVolume', 30);
    fMainform.Left := iniConfigFile.ReadInteger('main', 'MainformLeft', 300);
    fMainform.Top := iniConfigFile.ReadInteger('main', 'MainformTop', 200);
    fPopUp.Left := iniConfigFile.ReadInteger('main', 'PopUpLeft', 330);
    fPopUp.Top := iniConfigFile.ReadInteger('main', 'PopUpTop', 270);

    //TODO: Put in config file
    Form1.Left := 300;
    Form1.Top := 200;
  finally
  end;
end;

//Save Settings
//*****************************************
procedure TfMainform.saveSettings;
var
  iniConfigFile: TINIFile;
begin
  iniConfigFile := TINIFile.Create('config.ini');
  iniConfigFile.WriteInteger('main', 'TargetVolume', tbTargetVolume.Position);
  iniConfigFile.WriteInteger('main', 'DefaultVolume', tbCurrentVolume.Position);
  iniConfigFile.WriteInteger('main', 'DurationDefault', edMinutesUntilStop.Value);
  iniConfigFile.WriteInteger('main', 'MainformLeft', fMainform.Left);
  iniConfigFile.WriteInteger('main', 'MainformTop', fMainform.Top);
  iniConfigFile.WriteInteger('main', 'DelayDefault', edMinutesUntilStart.Value);
end;

//Start Button
//******************************************
procedure TfMainform.btnStartClick(Sender: TObject);

begin
  UpdateButtons; //enable/disable start/stop-buttons
  dVolumeLevelAtStart := VolumeControl.GetMasterVolume(); //Save current volume for later
  iDurationSetByUser := edMinutesUntilStop.Value; //Keep initial Duration in Mind

  //Start
  tmrWaitForStop.Enabled := True;
end;


//Stop Button
//***************************************
procedure TfMainform.btnStopClick(Sender: TObject);
begin
    StopCountDown;
    fPopUp.lblQuestion.Caption := 'Stopped. Restore volume level?';
end;


//OnClose
//***************************************
procedure TfMainform.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  saveSettings;
end;


//Update Buttons
//***************************************
procedure TfMainform.UpdateButtons;
begin
    btnStart.Enabled := not btnStart.Enabled;
    btnStop.Enabled := not btnStop.Enabled;
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
  tbCurrentVolume.Position := Round(dNewVolumeLevel * 100);

  //Update Label
  UpdateShowCurrentVolumeLabel;
end;

procedure TfMainform.MenuItem2Click(Sender: TObject);
begin
  Form1.Show;
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


//Current Volume Trackbar OnChange
//****************************************************
procedure TfMainform.tbCurrentVolumeChange(Sender: TObject);
var
  dNewVolumeLevel: Double;
  iNewVolumeLevel: Integer;
begin
  iNewVolumeLevel := tbCurrentVolume.Position;
  dNewVolumeLevel := Double(iNewVolumeLevel);
  VolumeControl.SetMasterVolume(dNewVolumeLevel / 100);
  UpdateShowCurrentVolumeLabel;
end;

procedure TfMainform.tmrWaitForStopStopTimer(Sender: TObject);
begin
end;

//Timer WaitForStop
//*********************************************
procedure TfMainform.tmrWaitForStopTimer(Sender: TObject);
var
  bTimeIsUp: Boolean;
  bTargetVolumeReached: Boolean;
  iCurrentVolume: Integer;
begin
  //if testmode -> faster contdown
  if bTestMode = true then
    tmrCountDown.Interval := 1000;

  //start count down
  tmrCountDown.Enabled := True;

  //check current parameters
  bTimeIsUp := edMinutesUntilStop.Value <= 0;
  iCurrentVolume := Trunc(VolumeControl.GetMasterVolume() * 100); //Get current Volume
  bTargetVolumeReached := iCurrentVolume <= tbTargetVolume.Position;

  //Stop
  if bTimeIsUp or bTargetVolumeReached then
    StopCountDown;
end;

procedure TfMainform.tmrCountDownStopTimer(Sender: TObject);
begin
end;

//Timer CountDown (default = 1 minute)
//***********************************
procedure TfMainform.tmrCountDownTimer(Sender: TObject);
var
  iMinutesLapsed: Integer = 0;
begin
  edMinutesUntilStop.Value := edMinutesUntilStop.Value - 1; //Count Minutes until stop
  iMinutesLapsed := iMinutesLapsed + 1; //Count Minutes since start

  if iMinutesLapsed > edMinutesUntilStart.Value then // if Start of vol red. reached)
  begin
    AdjustVolume(edMinutesUntilStop.Value, tbTargetVolume.Position);
  end;
end;


//TimeIsUp
//*************************************
procedure TfMainform.StopCountDown;
begin
  fPopUp.lblQuestion.Caption := 'Time is up. Restore volume level?';
  tmrWaitForStop.Enabled := False;
  tmrCountDown.Enabled := False;
  fPopUp.Show;
  UpdateButtons;
end;


//Update ShowCurrentVolumeLabel
procedure TfMainform.UpdateShowCurrentVolumeLabel;
begin
  fMainform.lblShowCurrentVolume.Caption := IntToStr(tbCurrentVolume.Position) + '%';
end;

end.

