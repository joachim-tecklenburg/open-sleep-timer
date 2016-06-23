unit mainform;

{$mode objfpc}{$H+}

interface

uses
  {Classes,} Process, SysUtils, {FileUtil,} {RTTICtrls,} TAGraph, TASeries,
  Forms, {Controls,} {Graphics,} Dialogs, StdCtrls, ExtCtrls, Spin, Menus, ComCtrls,
  VolumeControl, PopUp, optionsform, math, func, ActnList, about, DefaultTranslator, lclintf;

type

  { TfMainform }

  TfMainform = class(TForm)
    VolumeDown: TAction;
    VolumeUp: TAction;
    ActionList1: TActionList;
    btnStop: TButton;
    btnStart: TButton;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    chkStandby: TCheckBox;
    edMinutesDelay: TSpinEdit;
    lblCurrentVolume: TLabel;
    lblShowCurrentVolume: TLabel;
    lblShowTargetVolume: TLabel;
    lblTargetVolume: TLabel;
    lblMinutesUntilStop: TLabel;
    edMinutesDuration: TSpinEdit;
    lblMinutesUntilStart: TLabel;
    MenuItemOptions: TMenuItem;
    mnMainMenu: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItemAbout: TMenuItem;
    tbTargetVolume: TTrackBar;
    tbCurrentVolume: TTrackBar;
    tmrCountDown: TTimer;
    procedure VolumeDownExecute(Sender: TObject);
    procedure VolumeUpExecute(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure edMinutesDelayChange(Sender: TObject);
    procedure edMinutesDurationChange(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItemOptionsClick(Sender: TObject);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure tbCurrentVolumeMouseDown(Sender: TObject);
    procedure tbCurrentVolumeMouseUp(Sender: TObject);
    procedure tbTargetVolumeChange(Sender: TObject);
    procedure tbCurrentVolumeChange(Sender: TObject);
    procedure tmrCountDownTimer(Sender: TObject);
    procedure UpdateButtons;
    procedure StopCountDown(Sender: TObject);
    procedure loadSettings;
    procedure saveSettings;
    procedure drawGraph;
    procedure AdjustVolume;

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
  aVolumeLevels: Array[0..10000] of Double;
  iVolumeArrayCounter: Integer = 0;
  dPreviousVolume: Double;
  btbCurrentVolumeMouseDown: Boolean;
  const sTitlebarCaption: String = 'Open Sleep Timer v0.4';


implementation

{$R *.lfm}

{ TfMainform }

//Form Show
//*****************************************
procedure TfMainform.FormShow(Sender: TObject);
var
  bStartCountdownAutomatically: Boolean;
begin
  loadSettings;

  //Check if Countdown should start immedately
  bStartCountdownAutomatically := func.readConfig('options', 'StartCountdownAutomatically', False);
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
  iDelayedStart := edMinutesDelay.Value;
  iTargetVolume := tbTargetVolume.Position;
  iCurrentVolume := tbCurrentVolume.Position;
  iDuration := edMinutesDuration.Value;

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
  Chart1LineSeries1.Clear;
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
procedure TfMainform.loadSettings;
begin
    bTestMode := func.readConfig('development', 'TestMode', false);
    edMinutesDuration.Value := func.readConfig('main', 'DurationDefault', 75);
    edMinutesDuration.Increment := func.readConfig('main', 'MinutesIncrement', 15);
    edMinutesDelay.Value := func.readConfig('main', 'DelayDefault', 20);
    edMinutesDelay.Increment:= func.readConfig('main', 'MinutesIncrement', 15);
    tbTargetVolume.Position := func.readConfig('main', 'TargetVolume', 10);
    tbCurrentVolume.Position := func.readConfig('main', 'DefaultVolume', 30);
    chkStandby.Checked := func.readConfig('main', 'GoToStandby', False);
    fMainform.Left := func.readConfig('main', 'MainformLeft', 300);
    fMainform.Top := func.readConfig('main', 'MainformTop', 200);
    fPopUp.Left := func.readConfig('main', 'PopUpLeft', 330);
    fPopUp.Top := func.readConfig('main', 'PopUpTop', 270);
    fOptionsForm.Left := func.readConfig('main', 'OptionsFormLeft', 300);
    fOptionsForm.Top := func.readConfig('main', 'OptionsFormTop', 300);
end;

//Save to Config File
//*****************************************
procedure TfMainform.saveSettings;
begin
  func.writeConfig('main', 'TargetVolume', tbTargetVolume.Position);
  func.writeConfig('main', 'DefaultVolume', tbCurrentVolume.Position);
  func.writeConfig('main', 'DurationDefault', edMinutesDuration.Value);
  func.writeConfig('main', 'MainformLeft', fMainform.Left);
  func.writeConfig('main', 'MainformTop', fMainform.Top);
  func.writeConfig('main', 'DelayDefault', edMinutesDelay.Value);
  func.writeConfig('main', 'GoToStandby', chkStandby.Checked);
end;

//Adjust Volume
//****************************************
procedure TfMainform.AdjustVolume;
var
  //dPreviousVolume: Double;
  dVolumeStepSize: Double;
  dNewVolumeLevel: Double;
  dVolumeStepsTotal: Double;
  iMinutesDuration: Integer;
  iTargetVolume: Integer;
  iMinutesRemaining: Integer;
  iMinutesDelay: Integer;
begin
  iMinutesDuration := edMinutesDuration.Value;
  iTargetVolume := tbTargetVolume.Position;
  iMinutesRemaining := iMinutesDuration - iMinutesLapsed;
  iMinutesDelay := edMinutesDelay.Value;

  //calculate new volume level
  dVolumeStepsTotal := dPreviousVolume * 100 - iTargetVolume;
  if (iMinutesRemaining - iMinutesDelay > 0) then
  begin
    dVolumeStepSize := (dVolumeStepsTotal / (iMinutesRemaining - iMinutesDelay)) / 100;
  end
  else begin
    dVolumeStepSize := 0.00000000000001;
  end;
  dNewVolumeLevel := max((dPreviousVolume - dVolumeStepSize), 0);
  dPreviousVolume := dNewVolumeLevel;

  //Set new Volume
  tbCurrentVolume.Position := Round(dNewVolumeLevel * 100);
end;

//Start Button
//******************************************
procedure TfMainform.btnStartClick(Sender: TObject);
var
  sWebsiteLink: String;
begin
  dVolumeLevelAtStart := VolumeControl.GetMasterVolume();
  dPreviousVolume := dVolumeLevelAtStart;
  iMinutesLapsed := 0;

  //if testmode -> faster contdown
  if bTestMode = true then
    tmrCountDown.Interval := 1000;

  //disable / enable Buttons
  UpdateButtons;

  //start count down
  tmrCountDown.Enabled := True;

  //open Website
  if fOptionsForm.chkWebsiteLinkAtStart.Checked then
  sWebsiteLink := func.readConfig('options', 'WebsiteLink', '');
  begin
    if (sWebsiteLink <> '') then
      OpenDocument(sWebsiteLink);
  end;

end;

//Volume UP/DOWN Shortcuts
//*************************************
procedure TfMainform.VolumeUpExecute(Sender: TObject);
begin
  tbCurrentVolume.Position := tbCurrentVolume.Position + 1;
end;
procedure TfMainform.VolumeDownExecute(Sender: TObject);
begin
  tbCurrentVolume.Position := tbCurrentVolume.Position - 1;
end;

//Stop Button
//***************************************
procedure TfMainform.btnStopClick(Sender: TObject);
begin
  StopCountDown(Sender);
end;

//edMinutesDelay OnChange of Delayed Start Field
//*************************************************************
procedure TfMainform.edMinutesDelayChange(Sender: TObject);
begin
  edMinutesDelay.MaxValue := edMinutesDuration.Value;
  drawGraph;
end;

//edMinutesDuration Change - On Change of Duration Field
//*****************************************************
procedure TfMainform.edMinutesDurationChange(Sender: TObject);
begin
  edMinutesDuration.MinValue := edMinutesDelay.Value;
  drawGraph;
end;

//OnClose
//***************************************
procedure TfMainform.FormClose(Sender: TObject);
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

//Menu Procedures
//********************************************
procedure TfMainform.MenuItemAboutClick(Sender: TObject);
begin
  fAbout.Show;
  //showmessage('Open Sleep Timer - https://github.com/achim-tecklenburg/open-sleep-timer');
end;
procedure TfMainform.MenuItemOptionsClick(Sender: TObject);
begin
  fOptionsForm.Show;
end;

//Check CurrentVolumeMouseDown
//*********************************************
procedure TfMainform.tbCurrentVolumeMouseDown(Sender: TObject);
begin
  btbCurrentVolumeMouseDown:=True;
end;
procedure TfMainform.tbCurrentVolumeMouseUp(Sender: TObject);
begin
  btbCurrentVolumeMouseDown:=False;
end;

//tbTargetVolumeChange - Update Display of Target Volume near Slider
//****************************************************
procedure TfMainform.tbTargetVolumeChange(Sender: TObject);
begin
  lblShowTargetVolume.Caption := IntToStr(tbTargetVolume.Position) + '%';
  drawGraph;
end;

//Current Volume Trackbar OnChange
//****************************************************
procedure TfMainform.tbCurrentVolumeChange(Sender: TObject);
var
  iNewVolumeLevel: Integer;
begin
  iNewVolumeLevel := tbCurrentVolume.Position;
  dPreviousVolume := Double(iNewVolumeLevel) / 100;
  VolumeControl.SetMasterVolume(Double(iNewVolumeLevel) / 100);
  fMainform.lblShowCurrentVolume.Caption := IntToStr(tbCurrentVolume.Position) + '%';
  if {btnStart.Enabled and }btbCurrentVolumeMouseDown then
    drawGraph;
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
  iMinutesDelay := edMinutesDelay.Value;
  iMinutesDuration := edMinutesDuration.Value;
  iMinutesLapsed := iMinutesLapsed + 1;
  fMainform.Caption := sTitlebarCaption + ' - Remaining Minutes: ' + IntToStr(iMinutesDuration - iMinutesLapsed);

  bTimeIsUp := iMinutesLapsed >= iMinutesDuration;
  bStartReached := iMinutesLapsed > iMinutesDelay;

  if bStartReached then
  begin
    Inc(iVolumeArrayCounter);
    //tbCurrentVolume.Position := Round(aVolumeLevels[iVolumeArrayCounter]*100);
    AdjustVolume;
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




end.

