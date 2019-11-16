program FractalImageCompression;
{$R-}{$N+}
uses graphneu,dac,crt;
const block_=8;

const flip_x=1;
const flip_y=2;
const flip_d=4;
const max_sym=8;

const rand_pixel=128;

const infinity=256*256*block_*block_;

type pixel=byte;
type Tshift=integer;
type symmetrie=byte;
type index=integer;
type affin=record
           x,y:byte;
           shift:TShift;
           sym:symmetrie;
           end;
type fracfile=file of affin;

var f1:file; t1:fracfile;
    f2:fracfile; t2:file;

procedure show(bild: array of pixel; breite: integer; warten: boolean); forward;

procedure mean(r: array of pixel; var p:pixel);
var s: integer;
    i: index;
begin
 s:=0;
 for i:=0 to high(r) do s:=s+r[i];
 p:=round(s/(high(r)+1));
end;

procedure shift(var r: array of pixel; s: TShift);
var i: index; ri: integer;
begin
 for i:=0 to high(r) do begin ri:=r[i]; ri:=ri+s;
     if (0<=ri) and (ri<=255) then r[i]:=ri;
     if ri<0 then r[i]:=0; if ri>255 then r[i]:=255; end;
end;

function l2(r1, r2: array of pixel):comp;
var s: comp;
    i: index;
begin
 s:=0;
 for i:=0 to high(r1) do
     s:=s+sqr(longint(r1[i])-longint(r2[i]));
 l2:=s;
end;

procedure copy(src: array of pixel; src_x, src_y: index;
               var dest: array of pixel; dest_x, dest_y: index; h, w: index;
               src_breite, dest_breite: index);
var i, j: index;
begin
 for j:=0 to h-1 do
     for i:=0 to w-1 do
         dest[i+dest_x+(j+dest_y)*dest_breite] :=
             src[src_x+i+(src_y+j)*src_breite];
end;

procedure reduce(src: array of pixel; s_h, s_w: index;
            var dest: array of pixel; d_h, d_w: index);
var i,j: index;
    h: longint;
begin
 for j:=0 to d_h-1 do
     for i:=0 to d_w-1 do begin
      h:=src[2*i+  (2*j  )*s_w]+
         src[2*i+1+(2*j  )*s_w]+
         src[2*i+  (2*j+1)*s_w]+
         src[2*i+1+(2*j+1)*s_w];
      dest[i+j*d_w]:=round(h*3/16);
     end;
end;

procedure flip(src: array of pixel; var dest: array of pixel; s: symmetrie;
                    h,w: index);
var i,j, x,y,t:index;
begin
 for j:=0 to h-1 do
     for i:= 0 to w-1 do begin
         if (s and flip_x)<>0 then x:=w-1-i else x:=i;
         if (s and flip_y)<>0 then y:=h-1-j else y:=j;
         if (s and flip_d)<>0 then begin t:=y; y:=x; x:=t; end;
         dest[x+y*w]:=src[i+j*w];
         end;
end;

procedure compress(var from: file; var tof: fracfile; i_w, i_h: index);
type xxx=array[0..32*32] of pixel;
var  domain, range, flipped: array[0..block_*block_-1] of pixel;
     image, reduced: ^xxx;
     r_w, r_h: index;
     distance, min_distance: comp;
     sym: symmetrie; r_x, r_y, d_x, d_y: index;
     p: pixel; s: TShift; d_mean: pixel; map: affin;
     dummy: integer;
