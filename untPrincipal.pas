unit untPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FileCtrl, Vcl.Buttons,
  PngBitBtn, System.IOUtils, System.Types, Vcl.Mask, Vcl.ExtCtrls, Winapi.ShellAPI,
  Vcl.CheckLst, Vcl.Grids, Vcl.ComCtrls, untEncodeThread, Vcl.Menus, System.StrUtils;

type
  {TProcessFile}
  TProcessFile = Record
    Process: Boolean;
    InputFile: String;
    OutpuFile: String;
    Status: Integer;
  end;

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
    hbDialog: TOpenDialog;
    btnClose: TPngBitBtn;
    FileList2: TListView;
    timerCoding: TTimer;
    timerCheckFinish: TTimer;
    Status: TProgressBar;
    btnConfigurar: TPngBitBtn;
    procedure btnLoadSourcePathClick(Sender: TObject);
    procedure btnEncodeClick(Sender: TObject);
    function GenerateOutputFile(InputFile: String): String;
    procedure btnCloseClick(Sender: TObject);
    procedure btnHandBreakHelpClick(Sender: TObject);
    procedure timerCodingTimer(Sender: TObject);
    procedure timerCheckFinishTimer(Sender: TObject);
    procedure btnLocalParaSalvarClick(Sender: TObject);
    procedure btnExtraFlagsHelpClick(Sender: TObject);
    procedure btnConfigurarClick(Sender: TObject);
    procedure gpbFileListClick(Sender: TObject);
  private
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
    ProcessList: Array of TProcessFile;
    ThreadList: Array of TEncodeThread;
    RunningThreads: Integer;
    Software: Integer;
    CLIPath: String;
    BaseParams: String;
    NoSubtitle: Integer;
    Preset: String;
    MaxProcesses: Integer;
    VisualizarProcessos: Boolean;

    procedure DoTerminateEvent(Sender: TObject);
    procedure CheckConfig;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses untConfiguracoes;

function CheckSoftwareExists: Boolean;
begin
  Result := FileExists(frmPrincipal.CLIPath);
end;

function FixFFMPEGSubtitlePath(SubtitlePath: String): String;
begin
  Result:= StringReplace(SubtitlePath, '\', '\\\\', [rfReplaceAll]);
  Result:= StringReplace(Result, ':', '\\:', [rfReplaceAll]);
end;

procedure FileSearch(const PathName: string; const Extensions: string;
 var lstFiles: TStringList);
const
  FileMask = '*.*';
var
  Rec: TSearchRec;
  Path: string;
begin
  Path := IncludeTrailingBackslash(PathName);
  if FindFirst(Path + FileMask, faAnyFile - faDirectory, Rec) = 0 then
    try
      repeat
        if AnsiPos(ExtractFileExt(Rec.Name), Extensions) > 0 then
          lstFiles.Add(Path + Rec.Name);
      until FindNext(Rec) <> 0;
    finally
      FindClose(Rec);
    end;

  if FindFirst(Path + '*.*', faDirectory, Rec) = 0 then
    try
      repeat
        if ((Rec.Attr and faDirectory) <> 0) and (Rec.Name <> '.') and
          (Rec.Name <> '..') then
          FileSearch(Path + Rec.Name, Extensions, lstFiles);
      until FindNext(Rec) <> 0;
    finally
      FindClose(Rec);
    end;
end;

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
  Subtitle: String;
begin
  FParams := BaseParams;
  FParams := StringReplace(FParams, '#inputfile#', sourcefile, []);
  Subtitle := ChangeFileExt(sourcefile, '.srt');
  if Software = 1 then
    Subtitle := FixFFMPEGSubtitlePath(Subtitle);

  FParams := StringReplace(FParams, '#subtitlefile#', Subtitle, []);
  FParams := StringReplace(FParams, '#outputfile#', outputFile, []);
  FParams := StringReplace(FParams, '#preset#', Preset, []);
  Result := FParams;
end;

procedure TfrmPrincipal.BuildThreadForFile(Index: Integer);
var
  Source, Output: String;
begin

  if RunningThreads < MaxProcesses then begin
    Inc(RunningThreads);
    Source := FileList2.Items[Index].SubItems[0];
    OutPut := GenerateOutputFile(Source);
    FileList2.Items[Index].SubItems[2] := '3';
    ThreadList[Index] := TEncodeThread.Create(CLIPath, BuildParams(Source, Output), FileList2, Index);
    ThreadList[Index].FreeOnTerminate:=true;
    ThreadList[Index].OnTerminate := DoTerminateEvent;
    ThreadList[Index].Start;
  end;

end;

procedure TfrmPrincipal.CheckConfig;
begin
  if not CheckSoftwareExists then
    frmConfiguracoes.Showmodal;
end;

procedure TfrmPrincipal.btnConfigurarClick(Sender: TObject);
begin
  frmConfiguracoes.ShowModal;
end;

procedure TfrmPrincipal.btnEncodeClick(Sender: TObject);
var
  i: Integer;
begin
  for I := 0 to FileList2.Items.Count-1 do begin
    FileList2.Items[i].SubItems[1] := 'Aguardando In�cio';
    FileList2.Items[i].SubItems[2] := '0';
  end;

  if not CheckSoftwareExists then begin
    Showmessage('Software n�o encontrado, corrija o local do HandBreak');
    Abort;
  end;

  btnEncode.Enabled := False;
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
      if NoSubtitle = 1 then
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

procedure TfrmPrincipal.gpbFileListClick(Sender: TObject);
begin
  Showmessage(Booltostr(CheckSoftwareExists, true));
end;

function TfrmPrincipal.HasSubtitle(sourcefile: String): Boolean;
begin
  result:= FileExists(ChangeFileExt(sourcefile, '.srt'));
end;

procedure TfrmPrincipal.LoadFiles;
var
  List: TStringList;
  I: Integer;
begin
  FileList2.Items.Clear;
  List := TStringList.Create;

  for I := 0 to frmConfiguracoes.cklFileTypes.Items.Count-1 do begin
    if frmConfiguracoes.cklFileTypes.Checked[i] then
      FileSearch(edtSource.Text, '*.' + LowerCase(frmConfiguracoes.cklFileTypes.Items[i]), List);   //TODO Arrumar o filtro de arquivos
  end;

  lblArquivosEncontrados.Caption := 'Arquivos Encontrados: ' + IntToStr(List.Count);

  List.CustomSort(MySortProc);
  SetLength(ProcessList, List.Count);
  for I := 0 to List.Count-1 do begin
    ProcessList[I].Process := True;
    ProcessList[I].InputFile := List[I];
    ProcessList[I].OutpuFile := GenerateOutputFile(List[i]);
    ProcessList[I].Status := 0;
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

    if (RunningThreads < MaxProcesses) and (NextFile > -1) then
      BuildThreadForFile(NextFile)
    else
      break;

  end;


end;

end.

