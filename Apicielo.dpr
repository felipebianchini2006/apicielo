program Apicielo;

uses
  Vcl.Forms,
  uMain in 'src\uMain.pas' {frmMain},
  uCieloConfig in 'src\uCieloConfig.pas',
  uCieloApi in 'src\uCieloApi.pas',
  uCieloInterpreter in 'src\uCieloInterpreter.pas',
  uLogger in 'src\uLogger.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
