program rbrAnswerzCleaner;
{$APPTYPE CONSOLE}

uses
  SysUtils;

var
  fn: string = 'C:\Program Files\mIRC\scripts\#privat.de.raf';
  f1,f2: TextFile;
  x1,x2: string;
  y1,y2: string;
  z1,z2: string;
  p1,p2: longint;
  ic,dc: longint;

begin
  AssignFile(f1,fn);
  AssignFile(f2,fn);
  Reset(f1);
  p1 := 1;
  ic := 0;
  dc := 0;
  WriteLn('Starting work on file ',fn,' ...');
  while (NOT Eof(f1)) do begin
    repeat
      ReadLn(f1,x1); { Read question }
    until x1<>'';
    ReadLn(f1,y1); { Read answer }
    ReadLn(f1,z1); { Read blank line for testing whether still in synch }
    if ((z1<>'') OR (y1='') OR (x1='')) then begin
      WriteLn('INCOSISTENCY at pos. ',p1+2);
      Inc(ic);
    end;
    Reset(f2);
    p2 := 1;
    while (NOT Eof(f2)) do begin
      ReadLn(f2,x2);
      ReadLn(f2,y2);
      ReadLn(f2,z2);
      if ((x2=x1) AND (y2=y1) AND (p2>p1)) then begin
        WriteLn('DOUBLE QUESTION FOUND AT POS. ',p1,' & ',p2,'...');
        Inc(dc);
      end;
      Inc(p2,3);
    end;
    CloseFile(f2);
    Inc(p1,3);
  end;
  CloseFile(f1);
  Write('Done. Found ');
  if (ic=0) then Write('no') else Write(ic);
  Write(' inconsistencies and ');
  if (dc=0) then Write('no') else Write(dc);
  WriteLn(' double questions. Press ENTER.');
  ReadLn;
end.
