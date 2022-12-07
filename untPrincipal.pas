unit untPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FileCtrl, Vcl.Buttons,
  PngBitBtn, System.IOUtils, System.Types, Vcl.Mask, Vcl.ExtCtrls, Winapi.ShellAPI,
  Vcl.CheckLst, Vcl.Grids, Vcl.ComCtrls, untEncodeThread, Vcl.Menus;

type
  TfrmPrincipal = class(TForm)
    pbSourceLocation: TGroupBox;
    edtSource: TEdit;
    btnLoadSourcePath: TButton;
    odDialog: TFileOpenDialog;
    gb: TGroupBox;
    btnLocalParaSalvar: TButton;
    edtOutput: TEdit;
    btnEncode: TPngBitBtn;
    gpbFileList: TGroupBox;
    lblArquivosEncontrados: TLabel;
    gbOpcoes: TGroupBox;
    edtHandBreak: TEdit;
    btnOpenCLI: TButton;
    Label1: TLabel;
    hbDialog: TOpenDialog;
    Label2: TLabel;
    cbSemLegenda: TComboBox;
    edtFiltro: TLabeledEdit;
    cbPreset: TComboBox;
    Label3: TLabel;
    btnClose: TPngBitBtn;
    btnHandBreakHelp: TButton;
    btnSobre: TButton;
    FileList2: TListView;
    timerCoding: TTimer;
    timerCheckFinish: TTimer;
    Status: TProgressBar;
    edtExtraFlags: TLabeledEdit;
    btnExtraFlagsHelp: TButton;
    edtProcessos: TLabeledEdit;
    procedure btnLoadSourcePathClick(Sender: TObject);
    procedure btnEncodeClick(Sender: TObject);
    function GenerateOutputFile(InputFile: String): String;
    procedure btnOpenCLIClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnHandBreakHelpClick(Sender: TObject);
    procedure btnSobreClick(Sender: TObject);
    procedure timerCodingTimer(Sender: TObject);
    procedure timerCheckFinishTimer(Sender: TObject);
    procedure btnLocalParaSalvarClick(Sender: TObject);
    procedure btnExtraFlagsHelpClick(Sender: TObject);
  private
    HandBreakPath: String;
    function BuildParams(sourcefile, outputFile: String): WideString;
    function HasSubtitle(sourcefile: String): Boolean;
    procedure FixDirectory;
    procedure LoadFiles();
    procedure BuildThreadForFile(Index: Integer);
    function GetNextFile(Status: Integer): Integer;
    procedure FixNoSubtitles;
    { Private declarations }
  public
    { Public declarations }
    ThreadList: Array of TEncodeThread;
    RunningThreads: Integer;
    procedure DoTerminateEvent(Sender: TObject);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

function MySortProc(List: TStringList; Index1, Index2: Integer): Integer;
var
 Total1, Total2: Integer;
