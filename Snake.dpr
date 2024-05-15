program Snake;

uses
  Forms,
  SnakeForm in 'SnakeForm.pas' {SnakeF},
  MainMenu in 'MainMenu.pas' {Menu},
  SettingsForm in 'SettingsForm.pas' {Settings},
  RecordsForm in 'RecordsForm.pas' {RecordsF},
  BackEnd in 'BackEnd.pas',
  SettingsHelpForm in 'SettingsHelpForm.pas' {SettingsHelpF},
  RecordsHelpForm in 'RecordsHelpForm.pas' {RecordsHelpF},
  RulesForm in 'RulesForm.pas' {RulesF},
  SnakeHelpForm in 'SnakeHelpForm.pas' {SnakeHelpF};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMenu, Menu);
  Application.CreateForm(TSettingsHelpF, SettingsHelpF);
  Application.CreateForm(TRecordsHelpF, RecordsHelpF);
  Application.CreateForm(TRulesF, RulesF);
  Application.CreateForm(TSnakeHelpF, SnakeHelpF);
  Application.Run;
end.
