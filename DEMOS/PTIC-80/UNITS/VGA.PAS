unit vga;

interface

type
  PByteArray = ^TByteArray;
  TByteArray = array[0..32639] of byte;

var
  surface: PByteArray;

procedure initVGAMode;
procedure initTextMode;
procedure loadFont;
procedure cls(const colour: byte);
procedure print(const text: string; const x, y: integer; const colour: byte);
procedure pset(const x, y: word; const colour: byte);
procedure vgaFlush;
procedure tic80Flush;
procedure initBuffer;
procedure freeBuffer;

implementation

uses dos;

const
  bufferSize = 32640;
var
  a, b: integer;
  font8x8: array[0..127, 0..7] of byte;
  bufferInitialised: boolean;


procedure initVGAMode; assembler;
asm
  mov ax, 0013h
  int 10h
end;

procedure initTextMode; assembler;
asm
  mov ax, 0003h
  int 10h
end;

{ Load 8x8 font }
procedure loadFont;
var
  Regs: Registers;
begin
  { Get the 8x8 font pointer }
  regs.ah := $11;
  regs.al := $30;
  regs.bh := 3; { 8x8 font }
  Intr($10, Regs);

  { Copy font data to buffer }
  Move(Mem[Regs.ES:Regs.BP], font8x8, sizeOf(font8x8));
end;


procedure cls(const colour: byte);
begin
  { Important: dereference buffer! }
  fillChar(surface^, bufferSize, colour)
end;

procedure print(const text: string; const x, y: integer; const colour: byte);
var
  row, col, idx: integer;
  pos: integer;
  mask: byte;
begin
  for idx := 1 to length(text) do begin
    if (idx < 0) or (idx > 127) then continue;

    for row := 0 to 7 do begin
      mask := font8x8[ord(text[idx]), row];
      for col := 0 to 7 do
        if (mask and (1 shl (7 - col))) <> 0 then begin
          pset((idx-1) * 8 + x + col, y + row, colour);
          end;
    end;
  end;
end;

procedure PSET(const x, y: word; const colour: byte); assembler;
asm
  { Bounds check }
  cmp x, 240
  jae @@done
  cmp y, 136
  jae @@done

  { Calculate offset: y * 240 + x }
  mov ax, y
  mov bx, 240
  mul bx      { DX:AX = y * 240 --> result in AX }
  add ax, x   { AX = y * 240 + x }

  { Copy AX to BX because ES:[BX] is valid, not ES:[DI+AX] }
  mov bx, ax

  { Write byte to the `surface` array }
  les di, surface { ES:DI = surface^ }
  mov al, colour
  { mov es:[di+ax], colour } { <-- Invalid register combination }
  mov es:[di+bx], al
@@done:
end;


{
  Based on fastFlush from FPS.PAS and MOVEMOU4.PAS
  lds si, surface: loads DS:SI from surface
  mov es, $a000: targets the VGA framebuffer
  xor di, di: start writing at offset 0000
  rep movsw: fast string move; copies 2 bytes per iteration
  push/pop: preserves segment registers to avoid corruption
}
procedure vgaFlush;
begin
  asm
    push ds
    push es

    lds si, surface { Load DS:SI with source pointer }
    mov ax, $a000
    mov es, ax      { Set ES to VGA segment }
    xor di, di      { DI = 0 (Destination offset) }

    mov cx, 32000   { 64000 bytes / 2 = 32000 words }
    rep movsw       { Copy CX words from DS:SI to ES:DI }

    pop es
    pop ds
  end;
end;

procedure tic80Flush;
var
  y, offset, memOffset: integer;
begin
  for y:=0 to 135 do begin
    offset := y * 240;
    memOffset := y * 320;
    Move(surface^[offset], Mem[$A000:memOffset], 240);
  end;
end;

procedure initBuffer;
begin
  if not bufferInitialised then
    getMem(surface, bufferSize);
end;

procedure freeBuffer;
begin
  if bufferInitialised then begin
    freeMem(surface, bufferSize);
    surface := nil
  end;
end;

end.
