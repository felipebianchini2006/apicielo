unit uCieloInterpreter;

interface

uses
  System.SysUtils,
  System.JSON,
  uCieloApi;

type
  TCieloPaymentStatus = (
    psUnknown,
    psNotFinished,
    psAuthorized,
    psConfirmed,
    psDenied,
    psVoided,
    psRefunded,
    psPending
  );

  TCieloReturn = record
    Success: Boolean;
    HttpStatus: Integer;
    Status: TCieloPaymentStatus;
    StatusMessage: string;
    FriendlyMessage: string;
    MerchantOrderId: string;
    PaymentType: string;
    PaymentId: string;
    Tid: string;
    AuthorizationCode: string;
    Nsu: string;
    Brand: string;
    Installments: Integer;
    Amount: Integer;
    InstallmentAmount: Integer;
    LinkUrl: string;
    LinkShortUrl: string;
    LinkNumber: string;
    LinkTitle: string;
    LinkDescription: string;
    LinkReturnUrl: string;
    LinkExpirationDate: string;
    ReturnCode: string;
    ReturnMessage: string;
    ErrorCode: string;
    ErrorMessage: string;
    RawJson: string;
  end;

  TCieloReturnInterpreter = class
  public
    // Interpret a response and map status/error fields.
    function Interpret(const ApiResponse: TCieloApiResponse): TCieloReturn;
    // Convert status enum to text for UI display.
    class function StatusToText(Status: TCieloPaymentStatus): string;
  end;

implementation

function ReadStringValue(Obj: TJSONObject; const Name: string): string;
var
  Value: TJSONValue;
begin
  Result := '';
  if Obj = nil then
    Exit;
  Value := Obj.GetValue(Name);
  if Value <> nil then
    Result := Value.Value;
end;

function ReadIntValue(Obj: TJSONObject; const Name: string; const DefaultValue: Integer): Integer;
var
  Value: TJSONValue;
begin
  Result := DefaultValue;
  if Obj = nil then
    Exit;
  Value := Obj.GetValue(Name);
  if Value <> nil then
  begin
    if Value is TJSONNumber then
      Result := TJSONNumber(Value).AsInt
    else
      Result := StrToIntDef(Value.Value, DefaultValue);
  end;
end;

function ReadObjValue(Obj: TJSONObject; const Name: string): TJSONObject;
var
  Value: TJSONValue;
begin
  Result := nil;
  if Obj = nil then
    Exit;
  Value := Obj.GetValue(Name);
  if Value is TJSONObject then
    Result := TJSONObject(Value);
end;

function ReadArrayValue(Obj: TJSONObject; const Name: string): TJSONArray;
var
  Value: TJSONValue;
begin
  Result := nil;
  if Obj = nil then
    Exit;
  Value := Obj.GetValue(Name);
  if Value is TJSONArray then
    Result := TJSONArray(Value);
end;

function MapStatus(StatusCode: Integer): TCieloPaymentStatus;
begin
  // Update this mapping when Cielo adds new status codes.
  case StatusCode of
    0: Result := psNotFinished;
    1: Result := psAuthorized;
    2: Result := psConfirmed;
    3: Result := psDenied;
    10: Result := psVoided;
    11: Result := psRefunded;
    12: Result := psPending;
  else
    Result := psUnknown;
  end;
end;

class function TCieloReturnInterpreter.StatusToText(Status: TCieloPaymentStatus): string;
begin
  case Status of
    psNotFinished: Result := 'NotFinished';
    psAuthorized: Result := 'Authorized';
    psConfirmed: Result := 'Confirmed';
    psDenied: Result := 'Denied';
    psVoided: Result := 'Voided';
    psRefunded: Result := 'Refunded';
    psPending: Result := 'Pending';
  else
    Result := 'Unknown';
  end;
end;

function FindLinkHref(Links: TJSONArray; const Rel: string): string;
var
  I: Integer;
  Obj: TJSONObject;
  RelValue: string;
begin
  Result := '';
  if Links = nil then
    Exit;
  for I := 0 to Links.Count - 1 do
  begin
    if Links.Items[I] is TJSONObject then
    begin
      Obj := TJSONObject(Links.Items[I]);
      RelValue := ReadStringValue(Obj, 'Rel');
      if SameText(RelValue, Rel) then
      begin
        Result := ReadStringValue(Obj, 'Href');
        Exit;
      end;
    end;
  end;
  if (Links.Count > 0) and (Links.Items[0] is TJSONObject) then
    Result := ReadStringValue(TJSONObject(Links.Items[0]), 'Href');
end;

function BuildFriendlyMessage(const Data: TCieloReturn): string;
begin
  // Basic message resolution. Extend with new codes as needed.
  if Data.ErrorMessage <> '' then
    Exit(Data.ErrorMessage);
  if Data.ReturnMessage <> '' then
    Exit(Data.ReturnMessage);
  case Data.HttpStatus of
    200..299: Result := 'Operacao realizada com sucesso';
    400: Result := 'Requisicao invalida';
    401: Result := 'Nao autorizado';
    403: Result := 'Acesso negado';
    404: Result := 'Recurso nao encontrado';
    422: Result := 'Dados invalidos';
    500..599: Result := 'Erro interno da API';
  else
    Result := 'Resposta nao reconhecida';
  end;
