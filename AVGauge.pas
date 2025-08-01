unit AVGauge;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Math, LCLType, LCLIntf;

type
  TLookNFeel = (lfCustom, lfSilver, lfSnow, lfSand, lfViolet, lfGrass, lfIce,
    lfMatrix, lfAcid, lfRose, lfWood, lfBlack);

  TAVGauge = class(TCustomControl)
  private
    FGfxBmp: TBitmap;
    FPosition: Real;
    FMinValue: Real;
    FMaxValue: Real;

    FChanging: Boolean;
    FMyEdit: TEdit;
    FOnChange: TNotifyEvent;

    FBackColorTop: TColor;
    FBackColorMid: TColor;
    FBackColorBtm: TColor;

    FFrontColorTop: TColor;
    FFrontColorMid: TColor;
    FFrontColorBtm: TColor;

    FOuterFrameColor: TColor;
    FCaptFrameColor: TColor;

    FLookNFeel: TLookNFeel;
    FShowInfo: Boolean;
    FInfoFormat: string;
    FChangeable: Boolean;
    FEditable: Boolean;

    procedure SetGaugeColor(const Index: Integer; const Value: TColor);
    procedure SetLookNFeel(const Value: TLookNFeel);
    procedure SetMinValue(Value: Real);
    procedure SetMaxValue(Value: Real);
    procedure SetPosition(Value: Real);
    procedure SetShowInfo(const Value: Boolean);
    procedure SetInfoFormat(const Value: string);
    procedure SetChangeable(const Value: Boolean);

    procedure MouseChangeValue(X, Y: Integer);
    procedure MyEditExit(Sender: TObject);
    procedure MyEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HideMyEdit();

    procedure GradientFillVertical(Rect: TRect; StartColor, MidColor, EndColor: TColor);

  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property BackColorTop: TColor index 0 read FBackColorTop write SetGaugeColor;
    property BackColorMid: TColor index 1 read FBackColorMid write SetGaugeColor;
    property BackColorBtm: TColor index 2 read FBackColorBtm write SetGaugeColor;

    property FrontColorTop: TColor index 3 read FFrontColorTop write SetGaugeColor;
    property FrontColorMid: TColor index 4 read FFrontColorMid write SetGaugeColor;
    property FrontColorBtm: TColor index 5 read FFrontColorBtm write SetGaugeColor;

    property OuterFrameColor: TColor index 6 read FOuterFrameColor write SetGaugeColor;
    property CaptFrameColor: TColor index 7 read FCaptFrameColor write SetGaugeColor;

    property LookNFeel: TLookNFeel read FLookNFeel write SetLookNFeel;

    property MaxValue: Real read FMaxValue write SetMaxValue;
    property MinValue: Real read FMinValue write SetMinValue;
    property Position: Real read FPosition write SetPosition;

    property ShowInfo: Boolean read FShowInfo write SetShowInfo;
    property InfoFormat: string read FInfoFormat write SetInfoFormat;
    property Changeable: Boolean read FChangeable write SetChangeable;
    property Editable: Boolean read FEditable write FEditable;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property Align;
    property Anchors;
    property Constraints;
    property Cursor;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentFont;
    property Hint;
    property ShowHint;
    property ParentShowHint;
    property Visible;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnStartDock;
    property OnStartDrag;
    property PopupMenu;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('AfterView', [TAVGauge]);
end;

constructor TAVGauge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ControlStyle := [csCaptureMouse, csOpaque];

  FMyEdit := nil;

  Font.Name := 'Tahoma';
  Font.Style := [fsBold];

  Width := 100;
  Height := 18;

  FMinValue := 0.0;
  FMaxValue := 100.0;
  FPosition := 0.0;
  FGfxBmp := TBitmap.Create;
  FGfxBmp.PixelFormat := pf32bit;

  LookNFeel := lfSnow;
  FShowInfo := True;
  FInfoFormat := '%1.3f';
  FChangeable := False;
  FEditable := False;
  Cursor := crArrow;
  FChanging := False;
end;

destructor TAVGauge.Destroy;
begin
  FGfxBmp.Free;
  if FMyEdit <> nil then
    FMyEdit.Free;
  inherited Destroy;
end;

procedure TAVGauge.SetGaugeColor(const Index: Integer; const Value: TColor);
begin
  case Index of
    0: FBackColorTop := Value;
    1: FBackColorMid := Value;
    2: FBackColorBtm := Value;
    3: FFrontColorTop := Value;
    4: FFrontColorMid := Value;
    5: FFrontColorBtm := Value;
    6: FOuterFrameColor := Value;
    7: FCaptFrameColor := Value;
  end;

  FLookNFeel := lfCustom;
  Invalidate;
