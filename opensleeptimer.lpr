program opensleeptimer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, runtimetypeinfocontrols, lazcontrols, tachartlazaruspkg, mainform,
  VolumeControl, popup, optionsform, func
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfMainform, fMainform);
  Application.CreateForm(TfPopUp, fPopUp);
  Application.CreateForm(TfOptionsForm, fOptionsForm);
  Application.Run;
end.

