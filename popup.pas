{ Open Sleep Timer

  Copyright (c) 2016 Joachim Tecklenburg

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
}

unit popup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, func, DefaultTranslator, Types;

type

  { TfPopUp }

  TfPopUp = class(TForm)
    bntRestoreVolume: TButton;
    lblQuestion: TLabel;
    procedure bntRestoreVolumeClick(Sender: TObject);
    procedure FormClose(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fPopUp: TfPopUp;

implementation

uses
  mainform;  //to avoid circular reference, "mainform" is referenced from here

{$R *.lfm}

{ TfPopUp }

//OK Button
//******************************************************
procedure TfPopUp.bntRestoreVolumeClick(Sender: TObject);
begin
  fMainform.tbCurrentVolume.Position := Round(mainform.dVolumeLevelAtStart * 100);
  fPopUp.Close;
end;


//Form Close
//*******************************************************
procedure TfPopUp.FormClose(Sender: TObject);
begin
  func.writeConfig('main', 'PopUpLeft', fPopUp.Left);
  func.writeConfig('main', 'PopUpTop', fPopUp.Top);
end;


end.

