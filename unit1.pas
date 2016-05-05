unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, func;

type

  { TForm1 }

  TForm1 = class(TForm)
    chkStartCountdownAutomatically: TCheckBox;
    procedure chkStartCountdownAutomaticallyChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.chkStartCountdownAutomaticallyChange(Sender: TObject);
begin
  //iniConfigFile.WriteBool('options', 'StartCountdownAutomatically', chkStartCountDownAutomatically.State);
end;

end.

