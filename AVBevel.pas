unit AVBevel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, GraphUtil, LCLType, LResources;

type
  TAVBevel = class(TCustomControl)
  private
    FInnerFillTop: TColor;
    FInnerFillMiddle: TColor;
    FInnerFillBottom: TColor;
    FOuterColor: TColor;
    procedure SetInnerFillTop(AValue: TColor);
    procedure SetInnerFillMiddle(AValue: TColor);
    procedure SetInnerFillBottom(AValue: TColor);
    procedure SetOuterColor(AValue: TColor);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property InnerFillTop: TColor read FInnerFillTop write SetInnerFillTop default $E8F2F8;
    property InnerFillMiddle: TColor read FInnerFillMiddle write SetInnerFillMiddle default $DAF0FA;
    property InnerFillBottom: TColor read FInnerFillBottom write SetInnerFillBottom default $FFFFFF;
    property OuterColor: TColor read FOuterColor write SetOuterColor default $4A98CC;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('AfterView', [TAVBevel]);
end;

constructor TAVBevel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls];
  FInnerFillTop := $E8F2F8;      // Голубоватый верх
  FInnerFillMiddle := $DAF0FA;   // Светло-голубой центр
  FInnerFillBottom := $FFFFFF;   // Белый низ
  FOuterColor := $4A98CC;        // Синяя рамка
  Width := 100;
  Height := 100;
end;

procedure TAVBevel.SetInnerFillTop(AValue: TColor);
begin
  if FInnerFillTop = AValue then Exit;
  FInnerFillTop := AValue;
  Invalidate;  // Перерисовать компонент при изменении цвета
end;

procedure TAVBevel.SetInnerFillMiddle(AValue: TColor);
begin
  if FInnerFillMiddle = AValue then Exit;
  FInnerFillMiddle := AValue;
  Invalidate;
end;

procedure TAVBevel.SetInnerFillBottom(AValue: TColor);
begin
  if FInnerFillBottom = AValue then Exit;
  FInnerFillBottom := AValue;
  Invalidate;
end;

procedure TAVBevel.SetOuterColor(AValue: TColor);
begin
  if FOuterColor = AValue then Exit;
  FOuterColor := AValue;
  Invalidate;
end;

procedure TAVBevel.Paint;
var
  ARect: TRect;
  i, MiddlePos: Integer;
  r1, g1, b1, r2, g2, b2, r, g, b: Byte;
begin
  ARect := Rect(0, 0, Width, Height);
  MiddlePos := Height div 2;

  // Градиент от Top до Middle
  RedGreenBlue(FInnerFillTop, r1, g1, b1);
  RedGreenBlue(FInnerFillMiddle, r2, g2, b2);

  for i := 0 to MiddlePos - 1 do
  begin
    r := r1 + ((r2 - r1) * i) div MiddlePos;
    g := g1 + ((g2 - g1) * i) div MiddlePos;
    b := b1 + ((b2 - b1) * i) div MiddlePos;
    Canvas.Pen.Color := RGBToColor(r, g, b);
    Canvas.Line(0, i, Width, i);
  end;

  // Градиент от Middle до Bottom
  RedGreenBlue(FInnerFillMiddle, r1, g1, b1);
  RedGreenBlue(FInnerFillBottom, r2, g2, b2);

  for i := MiddlePos to Height - 1 do
  begin
    r := r1 + ((r2 - r1) * (i - MiddlePos)) div (Height - MiddlePos);
    g := g1 + ((g2 - g1) * (i - MiddlePos)) div (Height - MiddlePos);
    b := b1 + ((b2 - b1) * (i - MiddlePos)) div (Height - MiddlePos);
    Canvas.Pen.Color := RGBToColor(r, g, b);
    Canvas.Line(0, i, Width, i);
  end;

  // Рисуем рамку (без заливки)
  Canvas.Pen.Color := FOuterColor;
  Canvas.Brush.Style := bsClear;
  Canvas.Rectangle(ARect);

  inherited Paint;
end;

initialization
  {$I AfterView.lrs}

end.
