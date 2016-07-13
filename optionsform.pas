unit optionsform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Menus, func, DefaultTranslator, lclintf, LazUTF8;

type

  { TfOptionsForm }

  TfOptionsForm = class(TForm)
    btnEditLinkList: TButton;
    btnEditScriptList: TButton;
    chkWebsiteLinkAtStart: TCheckBox;
    chkStartCountdownAutomatically: TCheckBox;
    cbSelectWebsite: TComboBox;
    cbSelectScriptAtStart: TComboBox;
    chkStartProgramAtStart: TCheckBox;
    Label1: TLabel;
    procedure btnEditLinkListClick(Sender: TObject);
    procedure btnEditScriptListClick(Sender: TObject);
    procedure chkStartCountdownAutomaticallyChange(Sender: TObject);
    procedure chkStartProgramAtStartChange(Sender: TObject);
    procedure chkWebsiteLinkAtStartChange(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LoadLinkList;
    procedure LoadScriptList;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fOptionsForm: TfOptionsForm;
  LinkList: TStringlist;
  ScriptList: TStringlist;

implementation

{$R *.lfm}

{ TfOptionsForm }

//Form Show
//***********************************************
procedure TfOptionsForm.FormShow(Sender: TObject);
begin
  //load options
  chkStartCountDownAutomatically.Checked :=
    func.readConfig('options', 'StartCountdownAutomatically', false);
  cbSelectWebsite.Text := func.readConfig('options', 'WebsiteLink', '');
  //load website-links
  LinkList := TStringlist.Create;
  LoadLinkList;
  cbSelectWebsite.Items.Assign(LinkList);
  if cbSelectWebsite.Text = '' then
  begin
    cbSelectWebsite.Text := LinkList[0];
  end;
  //load script-list
  ScriptList := TStringlist.Create;
  LoadScriptList;
  cbSelectScriptAtStart.Items.Assign(ScriptList);
  if cbSelectScriptAtStart.Text = '' then
  begin
    cbSelectScriptAtStart.Text := ScriptList[0];
  end;
end;

//OnChange - Start Countdown automatically
//**********************************************
procedure TfOptionsForm.chkStartCountdownAutomaticallyChange(Sender: TObject);
begin
  func.writeConfig('options', 'StartCountdownAutomatically',
    chkStartCountDownAutomatically.Checked);
end;

//Get Path of Text-File
//*******************************
function GetPathOfTextfile(Filename: String):String;
begin
  //Windows: make sure special charactars in path are treated correctly
  Result := WinCPToUTF8(GetAppConfigDir(False)) + Filename;
end;

//Create Text-File
//***********************************
procedure CreateTextFile(Filename: String);
begin
  LinkList.SaveToFile(GetPathOfTextfile(Filename));
end;

//Load LinkList
//***********************************************
procedure TfOptionsForm.LoadLinkList;
begin
  try
    LinkList.LoadFromFile(GetPathOfTextfile('ListOfWebsites.txt'));
  except
    LinkList.Add('http://asoftmurmur.com/');
    LinkList.Add('https://www.youtube.com/watch?v=eyU3bRy2x44');
    CreateTextFile('ListOfWebsites.txt');
  end;
end;

//Edit LinkList
procedure TfOptionsForm.btnEditLinkListClick(Sender: TObject);
begin
  OpenDocument(GetPathOfTextfile('ListOfWebsites.txt'));
end;

//Enable LinkList DropDown
procedure TfOptionsForm.chkWebsiteLinkAtStartChange(Sender: TObject);
begin
  cbSelectWebsite.Enabled := chkWebsiteLinkAtStart.Checked;
end;


//Load ScriptList
//**********************************************
procedure TfOptionsForm.LoadScriptList;
begin
  try
    ScriptList.LoadFromFile(GetPathOfTextfile('ListOfScripts.txt'));
  except
    CreateTextFile('ListOfScripts.txt');
  end;
end;

//Edit Script List
procedure TfOptionsForm.btnEditScriptListClick(Sender: TObject);
begin
  OpenDocument(GetPathOfTextfile('ListOfScripts.txt'));
end;

//Enable Script List Dropdown
procedure TfOptionsForm.chkStartProgramAtStartChange(Sender: TObject);
begin
  cbSelectScriptAtStart.Enabled := chkStartProgramAtStart.Checked;
end;


//Form Close
//**********************************************
procedure TfOptionsForm.FormClose(Sender: TObject);
begin
  func.writeConfig('main', 'OptionsFormLeft', fOptionsForm.Left);
  func.writeConfig('main', 'OptionsFormTop', fOptionsForm.Top);
  func.writeConfig('options', 'WebsiteLink', cbSelectWebsite.Text);
  func.writeConfig('options', 'ExecuteAtStart',  cbSelectScriptAtStart.Text);
end;


end.

