Unit SettingsHelpForm;

Interface

Uses
    Winapi.Windows,
    Winapi.Messages,
    System.SysUtils,
    System.Variants,
    System.Classes,
    Vcl.Graphics,
    Vcl.Controls,
    Vcl.Forms,
    Vcl.Dialogs,
    Vcl.StdCtrls,
    BackEnd,
    Vcl.ExtCtrls;

Type
    TSettingsHelpF = Class(TForm)
        TextLabel: TLabel;
        BackgroundImage: TImage;
        Procedure FormCreate(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    SettingsHelpF: TSettingsHelpF;

Implementation

{$R *.dfm}

Procedure TSettingsHelpF.FormCreate(Sender: TObject);
Begin
    Width := 550;
    Height := 550;
    LoadSecondImage(BackgroundImage);
End;

End.
