object EditFrame: TEditFrame
  Left = 0
  Top = 0
  Width = 797
  Height = 41
  Align = alTop
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  DesignSize = (
    797
    41)
  object lParamName: TLabel
    Left = 16
    Top = 8
    Width = 129
    Height = 21
    AutoSize = False
  end
  object eParamValue: TEdit
    Left = 163
    Top = 8
    Width = 626
    Height = 21
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    OnChange = eParamValueChange
  end
end
