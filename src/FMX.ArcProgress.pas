unit FMX.ArcProgress;

interface

uses
  System.SysUtils, System.Types, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.Ani;

type

  TProgressState = (psNormal, psIndeterminate);

  TArcProgress = class(TControl)
  private
    FAni: TAnimation;
    FMax: Single;
    FMin: Single;
    FValue: Single;
    FProgressColor: TStrokeBrush;
    FBackgroundColor: TStrokeBrush;
    FStartAngle: Single;
    FEndAngle: Single;
    FState: TProgressState;
    FOnProcess: TNotifyEvent;
    procedure SetMax(const Value: Single);
    procedure SetMin(const Value: Single);
    procedure SetValue(const Value: Single);
    procedure SetBackgroundColor(const Value: TStrokeBrush);
    procedure SetProgressColor(const Value: TStrokeBrush);
    procedure SetState(const Value: TProgressState);
    procedure SetOnProcess(const Value: TNotifyEvent);
    procedure SetEndAngle(const Value: Single);
    procedure SetStartAngle(const Value: Single);
    { private declarations }
  protected
    { protected declarations }
    procedure UpdatedAniProgress;
    procedure SetEnabled(const Value: Boolean); override;
    procedure SetVisible(const Value: Boolean); override;
    procedure Paint; override;
    procedure DoProcess(Sender: TObject);

  public
    { public declarations }

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property StartAngle: Single read FStartAngle write SetStartAngle;
    property EndAngle: Single read FEndAngle write SetEndAngle;
  published
    { published declarations }
    property Max: Single read FMax write SetMax;
    property Min: Single read FMin write SetMin;
    property Value: Single read FValue write SetValue;
    property State: TProgressState read FState write SetState default TProgressState.psNormal;
    property BackgroundColor: TStrokeBrush read FBackgroundColor write SetBackgroundColor;
    property ProgressColor: TStrokeBrush read FProgressColor write SetProgressColor;
    property OnProcess: TNotifyEvent read FOnProcess write SetOnProcess;
    property Align;
    property Anchors;
    property ClipChildren;
    property ClipParent;
    property Cursor;
    property DragMode;
    property EnableDragHighlight;
    property Enabled;
    property Locked;
    property Height;
    property HitTest default False;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property TouchTargetExpansion;
    property Visible;
    property Width;
    property TabOrder;
    property TabStop;
    { Events }
    property OnPainting;
    property OnPaint;
    property OnResize;
    property OnResized;
    { Drag and Drop events }
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    { Mouse events }
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Material Design', [TArcProgress]);
end;

{ TArcProgress }

constructor TArcProgress.Create(AOwner: TComponent);
begin
  inherited;
  FAni := TFloatAnimation.Create(Self);
  FAni.Parent := Self;
  FAni.Loop := True;
  FAni.Duration := 0.5;
  FAni.OnProcess := DoProcess;
  FAni.SetSubComponent(True);
  FAni.Stored := False;
  TFloatAnimation(FAni).StartValue := 0;
  TFloatAnimation(FAni).StopValue := 360;
  TFloatAnimation(FAni).PropertyName := 'StartAngle';
  TFloatAnimation(FAni).AnimationType := TAnimationType.InOut;
  TFloatAnimation(FAni).Interpolation := TInterpolationType.Linear;
  FBackgroundColor := TStrokeBrush.Create(TBrushKind.Solid, $FFE0E0E0);
  FProgressColor := TStrokeBrush.Create(TBrushKind.Solid, $FF1976D2);
  FMin := 0;
  FMax := 100;
  FValue := 0;
  FStartAngle := 0;
  FEndAngle := 0;
  FState := TProgressState.psNormal;
end;

destructor TArcProgress.Destroy;
begin
  FreeAndNil(FAni);
  FreeAndNil(FBackgroundColor);
  FreeAndNil(FProgressColor);
  inherited;
end;

procedure TArcProgress.DoProcess(Sender: TObject);
begin
  Self.Repaint;
  if Assigned(FOnProcess) then
    FOnProcess(Sender);
end;

procedure TArcProgress.Paint;
begin
  inherited;

  case FState of
    psNormal:
      begin
        FStartAngle := -90 + (FValue * 360 / FMax);
        FEndAngle := (FValue * 360 / FMax) * -1;
      end;
  end;

  Canvas.DrawArc(TPointF.Create(Width / 2, Height / 2), TPointF.Create(Width / 2 - BackgroundColor.Thickness, Height / 2 - BackgroundColor.Thickness),
    360, -360, AbsoluteOpacity, FBackgroundColor);

  Canvas.DrawArc(TPointF.Create(Width / 2, Height / 2), TPointF.Create(Width / 2 - FProgressColor.Thickness, Height / 2 - FProgressColor.Thickness),
    FStartAngle, FEndAngle, AbsoluteOpacity, FProgressColor);
end;

procedure TArcProgress.SetBackgroundColor(const Value: TStrokeBrush);
begin
  FBackgroundColor := Value;
end;

procedure TArcProgress.SetEnabled(const Value: Boolean);
begin
  if Enabled <> Value then
  begin
    inherited;
    UpdatedAniProgress;
  end;
end;

procedure TArcProgress.SetEndAngle(const Value: Single);
begin
  FEndAngle := Value;
end;

procedure TArcProgress.SetMax(const Value: Single);
begin
  FMax := Value;
end;

procedure TArcProgress.SetMin(const Value: Single);
begin
  FMin := Value;
end;

procedure TArcProgress.SetOnProcess(const Value: TNotifyEvent);
begin
  FOnProcess := Value;
end;

procedure TArcProgress.SetProgressColor(const Value: TStrokeBrush);
begin
  FProgressColor := Value;
end;

procedure TArcProgress.SetStartAngle(const Value: Single);
begin
  FStartAngle := Value;
end;

procedure TArcProgress.SetState(const Value: TProgressState);
begin
  FState := Value;

  case FState of
    psIndeterminate:
      begin
        FStartAngle := 0;
        FEndAngle := -145;
        UpdatedAniProgress;
      end;
  end;
end;

procedure TArcProgress.SetValue(const Value: Single);
begin
  FValue := Value;
  Repaint;
end;

procedure TArcProgress.SetVisible(const Value: Boolean);
begin
  if Visible <> Value then
  begin
    inherited;
    UpdatedAniProgress;
  end;
end;

procedure TArcProgress.UpdatedAniProgress;
begin
  if FAni <> nil then
  begin
    if not(csDesigning in ComponentState) then
    begin
      if (Enabled) and (FState = TProgressState.psIndeterminate) then
        FAni.Start
      else
        FAni.Stop;
    end
    else
      StartAngle := 0;
  end;
end;

end.
