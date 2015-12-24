unit HttpConnectionFpHttp;

{$MODE Delphi}

interface

uses HttpConnection, Classes, SysUtils, Variants, fphttpclient;

type
  THttpConnectionFpHttp = class(TInterfacedObject, IHttpConnection)
  private
    FFpHttpRequest: TFPCustomHTTPClient;
    FAcceptTypes: string;
    FAcceptedLanguages: string;
    FContentTypes: string;
    FHeaders: TStrings;
    FConnectTimeout: Integer;
    FSendTimeout: Integer;
    FReceiveTimeout: Integer;
    FProxyCredentials: TProxyCredentials;
    FLogin: String;
    FPassword: String;
    FVerifyCert: boolean;

    procedure Configure;

  protected
    procedure DoRequest(sMethod, AUrl: string; AContent, AResponse: TStream);
  public
    OnConnectionLost: THTTPConnectionLostEvent;

    constructor Create;
    destructor Destroy; override;

    function SetAcceptTypes(AAcceptTypes: string): IHttpConnection;
    function SetAcceptedLanguages(AAcceptedLanguages: string): IHttpConnection;
    function SetContentTypes(AContentTypes: string): IHttpConnection;
    function SetHeaders(AHeaders: TStrings): IHttpConnection;

    procedure Get(AUrl: string; AResponse: TStream);
    procedure Post(AUrl: string; AContent: TStream; AResponse: TStream);
    procedure Put(AUrl: string; AContent: TStream; AResponse: TStream);
    procedure Patch(AUrl: string; AContent: TStream; AResponse: TStream);
    procedure Delete(AUrl: string; AContent: TStream; AResponse: TStream);

    function GetResponseCode: Integer;
    function GetResponseHeader(const Name: string): string;


    function GetEnabledCompression: Boolean;
    procedure SetEnabledCompression(const Value: Boolean);

    function GetOnConnectionLost: THTTPConnectionLostEvent;
    procedure SetOnConnectionLost(AConnectionLostEvent: THTTPConnectionLostEvent);

    procedure SetVerifyCert(const Value: boolean);
    function GetVerifyCert: boolean;

    function ConfigureTimeout(const ATimeOut: TTimeOut): IHttpConnection;
    function ConfigureProxyCredentials(AProxyCredentials: TProxyCredentials): IHttpConnection;
  end;

implementation


const
  HTTPREQUEST_SETCREDENTIALS_FOR_SERVER = 0;
  HTTPREQUEST_PROXYSETTING_PROXY = 2;
  HTTPREQUEST_SETCREDENTIALS_FOR_PROXY = 1;

{ THttpConnectionFpHttp }

procedure THttpConnectionFpHttp.Configure;
var
  i: Integer;

begin
  if FAcceptTypes <> EmptyStr then
    FFpHttpRequest.AddHeader('Accept', FAcceptTypes);

  if FAcceptedLanguages <> EmptyStr then
    FFpHttpRequest.AddHeader('Accept-Language', FAcceptedLanguages);

  if FContentTypes <> EmptyStr then
    FFpHttpRequest.AddHeader('Content-Type', FContentTypes);

  for i := 0 to FHeaders.Count-1 do
  begin
    FFpHttpRequest.AddHeader(FHeaders.Names[i], FHeaders.ValueFromIndex[i]);
  end;


  //FFpHttpRequest.SetTimeouts(0,
  //                            FConnectTimeout,
  //                            FSendTimeout,
  //                            FReceiveTimeout);


end;

function THttpConnectionFpHttp.ConfigureProxyCredentials(AProxyCredentials: TProxyCredentials): IHttpConnection;
begin
  FProxyCredentials := AProxyCredentials;
  Result := Self;
end;

function THttpConnectionFpHttp.ConfigureTimeout(const ATimeOut: TTimeOut): IHttpConnection;
begin
  FConnectTimeout := ATimeOut.ConnectTimeout;
  FReceiveTimeout := ATimeOut.ReceiveTimeout;
  FSendTimeout    := ATimeOut.SendTimeout;
  Result := Self;
end;


constructor THttpConnectionFpHttp.Create;
begin
  FHeaders := TStringList.Create;
  FLogin:='';
  FPassword:='';
  FVerifyCert := True;
end;

destructor THttpConnectionFpHttp.Destroy;
begin
  FHeaders.Free;
  FFpHttpRequest := nil;
  inherited;
end;

