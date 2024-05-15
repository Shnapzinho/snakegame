Unit RecordsHelpForm;

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
    Vcl.ExtCtrls,
    BackEnd,
    Vcl.StdCtrls;

Type
    TRecordsHelpF = Class(TForm)
        BackgroundImage: TImage;
        TextLabel: TLabel;
        Procedure FormCreate(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    RecordsHelpF: TRecordsHelpF;

Implementation

{$R *.dfm}

Procedure TRecordsHelpF.FormCreate(Sender: TObject);
Begin
    Width := 550;
    Height := 550;
    LoadSecondImage(BackgroundImage);
End;

End.
