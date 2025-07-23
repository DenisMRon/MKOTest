object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = #1047#1072#1076#1072#1095#1080
  ClientHeight = 656
  ClientWidth = 1150
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 416
    Width = 1150
    Height = 240
    Align = alBottom
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object lbTask: TListBox
    Left = 0
    Top = 0
    Width = 497
    Height = 416
    Align = alLeft
    ItemHeight = 13
    TabOrder = 1
    OnClick = lbTaskClick
  end
  object pTask: TPanel
    Left = 497
    Top = 0
    Width = 653
    Height = 416
    Align = alClient
    TabOrder = 2
    object pButtons: TPanel
      Left = 1
      Top = 360
      Width = 651
      Height = 55
      Align = alBottom
      TabOrder = 0
      DesignSize = (
        651
        55)
      object btnStart: TButton
        Left = 487
        Top = 16
        Width = 75
        Height = 25
        Anchors = [akTop, akRight, akBottom]
        Caption = #1057#1090#1072#1088#1090
        Enabled = False
        TabOrder = 0
        OnClick = btnStartClick
      end
      object btnStop: TButton
        Left = 568
        Top = 16
        Width = 75
        Height = 25
        Anchors = [akTop, akRight, akBottom]
        Caption = #1057#1090#1086#1087
        Enabled = False
        TabOrder = 1
        OnClick = btnStopClick
      end
      object btnAddParam: TButton
        Left = 406
        Top = 16
        Width = 75
        Height = 25
        Anchors = [akTop, akRight, akBottom]
        TabOrder = 2
        Visible = False
        OnClick = btnAddParamClick
      end
    end
    object pParams: TPanel
      Left = 1
      Top = 1
      Width = 408
      Height = 359
      Align = alLeft
      TabOrder = 1
    end
    object pResult: TPanel
      Left = 409
      Top = 1
      Width = 243
      Height = 359
      Align = alClient
      TabOrder = 2
      ExplicitLeft = 432
      ExplicitTop = 112
      ExplicitWidth = 185
      ExplicitHeight = 41
      object lbResult: TLabel
        Left = 1
        Top = 1
        Width = 241
        Height = 16
        Align = alTop
        Alignment = taCenter
        Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090
      end
      object mResult: TMemo
        Left = 1
        Top = 17
        Width = 241
        Height = 341
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
  end
end
