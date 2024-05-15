Unit SnakeForm;

Interface

Uses
    Windows,
    Messages,
    SysUtils,
    Variants,
    Classes,
    Graphics,
    Controls,
    Forms,
    Dialogs,
    Menus,
    ExtCtrls,
    StdCtrls,
    BackEnd,
    System.UITypes,
    SnakeHelpForm;

Type
    TSnakeDirection = (SdUp, SdDown, SdLeft, SdRight);

    TSnakePart = ^SnakePart;

    SnakePart = Record
        X, Y: Integer;
        Next: TSnakePart;
    End;

    TFood = Record
        X, Y: Integer;
        Level: Integer;
        Color: TColor;
    End;

    TSnakeF = Class(TForm)
        MainMenu: TMainMenu;
        ExitButton: TMenuItem;
        Timer: TTimer;
        ScoreInf: TMenuItem;
        PoisonAppleTimer: TTimer;
        DeletePoisonAppleTimer: TTimer;
        PauseResumeButton: TMenuItem;
        StartLabel: TLabel;
        PauseLabel: TLabel;
        HelpButton: TMenuItem;
        Procedure FormCreate(Sender: TObject);
        Procedure ExitButtonClick(Sender: TObject);
        Procedure FormPaint(Sender: TObject);
        Procedure TimerTimer(Sender: TObject);
        Procedure GameStart;
        Procedure MoveSnake;
        Procedure RenderSnake;
        Procedure RenderFood;
        Procedure CheckCollisions;
        Procedure EatFood;
        Procedure Defeat;
        Procedure LevelUp;
        Procedure RebootSnake;
        Procedure RespawnFood;
        Procedure FreeSnake;
        Procedure CreateScore;
        Procedure PoisonAppleTimerTimer(Sender: TObject);
        Procedure DeletePoisonAppleTimerTimer(Sender: TObject);
        Procedure PauseResumeButtonClick(Sender: TObject);
        Procedure SetOptions;
        Procedure DifficultySet;
        Procedure SetBack;
        Procedure GenerateRandomFoodPosition(Var X, Y: Integer);
        Procedure FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure HelpButtonClick(Sender: TObject);
    Private

    Public
        { Public declarations }
    End;

Var
    SnakeF: TSnakeF;
    Username: String;
    Snake: TSnakePart;
    SnakeDirection: TSnakeDirection;
    Direction: TPoint;
    SnakeSpeed, Score, UpScore, MaxInterval: Integer;
    Food, PoisonApple: TFood;
    First: Boolean;
    Difficulty: TDifficultyLevel;
    DirectionChanged: Boolean = False;

Implementation

{$R *.dfm}

Procedure TSnakeF.GameStart;
Begin
    //������ �������,����������� �� ����
    Timer.Enabled := True;
    PauseResumeButton.Enabled := True;
    If Difficulty = Hard Then
    Begin
        //������� ��� ����������� ����������� �����
        PoisonAppleTimer.Enabled := True;
        DeletePoisonAppleTimer.Enabled := True;
    End;
    First := False;
    StartLabel.Visible := False;
    UpScore := 500;
    MaxInterval := 40;
End;

Procedure TSnakeF.LevelUp;
Var
    NewBodyPartX, NewBodyPartY: Integer;
    I: Integer;
    NewBodyPart: TSnakePart;
    LastBodyPart: TSnakePart;
Begin
    For I := 1 To Food.Level Do
    Begin
        New(NewBodyPart);
        NewBodyPartX := Snake^.X;
        NewBodyPartY := Snake^.Y;
        NewBodyPart^.X := NewBodyPartX;
        NewBodyPart^.Y := NewBodyPartY;
        NewBodyPart^.Next := Nil;
        If Snake = Nil Then
            Snake := NewBodyPart
        Else
        Begin
            LastBodyPart := Snake;
            While LastBodyPart^.Next <> Nil Do
                LastBodyPart := LastBodyPart^.Next;
            LastBodyPart^.Next := NewBodyPart;
        End;
    End;
End;

Procedure TSnakeF.MoveSnake;
Var
    PrevX, PrevY, TempX, TempY: Integer;
    CurrentBody, NextBody: TSnakePart;
Begin
    PrevX := Snake^.X;
    PrevY := Snake^.Y;
    //������� ������ ������ � ����������� �� �����������
    Snake^.X := Snake^.X + Direction.X;
    Snake^.Y := Snake^.Y + Direction.Y;
    //������� ������ �������, ������� �� �������
    CurrentBody := Snake;
    NextBody := Snake^.Next;
    While NextBody <> Nil Do
    Begin
        TempX := NextBody^.X;
        TempY := NextBody^.Y;
        NextBody^.X := PrevX;
        NextBody^.Y := PrevY;
        PrevX := TempX;
        PrevY := TempY;
        CurrentBody := NextBody;
        NextBody := NextBody^.Next;
    End;
