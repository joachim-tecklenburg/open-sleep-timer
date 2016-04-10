unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, VolumeControl;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    btnStart: TButton;
    Edit1: TEdit;
    TrackBar1: TTrackBar;
    procedure btnStartClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
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

procedure TForm1.Button1Click(Sender: TObject);
var
  dVolume: double;
begin
  dVolume := StrToFloat(Edit1.Text) / 100;
  VolumeControl.Setmastervolume(dVolume);
end;

procedure TForm1.btnStartClick(Sender: TObject);
begin
  //Loop until time is over
  //read current audio volume from system
    ShowMessage(FloatToStr(VolumeControl.GetMasterVolume()));
  //calculate steps for volume reduction
  //Decrease audio volume one step
  //sleep one minute


end;

procedure TForm1.FormShow(Sender: TObject);
begin
 Trackbar1.Max:=100;
 Trackbar1.Min:=0;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Edit1.Text := IntToStr(TrackBar1.Position);
end;

end.

