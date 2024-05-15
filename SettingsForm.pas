Unit SettingsForm;

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
    System.UITypes,
    BackEnd,
    Vcl.FileCtrl,
    Vcl.Menus,
    SettingsHelpForm;

Type
    TSettings = Class(TForm)
        HeadColorBox: TColorBox;
        SegmentColorBox: TColorBox;
        DifficultyGroup: TRadioGroup;
        BackColorBox: TColorBox;
        ControlGroup: TRadioGroup;
        BackgroundImage: TImage;
        TextLabel: TLabel;
        HeadLabel: TLabel;
        SegmentLabel: TLabel;
        BackLabel: TLabel;
        MainMenu: TMainMenu;
        N1: TMenuItem;
        HelpButton: TMenuItem;
        Procedure HeadColorBoxSelect(Sender: TObject);
        Procedure SegmentColorBoxSelect(Sender: TObject);
        Procedure FormCreate(Sender: TObject);
        Procedure DifficultyGroupClick(Sender: TObject);
        Procedure BackColorBoxSelect(Sender: TObject);
        Procedure ControlGroupClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure SetOptions;
        Procedure N1Click(Sender: TObject);
        Procedure HelpButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    Settings: TSettings;

Implementation

{$R *.dfm}

Procedure TSettings.HeadColorBoxSelect(Sender: TObject);
Begin
    Options.HeadColor := HeadColorBox.Selected;
End;

Procedure TSettings.N1Click(Sender: TObject);
Begin
    Close;
End;

Procedure TSettings.HelpButtonClick(Sender: TObject);
Begin
    SettingsHelpF := TSettingsHelpF.Create(Self);
    SettingsHelpF.ShowModal;
End;

Procedure TSettings.DifficultyGroupClick(Sender: TObject);
Begin
    Case DifficultyGroup.ItemIndex Of
        0:
            Options.DifficultyLevel := Easy;
        1:
            Options.DifficultyLevel := Hard;
    End;
End;

Procedure TSettings.ControlGroupClick(Sender: TObject);
Begin
    Case ControlGroup.ItemIndex Of
        0:
            Options.UseArrowKeys := False;
        1:
            Options.UseArrowKeys := True;
    End;
End;

Procedure TSettings.SegmentColorBoxSelect(Sender: TObject);
Begin
    Options.SegmentColor := SegmentColorBox.Selected;
End;

//���������� � ����
Procedure SaveSettings;
Var
    SettingsFile: TextFile;
Begin
    AssignFile(SettingsFile, 'settings.txt');
    Rewrite(SettingsFile);
    Try
        WriteLn(SettingsFile, Options.HeadColor);
        WriteLn(SettingsFile, Options.SegmentColor);
        WriteLn(SettingsFile, Options.BackColor);
        WriteLn(SettingsFile, Integer(Options.DifficultyLevel));
        WriteLn(SettingsFile, Options.UseArrowKeys);
    Finally
        CloseFile(SettingsFile);
    End;
End;

//���������� �� �����
Procedure LoadSettings;
Var
    SettingsFile: TextFile;
    HeadColor, SegmentColor, BackColor, Difficulty, Control: String;
Begin
    If FileExists('settings.txt') Then
    Begin
        AssignFile(SettingsFile, 'settings.txt');
        Reset(SettingsFile);
        Try
            ReadLn(SettingsFile, HeadColor);
            Options.HeadColor := StrToInt(HeadColor);
            ReadLn(SettingsFile, SegmentColor);
            Options.SegmentColor := StrToInt(SegmentColor);
            ReadLn(SettingsFile, BackColor);
            Options.BackColor := StrToInt(BackColor);
            ReadLn(SettingsFile, Difficulty);
            Options.DifficultyLevel := TDifficultyLevel(StrToInt(Difficulty));
            ReadLn(SettingsFile, Control);
            Options.UseArrowKeys := StrToBool(Control);
        Finally
            CloseFile(SettingsFile);
        End;
    End;
End;

Procedure TSettings.BackColorBoxSelect(Sender: TObject);
Begin
    Options.BackColor := BackColorBox.Selected;
End;

Procedure TSettings.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Begin
    SaveSettings;
End;

//������� ��������
Procedure TSettings.SetOptions;
Begin
    HeadColorBox.Selected := TColor(Options.HeadColor);
    SegmentColorBox.Selected := TColor(Options.SegmentColor);
    BackColorBox.Selected := TColor(Options.BackColor);
    Case Options.DifficultyLevel Of
        Easy:
            DifficultyGroup.ItemIndex := 0;
        Hard:
            DifficultyGroup.ItemIndex := 1;
    End;
    If Options.UseArrowKeys Then
        ControlGroup.ItemIndex := 1
    Else
        ControlGroup.ItemIndex := 0;
End;

Procedure TSettings.FormCreate(Sender: TObject);
Begin
    Width := 800;
    Height := 800;
    LoadSettings;
    LoadSecondImage(BackgroundImage);
    HeadColorBox.Items.Clear;
    SegmentColorBox.Items.Clear;
    BackColorBox.Items.Clear;

    HeadColorBox.Items.AddObject('�������', TObject(ClRed));
    HeadColorBox.Items.AddObject('�����-�������', TObject(ClMaroon));
    HeadColorBox.Items.AddObject('�������', TObject(ClFuchsia));
    HeadColorBox.Items.AddObject('����', TObject(ClLime));
    HeadColorBox.Items.AddObject('�����', TObject(ClWhite));
    HeadColorBox.Items.AddObject('�����', TObject(ClGray));
    HeadColorBox.Items.AddObject('������-�����', TObject(ClSilver));
    HeadColorBox.Items.AddObject('�������', TObject(ClSkyBlue));

    SegmentColorBox.Items.AddObject('�������', TObject(ClRed));
    SegmentColorBox.Items.AddObject('�����-�������', TObject(ClMaroon));
    SegmentColorBox.Items.AddObject('�������', TObject(ClFuchsia));
    SegmentColorBox.Items.AddObject('����', TObject(ClLime));
    SegmentColorBox.Items.AddObject('�����', TObject(ClWhite));
    SegmentColorBox.Items.AddObject('�����', TObject(ClGray));
    SegmentColorBox.Items.AddObject('������-�����', TObject(ClSilver));
    SegmentColorBox.Items.AddObject('�������', TObject(ClSkyBlue));

    BackColorBox.Items.AddObject('������-���������', TObject(ClMoneyGreen));
    BackColorBox.Items.AddObject('������', TObject(ClBlack));
    BackColorBox.Items.AddObject('������-�������', TObject(ClGradientInactiveCaption));

    SetOptions
End;

End.
