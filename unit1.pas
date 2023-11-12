unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,pingsend,blcksock;

type

  { Note the creation of two arrays }

  TByteArr = array of byte;
  TStringArr = array of String;



  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    function PingHostfun(const Host: string): string;
    function TraceRouteHostfun(const Host: string): string;
    function Pingtracertrttl(const Host: string): string;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);



begin



  memo1.lines.add(pinghostfun('192.168.76.1'));
  memo1.lines.add(TraceRouteHostfun('192.168.76.1'));


  end;

function tform1.PingHostfun(const Host: string): string;
var
  low, high,timetotal,j,success:integer;

begin
  result:='';
  with TPINGSend.Create do
  try
      success:=0;
      timetotal:=0;
      low:=99999;
      high:=0;
      result:='Pinging '+host+ ' with ' +inttostr(PacketSize)+ ' bytes of data:'+#13#10;
    for j :=1 to 4 do
    begin
    if Ping(Host) then
      begin
      if ReplyError = IE_NoError then
        begin
        Result := result + 'Reply from ' + ReplyFrom +': bytes='+ inttostr(PacketSize) + ' time=' + inttostr(PingTime)+' TTL='+ inttostr(ord(TTL))+#13#10;
        timetotal:=timetotal+pingtime;
        success:=success+1;
        if pingtime < low then low:=pingtime;
        if pingtime > high then high:=pingtime;
        end

      else
        result:=result+ 'Error : '+ ReplyErrorDesc+#13#10;
      end;
    end;

      result:=result+#13#10+'Ping statistics for ' + host+':'#13#10;
      result:=result+'Packets: Sent = ' +inttostr(j)+', Received = ' + inttostr(success) +', Lost = ' + inttostr(j-success) + ' (' +inttostr(trunc((100-((success/j)*100))))+ '% loss)'+#13#10;
      result:=result+'Approximate round trip times in milli-seconds: ' + inttostr(timetotal)+'ms'+#13#10;
      result:=result+'Minimum = '+inttostr(low)+'ms, Maximum = ' + inttostr(high)+'ms, Average = ' + inttostr(trunc(timetotal/j))+'ms'+#13#10;

  finally
    Free;
  end;
end;

function tform1.Pingtracertrttl(const Host: string): string;
var
  j:integer;

begin

  result:='';
  with TPINGSend.Create do
  try
      for j :=1 to 2 do
    begin
    if Ping(Host) then
      begin
      if ReplyError = IE_NoError then
        begin
        Result := result +  inttostr(PingTime)+' ms    ';
        end

      else
        result:=result+ '*    ';
      end;
    end;

  finally
    Free;
  end;
end;

 function tform1.TraceRouteHostfun(const Host: string): string;
var
  Ping: TPingSend;
  ttl : byte;
  hopcount:integer;
begin
  hopcount:=0;
  result:='Tracing route to '+ host +' over a maximum of 30 hops'+crlf+crlf;

  Ping := TPINGSend.Create;
  try
    ttl := 1;
    repeat
      hopcount:=hopcount+1;
      ping.TTL := ttl;
      inc(ttl);
      if ttl > 30 then
        Break;
      if not ping.Ping(Host) then
      begin
        Result := Result + cAnyHost+ ' Timeout' + CRLF;
        continue;
      end;
      if (ping.ReplyError <> IE_NoError)
        and (ping.ReplyError <> IE_TTLExceed) then
      begin
        Result := Result + inttostr(ord(ttl))+'    '+Ping.ReplyFrom + ' ' + Ping.ReplyErrorDesc + CRLF;
        break;
      end;

      Result := Result +  inttostr(hopcount)+'    '+IntToStr(Ping.PingTime)+' ms    '+ Pingtracertrttl(host)+ Ping.ReplyFrom + CRLF;
    until ping.ReplyError = IE_NoError;

    Result := Result +crlf+'Trace complete.';

  finally
    Ping.Free;
  end;
end;

end.

