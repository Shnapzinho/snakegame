Unit RulesForm;

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
    Vcl.ExtCtrls,
    BackEnd;

Type
    TRulesF = Class(TForm)
        RulesLabel: TLabel;
        TextLabel: TLabel;
        BackgroundImage: TImage;
        Procedure FormCreate(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    RulesF: TRulesF;

Implementation

{$R *.dfm}

Procedure TRulesF.FormCreate(Sender: TObject);
Begin
    Width := 800;
    Height := 800;
    LoadSecondImage(BackgroundImage);
End;

End.
