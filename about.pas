unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ECLink, DefaultTranslator;

type

  { TfAbout }

  TfAbout = class(TForm)
    Label1: TLabel;
    lnkWebsite: TECLink;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fAbout: TfAbout;

implementation

{$R *.lfm}

end.