End;

Procedure TSnakeF.CheckCollisions;
Var
    Body: TSnakePart;
Begin
    //��������� ������������ � ������ ������
    If (Snake^.X < 0) Or (Snake^.X >= ClientWidth) Or (Snake^.Y < 0) Or (Snake^.Y >= ClientHeight) Then
        Defeat;
    //��������� ������������ � ����� ������
    Body := Snake^.Next;
    While Body <> Nil Do
    Begin
        If (Snake^.X = Body^.X) And (Snake^.Y = Body^.Y) Then
        Begin
            Defeat; //��������
            Exit;
        End;
        Body := Body^.Next;
    End;
    //��������� ������������ � ����
    If (Snake^.X >= Food.X - 10) And (Snake^.X <= Food.X + 10) And (Snake^.Y >= Food.Y - 10) And (Snake^.Y <= Food.Y + 10) Then
        EatFood; //�������� ������
    //��������� ������������ � ����������� �������
    If (Difficulty = Hard) And (Snake^.X >= PoisonApple.X - 10) And (Snake^.X <= PoisonApple.X + 10) And (Snake^.Y >= PoisonApple.Y - 10)
        And (Snake^.Y <= PoisonApple.Y + 10) Then
        Defeat; //��������
End;

Procedure TSnakeF.EatFood;
Begin
    //����������� ����
    Score := Score + (Food.Level * 100);
    ScoreInf.Caption := '����: ' + IntToStr(Score);

    If (Score > UpScore) And (Timer.Interval < MaxInterval) Then
    Begin
        //����������� �������� ������
        Timer.Interval := Timer.Interval - 10;
        UpScore := UpScore + 500; //����������� ���������� ����� ��� ���������� ���������� ��������
    End;
    LevelUp;
    //���������� ������ �� ����� �������
    RespawnFood;
End;

Procedure TSnakeF.HelpButtonClick(Sender: TObject);
Begin
    If Timer.Enabled Then
    Begin
        Timer.Enabled := False;
        If Difficulty = Hard Then
        Begin
            PoisonAppleTImer.Enabled := False;
            DeletePoisonAppleTimer.Enabled := False;
        End;
        PauseResumeButton.Caption := '����';
        PauseLabel.Visible := True;
        SnakeHelpF := TSnakeHelpF.Create(Self);
        SnakeHelpF.ShowModal;
    End
    Else
    Begin
        SnakeHelpF := TSnakeHelpF.Create(Self);
        SnakeHelpF.ShowModal;
    End;
End;

Procedure TSnakeF.PauseResumeButtonClick(Sender: TObject);
Begin
    If Timer.Enabled Then
    Begin
        Timer.Enabled := False;
        If Difficulty = Hard Then
        Begin
            PoisonAppleTImer.Enabled := False;
            DeletePoisonAppleTimer.Enabled := False;
        End;
        PauseResumeButton.Caption := '����';
        PauseLabel.Visible := True;
    End
    Else
    Begin
        Timer.Enabled := True;
        If Difficulty = Hard Then
        Begin
            PoisonAppleTImer.Enabled := True;
            DeletePoisonAppleTimer.Enabled := True;
        End;
        PauseResumeButton.Caption := '�����';
        PauseLabel.Visible := False;
    End;
End;

Procedure TSnakeF.PoisonAppleTimerTimer(Sender: TObject);
Begin
    GenerateRandomFoodPosition(PoisonApple.X, PoisonApple.Y);
    PoisonApple.Color := ClPurple;
    RenderFood;
    DeletePoisonAppleTimer.Enabled := True;
End;

Procedure TSnakeF.Defeat;
Var
    DefeatMessage: String;
Begin
    //���������� ��������
    Timer.Enabled := False;
    If Difficulty = Hard Then
    Begin
        PoisonAppleTimer.Enabled := False;
        DeletePoisonAppleTimer.Enabled := False;
    End;
    //��������� � ���������
    DefeatMessage := '����� ����!' + #13#10 + '��� ����: ' + IntToStr(Score);
    Application.MessageBox(PChar(DefeatMessage), '���������', MB_ICONINFORMATION Or MB_OK);
    StartLabel.Visible := True;
    //�������, ��� ���� �� ��������
    First := True;
    PauseResumeButton.Enabled := False;
    //���������� ����� � ������� ��������
    UpdateScore(GlobalScore, Username, Score);
    Score := 0;
    ScoreInf.Caption := '����: ' + IntToStr(Score);
    //����� ������
    RebootSnake;
    //��������� ����� ���
    RespawnFood;
End;

