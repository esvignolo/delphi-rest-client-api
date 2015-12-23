unit JsonToDataSetConverter;

interface

uses DB, BufDataset, SuperObject;

type
  TJsonToDataSetConverter = class
  private
    class procedure AppendRecord(ADataSet: TBufDataset; AObject: ISuperObject);
    class procedure SetFieldValue(AField: TField; AValue: ISuperObject);

    class procedure ExtractFields(ADataSet: TBufDataset; AObject: ISuperObject);

    class function SuperTypeToFieldType(ASuperType: TSuperType): TFieldType;
    class function SuperTypeToFieldSize(ASuperType: TSuperType): Integer;
  public
    class procedure UnMarshalToDataSet(ADataSet: TBufDataset; AJson: string);overload;
    class procedure UnMarshalToDataSet(ADataSet: TBufDataset; AObject: ISuperObject);overload;

    class function CreateDataSetMetadata(AJson: string): TBufDataset; overload;
    class function CreateDataSetMetadata(AObject: ISuperObject): TBufDataset; overload;
  end;

implementation

{ TJsonToDataSetConverter }

uses DataSetUtils;

class procedure TJsonToDataSetConverter.AppendRecord(ADataSet: TBufDataset;AObject: ISuperObject);
var
  vField: TField;
  vIterator: TSuperObjectIter;
begin
  ADataSet.Append;

  if SuperObject.ObjectFindFirst(AObject, vIterator) then
  begin
    try
      repeat
        vField := ADataSet.FindField(vIterator.key);

        if Assigned(vField) then
        begin
          SetFieldValue(vField, vIterator.val);
        end;
      until not SuperObject.ObjectFindNext(vIterator);
    finally
      SuperObject.ObjectFindClose(vIterator);
    end;
  end;

  ADataSet.Post;
end;

class function TJsonToDataSetConverter.CreateDataSetMetadata(AJson: string): TBufDataset;
var
  AObject: ISuperObject;
begin
  AObject := SuperObject.SO(AJson);

  Result := CreateDataSetMetadata(AObject);
end;

class function TJsonToDataSetConverter.CreateDataSetMetadata(AObject: ISuperObject): TBufDataset;
var
  vArray: TSuperArray;
begin
  Result := TBufDataset.Create(nil);

  if AObject.IsType(stArray) then
  begin
    vArray := AObject.AsArray;

    ExtractFields(Result, vArray.O[0]);
  end
  else
  begin
    ExtractFields(Result, AObject);
  end;

  Result.CreateDataSet;
end;

class procedure TJsonToDataSetConverter.ExtractFields(ADataSet: TBufDataset;AObject: ISuperObject);
var
  vIterator: TSuperObjectIter;
  vNestedField: TField;
  vArray: TSuperArray;
begin
  if SuperObject.ObjectFindFirst(AObject, vIterator) then
  begin
    try
      repeat
        if (vIterator.val.IsType(stArray)) then
        begin
          vNestedField := TDatasetUtils.CreateDataSetField(ADataSet, vIterator.key);

          vArray := vIterator.val.AsArray;
          //if (vArray.Length > 0) then
          //begin
          //  ExtractFields(vNestedField.NestedDataSet, vArray[0]);
          //end;
        end
        else
        begin
          TDatasetUtils.CreateField(ADataSet, SuperTypeToFieldType(vIterator.val.DataType), vIterator.key, SuperTypeToFieldSize(vIterator.val.DataType));
        end;
      until not SuperObject.ObjectFindNext(vIterator);
    finally
      SuperObject.ObjectFindClose(vIterator);
    end;
  end;
end;

class procedure TJsonToDataSetConverter.SetFieldValue(AField: TField;AValue: ISuperObject);
var
  vFieldName: string;
  vNestedDataSet: TBufDataset;
begin
  vFieldName := AField.FieldName;
  case AField.DataType of
    ftSmallint, ftInteger, ftWord, ftLargeint: AField.AsInteger := AValue.AsInteger;
    ftFloat, ftCurrency, ftBCD, ftFMTBcd: AField.AsFloat := AValue.AsDouble;
    ftBoolean: AField.AsBoolean := AValue.AsBoolean;
    ftDate, ftTime, ftDateTime, ftTimeStamp:
       AField.AsDateTime := AValue.AsDouble;
   // ftDataSet:  begin
   //               ftDataSet := TBufDatasetField(AField).NestedDataSet;
   //
   //               UnMarshalToDataSet(vNestedDataSet, AValue);
   //             end;
  else
    AField.AsString := AValue.AsString;
  end;
end;

class function TJsonToDataSetConverter.SuperTypeToFieldSize(ASuperType: TSuperType): Integer;
begin
  Result := 0;

  if (ASuperType = stString) then
  begin
    Result := 255;
  end;
end;

class function TJsonToDataSetConverter.SuperTypeToFieldType(ASuperType: TSuperType): TFieldType;
begin
  case ASuperType of
    stBoolean: Result := ftBoolean;
    stDouble: Result := ftFloat;
    stCurrency: Result := ftCurrency;
    stInt: Result := ftInteger;
    stObject: Result := ftDataSet;
    stArray: Result := ftDataSet;
    stString: Result := ftString;
  else
    Result := ftUnknown;
  end;
end;

class procedure TJsonToDataSetConverter.UnMarshalToDataSet(ADataSet: TBufDataset;AObject: ISuperObject);
var
  i: Integer;
  vArray: TSuperArray;
begin
  ADataSet.DisableControls;
  try
    if AObject.IsType(stArray) then
    begin
      vArray := AObject.AsArray;

      for I := 0 to vArray.Length-1 do
      begin
        AppendRecord(ADataSet, vArray.O[i]);
      end;
    end
    else
    begin
      AppendRecord(ADataSet, AObject);
    end;
  finally
    ADataSet.EnableControls;
  end;

  ADataSet.First;
end;

class procedure TJsonToDataSetConverter.UnMarshalToDataSet(ADataSet: TBufDataset; AJson: string);
var
  AObject: ISuperObject;
begin
  AObject := SuperObject.SO(AJson);

  UnMarshalToDataSet(ADataSet, AObject);
end;

end.
