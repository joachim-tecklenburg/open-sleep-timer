unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, FileUtil, RTTICtrls, TAGraph, {TASources,} TASeries,
  Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Spin, Menus, ComCtrls,
  VolumeControl, PopUp, optionsform, Math, IniFiles;

type

  { TfMainform }

  TfMainform = class(TForm)
    btnStop: TButton;
    btnStart: TButton;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    chkStandby: TCheckBox;
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
    tmrCountDown: TTimer;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure edMinutesUntilStartChange(Sender: TObject);
    procedure edMinutesUntilStopChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure tbTargetVolumeChange(Sender: TObject);
    procedure tbCurrentVolumeChange(Sender: TObject);
    procedure tmrCountDownTimer(Sender: TObject);
    procedure UpdateButtons;
    procedure StopCountDown(Sender: TObject);
    procedure UpdateShowCurrentVolumeLabel;
    procedure parseConfigFile;
    procedure saveSettings;
    procedure updateDiagram;

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
  iMinutesLapsed: Integer;
  aVolumeLevels: Array[0..1000] of Double;
  iVolumeArrayCounter: Integer = 0;
  //TODO: Define default values as constants


implementation

{$R *.lfm}

{ TfMainform }

//Form Show
//*****************************************
procedure TfMainform.FormShow(Sender: TObject);
var
  iniConfigFile: TINIFile; //TODO: Move config.ini access to func
  bStartCountdownAutomatically: Boolean;
begin
  parseConfigFile;
//  tbTargetVolumeChange(NIL); //Update lblShowTargetVolume.Caption
  //TODO: move trackbar change to form show?
  UpdateShowCurrentVolumeLabel;

  //Check if Countdown should start immedately
  iniConfigFile := TINIFile.Create('config.ini'); //TODO: Move config.ini access to func
  bStartCountdownAutomatically := iniConfigFile.ReadBool('options', 'StartCountdownAutomatically', False);
  if bStartCountdownAutomatically then
    btnStartClick(Application);

  //Style Settings for Diagram
  Chart1.BackColor:=clWhite;
  Chart1.Extent.UseYMin:=True;
  Chart1.Extent.YMin:=0;
  Chart1.Extent.UseYMax:=True;
  Chart1.Extent.YMax:=100;
  //Chart1.LeftAxis.Range.UseMin:=True;
  //Chart1.LeftAxis.Range.Min:=0;
  //Chart1.LeftAxis.Range.UseMax:=True;
  //Chart1.LeftAxis.Range.Max:=100;
end;

//Update Diagram
//******************************************
procedure TfMainform.updateDiagram;
var
  i: Integer;
  dSlope: Double;
  dYintercept: Double;
  iDuration: Integer;
  iDelayedStart: Integer;
  iTargetVolume: Integer;
  iCurrentVolume: Integer;
  dSlopeStop: Double;

begin
  iDelayedStart := edMinutesUntilStart.Value;
  iTargetVolume := tbTargetVolume.Position;
  iCurrentVolume := tbCurrentVolume.Position;
  iDuration := edMinutesUntilStop.Value;

  if (iDuration - iDelayedStart <> 0) then
  begin
    dSlope := (iTargetVolume - iCurrentVolume) / (iDuration - iDelayedStart);
  end
  else begin
    dSlope := -10000;
  end;

  dYintercept := dSlope *-1 * iDelayedStart + iCurrentVolume;

  if dSlope <> 0 then
    dSlopeStop := (iTargetVolume - dYintercept) / dSlope;

  for i := 0 to iDelayedStart do
  begin
    Chart1LineSeries1.AddXY(i, iCurrentVolume);
  end;
  for i := iDelayedStart to Trunc(dSlopeStop) do
  begin
    Chart1LineSeries1.AddXY(i, i * dSlope + dYintercept);
  end;
  {for i := Trunc(dSlopeStop) to iDuration do
  begin
    Chart1LineSeries1.AddXY(i, iTargetVolume);
  end;}
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
    chkStandby.Checked := iniConfigfile.Readbool('main', 'GoToStandby', False);
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
  iniConfigfile.Writebool('main', 'GoToStandby', chkStandby.Checked);
end;

//Start Button
//******************************************
procedure TfMainform.btnStartClick(Sender: TObject);
var
  dCurrentVolume: Double;
  dVolumeStepSize: Double;
  //dNewVolumeLevel: Double;
  dVolumeStepsTotal: Double;
  //iVolDiff: Integer;
  i: Integer;
  iMinutesUntilStop: Integer;
  iTargetVolume: Integer;

