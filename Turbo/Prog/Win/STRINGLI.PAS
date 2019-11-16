unit stringli(*st*);
interface
type PEintrag = ^TEintrag;
     TEintrag = record
              s: PChar;
              n: PEintrag;
     end;
type TStringList = object
                 strings: PEintrag;
                 anzahl: word;
                 constructor init;
                 function get(nr: word): PChar;
                 procedure add(s: string);
                 procedure setzen(nr: word; s: PChar);
                 procedure clear;
                 function getfromfile(d: string):boolean;
                 destructor fertig;
                 end;
implementation
uses strings;

constructor TStringList.init;
begin strings:=nil; anzahl:=0; end;

function TStringList.get;
var p: PEintrag;
    i: word;
begin
 if nr>anzahl-1 then begin get:=nil; exit; end;
 p:=strings;
 if nr>=1 then for i:=0 to nr-1 do p:=p^.n;
 get:=p^.s;
end;

procedure TStringList.setzen;
var p: PEintrag;
    i: word;
begin
 if nr>anzahl-1 then exit;
 p:=strings;
 if nr>=1 then for i:=0 to nr-1 do p:=p^.n;
 p^.s:=s;
end;

procedure TStringList.add;
var p: PEintrag;
    i: word;
    ss: array[0..256] of char;
begin
 if anzahl=0 then begin
    new(strings); p:=strings;
 end else begin
     p:=strings;
     if anzahl>1 then for i:=0 to anzahl-2 do p:=p^.n;
     new(p^.n); p:=p^.n;
 end;
 strPCopy(ss, s);
 p^.n:=nil; p^.s:=strnew(ss);
 inc(anzahl);
end;

procedure TStringList.clear;
var p: PEintrag;
    i: word;
begin
 for i:=1 to anzahl do begin
     p:=strings; strings:=strings^.n;
     strdispose(p^.s); dispose(p);
 end;
 anzahl:=0;
end;

function TStringList.getfromfile;
var f: text;
    s: string;
begin
 assign(f,d);
 {$I-}reset(f);{$I+} if IOResult<>0 then begin getfromfile:=false; exit; end;
 while not eof(f) do begin
       readln(f,s);
       add(s);
 end;
 close(f);
 getfromfile:=true;
end;

destructor TStringList.fertig;
begin
 clear;
end;
end.