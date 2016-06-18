unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, FileUtil, RTTICtrls, TAGraph, TASeries,
  Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Spin, Menus, ComCtrls,
  VolumeControl, PopUp, optionsform, IniFiles;

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
    procedure readConfigFile;
    procedure saveSettings;
    procedure drawGraph;

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fMainform: TfMainform;
  dVolumeLevelAtStart: Double;
  bTestMode: Boolean;
  iMinutesLapsed: Integer;
  aVolumeLevels: Array[0..1000] of Double;
  iVolumeArrayCounter: Integer = 0;
  const sTitlebarCaption: String = 'Open Sleep Timer v0.4';


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
  readConfigFile;

  //Check if Countdown should start immedately
  iniConfigFile := TINIFile.Create('config.ini'); //TODO: Move config.ini access to func
  bStartCountdownAutomatically := iniConfigFile.ReadBool('options', 'StartCountdownAutomatically', False);
  if bStartCountdownAutomatically then
    btnStartClick(Application);

  fMainform.Caption := sTitlebarCaption;
end;

//Draw Graph
//******************************************
procedure TfMainform.drawGraph;
var
  dSlope, dYintercept, dGraphEnd: Double;
  i, iDuration, iDelayedStart, iTargetVolume, iCurrentVolume: Integer;
begin
  iDelayedStart := edMinutesUntilStart.Value;
  iTargetVolume := tbTargetVolume.Position;
  iCurrentVolume := tbCurrentVolume.Position;
  iDuration := edMinutesUntilStop.Value;

  //Calculate Slope
  if (iDuration - iDelayedStart <> 0) then
  begin
    dSlope := (iTargetVolume - iCurrentVolume) / (iDuration - iDelayedStart);
  end
  else begin
    dSlope := -10000;
  end;

  //Calculate Start- and Endpoints of Graph
  dYintercept := dSlope *-1 * iDelayedStart + iCurrentVolume;
  if dSlope <> 0 then
  begin
    dGraphEnd := (iTargetVolume - dYintercept) / dSlope;
  end
  else begin
    dGraphEnd := iDuration;
  end;

  //Draw Line
  for i := 0 to iDelayedStart do
  begin
    Chart1LineSeries1.AddXY(i, iCurrentVolume);
  end;
  for i := iDelayedStart to Trunc(dGraphEnd) do
  begin
    Chart1LineSeries1.AddXY(i, i * dSlope + dYintercept);
  end;
end;

//Read Config File
//******************************************
procedure TfMainform.readConfigFile;
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
    fOptionsForm.Left := iniConfigFile.ReadInteger('main', 'OptionsFormLeft', 300);
    fOptionsForm.Top := iniConfigFile.ReadInteger('main', 'OptionsFormTop', 300);
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
  dVolumeStepsTotal: Double;
  i: Integer;
  iMinutesUntilStop: Integer;
  iTargetVolume: Integer;
  iMinutesUntilStart: Integer;

begin
  //Volume Gesamt-Differenz ermitteln
  //Anhand der Gesamtzeit einzelne Volume-Schritte ermitteln
  //Die Volume-Level vorberechnen und in einem Array ablegen
  //Das Array ist global
  //Es gibt außerdem einen globalen Zähler, der vom Timer hochgezählt wird
  //(if >Delayed Start, <Target Volume) wird zum Zähler das Volumelevel aus dem Array genommen und an AdjustVolume übergeben

  iMinutesUntilStop := edMinutesUntilStop.Value;
  iTargetVolume := tbTargetVolume.Position;
  iMinutesUntilStart := edMinutesUntilStart.Value;

  //read current audio volume from system
  dCurrentVolume := VolumeControl.GetMasterVolume();

  dVolumeStepsTotal := dCurrentVolume * 100 - iTargetVolume;
  if (iMinutesUntilStop - iMinutesUntilStart <> 0) then
  begin
    dVolumeStepSize := (dVolumeStepsTotal / (iMinutesUntilStop - iMinutesUntilStart)) / 100;
  end
  else begin
    dVolumeStepSize := 0.00000000000001;
  end;


  aVolumeLevels[0] := dCurrentVolume;
  for i := 1 to iMinutesUntilStop do begin
    aVolumeLevels[i] := aVolumeLevels[i-1] - dVolumeStepsize
  end;

  UpdateButtons; //enable/disable start/stop-buttons
  dVolumeLevelAtStart := VolumeControl.GetMasterVolume(); //Save current volume for later

  //if testmode -> faster contdown
  if bTestMode = true then
    tmrCountDown.Interval := 1000;

  iMinutesLapsed := 0;

  edMinutesUntilStop.MinValue := 0;

  //start count down
  tmrCountDown.Enabled := True;

