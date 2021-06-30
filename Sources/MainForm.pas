{ MKLINK [[/D] | [/H] | [/J]] Ссылка Назначение
Параметры командной строки:
/D - Создание символической ссылки на каталог. По умолчанию создается символическая ссылка на файл.
/H - Создание жесткой связи (hard link)вместо символической ссылки.
/J - Создание соединения для каталога.
Ссылка - Имя новой символической ссылки.
Назначение - Путь (относительный или абсолютный), на который ссылается создаваемая ссылка. }

unit MainForm;

{$MODE OBJFPC}
{$LONGSTRINGS ON}
{$ASSERTIONS ON}
{$RANGECHECKS ON}
{$BOOLEVAL OFF}

interface

uses
  Classes, SysUtils, Forms, Dialogs, StdCtrls, EditBtn, ComCtrls, ButtonPanel,
  LCLType, Process, LConvEncoding, FileInfo;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonPanel: TButtonPanel;
    CheckBoxJunction: TCheckBox;
    CheckBoxHardLink: TCheckBox;
    DirectoryEditSource: TDirectoryEdit;
    DirectoryEditDestination: TDirectoryEdit;
    FileNameEditSource: TFileNameEdit;
    Label1: TLabel;
    PageControl: TPageControl;
    TabSheetDir: TTabSheet;
    TabSheetFile: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  FileVerInfo: TFileVersionInfo;
begin
  FileVerInfo := TFileVersionInfo.Create(nil);
  try
    FileVerInfo.ReadFileInfo;
    Form1.Caption := FileVerInfo.VersionStrings.Values['FileDescription'] +
      ' (v' + FileVerInfo.VersionStrings.Values['ProductVersion'] + ')';
  finally
    FileVerInfo.Free;
  end;

  Form1.Constraints.MinHeight := Height;
  Form1.Constraints.MaxHeight := Height;
end;

procedure TForm1.OKButtonClick(Sender: TObject);
var
  MkLinkParameter: string = '';
  FSOName, DestDir, MkLinkOutput: string;
  MkLink: TProcess;
  OutputStringList: TStringList;
  Encoded: Boolean;
  OutputDlgType: TMsgDlgType;
begin
  if PageControl.PageIndex = TabSheetDir.TabIndex then
  begin
    FSOName := DirectoryEditSource.Text;
    if CheckBoxJunction.Checked then
      MkLinkParameter := '/J'
    else
      MkLinkParameter := '/D';
  end
  else
  begin
    FSOName := FileNameEditSource.Text;
    if CheckBoxHardLink.Checked then
      MkLinkParameter := '/H';
  end;
  DestDir := DirectoryEditDestination.Text;

  MkLink := TProcess.Create(nil);
  MkLink.Executable := 'cmd';
  MkLink.Parameters.Add('/c');
  MkLink.Parameters.Add('mklink');
  MkLink.Parameters.Add(MkLinkParameter);
  MkLink.Parameters.Add(ExtractFileName(FSOName));
  MkLink.Parameters.Add(FSOName);
  MkLink.CurrentDirectory := DestDir;
  MkLink.Options := MkLink.Options + [poWaitOnExit, poStderrToOutPut, poUsePipes];

  MkLink.Execute;

  OutputStringList := TStringList.Create;
  OutputStringList.LoadFromStream(MkLink.Output);
  MkLinkOutput := ConvertEncodingToUTF8(OutputStringList.Text,
    GetConsoleTextEncoding, Encoded);
  if not Encoded then
    MkLinkOutput := OutputStringList.Text;
  if MkLink.ExitCode = 0 then
    OutputDlgType := mtInformation
  else
    OutputDlgType := mtError;

  MessageDlg(MkLinkOutput, OutputDlgType, [mbOK], 0);

  OutputStringList.Free;
  MkLink.Free;
end;

end.


