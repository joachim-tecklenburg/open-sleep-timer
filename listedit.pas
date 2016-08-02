unit listedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, SdfData, FileUtil, RTTICtrls, Forms, Controls,
  Graphics, Dialogs, DBGrids, DbCtrls, StdCtrls, Buttons, ButtonPanel, Menus, func, Grids;

type

  { TfListEdit }

  TfListEdit = class(TForm)
    btnAdd: TButton;
    btnDeleteRow: TButton;
    btnChoose: TButton;
    DataSource1: TDataSource;
    DBGrid2: TDBGrid;
    SdfDataSet1: TSdfDataSet;
    StringGrid1: TStringGrid;
    procedure btnAddClick(Sender: TObject);
    procedure btnChooseClick(Sender: TObject);
    procedure btnDeleteRowClick(Sender: TObject);
    procedure DBGrid2ColEnter(Sender: TObject);
    procedure DBGrid2KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ToggleChooseBtn;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fListEdit: TfListEdit;
  TEditSelect: TEdit;
  sConfigListPath: String; //e.g. 'www.youtube.com' or 'programfiles/vlc/vlc.exe'
  sConfigSelectedItem: String; //e.g. 'youtube' or 'vlc'
  sListFilename: String; //e.g. 'ListOfWebsites.csv' or 'ListOfPrograms.csv'

implementation

uses
  optionsform;

{$R *.lfm}

{ TfListEdit }

procedure TfListEdit.FormShow(Sender: TObject);
begin
  sdfDataSet1.Open;
  DBGrid2.Refresh;
  //DBGrid2.LoadFromCSVFile('WebsiteList.csv', ',', True);
  if StringGrid1.ColCount = 0 then
  begin
    StringGrid1.Columns.Add;
    StringGrid1.Columns.Add;
    StringGrid1.Cols[0].Text := 'Name';
  end;
end;

procedure TfListEdit.btnAddClick(Sender: TObject);
begin
  SdfDataSet1.Append;
  if not btnDeleteRow.Enabled then
    btnDeleteRow.Enabled := True;
  StringGrid1.InsertColRow(false, 1);
end;

procedure TfListEdit.btnChooseClick(Sender: TObject);
var
  sLinkName: String;
  sLinkPath: String;
begin
  sLinkName := SdfDataSet1.FieldByName('Name').AsString;
  sLinkPath := SdfDataSet1.FieldByName('Path').AsString;

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

procedure TfListEdit.btnDeleteRowClick(Sender: TObject);
begin
  if not SdfDataSet1.IsEmpty then
  begin
    SdfDataSet1.Delete;
  end
  else begin
    btnDeleteRow.Enabled := False;
  end;

  if StringGrid1.RowCount <=1 then
  begin
    StringGrid1.DeleteRow(StringGrid1.Row);
  end
  else begin
    btnDeleteRow.Enabled := False;
  end;
end;

procedure TfListEdit.DBGrid2ColEnter(Sender: TObject);
begin

end;

procedure TfListEdit.DBGrid2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ToggleChooseBtn;
end;

procedure TfListEdit.ToggleChooseBtn;
begin
if SdfDataSet1.FieldByName('Path').AsString = '' then
begin
  btnChoose.Enabled := False;
end
else begin
  btnChoose.Enabled := True;
end;
end;


procedure TfListEdit.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //SdfDataSet1.Post;
  SdfDataSet1.Close;
  //SdfDataSet1.Free;
  StringGrid1.SaveToCSVFile(func.GetOsConfigPath(sListFilename), ',', false);
end;


end.

