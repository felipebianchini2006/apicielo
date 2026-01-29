unit uCieloApi;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Net.URLClient,
  System.Net.HttpClient,
  System.NetEncoding,
  uCieloConfig,
  uLogger;

type
  TCieloApiResponse = record
    HttpStatus: Integer;
    Body: string;
    ErrorMessage: string;
    function IsSuccess: Boolean;
  end;

  TCieloApiClient = class
  private
    FConfig: TCieloConfig;
    FLogger: TLogger;
    FHttp: TNetHTTPClient;
    procedure ApplyHeaders;
    function ExecutePost(const Url: string; const Payload: string): TCieloApiResponse;
    function ExecuteGet(const Url: string): TCieloApiResponse;
  public
    constructor Create(AConfig: TCieloConfig; ALogger: TLogger);
    destructor Destroy; override;
    // Creates a sale (payment/link) with POST /1/sales.
    function PostSales(const Payload: string): TCieloApiResponse;
    // Queries a sale by PaymentId with GET /1/sales/{PaymentId}.
    function GetSale(const PaymentId: string): TCieloApiResponse;
    // Simple auth test using a GET request.
    function TestAuth(const PaymentId: string): TCieloApiResponse;
  end;

implementation

function TCieloApiResponse.IsSuccess: Boolean;
begin
  Result := (HttpStatus >= 200) and (HttpStatus <= 299);
end;

constructor TCieloApiClient.Create(AConfig: TCieloConfig; ALogger: TLogger);
begin
  FConfig := AConfig;
  FLogger := ALogger;
  FHttp := TNetHTTPClient.Create(nil);
  FHttp.Accept := 'application/json';
  FHttp.ContentType := 'application/json';
  ApplyHeaders;
end;

destructor TCieloApiClient.Destroy;
begin
  FHttp.Free;
  inherited;
end;

procedure TCieloApiClient.ApplyHeaders;
begin
  FHttp.CustomHeaders['MerchantId'] := FConfig.MerchantId;
  FHttp.CustomHeaders['MerchantKey'] := FConfig.MerchantKey;
  FHttp.ConnectionTimeout := FConfig.TimeoutMs;
  FHttp.ResponseTimeout := FConfig.TimeoutMs;
end;

function TCieloApiClient.ExecutePost(const Url: string; const Payload: string): TCieloApiResponse;
var
  Response: IHTTPResponse;
  Stream: TStringStream;
begin
  ApplyHeaders;
  Stream := TStringStream.Create(Payload, TEncoding.UTF8);
  try
    if Assigned(FLogger) then
      FLogger.Log('POST ' + Url + ' payload=' + Payload);
    Response := FHttp.Post(Url, Stream);
    Result.HttpStatus := Response.StatusCode;
    Result.Body := Response.ContentAsString(TEncoding.UTF8);
    Result.ErrorMessage := '';
    if Assigned(FLogger) then
      FLogger.Log('Response ' + IntToStr(Result.HttpStatus) + ' body=' + Result.Body);
  except
    on E: Exception do
    begin
      Result.HttpStatus := 0;
      Result.Body := '';
      Result.ErrorMessage := E.Message;
      if Assigned(FLogger) then
        FLogger.Log('Error POST ' + Url + ' msg=' + E.Message);
    end;
  end;
end;

function TCieloApiClient.ExecuteGet(const Url: string): TCieloApiResponse;
var
  Response: IHTTPResponse;
begin
  ApplyHeaders;
  try
    if Assigned(FLogger) then
      FLogger.Log('GET ' + Url);
    Response := FHttp.Get(Url);
    Result.HttpStatus := Response.StatusCode;
    Result.Body := Response.ContentAsString(TEncoding.UTF8);
    Result.ErrorMessage := '';
    if Assigned(FLogger) then
      FLogger.Log('Response ' + IntToStr(Result.HttpStatus) + ' body=' + Result.Body);
  except
    on E: Exception do
    begin
      Result.HttpStatus := 0;
      Result.Body := '';
      Result.ErrorMessage := E.Message;
      if Assigned(FLogger) then
        FLogger.Log('Error GET ' + Url + ' msg=' + E.Message);
    end;
  end;
end;

function TCieloApiClient.PostSales(const Payload: string): TCieloApiResponse;
begin
  Result := ExecutePost(FConfig.BaseUrl + '/1/sales', Payload);
end;

function TCieloApiClient.GetSale(const PaymentId: string): TCieloApiResponse;
begin
  Result := ExecuteGet(FConfig.BaseUrl + '/1/sales/' + PaymentId);
end;

function TCieloApiClient.TestAuth(const PaymentId: string): TCieloApiResponse;
begin
  Result := GetSale(PaymentId);
end;

end.
