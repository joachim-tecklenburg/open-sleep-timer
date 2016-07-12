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
    chkWebsiteLinkAtStart: TCheckBox;
    chkStartCountdownAutomatically: TCheckBox;
    cbSelectWebsite: TComboBox;
    procedure btnEditLinkListClick(Sender: TObject);
    procedure chkStartCountdownAutomaticallyChange(Sender: TObject);
    procedure chkWebsiteLinkAtStartChange(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LoadLinkList;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fOptionsForm: TfOptionsForm;
  linklist: TStringlist;

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
  linklist := TStringlist.Create;
  LoadLinkList;
  cbSelectWebsite.Items.Assign(linklist);
  if cbSelectWebsite.Text = '' then
  begin
    cbSelectWebsite.Text := linklist[0];
  end;
end;

//OnChange - Start Countdown automatically
//**********************************************
procedure TfOptionsForm.chkStartCountdownAutomaticallyChange(Sender: TObject);
begin
  func.writeConfig('options', 'StartCountdownAutomatically',
    chkStartCountDownAutomatically.Checked);
end;


//Get Path: ListOfWebsites.txt
//*******************************
function GetPathListOfWebsitesTXT():String;
begin
  Result := WinCPToUTF8(GetAppConfigDir(False))+'ListOfWebsites.txt';
end;

//Create ListOfWebsites.txt
//***********************************
procedure CreateListOfWebsitesTXT;
begin
  linklist.Add('http://asoftmurmur.com/');
  linklist.Add('https://www.youtube.com/watch?v=eyU3bRy2x44');
  //FileCreate(GetPathListOfWebsitesTXT());
  //FileClose(GetPathListOfWebsitesTXT());
  linklist.SaveToFile(GetPathListOfWebsitesTXT());
end;

//Load LinkList
//***********************************************
procedure TfOptionsForm.LoadLinkList;
begin
  try
    linklist.LoadFromFile(GetPathListOfWebsitesTXT);
  except
    CreateListOfWebsitesTXT;
  end;
end;

//Edit LinkList
procedure TfOptionsForm.btnEditLinkListClick(Sender: TObject);
begin
  OpenDocument(GetPathListOfWebsitesTXT);
end;

//Enable LinkList DropDown
procedure TfOptionsForm.chkWebsiteLinkAtStartChange(Sender: TObject);
begin
  cbSelectWebsite.Enabled := chkWebsiteLinkAtStart.Checked;
end;


//Form Close
//**********************************************
procedure TfOptionsForm.FormClose(Sender: TObject);
begin
  func.writeConfig('main', 'OptionsFormLeft', fOptionsForm.Left);
  func.writeConfig('main', 'OptionsFormTop', fOptionsForm.Top);
  func.writeConfig('options', 'WebsiteLink', cbSelectWebsite.Text);
end;


end.

