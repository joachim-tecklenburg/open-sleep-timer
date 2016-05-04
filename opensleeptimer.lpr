program opensleeptimer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, runtimetypeinfocontrols, mainform, VolumeControl, popup,
  programoptions, Unit1
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfMainform, fMainform);
  Application.CreateForm(TfPopUp, fPopUp);
  Application.CreateForm(TfOptions, fOptions);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

