unit optionsform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, func,
  DefaultTranslator, lclintf, DbCtrls, LazUTF8, listedit;

type

  { TfOptionsForm }

  TfOptionsForm = class(TForm)
    btnEditWebsiteCountdownStart: TButton;
    btnEditWebsiteCountdownEnd: TButton;
    btnEditScriptCountdownStart: TButton;
    btnEditScriptCountdownEnd: TButton;
    chkWebsiteCountdownEnd: TCheckBox;
    chkScriptCountdownEnd: TCheckBox;
    chkWebsiteCountdownStart: TCheckBox;
    chkStartCountdownAutomatically: TCheckBox;
    chkScriptCountdownStart: TCheckBox;
    edScriptCountdownEnd: TEdit;
    edWebsiteCountdownStart: TEdit;
    edScriptCountdownStart: TEdit;
    edWebsiteCountdownEnd: TEdit;
    Label1: TLabel;
    lblExecuteAtCountdownEnd: TLabel;
    procedure btnEditScriptCountdownEndClick(Sender: TObject);
    procedure btnEditWebsiteCountdownEndClick(Sender: TObject);
    procedure btnEditWebsiteCountdownStartClick(Sender: TObject);
    procedure btnEditScriptCountdownStartClick(Sender: TObject);
    procedure chkScriptCountdownEndChange(Sender: TObject);
    procedure chkStartCountdownAutomaticallyChange(Sender: TObject);
    procedure chkScriptCountdownStartChange(Sender: TObject);
    procedure chkWebsiteCountdownEndChange(Sender: TObject);
    procedure chkWebsiteCountdownStartChange(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormShow(Sender: TObject);
    //procedure LoadLinkList;
    //procedure LoadScriptList;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fOptionsForm: TfOptionsForm;
  LinkList: TStringlist;
  ScriptList: TStringlist;

resourcestring
  CaptionchkWebsite = 'Open selected Website:';
  CaptionchkScript = 'Open selected Program:';

implementation

{$R *.lfm}

{ TfOptionsForm }

//Form Show
//***********************************************
procedure TfOptionsForm.FormShow(Sender: TObject);
begin
  //TODO: harmonise options parameter names
  //load options
  chkStartCountDownAutomatically.Checked :=
    func.readConfig('options', 'StartCountdownAutomatically', false);
  edWebsiteCountdownStart.Text := func.readConfig('options', 'WebsiteLinkName', '');
  edScriptCountdownStart.Text := func.readConfig('options', 'ExecuteAtStartName', '');
  edWebsiteCountdownEnd.Text := func.readConfig('options', 'WebsiteAtCountdownEndName', '');
  edScriptCountdownEnd.Text := func.readConfig('options', 'ExecuteAtCountdownEndName', '');
  chkWebsiteCountdownStart.Checked := func.readConfig('options', 'WebsiteLinkEnabled', False);
  chkWebsiteCountdownStart.Caption := CaptionchkWebsite;
  chkScriptCountdownStart.Checked := func.readConfig('options', 'ExecuteAtStartEnabled', False);
  chkScriptCountdownStart.Caption := CaptionchkScript;;
  chkWebsiteCountdownEnd.Checked := func.readConfig('options', 'WebsiteAtCountdownEndEnabled', False);
  chkWebsiteCountdownEnd.Caption := CaptionchkWebsite;
  chkScriptCountdownEnd.Checked := func.readConfig('options', 'ExecuteAtCountdownEndEnabled', False);
  chkScriptCountdownEnd.Caption := CaptionchkScript;;


end;

//OnChange - Start Countdown automatically
//**********************************************
procedure TfOptionsForm.chkStartCountdownAutomaticallyChange(Sender: TObject);
begin
  func.writeConfig('options', 'StartCountdownAutomatically',
    chkStartCountDownAutomatically.Checked);
end;



//Open List of Websites
//******************************************************************************
procedure OpenListOfWebsites;
const
  sListFileName: String = 'ListOfWebsites.csv';
begin
  fListEdit.Caption := 'List of Websites';
  fListEdit.StringGrid1.LoadFromCSVFile(func.GetOSConfigPath(sListFileName),',',false);
  listedit.sListFilename := sListFileName;
  fListEdit.Show;
end;

//Enable Website at Countdown Start TEdit
//******************************************************************************
procedure TfOptionsForm.chkWebsiteCountdownStartChange(Sender: TObject);
begin
  edWebsiteCountdownStart.Enabled := chkWebsiteCountdownStart.Checked;
end;

//Button Website at Countdown Start
//******************************************************************************
procedure TfOptionsForm.btnEditWebsiteCountdownStartClick(Sender: TObject);
begin
  listedit.TEditSelect := edWebsiteCountdownStart; //hand over TEdit in order to give back selection
  listedit.sConfigListPath := 'WebsiteLink';
  listedit.sConfigSelectedItem := 'WebsiteLinkName';
  OpenListOfWebsites;
end;

//Enable Website at Countdown End TEdit
//******************************************************************************
procedure TfOptionsForm.chkWebsiteCountdownEndChange(Sender: TObject);
begin
  edWebsiteCountdownEnd.Enabled := chkWebsiteCountdownEnd.Checked;
end;

//Button Website at Countdown End
//******************************************************************************
procedure TfOptionsForm.btnEditWebsiteCountdownEndClick(Sender: TObject);
begin
  listedit.TEditSelect := edWebsiteCountdownEnd; //hand over TEdit in order to give back selection
  listedit.sConfigListPath := 'WebsiteAtCountdownEndPath';
  listedit.sConfigSelectedItem := 'WebsiteAtCountdownEndName';
  OpenListOfWebsites;
end;



//Open List of Scripts
//******************************************************************************
procedure OpenListOfScripts;
const
  sListFileName : String = 'ListOfPrograms.csv';
begin
  fListEdit.Caption := 'List of executable Programs';
  fListEdit.StringGrid1.LoadFromCSVFile(func.GetOSConfigPath(sListFileName),',',false);
  listedit.sListFilename := sListFileName;
  fListEdit.Show;
end;

//Enable Script at Countdown Start TEdit
//******************************************************************************
procedure TfOptionsForm.chkScriptCountdownStartChange(Sender: TObject);
begin
  edScriptCountdownStart.Enabled := chkScriptCountdownStart.Checked;
end;

//Button Script at Countdown Start
//******************************************************************************
procedure TfOptionsForm.btnEditScriptCountdownStartClick(Sender: TObject);
begin
  listedit.TEditSelect := edScriptCountdownStart; //hand over TEdit in order to give back selection
  listedit.sConfigListPath := 'ExecuteAtStart';
  listedit.sConfigSelectedItem := 'ExecuteAtStartName';
  OpenListOfScripts;
end;

//Enable Script at Countdown End TEdit
//******************************************************************************
procedure TfOptionsForm.chkScriptCountdownEndChange(Sender: TObject);
begin
  edScriptCountdownEnd.Enabled := chkScriptCountdownEnd.Checked;
end;

//Button Script at Countdown End
//******************************************************************************
procedure TfOptionsForm.btnEditScriptCountdownEndClick(Sender: TObject);
begin
  listedit.TEditSelect := edScriptCountdownEnd; //hand over TEdit in order to give back selection
  listedit.sConfigListPath := 'ExecuteAtCountdownEndPath';
  listedit.sConfigSelectedItem := 'ExecuteAtCountDownEndName';
  OpenListOfScripts;
end;



//Form Close
//**********************************************
procedure TfOptionsForm.FormClose(Sender: TObject);
begin
  func.writeConfig('main', 'OptionsFormLeft', fOptionsForm.Left);
  func.writeConfig('main', 'OptionsFormTop', fOptionsForm.Top);
  func.writeConfig('options', 'WebsiteLinkEnabled', chkWebsiteCountdownStart.Checked);
  func.writeConfig('options', 'ExecuteAtStartEnabled', chkScriptCountdownStart.Checked);
  func.writeConfig('options', 'ExecuteAtCountdownEndEnabled', chkScriptCountdownEnd.Checked);
  func.writeConfig('options', 'WebsiteAtCountdownEndEnabled', chkScriptCountdownEnd.Checked);

end;

end.

