Unit BackEnd;

Interface

Uses
    System.UITypes,
    SysUtils,
    Vcl.ExtCtrls;

Type
    TDifficultyLevel = (Easy, Hard);
    ERRORS_CODE = (SUCCESS, INCORRECT_DATA_FILE, A_LOT_OF_DATA_FILE, OUT_OF_BORDER, OUT_OF_BORDER_SIZE);
    TFileStatus = (FsGood, FsNotFound, FsNotTxt, FsNotReadable, FsNotWritable, FsEmpty, FsWrongData, FsUnexpected);
    TArrayOfMessages = Array [TFileStatus] Of PWideChar;

    Records = ^TRecord;

    TRecord = Record
        Username: String;
        Score: Integer;
        Next: Records;
    End;

    TOptions = Record
        HeadColor: TColor;
        SegmentColor: TColor;
        BackColor: TColor;
        DifficultyLevel: TDifficultyLevel;
        UseArrowKeys: Boolean;
    End;

Procedure AddNewScore(Var ScoreList: Records; Username: String; ScoreValue: Integer);
Procedure UpdateScore(Var ScoreList: Records; Username: String; ScoreValue: Integer);
Function Len(List: Records): Integer;
Procedure FreeList(Var List: Records);
Function IsFileTxt(Var FileName: String): Boolean;
Function CheckFile(FileName: String): TFileStatus;
Function ReadList(FileName: String; Const SIZE: Integer; Var FileStatus: TFileStatus): Records;
Function ReadSize(FileName: String; Var FileStatus: TFileStatus): Integer;
Procedure LoadImage(Image: TImage);
Procedure LoadSecondImage(Image: TImage);

Const
    MIN_NUMB = 1;
    MAX_NUMB = 99999;
    MIN_SIZE = 1;
    MAX_SIZE = 99999;

Var
    GlobalName: String;
    Image: TImage;
    GlobalScore: Records;
    Options: TOptions;
    ERRORS: Array [ERRORS_CODE] Of String = (
        'Successfull',
        'Данные в файле некорректные',
        'В файле неверное количество элементов или стоит лишний пробел',
        'Числа должны быть в диапазоне [0, 100000]',
        'Размер должен быть в диапазоне [1, 6]'
    );

    ListOfMessages: TArrayOfMessages = ('Информация записана!', 'Файл не найден! Повторите ещё раз.',
        'Файл не текстовый! Повторите ещё раз.', 'Файл не доступен для чтения! Повторите ещё раз.',
        'Файл не доступен для записи! Повторите ещё раз.', 'Файл пустой! Повторите ещё раз.', 'Неверные данные в файле! Повторите ещё раз.',
        'Что-то пошло не так. Потворите ещё раз.');

Implementation

Procedure UpdateScore(Var ScoreList: Records; Username: String; ScoreValue: Integer);
Var
    UserExists: Boolean;
    Curr: Records;
Begin
    UserExists := False;
    Curr := ScoreList;
    //проверяем, существует ли пользователь в списке
    While (Curr <> Nil) And (Not UserExists) Do
    Begin
        Begin
            If Curr^.Username = Username Then
            Begin
                //если пользователь найден, обновляем его результат
                UserExists := True;
                If ScoreValue > Curr^.Score Then
                    Curr^.Score := ScoreValue;
            End;
        End;
        Curr := Curr^.Next;
    End;
    //если пользователь не найден, добавляем его в список
    If Not UserExists Then
        AddNewScore(ScoreList, Username, ScoreValue);
End;

Procedure AddNewScore(Var ScoreList: Records; Username: String; ScoreValue: Integer);
Var
    NewRecord: Records;
    CurrentRecord: Records;
    PreviousRecord: Records;
Begin
    New(NewRecord);
    NewRecord^.Username := Username;
    NewRecord^.Score := ScoreValue;
    NewRecord^.Next := Nil;
    If ScoreList = Nil Then
    Begin
        ScoreList := NewRecord;
        Exit;
    End;
    CurrentRecord := ScoreList;
    PreviousRecord := Nil;
    While (CurrentRecord <> Nil) And (ScoreValue <= CurrentRecord^.Score) Do
    Begin
        PreviousRecord := CurrentRecord;
        CurrentRecord := CurrentRecord^.Next;
    End;
    NewRecord^.Next := CurrentRecord;
    If PreviousRecord <> Nil Then
        PreviousRecord^.Next := NewRecord
    Else
        ScoreList := NewRecord;