end;

procedure TAVGauge.SetLookNFeel(const Value: TLookNFeel);
begin
  FLookNFeel := Value;

  case FLookNFeel of
    lfSilver:
    begin
      FBackColorTop := $EBEBEB;
      FBackColorMid := $F5F5F5;
      FBackColorBtm := $FFFFFF;

      FFrontColorTop := $D2D2D2;
      FFrontColorMid := $DCDCDC;
      FFrontColorBtm := $C1C1C1;

      FOuterFrameColor := $5F5F5F;
      FCaptFrameColor := $444444;

      Font.Color := $FFFFFF;
    end;

    lfSnow:
    begin
      FBackColorTop := $FFF3E5;
      FBackColorMid := $FFE8CE;
      FBackColorBtm := $FFFFFF;

      FFrontColorTop := $FFA85E;
      FFrontColorMid := $FFBA7F;
      FFrontColorBtm := $FF963E;

      FOuterFrameColor := $E74E00;
      FCaptFrameColor := $CD4600;

      Font.Color := $FFFFFF;
    end;

    lfSand:
    begin
      FBackColorTop := $E1F9FF;
      FBackColorMid := $CEF5FF;
      FBackColorBtm := $FFFFFF;

      FFrontColorTop := $26C7FF;
      FFrontColorMid := $34D1FF;
      FFrontColorBtm := $16B8FF;

      FOuterFrameColor := $0072B3;
      FCaptFrameColor := $1F425A;

      Font.Color := $FFFFFF;
    end;

    lfViolet:
    begin
      FBackColorTop := $FDE2F4;
      FBackColorMid := $FFD0EF;
      FBackColorBtm := $FFFFFF;

      FFrontColorTop := $FF167F;
      FFrontColorMid := $FF2D97;
      FFrontColorBtm := $FF014D;

      FOuterFrameColor := $C11855;
      FCaptFrameColor := $A11743;

      Font.Color := $FFFFFF;
    end;

    lfGrass:
    begin
      FBackColorTop := $E1FFE1;
      FBackColorMid := $D5FFD5;
      FBackColorBtm := $FFFFFF;

      FFrontColorTop := $00F500;
      FFrontColorMid := $80FF80;
      FFrontColorBtm := $00DD00;

      FOuterFrameColor := $179817;
      FCaptFrameColor := $217421;

      Font.Color := $FFFFFF;
    end;

    lfIce:
    begin
      FBackColorTop := $FFF3EF;
      FBackColorMid := $F7DFD6;
      FBackColorBtm := $FFFFFF;

      FFrontColorTop := $E7A27B;
      FFrontColorMid := $F7D3C6;
      FFrontColorBtm := $D67563;

      FOuterFrameColor := $C25416;
      FCaptFrameColor := $6B3A19;

      Font.Color := $FFFFFF;
    end;

    lfMatrix:
    begin
      FBackColorTop := $0A5409;
      FBackColorMid := $038500;
      FBackColorBtm := $10720E;

      FFrontColorTop := $2CF727;
      FFrontColorMid := $22C61F;
      FFrontColorBtm := $1EDF1A;

      FOuterFrameColor := $39FF49;
      FCaptFrameColor := $9BDCA0;

      Font.Color := $003304;
    end;

    lfAcid:
    begin
      FBackColorTop := $581829;
      FBackColorMid := $5F2131;
      FBackColorBtm := $5C0F23;

      FFrontColorTop := $E6446F;
      FFrontColorMid := $FF0F4F;
      FFrontColorBtm := $CF3B62;

      FOuterFrameColor := $EF8FAE;
      FCaptFrameColor := $F5B6C4;

      Font.Color := $490F22;
    end;

    lfRose:
    begin
      FBackColorTop := $161A48;
      FBackColorMid := $0D1460;
      FBackColorBtm := $0F1447;

      FFrontColorTop := $1427FF;
      FFrontColorMid := $1726D0;
      FFrontColorBtm := $1E2EE0;

      FOuterFrameColor := $3124FF;
      FCaptFrameColor := $B3A1EF;

      Font.Color := $000846;
    end;

    lfWood:
    begin
      FBackColorTop := $1C313F;
      FBackColorMid := $1B272F;
      FBackColorBtm := $27343E;

      FFrontColorTop := $5992C1;
      FFrontColorMid := $3782C0;
      FFrontColorBtm := $539FDE;

      FOuterFrameColor := $A2C5E3;
      FCaptFrameColor := $86C6FF;

      Font.Color := $19354D;
    end;

    lfBlack:
    begin
      FBackColorTop := $FFFFFF;
      FBackColorMid := $FFFFFF;
      FBackColorBtm := $FFFFFF;

      FFrontColorTop := $000000;
      FFrontColorMid := $000000;
      FFrontColorBtm := $000000;

      FOuterFrameColor := $000000;
      FCaptFrameColor := $000000;

      Font.Color := $FFFFFF;
    end;
  end;

  Invalidate;