procedure THttpConnectionFpHttp.DoRequest(sMethod, AUrl: string; AContent,
  AResponse: TStream);
var
  retryMode: THTTPRetryMode;
begin
  FFpHttpRequest := TFPCustomHTTPClient.Create(nil);


  Configure;

  try
    //FFpHttpRequest.SimpleGet(AUrl,AResponse);
    if sMethod='GET' then
       FFpHttpRequest.Get(AUrl,AResponse)
    else
      FFpHttpRequest.Post(AUrl,AResponse);

  except
    on E: Exception do
    begin
      //case E.ErrorCode of
      //  -2147012858: // WININET_E_SEC_CERT_CN_INVALID
      //    raise EHTTPVerifyCertError.Create('The host name in the certificate is invalid or does not match');
      //  -2147012859: // WININET_E_SEC_CERT_DATE_INVALID
      //    raise EHTTPVerifyCertError.Create('The date in the certificate is invalid or has expired');
      //  -2147012865, // WININET_E_CONNECTION_RESET
      //  -2147012866, // WININET_E_CONNECTION_ABORTED
      //  -2147012867: // WININET_E_CANNOT_CONNECT
      //  begin
      //    retryMode := hrmRaise;
      //    if assigned(OnConnectionLost) then
      //      OnConnectionLost(e, retryMode);
      //    if retryMode = hrmRaise then
      //      raise
      //    else if retryMode = hrmRetry then
      //      DoRequest(sMethod, AUrl, AContent, AResponse);
      //  end
      //  else
          raise;
      //end;
    end;
  end;
end;

procedure THttpConnectionFpHttp.Get(AUrl: string; AResponse: TStream);
begin
  DoRequest('GET', AUrl, nil, AResponse);
end;

procedure THttpConnectionFpHttp.Patch(AUrl: string; AContent,
  AResponse: TStream);
begin
  DoRequest('PATCH', AUrl, AContent, AResponse);
end;

procedure THttpConnectionFpHttp.Post(AUrl: string; AContent, AResponse: TStream);
begin
  DoRequest('POST', AUrl, AContent, AResponse);
end;

procedure THttpConnectionFpHttp.Put(AUrl: string; AContent,AResponse: TStream);
begin
  DoRequest('PUT', AUrl, AContent, AResponse);
end;

procedure THttpConnectionFpHttp.Delete(AUrl: string; AContent, AResponse: TStream);
begin
  DoRequest('DELETE', AUrl, AContent, AResponse);
end;

function THttpConnectionFpHttp.GetEnabledCompression: Boolean;
begin
  Result := False;
end;

function THttpConnectionFpHttp.GetOnConnectionLost: THTTPConnectionLostEvent;
begin
  result := OnConnectionLost;
end;

function THttpConnectionFpHttp.GetResponseCode: Integer;
begin
  Result := 200;//FFpHttpRequest.ResponseStatusCode;
end;

function THttpConnectionFpHttp.GetVerifyCert: boolean;
begin
 // result := FVerifyCert;
end;

function THttpConnectionFpHttp.GetResponseHeader(const Name: string): string;
begin
  //Result := FFpHttpRequest.GetResponseHeader(Name)
end;

function THttpConnectionFpHttp.SetAcceptedLanguages(AAcceptedLanguages: string): IHttpConnection;
begin
  FAcceptedLanguages := AAcceptedLanguages;

  Result := Self;
end;

function THttpConnectionFpHttp.SetAcceptTypes(AAcceptTypes: string): IHttpConnection;
begin
  FAcceptTypes := AAcceptTypes;

  Result := Self;
end;

function THttpConnectionFpHttp.SetContentTypes(AContentTypes: string): IHttpConnection;
begin
  FContentTypes := AContentTypes;

  Result := Self;
end;

procedure THttpConnectionFpHttp.SetEnabledCompression(const Value: Boolean);
begin
  //Nothing to do
end;

function THttpConnectionFpHttp.SetHeaders(AHeaders: TStrings): IHttpConnection;
begin
  FHeaders.Assign(AHeaders);

  Result := Self;
end;

procedure THttpConnectionFpHttp.SetOnConnectionLost(
  AConnectionLostEvent: THTTPConnectionLostEvent);
begin
  OnConnectionLost := AConnectionLostEvent;
end;

procedure THttpConnectionFpHttp.SetVerifyCert(const Value: boolean);
begin
  FVerifyCert := Value;
end;

end.
