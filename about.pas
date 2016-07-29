unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, DefaultTranslator;

type

  { TfAbout }

  TfAbout = class(TForm)
    Label1: TLabel;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fAbout: TfAbout;

implementation

{$R *.lfm}

{ TfAbout }

end.

