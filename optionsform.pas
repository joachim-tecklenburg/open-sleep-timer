unit optionsform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Menus, func, DefaultTranslator, lclintf;

type

  { TfOptionsForm }

  TfOptionsForm = class(TForm)
    btnEditLinkList: TButton;
    chkWebsiteLinkAtStart: TCheckBox;
    chkStartCountdownAutomatically: TCheckBox;
    cbSelectWebsite: TComboBox;
    MainMenu1: TMainMenu;
    procedure btnEditLinkListClick(Sender: TObject);
    procedure chkStartCountdownAutomaticallyChange(Sender: TObject);
    procedure chkWebsiteLinkAtStartChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
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

//OnChange - Start Countdown automatically
//**********************************************
procedure TfOptionsForm.chkStartCountdownAutomaticallyChange(Sender: TObject);
begin
  func.writeConfig('options', 'StartCountdownAutomatically',
    chkStartCountDownAutomatically.Checked);
end;

procedure TfOptionsForm.btnEditLinkListClick(Sender: TObject);
begin
  OpenDocument(GetAppConfigDir(False)+'\ListOfWebsites.txt');
end;

procedure TfOptionsForm.chkWebsiteLinkAtStartChange(Sender: TObject);
begin
  cbSelectWebsite.Enabled := chkWebsiteLinkAtStart.Checked;
end;


//Form Close
//**********************************************
procedure TfOptionsForm.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  func.writeConfig('main', 'OptionsFormLeft', fOptionsForm.Left);
  func.writeConfig('main', 'OptionsFormTop', fOptionsForm.Top);
  func.writeConfig('options', 'WebsiteLink', cbSelectWebsite.Text);
end;


//Form Create
//***********************************************
procedure TfOptionsForm.FormCreate(Sender: TObject);
begin
  chkStartCountDownAutomatically.Checked :=
    func.readConfig('options', 'StartCountdownAutomatically', false);
  cbSelectWebsite.Text := func.readConfig('options', 'WebsiteLink', '');
  linklist := TStringlist.Create;
  LoadLinkList;
  cbSelectWebsite.Items.Assign(linklist);
  if cbSelectWebsite.Text = '' then
  begin
    cbSelectWebsite.Text := linklist[0];
  end;
end;

//Load LinkList
//***********************************************
procedure TfOptionsForm.LoadLinkList;
var
  linklist: TStringList;
begin
  try
    linklist.LoadFromFile(GetAppConfigDir(False)+'\ListOfWebsites.txt');
  except
    linklist.Add('http://asoftmurmur.com/');
    linklist.Add('https://www.youtube.com/watch?v=eyU3bRy2x44');
    linklist.SaveToFile(GetAppConfigDir(False)+'\ListOfWebsites.txt');
  end;
end;


end.

