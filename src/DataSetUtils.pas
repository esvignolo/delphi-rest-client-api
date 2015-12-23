unit DataSetUtils;

interface

uses DB, SysUtils, BufDataset;

type
  TDataSetUtils = class
  public
    class function CreateField(DataSet: TBufDataset; FieldType: TFieldType; const FieldName: string = ''; ASize: Integer=0; ADisplayWidth: Integer = 30): TField;
    class function CreateDataSetField(DataSet: TBufDataset; const FieldName: string): TField;
  end;

implementation

{ TDataSetUtils }

class function TDataSetUtils.CreateDataSetField(DataSet: TBufDataset;const FieldName: string): TField;
begin
  Result := TField(CreateField(DataSet, ftDataSet, FieldName));
end;

class function TDataSetUtils.CreateField(DataSet: TBufDataset;
  FieldType: TFieldType; const FieldName: string; ASize: Integer; ADisplayWidth: Integer): TField;
begin
    Result:= DefaultFieldClasses[FieldType].Create(DataSet);
    Result.FieldName:= FieldName;
    if Result.FieldName = '' then
      Result.FieldName:= 'Field' + IntToStr(DataSet.FieldCount +1);
    Result.FieldKind := fkData;
    Result.DataSet:= DataSet;
    Result.Name:= DataSet.Name + Result.FieldName;
    Result.Size := ASize;
    if (FieldType = ftString) then
      Result.DisplayWidth := ADisplayWidth;

    if (FieldType = ftString) and (ASize <= 0) then
      raise Exception.CreateFmt('Size não definido para o campo "%s".',[FieldName]);
end;

end.
