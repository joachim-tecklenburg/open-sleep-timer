unit optionsform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Menus, func, DefaultTranslator;

type

  { TfOptionsForm }

  TfOptionsForm = class(TForm)
    chkStartCountdownAutomatically: TCheckBox;
    MainMenu1: TMainMenu;
    procedure chkStartCountdownAutomaticallyChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fOptionsForm: TfOptionsForm;

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


//Form Close
//**********************************************
procedure TfOptionsForm.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  func.writeConfig('main', 'OptionsFormLeft', fOptionsForm.Left);
  func.writeConfig('main', 'OptionsFormTop', fOptionsForm.Top);
end;


//Form Create
//***********************************************
procedure TfOptionsForm.FormCreate(Sender: TObject);
begin
  chkStartCountDownAutomatically.Checked := func.readConfig('options', 'StartCountdownAutomatically', false);
end;


end.

