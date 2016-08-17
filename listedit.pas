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

unit listedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls,
  Graphics, Dialogs, DBGrids, DbCtrls, StdCtrls, Buttons, Menus, func, Grids;

type

  { TfListEdit }

  TfListEdit = class(TForm)
    btnAdd: TButton;
    btnDeleteRow: TButton;
    btnChoose: TButton;
    StringGrid1: TStringGrid;
    procedure btnAddClick(Sender: TObject);
    procedure btnChooseClick(Sender: TObject);
    procedure btnDeleteRowClick(Sender: TObject);
    procedure StringGrid1KeyUp(Sender: TObject);
    procedure ToggleChooseBtn;
    procedure FormClose(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fListEdit: TfListEdit;
  TEditSelect: TEdit; //Holds edSelectedScript / edSelectedWebsite from Optionsform
  sConfigListPath: String; //e.g. 'www.youtube.com' or 'programfiles/vlc/vlc.exe'
  sConfigSelectedItem: String; //e.g. 'youtube' or 'vlc'
  sListFilename: String; //e.g. 'ListOfWebsites.csv' or 'ListOfPrograms.csv'

resourcestring
  Grid1stColumnCaption = 'Name';
  Grid2ndColumnCaption = 'Path / Address';

implementation

uses
  optionsform;

{$R *.lfm}

{ TfListEdit }

//Form Show
//******************************************************************************
procedure TfListEdit.FormShow(Sender: TObject);
begin
  //if grid is empty:
  if StringGrid1.ColCount = 0 then
  begin
    StringGrid1.Columns.Add;
    StringGrid1.Columns.Add;
    StringGrid1.Columns[1].Width := 500;
  end;

  //If only 1 Row left:
  if StringGrid1.FixedRows > StringGrid1.RowCount - 1 then
    btnDeleteRow.Enabled := False;

  //Rename Column Titles with rescource strings (for translation):
  StringGrid1.Columns[0].Title.Caption := Grid1stColumnCaption;
  StringGrid1.Columns[1].Title.Caption := Grid2ndColumnCaption;
end;

//Add-Button
//******************************************************************************
procedure TfListEdit.btnAddClick(Sender: TObject);
begin
  if not btnDeleteRow.Enabled then
    btnDeleteRow.Enabled := True;
  StringGrid1.InsertColRow(false, 1);
end;

//Choose-Button
//******************************************************************************
procedure TfListEdit.btnChooseClick(Sender: TObject);
var
  sLinkName: String;
  sLinkPath: String;
begin
  //get values from selected row
  sLinkName := StringGrid1.Cells[0, StringGrid1.Row];
  sLinkPath := StringGrid1.Cells[1, StringGrid1.Row];

  //update edit field optionsform
  TEditSelect.Text := sLinkName;
  //Save settings to config
  func.writeConfig('options', sConfigSelectedItem, sLinkName);
  //save path to config
  func.writeConfig('options', sConfigListPath, sLinkPath);

  fListEdit.Close;
end;

//Delete-Button
//******************************************************************************
procedure TfListEdit.btnDeleteRowClick(Sender: TObject);
begin
  if StringGrid1.FixedRows <= StringGrid1.RowCount - 1 then //If only 1 Row left
  begin
    StringGrid1.DeleteRow(StringGrid1.Row);
  end
  else begin
    btnDeleteRow.Enabled := False;
  end;
end;

//Key Up Event
//******************************************************************************
procedure TfListEdit.StringGrid1KeyUp(Sender: TObject);
begin
    ToggleChooseBtn;
end;

//ToogleChoose Button - Deaktivate Choose Button if Path = ''
//******************************************************************************
procedure TfListEdit.ToggleChooseBtn;
begin
  if StringGrid1.Cells[1, StringGrid1.Row] = '' then
  begin
    btnChoose.Enabled := False;
  end
  else begin
    btnChoose.Enabled := True;
  end;
end;

//Form Close
//******************************************************************************
procedure TfListEdit.FormClose(Sender: TObject);
begin
  StringGrid1.SaveToCSVFile(func.GetOsConfigPath(sListFilename), ',', false);
end;


end.