end;

function TCieloReturnInterpreter.Interpret(const ApiResponse: TCieloApiResponse): TCieloReturn;
var
  Json: TJSONValue;
  Root: TJSONObject;
  Payment: TJSONObject;
  LinkObj: TJSONObject;
  StatusCode: Integer;
  ErrorObj: TJSONObject;
begin
  Result.Success := ApiResponse.IsSuccess;
  Result.HttpStatus := ApiResponse.HttpStatus;
  Result.Status := psUnknown;
  Result.StatusMessage := '';
  Result.FriendlyMessage := '';
  Result.MerchantOrderId := '';
  Result.PaymentType := '';
  Result.PaymentId := '';
  Result.Tid := '';
  Result.AuthorizationCode := '';
  Result.Nsu := '';
  Result.Brand := '';
  Result.Installments := 0;
  Result.Amount := 0;
  Result.InstallmentAmount := 0;
  Result.LinkUrl := '';
  Result.LinkShortUrl := '';
  Result.LinkNumber := '';
  Result.LinkTitle := '';
  Result.LinkDescription := '';
  Result.LinkReturnUrl := '';
  Result.LinkExpirationDate := '';
  Result.ReturnCode := '';
  Result.ReturnMessage := '';
  Result.ErrorCode := '';
  Result.ErrorMessage := '';
  Result.RawJson := ApiResponse.Body;

  Json := TJSONObject.ParseJSONValue(ApiResponse.Body);
  try
    if (Json <> nil) and (Json is TJSONObject) then
    begin
      Root := TJSONObject(Json);
      Result.MerchantOrderId := ReadStringValue(Root, 'MerchantOrderId');
      Payment := Root.GetValue('Payment') as TJSONObject;
      if Payment <> nil then
      begin
        Result.PaymentType := ReadStringValue(Payment, 'Type');
        Result.PaymentId := ReadStringValue(Payment, 'PaymentId');
        Result.Tid := ReadStringValue(Payment, 'Tid');
        Result.AuthorizationCode := ReadStringValue(Payment, 'AuthorizationCode');
        Result.Nsu := ReadStringValue(Payment, 'Nsu');
        Result.Brand := ReadStringValue(Payment, 'Brand');
        Result.Installments := ReadIntValue(Payment, 'Installments', 0);
        Result.Amount := ReadIntValue(Payment, 'Amount', 0);
        if Result.Installments > 0 then
          Result.InstallmentAmount := Result.Amount div Result.Installments;
        Result.LinkUrl := ReadStringValue(Payment, 'Url');
        Result.ReturnCode := ReadStringValue(Payment, 'ReturnCode');
        Result.ReturnMessage := ReadStringValue(Payment, 'ReturnMessage');
        StatusCode := ReadIntValue(Payment, 'Status', -1);
        Result.Status := MapStatus(StatusCode);
        Result.StatusMessage := StatusToText(Result.Status);
      end;

      if Payment <> nil then
      begin
        if Result.LinkUrl = '' then
          Result.LinkUrl := FindLinkHref(ReadArrayValue(Payment, 'Links'), 'paymentlink');
        if Result.LinkUrl = '' then
          Result.LinkUrl := FindLinkHref(ReadArrayValue(Payment, 'Links'), 'self');
      end;

      if Payment <> nil then
      begin
        LinkObj := ReadObjValue(Payment, 'Link');
        if LinkObj <> nil then
        begin
          Result.LinkNumber := ReadStringValue(LinkObj, 'Number');
          Result.LinkTitle := ReadStringValue(LinkObj, 'Title');
          Result.LinkDescription := ReadStringValue(LinkObj, 'Description');
          Result.LinkReturnUrl := ReadStringValue(LinkObj, 'ReturnUrl');
          Result.LinkExpirationDate := ReadStringValue(LinkObj, 'ExpirationDate');
          Result.LinkShortUrl := ReadStringValue(LinkObj, 'ShortUrl');
          if Result.LinkUrl = '' then
            Result.LinkUrl := ReadStringValue(LinkObj, 'Url');
        end;
      end;

      ErrorObj := Root.GetValue('Error') as TJSONObject;
      if ErrorObj <> nil then
      begin
        Result.ErrorCode := ReadStringValue(ErrorObj, 'Code');
        Result.ErrorMessage := ReadStringValue(ErrorObj, 'Message');
      end
      else
      begin
        Result.ErrorCode := ReadStringValue(Root, 'Code');
        Result.ErrorMessage := ReadStringValue(Root, 'Message');
      end;
    end;
  finally
    Json.Free;
  end;

  Result.FriendlyMessage := BuildFriendlyMessage(Result);
end;

end.