begin
  //Volume Gesamt-Differenz ermitteln
  //Anhand der Gesamtzeit einzelne Volume-Schritte ermitteln
  //Die Volume-Level vorberechnen und in einem Array ablegen
  //Das Array ist global
  //Es gibt außerdem einen globalen Zähler, der vom Timer hochgezählt wird
  //(if >Delayed Start, <Target Volume) wird zum Zähler das Volumelevel aus dem Array genommen und an AdjustVolume übergeben

  iMinutesUntilStop := edMinutesUntilStop.Value;
  iTargetVolume := tbTargetVolume.Position;


  //iVolDiff := tbCurrentVolume.Position - tbTargetVolume.Position;
  //TODO: i negativ !!?

  //read current audio volume from system
  dCurrentVolume := VolumeControl.GetMasterVolume();

  dVolumeStepsTotal := dCurrentVolume * 100 - iTargetVolume;
  dVolumeStepSize := (dVolumeStepsTotal / iMinutesUntilStop) / 100;

  aVolumeLevels[0] := dCurrentVolume;
  for i := 1 to iMinutesUntilStop do begin
    aVolumeLevels[i] := aVolumeLevels[i-1] - dVolumeStepsize
  end;

  UpdateButtons; //enable/disable start/stop-buttons
  dVolumeLevelAtStart := VolumeControl.GetMasterVolume(); //Save current volume for later
  iDurationSetByUser := edMinutesUntilStop.Value; //Keep initial Duration in Mind

  //if testmode -> faster contdown
  if bTestMode = true then
    tmrCountDown.Interval := 1000;

  iMinutesLapsed := 0;

  //start count down
  tmrCountDown.Enabled := True;

end;


//Stop Button
//***************************************
procedure TfMainform.btnStopClick(Sender: TObject); //TODO: Rename
begin
  //StopCountDown;
  //fPopUp.lblQuestion.Caption := 'Stopped. Restore volume level?';
  StopCountDown(Sender);
end;


//edMinutesUntilStart OnChange of Delayed Start Field
//*************************************************************
procedure TfMainform.edMinutesUntilStartChange(Sender: TObject); //TODO: Rename
begin

  if btnStart.Enabled then //Only if not running  TODO: Disable when Started
  begin
    Chart1LineSeries1.Clear;
    UpdateDiagram;
  end;
end;

//edMinutesUntilStop Change - On Change of Duration Field
//*****************************************************
procedure TfMainform.edMinutesUntilStopChange(Sender: TObject);
begin
  if edMinutesUntilStart.Value > edMinutesUntilStop.Value then
    edMinutesUntilStart.Value := edMinutesUntilStop.Value;

  edMinutesUntilStart.MaxValue := edMinutesUntilStop.Value;

  if btnStart.Enabled then //Only if not running TODO: Disable when started
  begin
    Chart1LineSeries1.Clear;
    UpdateDiagram;
  end;
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
  if btnStart.Enabled then //Only if not running
  begin
    Chart1LineSeries1.Clear;
    UpdateDiagram;
  end;
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
  if btnStart.Enabled then //Only if not running
  begin
    Chart1LineSeries1.Clear;
    UpdateDiagram;
  end;
end;

//Timer CountDown (default = 1 minute)
//***********************************
procedure TfMainform.tmrCountDownTimer(Sender: TObject);
var
  //iMinutesLapsed: Integer = 0;
  iMinutesDelay: Integer;
  bTimeIsUp: Boolean;
  bTargetVolumeNotReached: Boolean;
  iCurrentVolume: Integer;
begin
  iMinutesDelay := edMinutesUntilStart.Value;

  //TODO: calculate remaining minutes beforehand, then make timer interval shorter (for responsiveness)
  edMinutesUntilStop.Value := edMinutesUntilStop.Value - 1; //Count Minutes until stop
  iMinutesLapsed := iMinutesLapsed + 1; //Count Minutes since start

  //check current parameters
  bTimeIsUp := edMinutesUntilStop.Value <= 0;
  iCurrentVolume := Trunc(VolumeControl.GetMasterVolume() * 100); //Get current Volume

  //check if target volume reached depending on rising/falling curve
  if tbTargetVolume.Position <= tbCurrentVolume.Position then
  begin
    bTargetVolumeNotReached := iCurrentVolume > tbTargetVolume.Position;
  end
  else begin
    bTargetVolumeNotReached := iCurrentVolume < tbTargetVolume.Position;
  end;

  // if Start of vol red. reached, but TargetVolume NOT reached
  if (iMinutesLapsed > iMinutesDelay) and (bTargetVolumeNotReached) then
  begin
    Inc(iVolumeArrayCounter);
    tbCurrentVolume.Position := trunc(aVolumeLevels[iVolumeArrayCounter]*100);
    //AdjustVolume(edMinutesUntilStop.Value, tbTargetVolume.Position);
  end;

  //Stop if time is up
  if bTimeIsUp {or bTargetVolumeReached} then
    StopCountDown(Self);
end;


//Stop CountDown
//*************************************
procedure TfMainform.StopCountDown(Sender: TObject);
var
  s: String;
begin
  fPopUp.lblQuestion.Caption := 'Stopped. Restore volume level?';
  //tmrWaitForStop.Enabled := False; TODO: Remove
  tmrCountDown.Enabled := False;
  fPopUp.Show;
  UpdateButtons;

  //Go to Standby at the end (if checked)
  if (chkStandby.Checked) AND (Sender <> btnStop) then //Standby option / Stop Buttton NOT pressed
    process.RunCommand('rundll32.exe powrprof.dll,SetSuspendState Standby', s);

  //Reset Counter
  iVolumeArrayCounter := 0;
end;


//Update ShowCurrentVolumeLabel
procedure TfMainform.UpdateShowCurrentVolumeLabel;
begin
  fMainform.lblShowCurrentVolume.Caption := IntToStr(tbCurrentVolume.Position) + '%';
end;

end.

