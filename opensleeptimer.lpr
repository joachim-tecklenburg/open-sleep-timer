program opensleeptimer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, runtimetypeinfocontrols, lazcontrols, tachartlazaruspkg, sdflaz,
  mainform, VolumeControl, popup, optionsform, func, about, listedit
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfMainform, fMainform);
  Application.CreateForm(TfPopUp, fPopUp);
  Application.CreateForm(TfOptionsForm, fOptionsForm);
  Application.CreateForm(TfAbout, fAbout);
  Application.CreateForm(TfListEdit, fListEdit);
  Application.Run;
end.