End;

//подсчет длины списка
Function Len(List: Records): Integer;
Var
    Length: Integer;
Begin
    Length := 0;
    While List <> Nil Do
    Begin
        Inc(Length);
        List := List^.Next;
    End;
    Len := Length;
End;

//очитска списка
Procedure FreeList(Var List: Records);
Var
    Temp: Records;
Begin
    While List <> Nil Do
    Begin
        Temp := List;
        List := List^.Next;
        Dispose(Temp);
    End;
End;

//является ли файл текстовым
Function IsFileTxt(Var FileName: String): Boolean;
Var
    FileType: String;
    Status: Boolean;
Begin
    FileType := Copy(FileName, Length(FileName) - 3, 4);
    If FileType = '.txt' Then
        Status := True
    Else
        Status := False;
    IsFileTxt := Status;
End;

//доступен ли файл для чтения
Function IsFileReadable(Var FileName: String): Boolean;
Var
    Status: Boolean;
    InFIle: TextFile;
Begin
    Try
        Assign(InFile, FileName);
        Reset(InFile);
        Status := True;
    Except
        Status := False;
    End;
    CloseFile(InFile);
    IsFileReadable := Status;
End;

//проверяем не является ли файл пустым
Function IsEmpty(FileName: String): Boolean;
Var
    Status: Boolean;
    InFIle: TextFile;
Begin
    Try
        Assign(InFile, FileName);
        Reset(InFile);
        Status := Eof(InFile);
        CloseFile(InFile);
    Except
    End;
    IsEmpty := Status;
End;

//проверка файла
Function CheckFile(FileName: String): TFileStatus;
Var
    FileStatus: TFileStatus;
Begin
    If Not FileExists(FileName) Then
        FileStatus := FsNotFound
    Else
        If Not IsFileTxt(FileName) Then
            FileStatus := FsNotTxt
        Else
            If Not IsFileReadable(FileName) Then
                FileStatus := FsNotReadable
            Else
                If IsEmpty(FileName) Then
                    FileStatus := FsEmpty
                Else
                    FileStatus := FsGood;
    CheckFile := FileStatus;
End;

//считывание таблицы рекордов
Function ReadList(FileName: String; Const SIZE: Integer; Var FileStatus: TFileStatus): Records;
Var
    List: Records;
    I: Integer;
    Score: Integer;
    InFile: TextFile;
    UserName: String;
Begin
    List := Nil;
    Try
        Assign(InFile, FileName);
        ReSet(InFile);
        For I := 1 To Size Do
        Begin
            If EOF(InFile) Then
            Begin
                FileStatus := FsWrongData;
            End;
            Readln(InFile, UserName, Score);
            If Not(Trim(UserName) = '') Then
            Begin
                If (Score <> 0) And (Score Mod 100 = 0) Then
                    UpdateScore(List, UserName, Score)
                Else
                    FileStatus := FsWrongData;
            End
            Else
                FileStatus := FsWrongData;
        End;
        CloseFile(InFile);
    Except
        FileStatus := FsUnexpected;
    End;
    ReadList := List;
End;

//считывание размера данных из таблицы
Function ReadSize(FileName: String; Var FileStatus: TFileStatus): Integer;
Var
    InFile: TextFile;
    CurrentLine: String;
    Size, Divisor: Integer;
Begin
    Divisor := 2;
    Size := 0;
    Try
        AssignFile(InFile, FileName);
        Reset(InFile);
        While Not EOF(InFile) Do
        Begin
            Readln(InFile, CurrentLine);
            Inc(Size);
        End;
        CloseFile(InFile);
    Except
        FileStatus := FsUnexpected;
    End;
    Size := Size Div Divisor;
    If Size < 1 Then
        FileStatus := FsWrongData;
    ReadSize := Size;
End;

Procedure LoadImage(Image: TImage);
Begin
    Image.Picture.LoadFromFile('background.jpg');
    Image.SendToBack;
End;

Procedure LoadSecondImage(Image: TImage);
Begin
    Image.Picture.LoadFromFile('background2.jpg');
    Image.SendToBack;
End;

End.
