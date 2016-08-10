unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DefaultTranslator, Menus, ECLink;

type

  { TfAbout }

  TfAbout = class(TForm)
    ECLink1: TECLink;
    LinkToIcons8: TECLink;
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

