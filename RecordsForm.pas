Unit RecordsForm;

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
    Vcl.Grids,
    BackEnd,
    Vcl.StdCtrls,
    Vcl.Menus,
    Vcl.ExtCtrls,
    RecordsHelpForm;

Type
    TRecordsF = Class(TForm)
        RecordGrid: TStringGrid;
        TextLabel: TLabel;
        MainMenu: TMainMenu;
        FileButton: TMenuItem;
        OpenButton: TMenuItem;
        SaveButton: TMenuItem;
        ExitButton: TMenuItem;
        OpenDialog: TOpenDialog;
        SaveDialog: TSaveDialog;
        BackgroundImage: TImage;
        HelpButton: TMenuItem;
        Procedure FormCreate(Sender: TObject);
        Procedure OpenButtonClick(Sender: TObject);
        Procedure FillGrid(Score: Records);
        Procedure SaveButtonClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure ExitButtonClick(Sender: TObject);
        Procedure HelpButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    RecordsF: TRecordsF;
    Score: Records;

Implementation

{$R *.dfm}

//очищение
Procedure ClearStringGrid(Grid: TStringGrid);
Var
    I, J: Integer;
Begin
    For I := 1 To Grid.RowCount - 1 Do
        For J := 0 To Grid.ColCount - 1 Do
            Grid.Cells[J, I] := '';
    Grid.RowCount := 0;
End;

Procedure TRecordsF.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Begin
    FreeList(Score);
End;

Procedure TRecordsF.FormCreate(Sender: TObject);
Begin
    Width := 800;
    Height := 800;
    LoadSecondImage(BackgroundImage);
    If GlobalScore <> Nil Then
    Begin
        FillGrid(GlobalScore);
    End;
End;

Procedure TRecordsF.HelpButtonClick(Sender: TObject);
Begin
    RecordsHelpF := TRecordsHelpF.Create(Self);
    RecordsHelpF.ShowModal;
End;

Procedure TRecordsF.ExitButtonClick(Sender: TObject);
Begin
    Close;
End;

//заполнение
Procedure TRecordsF.FillGrid(Score: Records);
Var
    CurrentRecord: Records;
    RowIndex, NewHeight, I, Size: Integer;
Begin
    ClearStringGrid(RecordGrid);
    RecordGrid.Visible := True;
    Size := Len(Score);
    If Size > 5 Then
    Begin
        RecordGrid.Width := (RecordGrid.DefaultColWidth + 3) * 2 + 25;
        RecordGrid.Height := (RecordGrid.DefaultRowHeight + 3) * 5;
    End
    Else
    Begin
        RecordGrid.Width := (RecordGrid.DefaultColWidth + 3) * 2;
        RecordGrid.Height := (RecordGrid.DefaultRowHeight + 4) * Size;
    End;
    RecordGrid.ColCount := 2;
    RecordGrid.RowCount := Size;
    CurrentRecord := Score;
    For I := 0 To Size - 1 Do
    Begin
        RecordGrid.Cells[0, I] := CurrentRecord^.Username;
        RecordGrid.Cells[1, I] := IntToStr(CurrentRecord^.Score);
        CurrentRecord := CurrentRecord^.Next;
    End;
    SaveButton.Enabled := True;
End;

//проверка данных
Function ReadOneFromFile(Var Numb: Integer; Var MyFile: TextFile; IsElemRead: Boolean = True): ERRORS_CODE;
Var
    Err: ERRORS_CODE;
    NumbInt: Integer;
    NumbStr: String;
Begin
    Err := SUCCESS;
    NumbInt := 0;
    Try
        Read(MyFile, NumbInt);
    Except
        Err := INCORRECT_DATA_FILE;
    End;
    If Err = SUCCESS Then
        If IsElemRead Then
            If (NumbInt > MAX_NUMB) Or (NumbInt < MIN_NUMB) Then
                Err := OUT_OF_BORDER
            Else
                Numb := NumbInt
        Else
            If (NumbInt > MAX_SIZE) Or (NumbInt < MIN_SIZE) Then
                Err := OUT_OF_BORDER_SIZE
            Else
                Numb := NumbInt;
    ReadOneFromFile := Err;
End;

//открытие из файла
Procedure TRecordsF.OpenButtonClick(Sender: TObject);
Var
    FileName: String;
    FileStatus: TFileStatus;
    Size: Integer;
Begin
    If OpenDialog.Execute() Then
    Begin
        FileName := OpenDialog.FileName;
        FileStatus := CheckFile(FileName);
        If FileStatus = FsGood Then
        Begin
            Size := ReadSize(Filename, FileStatus);
            If FileStatus = FsGood Then
            Begin
                GlobalScore := ReadList(FileName, Size, FileStatus);
                If FileStatus = FsGood Then
                    FillGrid(GlobalScore)
                Else
                    MessageBox(Self.Handle, ListOfMessages[FileStatus], 'Ошибка', MB_ICONERROR);
            End
            Else
                MessageBox(Self.Handle, ListOfMessages[FileStatus], 'Ошибка', MB_ICONERROR);
        End
        Else
            MessageBox(Self.Handle, ListOfMessages[FileStatus], 'Ошибка', MB_ICONERROR);
    End;
End;

//сохранение в файл
Procedure TRecordsF.SaveButtonClick(Sender: TObject);
Var
    OutFile: TextFile;
    I, J: Integer;
Begin
    If SaveDialog.Execute() Then
    Begin
        AssignFile(OutFile, SaveDialog.FileName);
        Rewrite(OutFile);

        Writeln(OutFile, 'Таблица рекордов');
        For I := 0 To RecordGrid.ColCount - 1 Do
        Begin
            Writeln(OutFile, RecordGrid.Cells[0, I] + ' ' + RecordGrid.Cells[1, I]);
        End;

        CloseFile(OutFile);
    End;
End;

End.
