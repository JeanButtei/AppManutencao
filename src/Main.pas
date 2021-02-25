unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.AppEvnts;

type
  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    ApplicationEvents1: TApplicationEvents;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
  private
  public
  end;

var
  fMain: TfMain;

implementation

uses
  DatasetLoop, ClienteServidor;

{$R *.dfm}

procedure TfMain.ApplicationEvents1Exception(Sender: TObject; E: Exception);
var
  LogPath: string;
  LogFile: TextFile;
begin
  LogPath := GetCurrentDir + '\Exceptions.txt';

  AssignFile(LogFile, LogPath);

  if FileExists(LogPath) then
    Append(LogFile)
  else
    ReWrite(LogFile);


  WriteLn(LogFile, 'Mensagem........: ' + E.Message);
  WriteLn(LogFile, 'Classe Exceção..: ' + E.ClassName);
  WriteLn(LogFile, StringOfChar('-', 70));

  CloseFile(LogFile);
  ShowMessage('Ocorreram erros durante o processamento. Verifique o log em ' + LogPath);
end;

procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  fDatasetLoop.Show;
end;

procedure TfMain.btStreamsClick(Sender: TObject);
begin
  fClienteServidor.Show;
end;

end.
