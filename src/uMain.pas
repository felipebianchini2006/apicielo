unit uMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.DateUtils,
  System.JSON,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  uCieloConfig,
  uCieloApi,
  uCieloInterpreter,
  uLogger;

type
  TfrmMain = class(TForm)
    PageMain: TPageControl;
    TabConfig: TTabSheet;
    TabLink: TTabSheet;
    TabLogs: TTabSheet;
    lblMerchantId: TLabel;
    lblMerchantKey: TLabel;
    lblEnvironment: TLabel;
    lblTimeout: TLabel;
    lblTestPaymentId: TLabel;
    edtMerchantId: TEdit;
    edtMerchantKey: TEdit;
    cbEnvironment: TComboBox;
    edtTimeout: TEdit;
    edtTestPaymentId: TEdit;
    btnLoadConfig: TButton;
    btnSaveConfig: TButton;
    btnTestAuth: TButton;
    memoAuthResult: TMemo;
    grpCreateLink: TGroupBox;
    lblExpiration: TLabel;
    lblTitle: TLabel;
    lblDescription: TLabel;
    lblOrderNumber: TLabel;
    lblAmount: TLabel;
    lblInstallments: TLabel;
    lblPaymentType: TLabel;
    lblReturnUrl: TLabel;
    lblCustomerName: TLabel;
    lblSoftDescriptor: TLabel;
    lblCapture: TLabel;
    lblAuthenticate: TLabel;
    chkCapture: TCheckBox;
    chkAuthenticate: TCheckBox;
    dtpExpiration: TDateTimePicker;
    edtTitle: TEdit;
    memoDescription: TMemo;
    edtOrderNumber: TEdit;
    edtAmount: TEdit;
    edtInstallments: TEdit;
    cbPaymentType: TComboBox;
    edtReturnUrl: TEdit;
    edtCustomerName: TEdit;
    edtSoftDescriptor: TEdit;
    chkIncludeCard: TCheckBox;
    grpCardData: TGroupBox;
    lblCardNumber: TLabel;
    lblCardHolder: TLabel;
    lblCardExp: TLabel;
    lblCardCvv: TLabel;
    lblCardBrand: TLabel;
    edtCardNumber: TEdit;
    edtCardHolder: TEdit;
    edtCardExp: TEdit;
    edtCardCvv: TEdit;
    cbCardBrand: TComboBox;
    lblAdditionalJson: TLabel;
    memoAdditionalJson: TMemo;
    lblMerchantFields: TLabel;
    memoMerchantFields: TMemo;
    btnCreateLink: TButton;
    memoCreateResponse: TMemo;
    grpConsult: TGroupBox;
    lblPaymentId: TLabel;
    lblTid: TLabel;
    lblAuthorization: TLabel;
    lblNsu: TLabel;
    lblBrandOut: TLabel;
    lblInstallmentsOut: TLabel;
    lblInstallmentAmountOut: TLabel;
    lblAmountOut: TLabel;
    lblLinkUrlOut: TLabel;
    edtPaymentId: TEdit;
    edtTid: TEdit;
    edtAuthorization: TEdit;
    edtNsu: TEdit;
    edtBrandOut: TEdit;
    edtInstallmentsOut: TEdit;
    edtInstallmentAmountOut: TEdit;
    edtAmountOut: TEdit;
    edtLinkUrlOut: TEdit;
    btnOpenLink: TButton;
    btnConsult: TButton;
    memoConsultResponse: TMemo;
    memoLogs: TMemo;
    btnOpenLog: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoadConfigClick(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure btnTestAuthClick(Sender: TObject);
    procedure btnCreateLinkClick(Sender: TObject);
    procedure btnConsultClick(Sender: TObject);
    procedure btnOpenLogClick(Sender: TObject);
    procedure chkIncludeCardClick(Sender: TObject);
    procedure btnOpenLinkClick(Sender: TObject);
  private
    FConfig: TCieloConfig;
    FLogger: TLogger;
    FApi: TCieloApiClient;
    FInterpreter: TCieloReturnInterpreter;
    function GetIniPath: string;
    function GetLogPath: string;
    procedure LoadConfigToUI;
    procedure SaveUIToConfig;
    procedure RefreshClient;
    procedure HandleLog(const Line: string);
    function ParseAmountToCents(const AmountText: string): Integer;
    function FormatCents(const Cents: Integer): string;
    function BuildCreatePayload: string;
    function FormatResult(const ResultData: TCieloReturn): string;
    procedure FillResultOutputs(const ResultData: TCieloReturn);
    procedure FillDetailMemo(AMemo: TMemo; const ResultData: TCieloReturn);
    function BuildMerchantDefinedFields: TJSONArray;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

function TfrmMain.GetIniPath: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'apicielo.ini';
end;

function TfrmMain.GetLogPath: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'apicielo.log';
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FConfig := TCieloConfig.Create;
  FLogger := TLogger.Create(GetLogPath);
  FLogger.OnLog := HandleLog;
  FInterpreter := TCieloReturnInterpreter.Create;

  cbEnvironment.Items.Add('Sandbox');
  cbEnvironment.Items.Add('Production');
  cbPaymentType.Items.Add('CreditCard');
  cbPaymentType.Items.Add('DebitCard');
  cbCardBrand.Items.Add('Visa');
  cbCardBrand.Items.Add('Master');
  cbCardBrand.Items.Add('Amex');
  cbCardBrand.Items.Add('Elo');
  cbCardBrand.Items.Add('Hipercard');

  LoadConfigToUI;
  if cbPaymentType.Items.Count > 0 then
    cbPaymentType.ItemIndex := 0;
  chkIncludeCard.Checked := False;
  chkIncludeCard.Enabled := False;
  grpCardData.Enabled := False;
  chkCapture.Checked := True;
  RefreshClient;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FApi.Free;
  FInterpreter.Free;
  FLogger.Free;
  FConfig.Free;
end;

procedure TfrmMain.HandleLog(const Line: string);
begin
  if memoLogs <> nil then
    memoLogs.Lines.Add(Line);
end;

procedure TfrmMain.LoadConfigToUI;
begin
  if FileExists(GetIniPath) then
    FConfig.LoadFromIni(GetIniPath);
  edtMerchantId.Text := FConfig.MerchantId;
  edtMerchantKey.Text := FConfig.MerchantKey;
  edtTimeout.Text := IntToStr(FConfig.TimeoutMs);
  if FConfig.Environment = ceProduction then
    cbEnvironment.ItemIndex := 1
  else
    cbEnvironment.ItemIndex := 0;
end;

procedure TfrmMain.SaveUIToConfig;
begin
  FConfig.MerchantId := Trim(edtMerchantId.Text);
  FConfig.MerchantKey := Trim(edtMerchantKey.Text);
  FConfig.TimeoutMs := StrToIntDef(Trim(edtTimeout.Text), 15000);
  if cbEnvironment.ItemIndex = 1 then
    FConfig.Environment := ceProduction
  else
    FConfig.Environment := ceSandbox;
  FConfig.ApplyEnvironment;
  FConfig.SaveToIni(GetIniPath);
end;

procedure TfrmMain.RefreshClient;
begin
  FreeAndNil(FApi);
  FApi := TCieloApiClient.Create(FConfig, FLogger);
end;

procedure TfrmMain.btnLoadConfigClick(Sender: TObject);
begin
  LoadConfigToUI;
  RefreshClient;
  if Assigned(FLogger) then
    FLogger.Log('Config loaded from ini');
end;

procedure TfrmMain.btnSaveConfigClick(Sender: TObject);
begin
  SaveUIToConfig;
  RefreshClient;
  if Assigned(FLogger) then
    FLogger.Log('Config saved to ini');
end;

procedure TfrmMain.btnTestAuthClick(Sender: TObject);
var
  Response: TCieloApiResponse;
  PaymentId: string;
  Parsed: TCieloReturn;
begin
  SaveUIToConfig;
  RefreshClient;
  PaymentId := Trim(edtTestPaymentId.Text);
  if PaymentId = '' then
    PaymentId := '00000000-0000-0000-0000-000000000000';
  Response := FApi.TestAuth(PaymentId);
  Parsed := FInterpreter.Interpret(Response);
  FillDetailMemo(memoAuthResult, Parsed);
  memoAuthResult.Lines.Add('Raw:');
  memoAuthResult.Lines.Add(Response.Body);
end;

procedure TfrmMain.btnCreateLinkClick(Sender: TObject);
var
  Payload: string;
  Response: TCieloApiResponse;
  Parsed: TCieloReturn;
begin
  SaveUIToConfig;
  RefreshClient;
  Payload := BuildCreatePayload;
  Response := FApi.PostSales(Payload);
  Parsed := FInterpreter.Interpret(Response);
  FillResultOutputs(Parsed);
  FillDetailMemo(memoCreateResponse, Parsed);
  memoCreateResponse.Lines.Add('Raw:');
  memoCreateResponse.Lines.Add(Response.Body);
end;

procedure TfrmMain.btnConsultClick(Sender: TObject);
var
  Response: TCieloApiResponse;
  Parsed: TCieloReturn;
  PaymentId: string;
begin
  SaveUIToConfig;
  RefreshClient;
  PaymentId := Trim(edtPaymentId.Text);
  Response := FApi.GetSale(PaymentId);
  Parsed := FInterpreter.Interpret(Response);
  FillResultOutputs(Parsed);
  FillDetailMemo(memoConsultResponse, Parsed);
  memoConsultResponse.Lines.Add('Raw:');
  memoConsultResponse.Lines.Add(Response.Body);
end;

procedure TfrmMain.btnOpenLogClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(GetLogPath), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmMain.chkIncludeCardClick(Sender: TObject);
begin
  grpCardData.Enabled := chkIncludeCard.Checked;
end;

procedure TfrmMain.btnOpenLinkClick(Sender: TObject);
var
  Url: string;
begin
  Url := Trim(edtLinkUrlOut.Text);
  if Url <> '' then
    ShellExecute(Handle, 'open', PChar(Url), nil, nil, SW_SHOWNORMAL);
end;

function TfrmMain.ParseAmountToCents(const AmountText: string): Integer;
var
  Normalized: string;
  Value: Double;
  FS: TFormatSettings;
begin
  Normalized := StringReplace(AmountText, ',', '.', [rfReplaceAll]);
  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';
  if TryStrToFloat(Normalized, Value, FS) then
    Result := Round(Value * 100)
  else
    Result := StrToIntDef(Trim(AmountText), 0);
end;

function TfrmMain.FormatCents(const Cents: Integer): string;
begin
  Result := FormatFloat('0.00', Cents / 100);
end;

function TfrmMain.BuildMerchantDefinedFields: TJSONArray;
var
  Lines: TStringList;
  I: Integer;
  Line: string;
  SepPos: Integer;
  IdText: string;
  ValText: string;
  IdValue: Integer;
  Item: TJSONObject;
begin
  Result := nil;
  if Trim(memoMerchantFields.Text) = '' then
    Exit;
  Lines := TStringList.Create;
  try
    Lines.Text := memoMerchantFields.Text;
    Result := TJSONArray.Create;
    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);
      if Line = '' then
        Continue;
      SepPos := Pos('=', Line);
      if SepPos = 0 then
        SepPos := Pos(':', Line);
      if SepPos = 0 then
        Continue;
      IdText := Trim(Copy(Line, 1, SepPos - 1));
      ValText := Trim(Copy(Line, SepPos + 1, MaxInt));
      IdValue := StrToIntDef(IdText, -1);
      if IdValue < 0 then
        Continue;
      Item := TJSONObject.Create;
      Item.AddPair('Id', TJSONNumber.Create(IdValue));
      Item.AddPair('Value', ValText);
      Result.Add(Item);
    end;
    if Result.Count = 0 then
    begin
      Result.Free;
      Result := nil;
    end;
  finally
    Lines.Free;
  end;
