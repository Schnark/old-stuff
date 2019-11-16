unit langezahlen;
interface
type longint=record
             vorzeichen:boolean;
             zahl:string;
             end;
procedure load(z: integer; var l:longint);
procedure add(a1, a2: longint; var z: longint);

implementation

procedure load;
begin
 l.vorzeichen:=(z<0);
 l.zahl:='';
 z:=abs(z);
 while z>0 do begin
    l.zahl:=chr(z mod 256)+l.zahl;
    z:=z div 256;
 end;
end;

procedure add;
var b1, b2, ueb: byte;
begin
 z.zahl:='';
 ueb:=0;
 while (a1.zahl<>'') or (a2.zahl<>'') do begin
    if a1.zahl='' then b1:=0 else begin
          b1:=ord(a1.zahl[length(a1.zahl)]);
          a1.zahl:=copy(a1.zahl,1,length(a1.zahl)-1);
          end;
    if a2.zahl='' then b2:=0 else begin
          b2:=ord(a2.zahl[length(a2.zahl)]);
          a2.zahl:=copy(a2.zahl,1,length(a2.zahl)-1);
          end;
    z.zahl:=chr((b1+b2+ueb) mod 256)+z.zahl;
    ueb:=(b1+b2+ueb) div 256;
 end;
 if ueb>0 then z.zahl:=chr(ueb)+z.zahl;
end;

end.