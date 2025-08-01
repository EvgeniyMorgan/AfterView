unit AVColorBox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, LCLType, LCLIntf;

type
  TAVColorBox = class(TGraphicControl)
  private
    ColorBmp: TBitmap;
    ImageBmp: TBitmap;
    FBoxColor: Cardinal;
    FGridSize: Integer;

    FInnerColor: TColor;
    FOuterColor: TColor;
    FGridColor1: TColor;
    FGridColor2: TColor;

    procedure SetBoxColor(const Value: Cardinal);
    procedure SetColors(const Index: Integer; const Value: TColor);
    procedure SetGridSize(const Value: Integer);

    procedure ClearBitmap(Bmp: TBitmap; ColorValue: Cardinal);
    procedure RenderLineAlpha(Dest, Src: PByte; PixelCount: Integer; Alpha: Byte); // Изменили параметр с Width на PixelCount
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property BoxColor: Cardinal read FBoxColor write SetBoxColor;

    property OuterColor: TColor index 0 read FOuterColor write SetColors;
    property InnerColor: TColor index 1 read FInnerColor write SetColors;
    property GridColor1: TColor index 2 read FGridColor1 write SetColors;
    property GridColor2: TColor index 3 read FGridColor2 write SetColors;

    property GridSize: Integer read FGridSize write SetGridSize;

    property Align;
    property Color;
    property Constraints;
    property Cursor;
    property Enabled;
    property Hint;
    property ShowHint;
    property ParentShowHint;
    property Visible;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property PopupMenu;
    property OnClick;
    property OnDblClick;
  end;

procedure Register;

implementation

constructor TAVColorBox.Create(AOwner: TComponent);
begin
  inherited;

  ColorBmp := TBitmap.Create();
  ColorBmp.PixelFormat := pf32bit;

  ImageBmp := TBitmap.Create();
  ImageBmp.PixelFormat := pf32bit;

  FBoxColor := $80B2CEDC;

  FGridColor1 := $4F6070;
  FGridColor2 := $384450;

  FOuterColor := $222C31;
  FInnerColor := $D7DFE3;
  FGridSize := 16;

  Self.Width := 32;
  Self.Height := 32;
end;

destructor TAVColorBox.Destroy;
begin
  ColorBmp.Free();
  ImageBmp.Free();
  inherited;
end;

procedure TAVColorBox.SetBoxColor(const Value: Cardinal);
begin
  if FBoxColor <> Value then
  begin
    FBoxColor := Value;
    Invalidate();
  end;
end;

procedure TAVColorBox.SetColors(const Index: Integer; const Value: TColor);
begin
  case Index of
    0: if FOuterColor <> Value then begin FOuterColor := Value; Invalidate(); end;
    1: if FInnerColor <> Value then begin FInnerColor := Value; Invalidate(); end;
    2: if FGridColor1 <> Value then begin FGridColor1 := Value; Invalidate(); end;
    3: if FGridColor2 <> Value then begin FGridColor2 := Value; Invalidate(); end;
  end;
end;

procedure TAVColorBox.SetGridSize(const Value: Integer);
begin
  if FGridSize <> Value then
  begin
    FGridSize := Value;
    if (FGridSize < 1) then FGridSize := 1;
    Invalidate();
  end;
end;

procedure TAVColorBox.ClearBitmap(Bmp: TBitmap; ColorValue: Cardinal);
var
  i: Integer;
  P: PCardinal;
begin
  Bmp.BeginUpdate();
  try
    for i := 0 to Bmp.Height - 1 do
    begin
      P := Bmp.ScanLine[i];
      FillDWord(P^, Bmp.Width, ColorValue);
    end;
  finally
    Bmp.EndUpdate();
  end;
end;

procedure TAVColorBox.RenderLineAlpha(Dest, Src: PByte; PixelCount: Integer; Alpha: Byte);
var
  i: Integer;
  D, S: PCardinal;
  InvAlpha: Cardinal;
  r, g, b: Cardinal;
begin
  D := PCardinal(Dest);
  S := PCardinal(Src);
  InvAlpha := 255 - Alpha;

  for i := 0 to PixelCount - 1 do
  begin
    r := ((D^ and $00FF0000) * InvAlpha + (S^ and $00FF0000) * Alpha) shr 8;
    g := ((D^ and $0000FF00) * InvAlpha + (S^ and $0000FF00) * Alpha) shr 8;
    b := ((D^ and $000000FF) * InvAlpha + (S^ and $000000FF) * Alpha) shr 8;

    D^ := (r and $00FF0000) or (g and $0000FF00) or (b and $000000FF) or $FF000000;
    Inc(D);
    Inc(S);
  end;
end;

procedure TAVColorBox.Paint;
var
  i, j: Integer;
  MyColor: Cardinal;
  DestPtr, SrcPtr: PByte;
  x, y: Integer;
begin
  if not Visible then Exit;

  MyColor := FBoxColor;
  if not Enabled then
    MyColor := $FF808080;

  // Устанавливаем размеры битмапов
  ColorBmp.SetSize(Self.Width, Self.Height);
  ImageBmp.SetSize(Self.Width, Self.Height);

  // Очищаем битмап изображения
  with ImageBmp.Canvas do
  begin
    Brush.Color := FGridColor1;
    FillRect(0, 0, Self.Width, Self.Height);
  end;

  // Рисуем шахматную сетку
  with ImageBmp.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := FGridColor2;

    for j := 0 to (Self.Height div FGridSize) do
    begin
      for i := 0 to (Self.Width div FGridSize) do
      begin
        if ((i + j) mod 2 = 0) then
        begin
          x := i * FGridSize;
          y := j * FGridSize;
          FillRect(x, y, x + FGridSize, y + FGridSize);
        end;
      end;
    end;
  end;

  // Заполняем цветной битмап
  ClearBitmap(ColorBmp, MyColor or $FF000000);

  // Если компонент disabled - рисуем диагональную штриховку
  if not Enabled then
  begin
    with ImageBmp.Canvas do
    begin
      Brush.Style := bsDiagCross;
      Brush.Color := $A0A0A0;
      FillRect(0, 0, Self.Width, Self.Height);
    end;
  end
  else
  begin
    // Наложение цвета с альфа-каналом
    for i := 0 to Self.Height - 1 do
    begin
      DestPtr := PByte(ColorBmp.ScanLine[i]);
      SrcPtr := PByte(ImageBmp.ScanLine[i]);
      RenderLineAlpha(DestPtr, SrcPtr, Self.Width, MyColor shr 24);
    end;
  end;

  // Рисуем рамку
  with ImageBmp.Canvas do
  begin
    Brush.Style := bsClear;
    Pen.Color := FOuterColor;
    Rectangle(0, 0, Self.Width, Self.Height);

    Pen.Color := FInnerColor;
    Rectangle(1, 1, Self.Width - 1, Self.Height - 1);
  end;

  // Копируем результат на экран
  Canvas.Draw(0, 0, ImageBmp);
end;

procedure Register;
begin
  RegisterComponents('AfterView', [TAVColorBox]);
end;

initialization
  {$I AfterView.lrs}

end.
