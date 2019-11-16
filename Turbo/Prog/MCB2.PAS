program mcb_anzeigen;
uses crt,dos;
const max = 50;
const maxint = $77;
type vier=string[4];
type mcb_eintrag=record
                 kette: char;
                 besitzer: word;
                 laenge: word;
                 leer: array[1..3] of byte;
                 name: array[0..7] of char;
                 end;
type speicher_typ = (unbekannt,frei,system_,psp_,umgebung,daten,ohnemcb);
var reg:registers;
    dib_seg,dib_offs,mcb_segment,mcb_offset:word;
    env: word;
    mcb_nr:word;
    mcb_ein:mcb_eintrag;
    i,j,umbstatus: byte;
    zeilen: byte;
    intvec: longint;
    intvector: pointer;
    start,ende: longint;
    int: byte;
    alle_mcb: array[1..max] of record
                   mcb,psp: pointer;
                   groesse: word;
                   name: string[8];
                   typ: speicher_typ;
                   vorfahre: pointer; {Zeiger auf aufrufenden Prozess
                                       bei Typ PSP}
                   interrupts: set of $00 .. maxint;
                   end;

function hex(wert:word):vier;
const ziffern: array[0..15] of char =
      ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
var h: vier;
    i: byte;
    teiler:word;
begin
 h:='0000';
 for i:=3 downto 0 do begin
     teiler:=wert shr (i shl 2);
     wert:=wert-(teiler shl (i shl 2));
     h[4-i]:=ziffern[teiler];
 end;
 hex:=h;
end;

