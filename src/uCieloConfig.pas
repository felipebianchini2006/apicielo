unit uCieloConfig;

interface

uses
  System.SysUtils,
  System.IniFiles;

type
  TCieloEnvironment = (ceSandbox, ceProduction);

  TCieloConfig = class
  private
    FMerchantId: string;
    FMerchantKey: string;
    FBaseUrl: string;
    FTimeoutMs: Integer;
    FEnvironment: TCieloEnvironment;
  public
    constructor Create;
    procedure ApplyEnvironment;
    // Load auth parameters from ini file.
    procedure LoadFromIni(const FilePath: string);
    // Persist auth parameters to ini file.
    procedure SaveToIni(const FilePath: string);
    property MerchantId: string read FMerchantId write FMerchantId;
    property MerchantKey: string read FMerchantKey write FMerchantKey;
    property BaseUrl: string read FBaseUrl write FBaseUrl;
    property TimeoutMs: Integer read FTimeoutMs write FTimeoutMs;
    property Environment: TCieloEnvironment read FEnvironment write FEnvironment;
  end;

const
  CIELO_SANDBOX_URL = 'https://apisandbox.cieloecommerce.cielo.com.br';
  CIELO_PROD_URL = 'https://api.cieloecommerce.cielo.com.br';

implementation

constructor TCieloConfig.Create;
begin
  FEnvironment := ceSandbox;
  FTimeoutMs := 15000;
  ApplyEnvironment;
end;

procedure TCieloConfig.ApplyEnvironment;
begin
  case FEnvironment of
    ceSandbox: FBaseUrl := CIELO_SANDBOX_URL;
    ceProduction: FBaseUrl := CIELO_PROD_URL;
  end;
end;

procedure TCieloConfig.LoadFromIni(const FilePath: string);
var
  Ini: TIniFile;
  EnvText: string;
begin
  Ini := TIniFile.Create(FilePath);
  try
    FMerchantId := Ini.ReadString('Auth', 'MerchantId', '');
    FMerchantKey := Ini.ReadString('Auth', 'MerchantKey', '');
    FTimeoutMs := Ini.ReadInteger('Auth', 'TimeoutMs', 15000);
    EnvText := Ini.ReadString('Auth', 'Environment', 'Sandbox');
    if SameText(EnvText, 'Production') then
      FEnvironment := ceProduction
    else
      FEnvironment := ceSandbox;
    ApplyEnvironment;
  finally
    Ini.Free;
  end;
end;

procedure TCieloConfig.SaveToIni(const FilePath: string);
var
  Ini: TIniFile;
  EnvText: string;
begin
  Ini := TIniFile.Create(FilePath);
  try
    Ini.WriteString('Auth', 'MerchantId', FMerchantId);
    Ini.WriteString('Auth', 'MerchantKey', FMerchantKey);
    Ini.WriteInteger('Auth', 'TimeoutMs', FTimeoutMs);
    if FEnvironment = ceProduction then
      EnvText := 'Production'
    else
      EnvText := 'Sandbox';
    Ini.WriteString('Auth', 'Environment', EnvText);
  finally
    Ini.Free;
  end;
end;

end.