end;


//Stop Button
//***************************************
procedure TfMainform.btnStopClick(Sender: TObject); //TODO: Rename
begin
  StopCountDown(Sender);
end;


//edMinutesUntilStart OnChange of Delayed Start Field
//*************************************************************
procedure TfMainform.edMinutesUntilStartChange(Sender: TObject); //TODO: Rename
begin
  {if edMinutesUntilStart.Value > edMinutesUntilStop.Value then
    edMinutesUntilStart.Value := edMinutesUntilStop.Value;}

  edMinutesUntilStart.MaxValue := edMinutesUntilStop.Value;

  if btnStart.Enabled then //Only if not running  TODO: Disable when Started
  begin
    Chart1LineSeries1.Clear;
    drawGraph;
  end;
end;

//edMinutesUntilStop Change - On Change of Duration Field
//*****************************************************
procedure TfMainform.edMinutesUntilStopChange(Sender: TObject);
begin

  if btnStart.Enabled then //if not running
  begin
    edMinutesUntilStop.MinValue := edMinutesUntilStart.Value;
  end;

  if btnStart.Enabled then //Only if not running TODO: Disable when started
  begin
    Chart1LineSeries1.Clear;
    drawGraph;
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
    {
    tbTargetVolume.Enabled := not tbTargetVolume.Enabled;
    tbCurrentVolume.Enabled := not tbCurrentVolume.Enabled;
    edMinutesUntilStart.Enabled := not edMinutesUntilStart.Enabled;
    edMinutesUntilStop.Enabled := not edMinutesUntilStop.Enabled;
    chkStandby.Enabled := not chkStandby.Enabled;
    }
end;


procedure TfMainform.MenuItem2Click(Sender: TObject);
begin
  fOptionsForm.Show;
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
    drawGraph;
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
    drawGraph;
  end;
end;

//Timer CountDown (default = 1 minute)
//***********************************
procedure TfMainform.tmrCountDownTimer(Sender: TObject);
var
  iMinutesDelay: Integer;
  iMinutesDuration: Integer;
  bTimeIsUp: Boolean;
  bStartReached: Boolean;
begin
  iMinutesDelay := edMinutesUntilStart.Value;
  iMinutesDuration := edMinutesUntilStop.Value;
  iMinutesLapsed := iMinutesLapsed + 1;
  fMainform.Caption := sTitlebarCaption + ' - Remaining Minutes: ' + IntToStr(iMinutesDuration - iMinutesLapsed);

  bTimeIsUp := iMinutesLapsed >= iMinutesDuration;
  bStartReached := iMinutesLapsed > iMinutesDelay;

  if bStartReached then
  begin
    Inc(iVolumeArrayCounter);
    tbCurrentVolume.Position := Round(aVolumeLevels[iVolumeArrayCounter]*100);
  end;

  if bTimeIsUp then
    StopCountDown(Self);
end;


//Stop CountDown
//*************************************
procedure TfMainform.StopCountDown(Sender: TObject);
var
  s: String;
begin
  tmrCountDown.Enabled := False;
  fPopUp.Show;
  UpdateButtons;

  //Go to Standby at the end (if checked)
  if (chkStandby.Checked) AND (Sender <> btnStop) then
    process.RunCommand('rundll32.exe powrprof.dll,SetSuspendState Standby', s);

  //Reset Counter
  iVolumeArrayCounter := 0;
  //Reset Titlebar
  fMainform.Caption := sTitlebarCaption;


end;


//Update ShowCurrentVolumeLabel
procedure TfMainform.UpdateShowCurrentVolumeLabel;
begin
  fMainform.lblShowCurrentVolume.Caption := IntToStr(tbCurrentVolume.Position) + '%';
end;

end.