begin
  Total1 := List[Index1].CountChar('\');
  Total2 := List[Index2].CountChar('\');
  if Total1 < Total2 then
    Result := -1
  else if Total2 < Total1 then
    Result := 1
  else
    Result := 0;

end;

procedure TfrmPrincipal.btnCloseClick(Sender: TObject);
begin
  Close;
end;

function TfrmPrincipal.BuildParams(sourcefile, outputFile: String): WideString;
var
  FParams: WideString;
begin
  FParams := '-i "#inputfile#" -Z "#preset#" --srt-file "#subtitlefile#" --srt-burn "1" #extra# -o "#outputfile#"';
  FParams := StringReplace(FParams, '#inputfile#', sourcefile, []);
  FParams := StringReplace(FParams, '#subtitlefile#', ChangeFileExt(sourcefile, '.srt'), []);
  FParams := StringReplace(FParams, '#outputfile#', outputFile, []);
  FParams := StringReplace(FParams, '#preset#', cbPreset.Text, []);
  FParams := StringReplace(FParams, '#extra#', Trim(edtExtraFlags.Text), []);
  Result := FParams;
end;

procedure TfrmPrincipal.BuildThreadForFile(Index: Integer);
var
  Source, Output: String;
begin

  if RunningThreads < StrToInt(edtProcessos.Text) then begin
    Inc(RunningThreads);
    Source := FileList2.Items[Index].SubItems[0];
    OutPut := GenerateOutputFile(Source);
    FileList2.Items[Index].SubItems[2] := '3';
    ThreadList[Index] := TEncodeThread.Create(edtHandBreak.Text, BuildParams(Source, Output), FileList2, Index);
    ThreadList[Index].FreeOnTerminate:=true;
    ThreadList[Index].OnTerminate := DoTerminateEvent;
    ThreadList[Index].Start;
  end;

end;

procedure TfrmPrincipal.btnEncodeClick(Sender: TObject);
var
  i: Integer;
begin
  for I := 0 to FileList2.Items.Count-1 do begin
    FileList2.Items[i].SubItems[1] := 'Aguardando In�cio';
    FileList2.Items[i].SubItems[2] := '0';
  end;

  btnEncode.Enabled := False;
  gbOpcoes.Enabled := False;
  RunningThreads := 0;
  Status.Visible := True;
  Status.Max := 0;
  Status.Position := 0;
  SetLength(ThreadList, FileList2.Items.Count);
  FixDirectory;
  FixNoSubtitles;
  timerCoding.Enabled := true;

end;

procedure TfrmPrincipal.btnExtraFlagsHelpClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://handbrake.fr/docs/en/latest/cli/command-line-reference.html'), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmPrincipal.btnLoadSourcePathClick(Sender: TObject);
begin

  if odDialog.Execute then begin
    edtSource.Text := odDialog.FileName;
    edtOutput.Text := edtSource.Text + ' - Legendado';
    LoadFiles();
  end;

end;

procedure TfrmPrincipal.btnLocalParaSalvarClick(Sender: TObject);
begin
  if odDialog.Execute then begin
    edtOutput.Text := odDialog.FileName;
  end;
end;

procedure TfrmPrincipal.btnHandBreakHelpClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://handbrake.fr/downloads2.php'), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmPrincipal.btnOpenCLIClick(Sender: TObject);
begin
if hbDialog.Execute then
  edtHandBreak.Text := hbDialog.FileName;

end;

procedure TfrmPrincipal.btnSobreClick(Sender: TObject);
begin
  ShowMessage('Desenvolvido por @andcarpi');
end;

procedure TfrmPrincipal.DoTerminateEvent(Sender: TObject);
var
  Index: Integer;
begin
  Index := TEncodeThread(Sender).IndexP;
  //ThreadList[Index].Terminate
  Dec(RunningThreads);
  ThreadList[Index] := nil;
  Status.StepIt;

//  ShowMessage(IntToStr(TEncodeThread(Sender).IndexP));
end;

procedure TfrmPrincipal.FixDirectory;
var
  i: Integer;
  Dir: String;
begin
  for i := 0 to fileList2.Items.Count-1 do begin
    if fileList2.Items[i].Checked then begin
      Dir := GenerateOutputFile(fileList2.Items[i].SubItems[0]);
      Dir := ExtractFileDir(Dir);
      if (not DirectoryExists(Dir)) then
        CreateDir(Dir);
    end;
  end;
end;

procedure TfrmPrincipal.FixNoSubtitles;
var
  i: Integer;
begin
  for I := 0 to FileList2.Items.Count-1 do begin
    if (not HasSubtitle(FileList2.Items[i].SubItems[0])) then begin
      FileList2.Items[i].SubItems[2] := '2';
      FileList2.Items[i].SubItems[1] := 'Sem Legendas!';
      if cbSemLegenda.ItemIndex = 1 then
        CopyFile(PWideChar(FileList2.Items[i].SubItems[0]), PWideChar(FileList2.Items[i].SubItems[3]), True);
    end else begin
      Status.Max := Status.Max + 1;
    end;
  
  end;

end;

function TfrmPrincipal.GenerateOutputFile(InputFile: String): String;
var
  outputFile: String;
begin
  outputFile := InputFile;
  Delete(outputFile, 1, Length(edtSource.Text));
  outputFile := edtOutput.Text + outPutFile;
  result := outPutFile;

end;

function TfrmPrincipal.GetNextFile(Status: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to FileList2.Items.Count-1 do begin
    if ((FileList2.Items[i].SubItems[2] = IntToStr(Status)) and (FileList2.Items[i].Checked) and HasSubtitle(FileList2.Items[i].SubItems[0])) then begin
      Result := i;
      Exit;
    end;
  end;

end;

function TfrmPrincipal.HasSubtitle(sourcefile: String): Boolean;
begin
  result:= FileExists(ChangeFileExt(sourcefile, '.srt'));
end;

procedure TfrmPrincipal.LoadFiles;
var
  S: TStringDynArray;
  List: TStringList;
  I: Integer;
begin
  FileList2.Items.Clear;
  S := TDirectory.GetFiles(edtSource.Text, edtFiltro.Text ,TSearchOption.soAllDirectories);
  lblArquivosEncontrados.Caption := 'Arquivos Encontrados: ' + IntToStr(Length(S));
  List := TStringList.Create;
  for I := 0 to Length(S)-1 do begin
    List.Add(S[i]);
  end;
  List.CustomSort(MySortProc);
  for I := 0 to List.Count-1 do begin
    FileList2.Items.Add;
    FileList2.Items[i].Checked := true;
    FileList2.Items[i].SubItems.Add(List[i]);
    FileList2.Items[i].SubItems.Add('Aguardando In�cio');
    FileList2.Items[i].SubItems.Add('0');
    FileList2.Items[i].SubItems.Add(GenerateOutputFile(List[i]));
  end;

  btnEncode.Enabled := (List.Count > 0);
  FreeAndNil(List);

end;

procedure TfrmPrincipal.timerCheckFinishTimer(Sender: TObject);
begin
  if ((GetNextFile(0) = -1) and (RunningThreads = 0)) then begin
    timerCheckFinish.Enabled := False;
    gbOpcoes.Enabled := true;
    ShowMessage('Processo Encerrado');
    btnEncode.Enabled := True;
    Status.Visible := False;
  end;
end;

procedure TfrmPrincipal.timerCodingTimer(Sender: TObject);
var
  NextFile: Integer;
begin

  while (True) do begin

    NextFile := GetNextFile(0);
    if NextFile = -1 then begin
      timerCheckFinish.Enabled := True;
      timerCoding.Enabled := False;
    end;

    if (RunningThreads < StrToInt(edtProcessos.Text)) and (NextFile > -1) then
      BuildThreadForFile(NextFile)
    else
      break;

  end;


end;

end.