Procedure TSnakeF.DeletePoisonAppleTimerTimer(Sender: TObject);
Begin
    PoisonApple.X := 0;
    PoisonApple.Y := 0;
    DeletePoisonAppleTimer.Enabled := False;
    Invalidate;
End;

Procedure TSnakeF.RebootSnake;
Begin
    If Snake <> Nil Then
        FreeSnake;
    New(Snake);
    Snake^.X := ClientWidth Div 2;
    Snake^.Y := ClientHeight Div 2;
    Snake^.Next := Nil;
    SnakeDirection := SdUp;
    Direction := Point(0, -SnakeSpeed);
End;

Procedure TSnakeF.GenerateRandomFoodPosition(Var X, Y: Integer);
Var
    Body: TSnakePart;
    IsValidPosition: Boolean;
Begin
    Repeat
        X := Random(ClientWidth - 20) + 10;
        Y := Random(ClientHeight - 20) + 10;
        IsValidPosition := True;
        Body := Snake;
        While Body <> Nil Do
        Begin
            If (X >= Body^.X - 10) And (X <= Body^.X + 10) And (Y >= Body^.Y - 10) And (Y <= Body^.Y + 10) Then
            Begin
                IsValidPosition := False;
                Break;
            End;
            Body := Body^.Next;
        End;
    Until IsValidPosition;
End;

Procedure TSnakeF.RespawnFood;
Var
    RandomColorIndex: Integer;
Begin
    //���������� ����� ������� ��� ������
    GenerateRandomFoodPosition(Food.X, Food.Y);
    //���������� ������� � ���� ������ ������
    Food.Level := Random(3) + 1;
    Case Food.Level Of
        1:
            Food.Color := ClGreen;
        2:
            Food.Color := ClBlue;
        3:
            Food.Color := ClYellow;
    End;
End;

Procedure TSnakeF.RenderSnake;
Var
    Body: TSnakePart;
    IsHead: Boolean;
Begin
    Body := Snake;
    IsHead := True; //����, �����������, �������� �� ������� ������� ������� ������
    While Body <> Nil Do
    Begin
        //������ �������������� ����� ������, � ���� ������
        If IsHead Then
        Begin
            If Color = ClBlack Then
                Canvas.Brush.Color := ClRed
            Else
                Canvas.Brush.Color := Options.HeadColor//���� ������
        End
        Else
        Begin
            If Color = ClBlack Then
                Canvas.Brush.Color := ClGray
            Else
                Canvas.Brush.Color := Options.SegmentColor; //���� ����

        End;
        Canvas.Rectangle(Body^.X - 10, Body^.Y - 10, Body^.X + 10, Body^.Y + 10);
        //����������� ���� ��� ��������� ���������� ��������
        IsHead := False;
        Body := Body^.Next;
    End;
End;

Procedure TSnakeF.RenderFood;
Begin
    //����������� �������� ������
    Canvas.Brush.Color := Food.Color;
    Canvas.Rectangle(Food.X - 10, Food.Y - 10, Food.X + 10, Food.Y + 10);

    //�������� �� ������ ������������ ������ � ��� �����������
    If (PoisonApple.X <> 0) And (PoisonApple.Y <> 0) And (Difficulty = Hard) Then
    Begin
        Canvas.Brush.Color := ClPurple;
        Canvas.Rectangle(PoisonApple.X - 10, PoisonApple.Y - 10, PoisonApple.X + 10, PoisonApple.Y + 10);
    End;
End;

Procedure TSnakeF.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Begin
    If Timer.Enabled Then
    Begin
        Timer.Enabled := False;
        If Difficulty = Hard Then
        Begin
            PoisonAppleTImer.Enabled := False;
            DeletePoisonAppleTimer.Enabled := False;
        End;
        PauseResumeButton.Caption := '����';
        PauseLabel.Visible := True;

        If Application.MessageBox('���� �� ���������. �� �������, ��� ������ �����?', '��������', MB_ICONQUESTION Or MB_YESNO) = IDYES Then
        Begin
            UpdateScore(GlobalScore, Username, Score);
            FreeSnake;
            CanClose := True;
        End
        Else
        Begin
            CanClose := False;
        End;
    End
    Else
    Begin
        CanClose := True;
    End;
End;

Procedure TSnakeF.FormCreate(Sender: TObject);
Begin
    SetOptions;
End;