begin
 reg.ah:=$58; reg.al:=2; msdos(reg); umbstatus:=reg.al; {Ermittle UMB-Status}
 reg.ah:=$58; reg.al:=3; reg.bx:=1; msdos(reg); {Verkette UMB mit Speicher}
 reg.ah:=$52; msdos(reg);
 dib_seg:=reg.es-1;
 dib_offs:=reg.bx+12;
 mcb_offset:=mem[dib_seg:dib_offs]+256*mem[dib_seg:dib_offs+1];
 mcb_segment:=mem[dib_seg:dib_offs+2]+256*mem[dib_seg:dib_offs+3];
                                               {Ermittle ersten MCB}
 with alle_mcb[1] do begin
  mcb:=ptr(0,0); psp:=mcb;
  groesse:=$40;
  name:=' Int-Vec';
  typ:=ohnemcb;
  vorfahre:=nil;
 end;
 with alle_mcb[2] do begin
  mcb:=ptr($40,0); psp:=mcb;
  groesse:=$10;
  name:='BIOS-Dat';
  typ:=ohnemcb;
  vorfahre:=nil;
 end;
 with alle_mcb[3] do begin
  mcb:=ptr($50,0); psp:=mcb;
  groesse:=$20;
  name:=' DOS-Dat';
  typ:=ohnemcb;
  vorfahre:=nil;
 end;
 with alle_mcb[4] do begin
  mcb:=ptr($70,0); psp:=mcb;
  groesse:=dib_seg+1-$70;
  name:='     I/O';
  typ:=ohnemcb;
  vorfahre:=nil;
 end;
 with alle_mcb[5] do begin
  mcb:=ptr(dib_seg+1,dib_offs-12-$26); psp:=mcb;
  groesse:=mcb_segment-seg(psp^);
  name:=' DOS-Sys';
  typ:=ohnemcb;
  vorfahre:=nil;
 end;

 mcb_nr:=6;  {weitere Speicherbl”cke}
 repeat
  mcb_ein:=mcb_eintrag(ptr(mcb_segment,mcb_offset)^);
  with alle_mcb[mcb_nr] do begin
       mcb:=ptr(mcb_segment,mcb_offset);
       psp:=ptr(mcb_ein.besitzer,0);
       groesse:=mcb_ein.laenge;
       name:='';
       for i:=0 to 7 do begin if mcb_ein.name[i]=#0 then break;
           name:=name+mcb_ein.name[i]; end;

       typ:=unbekannt;
       if psp=ptr(0,0) then typ:=frei;
       if psp=ptr(seg(mcb^)+1,0) then begin
          typ:=psp_;
          vorfahre:=ptr(memw[mcb_segment:mcb_offset+$16+$10],0);
       end;
       if typ=unbekannt then
          if (name[1]='S') and (name[2]='D') then name:='SD'
          else if (name[1]='S') and (name[2]='C') then name:='SC'
          else name:='';
       if (typ<>psp_) and ((name='SC')or(name='SD')) then typ:=system_;
  end;
  mcb_segment:=mcb_segment+mcb_ein.laenge+1;
  mcb_nr:=mcb_nr+1;
 until mcb_ein.kette<>'M';
 dec(mcb_nr);
 reg.ah:=$58; reg.al:=3; reg.bl:=umbstatus; msdos(reg); {Setze alten UMB-Status}

 for i:=1 to mcb_nr do with alle_mcb[i] do if typ=psp_ then begin
     {Suche Umgebung und markiere diese}
     env:=memw[seg(mcb^)+1:$2C];
     if env=0 then continue;
     for j:=1 to mcb_nr do with alle_mcb[j] do if env=seg(mcb^)+1 then begin
         if psp=alle_mcb[i].psp then typ:=umgebung;
     end;
 end;

 for i:=1 to mcb_nr do with alle_mcb[i] do if typ=unbekannt then begin
     for j:=1 to mcb_nr do if (seg(psp^)=seg(alle_mcb[j].mcb^)+1) and (alle_mcb[j].typ=psp_)
         then typ:=daten;
 end;

 for i:=1 to mcb_nr do with alle_mcb[i] do begin
       interrupts:=[];
       for j:=$00 to maxint do begin
           getintvec(j,intvector);
           intvec:=longint(seg(intvector^))*$10+longint(ofs(intvector^));
           start:=seg(mcb^)+1;
           if typ=ohnemcb then dec(start);
           start:=start*$10;
           ende:=start+longint(groesse)*$10;
           if (intvec >= start) and (ende >= intvec)
              then interrupts:=interrupts+[j];
       end;
 end;

 zeilen:=3;
 clrscr;
 writeln('              Speicherbl”cke');
 writeln;
 writeln(' Adresse    Gr”áe (Para/Byte)  PSP       Name      Vorfahre   Interrupts');

 for i:=1 to mcb_nr do with alle_mcb[i] do begin
    if (typ=umgebung) or (typ=daten) then continue;
    if typ=unbekannt then write('?') else write('>');

    if typ=ohnemcb then write('ohne MCB ')
    else write(hex(seg(mcb^)),':',hex(ofs(mcb^)));

    write(hex(groesse):8); write((longint(groesse) shl 4):8);

    write(hex(seg(psp^)):8,':',hex(ofs(psp^)));

    if typ=frei then write('-FREI-':10) else write(name:10);

    if typ=psp_ then write(hex(seg(vorfahre^)):6,':',hex(ofs(vorfahre^)),'  ')
    else write('             ');

    int:=0;
    for intvec:=$00 to maxint do if intvec in interrupts then
        begin write(copy(hex(intvec),3,2),' '); inc(int);
        if int=6 then begin int:=0; inc(zeilen);
        write('                                                              ');
        end; end;

    writeln; inc(zeilen); if zeilen=24 then begin readln; zeilen:=1; end;

    if typ=psp_ then
    for j:=1 to mcb_nr do with alle_mcb[j] do
    if (psp=alle_mcb[i].psp) and (i<>j) then begin
        write(' ');
        write(hex(seg(mcb^)),':',hex(ofs(mcb^)));
        write(hex(groesse):8); write((longint(groesse) shl 4):8);

        if typ=umgebung then write('                --ENV--');
        if typ=daten then    write('                --DAT--');
        int:=0;
        for intvec:=$00 to maxint do if intvec in interrupts then
            begin write(copy(hex(intvec),3,2),' '); inc(int);
            if int=6 then begin int:=0; inc(zeilen);
            write('                                                              ');
            end; end;
        writeln; inc(zeilen); if zeilen=24 then begin readln; zeilen:=1; end;
    end;
 end;
 readln;
end.