end;

function TfrmMain.BuildCreatePayload: string;
var
  Root: TJSONObject;
  Customer: TJSONObject;
  Payment: TJSONObject;
  Link: TJSONObject;
  PaymentType: string;
  AmountCents: Integer;
  Installments: Integer;
  Additional: TJSONValue;
  MerchantFields: TJSONArray;
begin
  Root := TJSONObject.Create;
  try
    Root.AddPair('MerchantOrderId', Trim(edtOrderNumber.Text));

    if Trim(edtCustomerName.Text) <> '' then
    begin
      Customer := TJSONObject.Create;
      Customer.AddPair('Name', Trim(edtCustomerName.Text));
      Root.AddPair('Customer', Customer);
    end;

    Payment := TJSONObject.Create;
    PaymentType := Trim(cbPaymentType.Text);
    if PaymentType = '' then
      PaymentType := 'CreditCard';
    Payment.AddPair('Type', PaymentType);

    AmountCents := ParseAmountToCents(edtAmount.Text);
    Installments := StrToIntDef(Trim(edtInstallments.Text), 1);
    Payment.AddPair('Amount', TJSONNumber.Create(AmountCents));
    Payment.AddPair('Installments', TJSONNumber.Create(Installments));

    if Trim(edtSoftDescriptor.Text) <> '' then
      Payment.AddPair('SoftDescriptor', Trim(edtSoftDescriptor.Text));

    if chkCapture.Checked then
      Payment.AddPair('Capture', TJSONBool.Create(True));
    if chkAuthenticate.Checked then
      Payment.AddPair('Authenticate', TJSONBool.Create(True));

    Link := TJSONObject.Create;
    Link.AddPair('ExpirationDate', FormatDateTime('yyyy-mm-dd', dtpExpiration.Date));
    if Trim(edtTitle.Text) <> '' then
      Link.AddPair('Title', Trim(edtTitle.Text));
    if Trim(memoDescription.Text) <> '' then
      Link.AddPair('Description', Trim(memoDescription.Text));
    if Trim(edtOrderNumber.Text) <> '' then
      Link.AddPair('Number', Trim(edtOrderNumber.Text));
    if Trim(edtReturnUrl.Text) <> '' then
      Link.AddPair('ReturnUrl', Trim(edtReturnUrl.Text));
    Payment.AddPair('Link', Link);

    // Payment link: card data is provided by the customer on the hosted page.

    Root.AddPair('Payment', Payment);

    MerchantFields := BuildMerchantDefinedFields;
    if MerchantFields <> nil then
      Root.AddPair('MerchantDefinedFields', MerchantFields);

    if Trim(memoAdditionalJson.Text) <> '' then
    begin
      Additional := TJSONObject.ParseJSONValue(Trim(memoAdditionalJson.Text));
      if Additional <> nil then
        Root.AddPair('AdditionalData', Additional);
    end;

    Result := Root.ToJSON;
  finally
    Root.Free;
  end;