end;

procedure TAVGauge.SetPosition(Value: Real);
begin
  FPosition := Max(Min(Value, FMaxValue), FMinValue);
  Invalidate;
end;

procedure TAVGauge.SetMinValue(Value: Real);
begin
  if (Value < FMaxValue) then
  begin
    FMinValue := Value;
    Invalidate;
  end;
end;

procedure TAVGauge.SetMaxValue(Value: Real);
begin
  if (Value > FMinValue) then
  begin
    FMaxValue := Value;
    Invalidate;
  end;
end;

procedure TAVGauge.SetShowInfo(const Value: Boolean);
begin
  FShowInfo := Value;
  Invalidate;
end;

procedure TAVGauge.SetInfoFormat(const Value: string);
begin
  FInfoFormat := Value;
  Invalidate;
end;

procedure TAVGauge.SetChangeable(const Value: Boolean);
begin
  FChangeable := Value;

  if (FChangeable) then
    Cursor := crHandPoint
  else
    Cursor := crArrow;
end;

procedure TAVGauge.GradientFillVertical(Rect: TRect; StartColor, MidColor, EndColor: TColor);
var
  i, H: Integer;
  r1, g1, b1: Byte;
  r2, g2, b2: Byte;
  r3, g3, b3: Byte;
  dr1, dg1, db1: Real;
  dr2, dg2, db2: Real;
  Color1, Color2: TColor;
begin
  H := Rect.Bottom - Rect.Top;
  if H <= 0 then Exit;

  Color1 := ColorToRGB(StartColor);
  Color2 := ColorToRGB(MidColor);

  r1 := GetRValue(Color1);
  g1 := GetGValue(Color1);
  b1 := GetBValue(Color1);

  r2 := GetRValue(Color2);
  g2 := GetGValue(Color2);
  b2 := GetBValue(Color2);

  dr1 := (r2 - r1) / (H div 2);
  dg1 := (g2 - g1) / (H div 2);
  db1 := (b2 - b1) / (H div 2);

  Color1 := ColorToRGB(MidColor);
  Color2 := ColorToRGB(EndColor);

  r2 := GetRValue(Color1);
  g2 := GetGValue(Color1);
  b2 := GetBValue(Color1);

  r3 := GetRValue(Color2);
  g3 := GetGValue(Color2);
  b3 := GetBValue(Color2);

  dr2 := (r3 - r2) / (H div 2);
  dg2 := (g3 - g2) / (H div 2);
  db2 := (b3 - b2) / (H div 2);

  FGfxBmp.Canvas.Pen.Style := psSolid;

  for i := 0 to H - 1 do
  begin
    if i < H div 2 then
    begin
      FGfxBmp.Canvas.Pen.Color := RGB(
        Round(r1 + dr1 * i),
        Round(g1 + dg1 * i),
        Round(b1 + db1 * i));
    end
    else
    begin
      FGfxBmp.Canvas.Pen.Color := RGB(
        Round(r2 + dr2 * (i - H div 2)),
        Round(g2 + dg2 * (i - H div 2)),
        Round(b2 + db2 * (i - H div 2)));
    end;

    FGfxBmp.Canvas.MoveTo(Rect.Left, Rect.Top + i);
    FGfxBmp.Canvas.LineTo(Rect.Right, Rect.Top + i);
  end;
end;

procedure TAVGauge.Paint;
var
  GaugeRect: TRect;  // Переименовано из ClientRect
  SelectRect: TRect;
  Theta: Real;
  ThetaPos, xText, yText: Integer;
  s: string;