Procedure TSnakeF.SetOptions;
Begin
    //������� �������� ����
    Height := 800;
    Width := 800;
    //��������� ����
    SetBack;
    //������� ��������� ����� ��� ����������� ������
    StartLabel.Left := (ClientWidth - StartLabel.Width) Div 2;
    PauseLabel.Left := (ClientWidth - PauseLabel.Width) Div 2;
    PauseLabel.Top := (ClientHeight - PauseLabel.Height) Div 2;
    //����������� ���������� ��� ����� �������� �������������
    Difficulty := Options.DifficultyLevel;
    //����������� ��������
    Username := GlobalName;
    Randomize;
    //������� ����, ��� ���� �� ������
    First := True;
    SnakeSpeed := 20;
    DoubleBuffered := True;
    //������������� �����
    Score := 0;
    //������� ������ ���������
    DifficultySet;
    //�������� ����� ������ ��� ������� ��������
    CreateScore;
    //�������� ������
    RebootSnake;
    //�������� ���
    RespawnFood;
End;

//��������� ������� ��������� �������� ������ � ��������� �������� ��� ��������� ������
Procedure TSnakeF.DifficultySet;
Begin
    Case Difficulty Of
        Easy:
            Begin
                Timer.Interval := 110;
                PoisonApple.X := 0;
                PoisonApple.Y := 0;
            End;
        Hard:
            Begin
                Timer.Interval := 80;
                PoisonAppleTimer.Interval := 10000;
                DeletePoisonAppleTimer.Interval := 10000;
            End;
    End;
End;

Procedure TSnakeF.CreateScore;
Begin
    If GlobalScore = Nil Then
    Begin
        New(GlobalScore);
        GlobalScore := Nil;
    End;
End;

//������� �������� ���� ����
Procedure TSnakeF.SetBack;
Begin
    If Color = ClBlue Then
        If Options.BackColor = ClNone Then
            Color := ClMoneyGreen
        Else
            Color := Options.BackColor;
End;

Procedure TSnakeF.ExitButtonClick(Sender: TObject);
Begin
    Close;
End;

Procedure TSnakeF.FormPaint(Sender: TObject);
Begin
    //���������, ���������� �� �������� ������
    MoveSnake;
    //���������, ���������� �� �������� ������������
    CheckCollisions;
    //���������, ���������� �� ��������� ������
    RenderSnake;
    //���������, ���������� �� ��������� ���
    RenderFood;
End;

Procedure TSnakeF.TimerTimer(Sender: TObject);
Begin
    DirectionChanged := False;
    Invalidate;
End;

Procedure TSnakeF.FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
Begin
    //����������� �������� �� ��� �����������
    If Not DirectionChanged Then
    Begin
        //����� ��� ���������� ����
        If (Key = VK_ESCAPE) And (Not First) Then
            PauseResumeButtonClick(Sender)
        Else
            //������ ����
            If First Then
                GameStart
            Else
            Begin
                //����� ���������� ���������
                Case Options.UseArrowKeys Of
                    True:
                        Begin
                            Case Key Of
                                VK_UP:
                                    If SnakeDirection <> SdDown Then
                                    Begin
                                        Direction := Point(0, -SnakeSpeed);
                                        SnakeDirection := SdUp;
                                    End;
                                VK_DOWN:
                                    If SnakeDirection <> SdUp Then
                                    Begin
                                        Direction := Point(0, SnakeSpeed);
                                        SnakeDirection := SdDown;
                                    End;
                                VK_LEFT:
                                    If SnakeDirection <> SdRight Then
                                    Begin
                                        Direction := Point(-SnakeSpeed, 0);
                                        SnakeDirection := SdLeft;
                                    End;
                                VK_RIGHT:
                                    If SnakeDirection <> SdLeft Then
                                    Begin
                                        Direction := Point(SnakeSpeed, 0);
                                        SnakeDirection := SdRight;
                                    End;
                            End;
                        End;
                    //����� ���������� WASD
                    False:
                        Begin
                            Case Key Of
                                Ord('W'):
                                    If SnakeDirection <> SdDown Then
                                    Begin
                                        Direction := Point(0, -SnakeSpeed);
                                        SnakeDirection := SdUp;
                                    End;
                                Ord('S'):
                                    If SnakeDirection <> SdUp Then
                                    Begin
                                        Direction := Point(0, SnakeSpeed);
                                        SnakeDirection := SdDown;
                                    End;
                                Ord('A'):
                                    If SnakeDirection <> SdRight Then
                                    Begin
                                        Direction := Point(-SnakeSpeed, 0);
                                        SnakeDirection := SdLeft;
                                    End;
                                Ord('D'):
                                    If SnakeDirection <> SdLeft Then
                                    Begin
                                        Direction := Point(SnakeSpeed, 0);
                                        SnakeDirection := SdRight;
                                    End;
                            End;
                        End;
                End;
            End;
    End;
    DirectionChanged := True;
End;

//��������
Procedure TSnakeF.FreeSnake;
Var
    CurrentSegment: TSnakePart;
Begin
    While Snake <> Nil Do
    Begin
        CurrentSegment := Snake;
        Snake := Snake^.Next;
        Dispose(CurrentSegment);
    End;
End;

End.
