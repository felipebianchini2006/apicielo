unit uLogger;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils;

type
  TLogEvent = procedure(const Line: string) of object;

  TLogger = class
  private
    FFilePath: string;
    FOnLog: TLogEvent;
  public
    constructor Create(const FilePath: string);
    procedure Log(const Line: string);
    property FilePath: string read FFilePath;
    property OnLog: TLogEvent read FOnLog write FOnLog;
  end;

implementation

constructor TLogger.Create(const FilePath: string);
begin
  FFilePath := FilePath;
end;

procedure TLogger.Log(const Line: string);
var
  FullLine: string;
begin
  FullLine := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' - ' + Line;
  TFile.AppendAllText(FFilePath, FullLine + sLineBreak, TEncoding.UTF8);
  if Assigned(FOnLog) then
    FOnLog(FullLine);
end;

end.
