Unit MainMenu;

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
    Vcl.Buttons,
    SnakeForm,
    Vcl.Imaging.Jpeg,
    Vcl.ExtCtrls,
    SettingsForm,
    RecordsForm,
    Vcl.StdCtrls,
    BackEnd,
    Vcl.Menus,
    RulesForm;

Type
    TMenu = Class(TForm)
        GameButton: TSpeedButton;
        RecordsButton: TSpeedButton;
        SettingsButton: TSpeedButton;
        BackgroundImage: TImage;
        RulesButton: TSpeedButton;
        NameEdit: TEdit;
        NameButton: TButton;
        NameLabel: TLabel;
        ExitButton: TSpeedButton;
        TextLabel: TLabel;
        MainMenu: TMainMenu;
        DeveloperButton: TMenuItem;
        Procedure GameButtonClick(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure SettingsButtonClick(Sender: TObject);
        Procedure NameButtonClick(Sender: TObject);
        Procedure RecordsButtonClick(Sender: TObject);
        Procedure ShowMenu;
        Procedure NameEditChange(Sender: TObject);
        Procedure ExitButtonClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure RulesButtonClick(Sender: TObject);
        Procedure NameEditKeyPress(Sender: TObject; Var Key: Char);
        Procedure DeveloperButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    Menu: TMenu;

Implementation

{$R *.dfm}

Procedure TMenu.DeveloperButtonClick(Sender: TObject);
Begin
    Application.MessageBox('Разработчик: Студент Владислав ' + #13#10 + 'Студент группы 351004', 'Информация о разработчике',
        MB_ICONINFORMATION Or MB_OK);
End;

Procedure TMenu.ExitButtonClick(Sender: TObject);
Begin
    Close;
End;

Procedure TMenu.FormCloseQuery(Sender: TObject;

    Var CanClose: Boolean);
Begin
    If Application.MessageBox('Вы уверены, что хотите выйти?', 'Подтверждение', MB_ICONQUESTION Or MB_YESNO) = IDNO Then
        CanClose := False
    Else
    Begin
        If GlobalScore <> Nil Then
            FreeList(GlobalScore);
        CanClose := True;
    End;
End;

Procedure TMenu.FormCreate(Sender: TObject);
Begin
    Width := 800;
    Height := 800;
    LoadImage(BackgroundImage);
End;

Procedure TMenu.NameButtonClick(Sender: TObject);
Begin
    GlobalName := NameEdit.Text;
    GameButton.Enabled := True;
    RecordsButton.Enabled := True;
    SettingsButton.Enabled := True;
End;

Procedure TMenu.NameEditChange(Sender: TObject);
Begin
    NameButton.Enabled := (NameEdit.Text <> '');
End;

Procedure TMenu.NameEditKeyPress(Sender: TObject; Var Key: Char);
Begin
    If Key = ' ' Then
        Key := #0;
End;

Procedure TMenu.GameButtonClick(Sender: TObject);
Begin
    SnakeF := TSnakeF.Create(Self);
    SnakeF.ShowModal;
End;

Procedure TMenu.RecordsButtonClick(Sender: TObject);
Begin
    RecordsF := TRecordsF.Create(Self);
    RecordsF.ShowModal;
End;

Procedure TMenu.RulesButtonClick(Sender: TObject);
Begin
    RulesF := TRulesF.Create(Self);
    RulesF.ShowModal;
End;

Procedure TMenu.SettingsButtonClick(Sender: TObject);
Begin
    Settings := TSettings.Create(Self);
    Settings.ShowModal;
End;

Procedure TMenu.ShowMenu;
Begin
    Show;
End;

End.
