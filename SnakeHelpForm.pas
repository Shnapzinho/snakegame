Unit SnakeHelpForm;

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
    TSnakeHelpF = Class(TForm)
        GreenImage: TImage;
        BlueImage: TImage;
        YellowImage: TImage;
        PurpleImage: TImage;
        BackgroundImage: TImage;
        GreenLabel: TLabel;
        BlueLabel: TLabel;
        YellowLabel: TLabel;
        PurpleLabel: TLabel;
        Procedure FormCreate(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    SnakeHelpF: TSnakeHelpF;

Implementation

{$R *.dfm}

Procedure TSnakeHelpF.FormCreate(Sender: TObject);
Begin
    Width := 550;
    Height := 550;
    LoadSecondImage(BackGroundImage);
    GreenImage.Picture.LoadFromFile('green.jpg');
    BlueImage.Picture.LoadFromFile('blue.jpg');
    YellowImage.Picture.LoadFromFile('yellow.jpg');
    PurpleImage.Picture.LoadFromFile('purple.jpg');
End;

End.
