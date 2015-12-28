unit Unit1;


interface

uses
  {$IFDEF WINDOWS}Windows,{$ENDIF} Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus, typinfo, contnrs, RestUtils, OldRttiUnMarshal;

type
  TClientes = class
  public
    srazonsocial: string;
    sdomicilio: string;
    fcreacion: TDateTime;

    //destructor Destroy; override;
  end;
    {$M+}
  TEnumType = (etOne, etTwo, etThree);

  TEnumTypeSet = set of TEnumType;

  TRecordTypes = record
    one: string;
    two: Integer;
  end;

  TAllTypes = class;

  TAllTypes = class(TPersistent)
  private
    FvalueChar: Char;
    FvalueBoolean: Boolean;
    FvalueAnsiChar: AnsiChar;
    FvalueEnum: TEnumType;
    FvalueDateTime: TDateTime;
    FvalueExtended: Extended;
    FvalueObjectList: TObjectList;
    FvalueTObject: TAllTypes;
    FvalueInt64: Int64;
    FvalueList: TList;
    FvalueSingle: Single;
    FvalueString: string;
    FvalueCurrency: Currency;
    FvalueInteger: Integer;
    FvalueSet: TEnumTypeSet;
    FvalueAnsiString: AnsiString;
    FvalueDouble: Double;
  public
    //destructor Destroy; override;
  published
    property valueInteger: Integer read FvalueInteger write FvalueInteger;
    property valueDouble: Double read FvalueDouble write FvalueDouble;
    property valueCurrency: Currency read FvalueCurrency write FvalueCurrency;
    property valueAnsiString: AnsiString read FvalueAnsiString write FvalueAnsiString;
    property valueString: string read FvalueString write FvalueString;
    property valueAnsiChar: AnsiChar read FvalueAnsiChar write FvalueAnsiChar;
    property valueChar: Char read FvalueChar write FvalueChar;
    property valueInt64: Int64 read FvalueInt64 write FvalueInt64;
    property valueSingle: Single read FvalueSingle write FvalueSingle;
    property valueExtended: Extended read FvalueExtended write FvalueExtended;
    property valueBoolean: Boolean read FvalueBoolean write FvalueBoolean;
    property valueTObject: TAllTypes read FvalueTObject write FvalueTObject;
    property AllTypesList: TList read FvalueList write FvalueList;
    property AllTypesObjectList: TObjectList read FvalueObjectList write FvalueObjectList;
    property valueDateTime: TDateTime read FvalueDateTime write FvalueDateTime;
    property valueEnum: TEnumType read FvalueEnum write FvalueEnum;
    property valueSet: TEnumTypeSet read FvalueSet write FvalueSet;
  end;
  {$M-}

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation


{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  vList: TList;
begin
  //vList := TList(TOldRttiUnMarshal.FromJsonArray(TList, TAllTypes, '[{"valueInteger":123}]'));
  vList := TList(TOldRttiUnMarshal.FromJsonArray(TList, TAllTypes, '[{"valueInteger":123}]'));
  try
    //CheckNotNull(vList);
    //CheckEquals(1, vList.Count);
    if vList.Count=1 then
       ShowMessage('OK 1');
    if TAllTypes(vList[0]).valueInteger=123 then
       ShowMessage('OK 2');
    //CheckEquals(123, TAllTypes(vList[0]).valueInteger);
  finally
    TAllTypes(vList[0]).Free;
    vList.Free;
  end;
end;

end.

