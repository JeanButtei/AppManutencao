unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB,
  Vcl.AppEvnts;

type
  TServidor = class
  private
    FPath: String;
  public
    constructor Create;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant; aFileIndex: Integer): Boolean;
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FPath: String;
    FServidor: TServidor;

    function InitDataset: TClientDataset;
    procedure ClearPath;
  public
  end;

var
  fClienteServidor: TfClienteServidor;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

procedure TfClienteServidor.ClearPath;
var
  i: integer;
  SearchRec: TSearchRec;
  LocalPath: String;
begin
  LocalPath := (ExtractFilePath(ParamStr(0))) + '\Servidor\';

  i := FindFirst(LocalPath+'*.*', faAnyFile, SearchRec);
  while i = 0 do
  begin
    DeleteFile(LocalPath + SearchRec.Name);
    i := FindNext(SearchRec);
  end;

end;

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  try
    ProgressBar.Position := 0;
    ProgressBar.Max := (QTD_ARQUIVOS_ENVIAR - 1);

    for i := 0 to (QTD_ARQUIVOS_ENVIAR - 1) do
    begin
      ProgressBar.Position := (ProgressBar.Position + 1);
      cds := InitDataset;
      cds.Append;
      TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
      cds.Post;

      {$REGION Simulação de erro, não alterar}
      if i = (QTD_ARQUIVOS_ENVIAR/2) then
        FServidor.SalvarArquivos(NULL, i);
      {$ENDREGION}

      FServidor.SalvarArquivos(cds.Data, i);
      FreeAndNil(cds);
      ShowMessage('Processo concluído com êxito');
    end;
  except
    ProgressBar.Position := 0;
    ClearPath;
    raise;
  end;
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  ProgressBar.Position := 0;
  ProgressBar.Max := (QTD_ARQUIVOS_ENVIAR - 1);
  for i := 0 to (QTD_ARQUIVOS_ENVIAR - 1) do
  begin
    ProgressBar.Position := (ProgressBar.Position + 1);
    cds := InitDataset;
    cds.Append;      
    TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);  
    cds.Post;   
    FServidor.SalvarArquivos(cds.Data, i);
    FreeAndNil(cds);
    ShowMessage('Processo concluído com êxito');
  end;                 
end;

procedure TfClienteServidor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeAndNil(FServidor);
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  FServidor := TServidor.Create;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\';
end;

function TServidor.SalvarArquivos(AData: OleVariant; aFileIndex: Integer): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  try
    Result := False;
    try
      cds := TClientDataset.Create(nil);
      cds.Data := AData;

    {$REGION Simulação de erro, não alterar}
    if cds.RecordCount = 0 then
      Exit;
    {$ENDREGION}

      cds.First;

      while not cds.Eof do
      begin
        FileName := FPath + IntToStr(aFileIndex+1) + '.pdf';
        if TFile.Exists(FileName) then
          TFile.Delete(FileName);

        TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
        cds.Next;
      end;

      Result := True;
    except    
      raise;
    end;
  finally
    FreeAndNil(cds);
  end;
end;

end.
