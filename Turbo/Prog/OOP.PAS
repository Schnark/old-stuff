program oop;
uses crt;

type objekt = object
 x, y: integer;
 constructor init;
 procedure beep; virtual;
 destructor done;
 end;

type objekt1 = object (objekt)
 constructor init;
 procedure beep; virtual;
 destructor done;
 end;

type objekt2 = object (objekt)
 constructor init;
 procedure beep; virtual;
 destructor done;
 end;

var o: objekt;
    o1: objekt1;
    o2: objekt2;


constructor objekt.init;
begin
x := 1; y := 2;
end;

constructor objekt1.init;
begin
objekt.init;
x := 4;
end;

constructor objekt2.init;
begin
objekt.init;
y := 6;
end;

destructor objekt.done;
begin
end;

destructor objekt1.done;
begin
end;

destructor objekt2.done;
begin
end;

procedure objekt.beep;
begin
writeln('Objekt: ', x, ' ', y);
sound(400);
delay(200);
nosound;
readln;
end;

procedure objekt1.beep;
begin
writeln('Objekt 1: ', x, ' ', y);
sound(800);
delay(200);
nosound;
readln;
end;

procedure objekt2.beep;
begin
writeln('Objekt 2: ', x, ' ', y);
sound(400);
delay(500);
nosound;
readln;
end;

procedure pieps(var o: objekt);
begin
o.beep;
end;

begin
o.init;
o1.init;
o2.init;
o.beep;
o1.beep;
o2.beep;
pieps(o);
pieps(o1);
pieps(o2);
o.done;
o1.done;
o2.done;
end.