end;

function TfrmMain.FormatResult(const ResultData: TCieloReturn): string;
begin
  Result := 'Status=' + ResultData.StatusMessage +
    ' Friendly=' + ResultData.FriendlyMessage +
    ' PaymentId=' + ResultData.PaymentId +
    ' Tid=' + ResultData.Tid +
    ' Auth=' + ResultData.AuthorizationCode +
    ' Nsu=' + ResultData.Nsu +
    ' Brand=' + ResultData.Brand +
    ' Installments=' + IntToStr(ResultData.Installments) +
    ' InstallmentAmount=' + FormatCents(ResultData.InstallmentAmount) +
    ' Amount=' + FormatCents(ResultData.Amount) +
    ' LinkUrl=' + ResultData.LinkUrl +
    ' ReturnCode=' + ResultData.ReturnCode +
    ' ReturnMessage=' + ResultData.ReturnMessage +
    ' ErrorCode=' + ResultData.ErrorCode +
    ' ErrorMessage=' + ResultData.ErrorMessage;
end;

procedure TfrmMain.FillResultOutputs(const ResultData: TCieloReturn);
var
  LinkToShow: string;
begin
  edtPaymentId.Text := ResultData.PaymentId;
  edtTid.Text := ResultData.Tid;
  edtAuthorization.Text := ResultData.AuthorizationCode;
  edtNsu.Text := ResultData.Nsu;
  edtBrandOut.Text := ResultData.Brand;
  edtInstallmentsOut.Text := IntToStr(ResultData.Installments);
  edtInstallmentAmountOut.Text := FormatCents(ResultData.InstallmentAmount);
  edtAmountOut.Text := FormatCents(ResultData.Amount);
  LinkToShow := ResultData.LinkShortUrl;
  if LinkToShow = '' then
    LinkToShow := ResultData.LinkUrl;
  edtLinkUrlOut.Text := LinkToShow;
