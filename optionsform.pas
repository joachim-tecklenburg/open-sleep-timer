unit optionsform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, func,
  DefaultTranslator, lclintf, DbCtrls, LazUTF8, listedit;

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
    edSelectedWebsite: TEdit;
    edSelectedScript: TEdit;
    Label1: TLabel;
    procedure btnEditLinkListClick(Sender: TObject);
    procedure btnEditScriptListClick(Sender: TObject);
    procedure chkStartCountdownAutomaticallyChange(Sender: TObject);
    procedure chkStartProgramAtStartChange(Sender: TObject);
    procedure chkWebsiteLinkAtStartChange(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  edSelectedWebsite.Text := func.readConfig('options', 'WebsiteLinkName', '');
  edSelectedScript.Text := func.readConfig('options', 'ExecuteAtStartName', '');
  chkWebsiteLinkAtStart.Checked := func.readConfig('options', 'WebsiteLinkEnabled', False);
  chkStartProgramAtStart.Checked := func.readConfig('options', 'ExecuteAtStartEnabled', False);
  //load website-links
  {LinkList := TStringlist.Create;
  LoadLinkList;
  cbSelectWebsite.Items.Assign(LinkList);
  if cbSelectWebsite.Text = '' then
  begin
    cbSelectWebsite.Text := LinkList[0];
  end;}

  //load script-list
  {ScriptList := TStringlist.Create;
  LoadScriptList;
  cbSelectScriptAtStart.Items.Assign(ScriptList);
  if cbSelectScriptAtStart.Text = '' then
  begin
    cbSelectScriptAtStart.Text := ScriptList[0];
  end;}
end;

//OnChange - Start Countdown automatically
//**********************************************
procedure TfOptionsForm.chkStartCountdownAutomaticallyChange(Sender: TObject);
begin
  func.writeConfig('options', 'StartCountdownAutomatically',
    chkStartCountDownAutomatically.Checked);
end;

//Create Text-File
//***********************************
{
procedure CreateTextFile(Filename: String);
begin
  LinkList.SaveToFile(func.GetOSConfigPath(Filename));
end;
}

//Load WebsiteList
//***********************************************
{
procedure TfOptionsForm.LoadLinkList;
begin
  try
    LinkList.LoadFromFile(GetPathOfFile('ListOfWebsites.txt'));
  except
    LinkList.Add('http://asoftmurmur.com/');
    LinkList.Add('https://www.youtube.com/watch?v=eyU3bRy2x44');
    CreateTextFile('ListOfWebsites.txt');
  end;
end;
}

//Edit WebsiteList
procedure TfOptionsForm.btnEditLinkListClick(Sender: TObject);
begin
  fListEdit.Caption := 'List of Websites';
  fListEdit.StringGrid1.LoadFromCSVFile(func.GetOSConfigPath('ListOfWebsites.csv'),',',false);
  listedit.TEditSelect := edSelectedWebsite;
  listedit.sConfigListPath := 'WebsiteLink';
  listedit.sConfigSelectedItem := 'WebsiteLinkName';
  listedit.sListFilename := 'ListOfWebsites.csv';
  fListEdit.Show;
end;

//Enable LinkList DropDown
procedure TfOptionsForm.chkWebsiteLinkAtStartChange(Sender: TObject);
begin
  edSelectedWebsite.Enabled := chkWebsiteLinkAtStart.Checked;
end;

//Load ScriptList
//**********************************************
{
procedure TfOptionsForm.LoadScriptList;
begin
  try
    ScriptList.LoadFromFile(func.GetOSConfigPath('ListOfScripts.txt'));
  except
    CreateTextFile('ListOfScripts.txt');
  end;
end;
}

//Edit Script List
procedure TfOptionsForm.btnEditScriptListClick(Sender: TObject);
const
  sListFileName : String = 'ListOfPrograms.csv';
begin
  fListEdit.Caption := 'List of executable Programs';
  fListEdit.StringGrid1.LoadFromCSVFile(func.GetOSConfigPath(sListFileName),',',false);
  listedit.TEditSelect := edSelectedScript; //hand over TEdit in Order to give back Selection
  listedit.sConfigListPath := 'ExecuteAtStart';
  listedit.sConfigSelectedItem := 'ExecuteAtStartName';
  listedit.sListFilename := sListFileName;
  fListEdit.Show;
end;

//Enable Script List Dropdown
procedure TfOptionsForm.chkStartProgramAtStartChange(Sender: TObject);
begin
  edSelectedScript.Enabled := chkStartProgramAtStart.Checked;
end;


//Form Close
//**********************************************
procedure TfOptionsForm.FormClose(Sender: TObject);
begin
  func.writeConfig('main', 'OptionsFormLeft', fOptionsForm.Left);
  func.writeConfig('main', 'OptionsFormTop', fOptionsForm.Top);
  func.writeConfig('options', 'WebsiteLinkEnabled', chkWebsiteLinkAtStart.Checked);
  func.writeConfig('options', 'ExecuteAtStartEnabled', chkStartProgramAtStart.Checked);
end;

procedure TfOptionsForm.FormCreate(Sender: TObject);
begin

end;


end.

