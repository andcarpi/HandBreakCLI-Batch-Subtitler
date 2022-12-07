program Encoder;

uses
  Vcl.Forms,
  untPrincipal in 'untPrincipal.pas' {frmPrincipal},
  untEncodeThread in 'untEncodeThread.pas',
  untConfiguracoes in 'untConfiguracoes.pas' {frmConfiguracoes},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Glossy');
  Application.Title := 'AcervoCursos - Encoder de Legenda';
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmConfiguracoes, frmConfiguracoes);
  Application.Run;
end.