begin
  if not Visible then Exit;

  // resize the internal graphics
  if FGfxBmp.Width <> ClientWidth then FGfxBmp.Width := ClientWidth;
  if FGfxBmp.Height <> ClientHeight then FGfxBmp.Height := ClientHeight;

  // find the real position of selected rectangle
  Theta := (FPosition - FMinValue) / (FMaxValue - FMinValue);
  ThetaPos := Round(Theta * (FGfxBmp.Width - 4));

  // calculate original and selected rectangles
  GaugeRect := Bounds(1, 1, FGfxBmp.Width - 2, FGfxBmp.Height - 2);
  SelectRect := Rect(2, 2, ThetaPos + 2, FGfxBmp.Height - 2);

  // render the control
  GradientFillVertical(GaugeRect, FBackColorTop, FBackColorMid, FBackColorBtm);

  if Enabled then
  begin
    GradientFillVertical(SelectRect, FFrontColorTop, FFrontColorMid, FFrontColorBtm);

    with FGfxBmp.Canvas do
    begin
      Pen.Style := psSolid;

      if ThetaPos > 0 then
      begin
        Pen.Color := FFrontColorBtm;
        MoveTo(ThetaPos + 1, 2);
        LineTo(ThetaPos + 1, FGfxBmp.Height - 2);

        MoveTo(2, 2);
        LineTo(ThetaPos + 1, 2);

        Pen.Color := FFrontColorTop;
        MoveTo(2, 2);
        LineTo(2, FGfxBmp.Height - 3);
        LineTo(ThetaPos + 1, FGfxBmp.Height - 3);
      end;

      Pen.Color := FBackColorTop;
      MoveTo(1, 1);
      LineTo(1, FGfxBmp.Height - 2);
      LineTo(FGfxBmp.Width - 2, FGfxBmp.Height - 2);

      Pen.Color := FBackColorBtm;
      MoveTo(1, 1);
      LineTo(FGfxBmp.Width - 2, 1);
      LineTo(FGfxBmp.Width - 2, FGfxBmp.Height - 2);
    end;
  end;

  // render caption
  FGfxBmp.Canvas.Font.Assign(Font);
  if FShowInfo and Enabled then
    with FGfxBmp.Canvas do
    begin
      Font.Color := FCaptFrameColor;
      Brush.Style := bsClear;

      s := Format(FInfoFormat, [FPosition]);
      xText := (FGfxBmp.Width - TextWidth(s)) div 2;
      yText := (FGfxBmp.Height - TextHeight(s)) div 2;

      TextOut(xText - 1, yText, s);
      TextOut(xText + 1, yText, s);
      TextOut(xText, yText - 1, s);
      TextOut(xText, yText + 1, s);

      Font.Color := Self.Font.Color;
      TextOut(xText, yText, s);
    end;

  // render frame
  with FGfxBmp.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := FOuterFrameColor;
    if not Enabled then
      Brush.Color := clGray;
    FrameRect(Bounds(0, 0, FGfxBmp.Width, FGfxBmp.Height));
  end;

  // render the graphics
  Canvas.Draw(0, 0, FGfxBmp);
end;

procedure TAVGauge.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if (Button = mbLeft) and FChangeable then
  begin
    FChanging := True;
    MouseChangeValue(X, Y);
    if not Focused then SetFocus;
  end;

  if (Button = mbRight) and FEditable and FChangeable then
  begin
    if FMyEdit = nil then
    begin
      FMyEdit := TEdit.Create(Self);
      FMyEdit.Parent := Self;
      FMyEdit.Align := alClient;
      FMyEdit.Font.Color := clWindowText;
      FMyEdit.OnExit := @MyEditExit;
      FMyEdit.OnKeyDown := @MyEditKeyDown;
    end;

    FMyEdit.Text := Format('%1.3f', [FPosition]);

    if not FMyEdit.Visible then FMyEdit.Show;
    if not FMyEdit.Focused then FMyEdit.SetFocus;
  end;
end;

procedure TAVGauge.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if FChanging then MouseChangeValue(X, Y);
end;

procedure TAVGauge.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  FChanging := False;
end;

procedure TAVGauge.MouseChangeValue(X, Y: Integer);
var
  Theta: Real;
begin
  Theta := (X - 1) / (Width - 2);

  // update position
  Position := (Theta * (FMaxValue - FMinValue)) + FMinValue;

  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TAVGauge.MyEditExit(Sender: TObject);
begin
  if (FMyEdit <> nil) and FMyEdit.Visible then HideMyEdit;
end;

procedure TAVGauge.MyEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (FMyEdit <> nil) and FMyEdit.Visible and (Key = VK_RETURN) then HideMyEdit;
end;

procedure TAVGauge.HideMyEdit;
begin
  if (FMyEdit <> nil) and FMyEdit.Visible then
  begin
    Position := StrToFloatDef(FMyEdit.Text, FPosition);
    FMyEdit.Hide;

    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

initialization
  {$I AfterView.lrs}

end.