begin
 r_w:=(i_w+1) div 2; r_h:=(i_h+1) div 2;
 getmem(image, i_w*i_h*sizeof(pixel));
 getmem(reduced, r_w*r_h*sizeof(pixel));
 blockread(from, image^, filesize(from) div sizeof(pixel), dummy);
 show(image^,i_w,true);

 reduce(image^,i_h,i_w,reduced^,r_h,r_w);
 d_y:=0;
 while d_y<i_h do begin
       d_x:=0;
       while d_x<i_w do begin
             {alle Bl”cke werden komprimiert}
             min_distance:=infinity;
             copy(image^,d_x,d_y,domain,0,0,block_,block_,i_w,block_);
             mean(domain,d_mean);
             {zun„chst werden sie extrahiert und
               die Durchschnittsfarbe berechnet}

             for r_y:=0 to r_h-block_ do
                 for r_x:=0 to r_w-block_ do begin
                     {alle Bl”cke im verkleinerten Bild werden untersucht}

                     copy(reduced^,r_x,r_y,range,0,0,block_,block_,r_w,block_);
                     mean(range,p); s:=TShift(d_mean)-TShift(p);
                     shift(range,s);
                     {.. welcher bei der selben Durchschnittsfarbe}

                     for sym:=0 to max_sym-1 do begin
                         flip(range,flipped,sym,block_,block_);
                         {.. und einer geeigneten Spiegelung}

                         distance:=l2(domain,flipped);
                         if distance<min_distance then begin
                            {am besten passt}
                            min_distance:=distance;
                            map.x:=r_x; map.y:=r_y;
                            map.shift:=s; map.sym:=sym;
                         end;
                     end;
                 end;
                 write(tof,map); {diese Abbildung wird gespeichert}
       d_x:=d_x+block_;
       end;
 d_y:=d_y+block_;
 end;

 freemem(reduced, r_w*r_h*sizeof(pixel));
 freemem(image, i_w*i_h*sizeof(pixel));
end;

procedure decompress(var from: fracfile; var tof: file; i_w, i_h: index);
const max_iter=256;
type xxx=array[0..32*32] of pixel;
type yyy=array[0..16] of affin;
var  range, flipped: array[0..block_*block_-1] of pixel;
     image, newimage, reduced: ^xxx;
     h: pointer;
     r_w, r_h: index;
     d_x, d_y: index;
     maps: ^yyy;
     nr_maps, map_nr: integer;
     dummy, i: integer;
begin
 r_w:=(i_w+1) div 2; r_h:=(i_h+1) div 2;
 nr_maps:=filesize(from);

 getmem(image, i_w*i_h*sizeof(pixel));
 getmem(newimage, i_w*i_h*sizeof(pixel));
 getmem(reduced, r_w*r_h*sizeof(pixel));
 getmem(maps, nr_maps*sizeof(affin));

 for i:=0 to i_w*i_h-1 do image^[i]:=rand_pixel;
 for i:=0 to nr_maps-1 do read(from,maps^[i]);

 show(image^,i_w,false);

 for i:=1 to max_iter do begin
     reduce(image^,i_h,i_w,reduced^,r_h,r_w);
     d_y:=0; map_nr:=0;
     while d_y<i_h do begin
           d_x:=0;
           while d_x<i_w do begin
                 copy(reduced^,maps^[map_nr].x,maps^[map_nr].y,range,0,0,block_,block_,r_w,block_);
                 shift(range,maps^[map_nr].shift);
                 flip(range,flipped,maps^[map_nr].sym,block_,block_);
                 copy(flipped,0,0,newimage^,d_x,d_y,block_,block_,block_,i_w);
           d_x:=d_x+block_; inc(map_nr);
           end;
     d_y:=d_y+block_;
     end;
     h:=image;
     image:=newimage;
     show(image^,i_w,false);
     newimage:=h;
 end;
 write(#7);
 show(image^,i_w,true);

 blockwrite(tof,image^,i_h*i_w,dummy);

 freemem(reduced, r_w*r_h*sizeof(pixel));
 freemem(image, i_w*i_h*sizeof(pixel));
 freemem(newimage, i_w*i_h*sizeof(pixel));
end;

procedure graphik;
var reg: dac_reg;
    i: byte;
begin
 for i:=0 to 255 do begin
     reg.R:=i; reg.G:=i; reg.B:=i;
     setdacreg(i,reg);
 end;
end;

procedure show;
var i,x,y: integer;
begin
 if getgraphmode<>VGA320x200 then begin
  initgraph(VGA320x200);
  graphik;
 end;
 for i:=0 to high(bild)-1 do begin
  y:=i div breite + 1;
  x:=i mod breite + 1;
  setP320x200(x,y,bild[i]);
 end;
 if warten then begin readln;
    closegraph;
 end;
end;


begin
assign(f1, 'c:\turbo\extra\m1.img'); assign(t1, 'c:\turbo\extra\m.fic');
reset(f1,sizeof(pixel)); rewrite(t1);
compress(f1,t1,32,32);
close(f1); close(t1);
writeln;
assign(f2, 'c:\turbo\extra\m.fic'); assign(t2, 'c:\turbo\extra\m2.img');
reset(f2); rewrite(t2,sizeof(pixel));
decompress(f2,t2,32,32);
close(f2); close(t2);
end.