end;

procedure AddDetailLine(AMemo: TMemo; const LabelText: string; const Value: string);
begin
  if Value <> '' then
    AMemo.Lines.Add(LabelText + ': ' + Value);
end;

procedure TfrmMain.FillDetailMemo(AMemo: TMemo; const ResultData: TCieloReturn);
begin
  if AMemo = nil then
    Exit;
  AMemo.Lines.BeginUpdate;
  try
    AMemo.Lines.Clear;
    AMemo.Lines.Add('HttpStatus: ' + IntToStr(ResultData.HttpStatus));
    AMemo.Lines.Add('Success: ' + BoolToStr(ResultData.Success, True));
    AddDetailLine(AMemo, 'Status', ResultData.StatusMessage);
    AddDetailLine(AMemo, 'FriendlyMessage', ResultData.FriendlyMessage);
    AddDetailLine(AMemo, 'MerchantOrderId', ResultData.MerchantOrderId);
    AddDetailLine(AMemo, 'PaymentType', ResultData.PaymentType);
    AddDetailLine(AMemo, 'PaymentId', ResultData.PaymentId);
    AddDetailLine(AMemo, 'Tid', ResultData.Tid);
    AddDetailLine(AMemo, 'AuthorizationCode', ResultData.AuthorizationCode);
    AddDetailLine(AMemo, 'Nsu', ResultData.Nsu);
    AddDetailLine(AMemo, 'Brand', ResultData.Brand);
    AddDetailLine(AMemo, 'Installments', IntToStr(ResultData.Installments));
    AddDetailLine(AMemo, 'InstallmentAmount', FormatCents(ResultData.InstallmentAmount));
    AddDetailLine(AMemo, 'Amount', FormatCents(ResultData.Amount));
    AddDetailLine(AMemo, 'LinkUrl', ResultData.LinkUrl);
    AddDetailLine(AMemo, 'LinkShortUrl', ResultData.LinkShortUrl);
    AddDetailLine(AMemo, 'LinkNumber', ResultData.LinkNumber);
    AddDetailLine(AMemo, 'LinkTitle', ResultData.LinkTitle);
    AddDetailLine(AMemo, 'LinkDescription', ResultData.LinkDescription);
    AddDetailLine(AMemo, 'LinkReturnUrl', ResultData.LinkReturnUrl);
    AddDetailLine(AMemo, 'LinkExpirationDate', ResultData.LinkExpirationDate);
    AddDetailLine(AMemo, 'ReturnCode', ResultData.ReturnCode);
    AddDetailLine(AMemo, 'ReturnMessage', ResultData.ReturnMessage);
    AddDetailLine(AMemo, 'ErrorCode', ResultData.ErrorCode);
    AddDetailLine(AMemo, 'ErrorMessage', ResultData.ErrorMessage);
  finally
    AMemo.Lines.EndUpdate;
  end;
end;

end.
