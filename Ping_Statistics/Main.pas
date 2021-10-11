unit Main;

interface

uses
  Windows, Messages, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  SysUtils, Classes, IdIcmpClient, IdBaseComponent, IdComponent, IdRawBase, IdRawClient,
  Spin, Grids, TeeProcs, TeEngine, Chart, shellapi,series, Buttons, XPMan;

type
  TfrmPing = class(TForm)
    lstReplies: TListBox;
    ICMP: TIdIcmpClient;
    Panel1: TPanel;
    btnPing: TButton;
    edtHost: TEdit;
    StringGrid1: TStringGrid;
    Timer1: TTimer;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Button1: TButton;
    Label2: TLabel;
    Chart1: TChart;
    Series2: TLineSeries;
    Series3: TLineSeries;
    Memo1: TMemo;
    Label3: TLabel;
    StringGrid2: TStringGrid;
    BitBtn1: TBitBtn;
    Button2: TButton;
    Label4: TLabel;
    XPManifest1: TXPManifest;
    procedure btnPingClick(Sender: TObject);
    procedure ICMPReply(ASender: TComponent; const ReplyStatus: TReplyStatus);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Chart1ClickSeries(Sender: TCustomChart; Series: TChartSeries;
      ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure BitBtn1Click(Sender: TObject);
  private
  public
  end;

var
  frmPing: TfrmPing;
   i, j, tmp:integer;
   minTTL, maxTTL, meanTTL, minTrip, maxTrip, meanTrip :integer;
   sommeTTL, sommeTrip: integer;
implementation
{$R *.DFM}

procedure TfrmPing.btnPingClick(Sender: TObject);
begin
//Chart1.Title:=({'Ping Statistics for '+}edtHost.Text);
Timer1.Interval:=(StrToInt(combobox1.text)*1000);

If btnPing.caption='Start' then
begin
  Timer1.Enabled:=True;
  btnPing.Caption:='Stop';
  Combobox1.Visible:=False;
  Label2.Visible:=False;
  edtHost.ReadOnly:=True;
  Label4.Visible:=False;
  end
  else
  begin
  Timer1.Enabled:=False;
  btnPing.Caption:='Start';
  Combobox1.Visible:=True;
  Label2.Visible:=True;
  edtHost.ReadOnly:=False;
  Label4.Visible:=True;
  end;
end;

procedure TfrmPing.ICMPReply(ASender: TComponent; const ReplyStatus: TReplyStatus);
var
  sTime: string;
begin
  // TODO: check for error on ping reply (ReplyStatus.MsgType?)

  //-----------------------------------------------------

  lstReplies.Items.Add(Format('%d;%d',      //%s
    [
    ReplyStatus.TimeToLive,
{    sTime,}
    ReplyStatus.MsRoundTripTime]));
    //------------------------------------------------------
    StringGrid1.RowCount:=j+1;
    StringGrid1.Cells[0,j]:=DateTimeToStr(now);
    StringGrid1.Cells[1,j]:= (copy(lstReplies.Items.Text,0,pos(';',lstReplies.Items.Text)-1));
    StringGrid1.Cells[2,j]:= copy(lstReplies.Items.Text,pos(';',lstReplies.Items.Text)+1,length(lstReplies.Items.Text)-(length(StringGrid1.Cells[1,j])+3));
    //---------------------statistiques--------------------------------------------------------------
    If StrToInt(StringGrid1.Cells[1,j])>maxTTL then
    begin
    maxTTL:=strToInt(StringGrid1.Cells[1,j]);
    StringGrid2.Cells[2,2]:=StringGrid1.Cells[1,j];
    StringGrid2.Cells[1,2]:=StringGrid1.Cells[0,j];
    end;
    If StrToInt(StringGrid1.Cells[1,j])<minTTL then
    begin
    minTTL:=strToInt(StringGrid1.Cells[1,j]);
    StringGrid2.Cells[2,1]:=StringGrid1.Cells[1,j];
    StringGrid2.Cells[1,1]:=StringGrid1.Cells[0,j];
    end;

    If StrToInt(StringGrid1.Cells[2,j])>maxTrip then
    begin
    maxTrip:=strToInt(StringGrid1.Cells[2,j]);
    StringGrid2.Cells[2,4]:=StringGrid1.Cells[2,j];
    StringGrid2.Cells[1,4]:=StringGrid1.Cells[0,j];
    end;

    If StrToInt(StringGrid1.Cells[2,j])<minTrip then
    begin
    minTrip:=strToInt(StringGrid1.Cells[2,j]);
    StringGrid2.Cells[2,5]:=StringGrid1.Cells[2,j];
    StringGrid2.Cells[1,5]:=StringGrid1.Cells[0,j];
    end;

    sommeTTL:=sommeTTL+strToInt(StringGrid1.Cells[1,j]);
    If j>1 then meanTTL:=round(sommeTTL/(j));
    StringGrid2.Cells[2,3]:=IntToStr(meanTTL);

    sommeTrip:=sommeTrip+strToInt(StringGrid1.Cells[2,j]);
    If j>1 then meanTrip:=round(sommeTrip/(j));
    StringGrid2.Cells[2,6]:=IntToStr(meanTrip);
    //---------------------fin statistques------------------------------------------------------------
    Memo1.Lines.Append(StringGrid1.Cells[0,j]+';'+StringGrid1.Cells[1,j]+';'+StringGrid1.Cells[2,j]);
    Memo1.Lines.SaveToFile('Ping_log.csv');
    lstReplies.Clear;
    j:=j+1;

//----------------------Graph------------------------------------
//Series1.Clear;
Series2.Clear;
Series3.Clear;
With Chart1 do
begin
for I:=1 to Stringgrid1.RowCount -1 do
begin
//Series1.Add(StrToDateTime(Stringgrid1.cells[0,I]));
Series2.Add(Strtoint(Stringgrid1.cells[1,I]));
Series3.Add(Strtoint(Stringgrid1.cells[2,I])); 
end;
end;
//Series1.Active:=True;
Series2.Active:=True;
Series3.Active:=True;

//-------------------------Fin Graph-------------------------------
   end;

procedure TfrmPing.FormCreate(Sender: TObject);
begin
j:=1;
Combobox1.ItemIndex:=0;
StringGrid1.ColWidths[0]:=105;
StringGrid1.Cells[0,0]:='Date_Time';
StringGrid1.Cells[1,0]:='TTL';
StringGrid1.Cells[2,0]:='TripT.';

StringGrid2.RowHeights[0]:=0;
StringGrid2.ColWidths[1]:=105;
StringGrid2.ColWidths[0]:=62;
StringGrid2.Cells[0,1]:='Min.TTL';
StringGrid2.Cells[0,2]:='Max.TTL';
StringGrid2.Cells[0,3]:='Mean TTL';
StringGrid2.Cells[0,4]:='Min.Trip T.';
StringGrid2.Cells[0,5]:='Max.Trip T.';
StringGrid2.Cells[0,6]:='Mean Trip T.';

minTTL:=256;
maxTTL:=0;
sommeTTL:=0;
//meanTTL:=0;
minTrip:=5000;
maxTrip:=0;
sommeTrip:=0;
//meanTrip:=0;
end;

procedure TfrmPing.Timer1Timer(Sender: TObject);
begin
  ICMP.OnReply := ICMPReply;
  ICMP.ReceiveTimeout := 5000;
  try
    ICMP.Host := edtHost.Text;
    begin
      ICMP.Ping;
      Application.ProcessMessages;
    end;
  finally btnPing.Enabled := True; end;
end;

procedure TfrmPing.Button1Click(Sender: TObject);
begin
Application.Terminate;
end;

procedure TfrmPing.Label1Click(Sender: TObject);
begin
ShellExecute(Handle,'OPEN','http://www.phl-soft.com','','',SW_SHOWNORMAL);
end;

procedure TfrmPing.Chart1ClickSeries(Sender: TCustomChart;
  Series: TChartSeries; ValueIndex: Integer; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  tmp:=Series2.GetCursorValueIndex;
if tmp<>-1 then
	  begin
    Label3.Caption:='Selected Ping:   '+  (StringGrid1.Cells[0,tmp+1])+'    TTL: '+StringGrid1.Cells[1,tmp+1]+'    Trip T.: '+StringGrid1.Cells[2,tmp+1];
end;
tmp:=-1;
  tmp:=Series3.GetCursorValueIndex;
if tmp<>-1 then
	  begin
     Label3.Caption:='Selected Ping: '+  (StringGrid1.Cells[0,tmp+1])+'   TTL: '+StringGrid1.Cells[1,tmp+1]+'   Trip T.: '+StringGrid1.Cells[2,tmp+1];
    tmp:=-1;
end;
  end;

procedure TfrmPing.BitBtn1Click(Sender: TObject);
begin
J:=1;
minTTL:=256;
maxTTL:=0;
meanTTL:=0;
sommeTTL:=0;
minTrip:=5000;
maxTrip:=0;
meanTrip:=0;
sommeTrip:=0;
end;

end.
