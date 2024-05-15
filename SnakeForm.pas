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
    //запуск таймера,отвечающего за игру
    Timer.Enabled := True;
    PauseResumeButton.Enabled := True;
    If Difficulty = Hard Then
    Begin
        //таймеры для отображения отравленных яблок
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
    //двигаем голову змейки в зависимости от направления
    Snake^.X := Snake^.X + Direction.X;
    Snake^.Y := Snake^.Y + Direction.Y;
    //двигаем каждый квадрат, начиная со второго
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
    //проверяем столкновения с краями экрана
    If (Snake^.X < 0) Or (Snake^.X >= ClientWidth) Or (Snake^.Y < 0) Or (Snake^.Y >= ClientHeight) Then
        Defeat;
    //проверяем столкновения с телом змейки
    Body := Snake^.Next;
    While Body <> Nil Do
    Begin
        If (Snake^.X = Body^.X) And (Snake^.Y = Body^.Y) Then
        Begin
            Defeat; //проигрыш
            Exit;
        End;
        Body := Body^.Next;
    End;
    //проверяем столкновение с едой
    If (Snake^.X >= Food.X - 10) And (Snake^.X <= Food.X + 10) And (Snake^.Y >= Food.Y - 10) And (Snake^.Y <= Food.Y + 10) Then
        EatFood; //поедание яблока
    //проверяем столкновение с отравленным яблоком
    If (Difficulty = Hard) And (Snake^.X >= PoisonApple.X - 10) And (Snake^.X <= PoisonApple.X + 10) And (Snake^.Y >= PoisonApple.Y - 10)
        And (Snake^.Y <= PoisonApple.Y + 10) Then
        Defeat; //проигрыш
End;

Procedure TSnakeF.EatFood;
Begin
    //увеличиваем счет
    Score := Score + (Food.Level * 100);
    ScoreInf.Caption := 'Счет: ' + IntToStr(Score);

    If (Score > UpScore) And (Timer.Interval < MaxInterval) Then
    Begin
        //увеличиваем скорости змейки
        Timer.Interval := Timer.Interval - 10;
        UpScore := UpScore + 500; //увеличиваем количество очков для следующего увеличения скорости
    End;
    LevelUp;
    //перемещаем яблоко на новую позицию
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
        PauseResumeButton.Caption := 'Пуск';
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
        PauseResumeButton.Caption := 'Пуск';
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
        PauseResumeButton.Caption := 'Пауза';
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
    //отключение таймеров
    Timer.Enabled := False;
    If Difficulty = Hard Then
    Begin
        PoisonAppleTimer.Enabled := False;
        DeletePoisonAppleTimer.Enabled := False;
    End;
    //сообщение о проигрыше
    DefeatMessage := 'Конец игры!' + #13#10 + 'Ваш счет: ' + IntToStr(Score);
    Application.MessageBox(PChar(DefeatMessage), 'Поражение', MB_ICONINFORMATION Or MB_OK);
    StartLabel.Visible := True;
    //признак, что игра не запущена
    First := True;
    PauseResumeButton.Enabled := False;
    //добавление счета в таблицу рекордов
    UpdateScore(GlobalScore, Username, Score);
    Score := 0;
    ScoreInf.Caption := 'Счет: ' + IntToStr(Score);
    //сброс змейки
    RebootSnake;
    //появление новой еды
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
    //генерируем новую позицию для яблока
    GenerateRandomFoodPosition(Food.X, Food.Y);
    //генерируем уровень и цвет нового яблока
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
    IsHead := True; //флаг, указывающий, является ли текущий сегмент головой змейки
    While Body <> Nil Do
    Begin
        //голова отрисовывается одним цветом, а тело другим
        If IsHead Then
        Begin
            If Color = ClBlack Then
                Canvas.Brush.Color := ClRed
            Else
                Canvas.Brush.Color := Options.HeadColor//цвет головы
        End
        Else
        Begin
            If Color = ClBlack Then
                Canvas.Brush.Color := ClGray
            Else
                Canvas.Brush.Color := Options.SegmentColor; //цвет тела

        End;
        Canvas.Rectangle(Body^.X - 10, Body^.Y - 10, Body^.X + 10, Body^.Y + 10);
        //переключаем флаг для отрисовки следующего сегмента
        IsHead := False;
        Body := Body^.Next;
    End;
End;

Procedure TSnakeF.RenderFood;
Begin
    //отображение обычного яблока
    Canvas.Brush.Color := Food.Color;
    Canvas.Rectangle(Food.X - 10, Food.Y - 10, Food.X + 10, Food.Y + 10);

    //проверка на наличи отравленного яблока и его отображение
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
        PauseResumeButton.Caption := 'Пуск';
        PauseLabel.Visible := True;

        If Application.MessageBox('Игра не закончена. Вы уверены, что хотите выйти?', 'Внимание', MB_ICONQUESTION Or MB_YESNO) = IDYES Then
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
    //задание размеров окна
    Height := 800;
    Width := 800;
    //установка фона
    SetBack;
    //задание положения меток для отображения текста
    StartLabel.Left := (ClientWidth - StartLabel.Width) Div 2;
    PauseLabel.Left := (ClientWidth - PauseLabel.Width) Div 2;
    PauseLabel.Top := (ClientHeight - PauseLabel.Height) Div 2;
    //определение переменной для более удобного использования
    Difficulty := Options.DifficultyLevel;
    //определение никнейма
    Username := GlobalName;
    Randomize;
    //признак того, что игра не начата
    First := True;
    SnakeSpeed := 20;
    DoubleBuffered := True;
    //инициализация счета
    Score := 0;
    //задание уровня сложности
    DifficultySet;
    //создание счета игрока для таблицы рекордов
    CreateScore;
    //создание змейки
    RebootSnake;
    //создание еды
    RespawnFood;
End;

//процедура задания начальной скорости змейки и интервала таймеров для ядовитого яблока
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

//задание внешнего вида фона
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
    //процедура, отвечающая за движение змейки
    MoveSnake;
    //процедура, отвечающая за проверку столкновений
    CheckCollisions;
    //процедура, отвечающая за отрисовку змейки
    RenderSnake;
    //процедура, отвечающая за отрисовку еды
    RenderFood;
End;

Procedure TSnakeF.TimerTimer(Sender: TObject);
Begin
    DirectionChanged := False;
    Invalidate;
End;

Procedure TSnakeF.FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
Begin
    //проверяется изменено ли уже направление
    If Not DirectionChanged Then
    Begin
        //пауза при запущенной игре
        If (Key = VK_ESCAPE) And (Not First) Then
            PauseResumeButtonClick(Sender)
        Else
            //запуск игры
            If First Then
                GameStart
            Else
            Begin
                //режим управления стрелками
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
                    //режим управления WASD
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

//очищение
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
