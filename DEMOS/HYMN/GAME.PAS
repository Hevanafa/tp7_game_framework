{$DEFINE DEBUG}

uses
  CRT, DOS,
  Bitmap, Logger, PCS, Timing, VGA;

const
  SC_ESC = $01;

  C4 = 262;
  D4 = 294;
  E4 = 330;
  F4 = 349;
  G4 = 392;
  A4 = 440;
  B4 = 494;
  C5 = 523;
  D5 = 587;
  E5 = 659;
  F5 = 698;
  G5 = 784;

  quart = 0.25;
  threeEighth = 0.375;
  half = 0.5;
  threeFourth = 0.75;
  full = 1.0;

var
  done: boolean;
  t: double;
  DosuEXE: array[0..1] of PBitmap;
  imgPiano: PBitmap;
  hymn: TMelody;
  { TODO: More of your game state here }


procedure INIT;
begin
  initLogger;
  initVGAMode;
  loadFont;
  initBuffer;
  initDeltaTime;
  { initKeyHandler; }
  { initMouse; }

  { TODO: Your init code here }

  randomize;
  loadBMP(imgPiano, 'IMG\PIANO.BMP');
  {
  loadBMP(dosuEXE[0], 'IMG/DOSU_1.BMP');
  loadBMP(dosuEXE[1], 'IMG/DOSU_2.BMP');
  }
  PCSpeaker.init;
end;

{
procedure initJerusalemHymn;
begin
  hymn.noteCount := 128;

  initNote(hymn.notes[0], G4, 0.25);
  initNote(hymn.notes[1], G4, 0.25);
  initNote(hymn.notes[2], A4, 0.25);
  initNote(hymn.notes[3], B4, 0.5);
  initNote(hymn.notes[4], C5, 0.25);
  initNote(hymn.notes[5], B4, 0.25);
  initNote(hymn.notes[6], A4, 0.5);
  initNote(hymn.notes[7], G4, 0.75);

  initNote(hymn.notes[8], B4, 0.25);
  initNote(hymn.notes[9], B4, 0.25);
  initNote(hymn.notes[10], C5, 0.25);
  initNote(hymn.notes[11], D5, 0.5);
  initNote(hymn.notes[12], E5, 0.25);
  initNote(hymn.notes[13], D5, 0.25);
  initNote(hymn.notes[14], C5, 0.5);
  initNote(hymn.notes[15], G4, 1);
end;
}

procedure initJerusalemHymn;
begin
  hymn.noteCount := 128;

  { and did those feet in ancient time }
  initNote(hymn.notes[0], G4, quart);
  initNote(hymn.notes[1], G4, quart);
  initNote(hymn.notes[2], A4, quart);
  initNote(hymn.notes[3], B4, half);
  initNote(hymn.notes[4], C5, quart);
  initNote(hymn.notes[5], B4, quart);
  initNote(hymn.notes[6], A4, half);
  initNote(hymn.notes[7], G4, threeFourth);

  initNote(hymn.notes[8], B4, quart);
  initNote(hymn.notes[9], B4, quart);
  initNote(hymn.notes[10], C5, quart);
  initNote(hymn.notes[11], D5, half);
  initNote(hymn.notes[12], E5, quart);
  initNote(hymn.notes[13], D5, quart);
  initNote(hymn.notes[14], C5, half);
  initNote(hymn.notes[15], G4, full);

  initNote(hymn.notes[16], G4, quart);
  initNote(hymn.notes[17], G4, quart);
  initNote(hymn.notes[18], A4, quart);
  initNote(hymn.notes[19], B4, half);
  initNote(hymn.notes[20], C5, quart);
  initNote(hymn.notes[21], B4, quart);
  initNote(hymn.notes[22], A4, half);
  initNote(hymn.notes[23], G4, threeFourth);

  initNote(hymn.notes[24], B4, quart);
  initNote(hymn.notes[25], B4, quart);
  initNote(hymn.notes[26], C5, quart);
  initNote(hymn.notes[27], D5, half);
  initNote(hymn.notes[28], E5, quart);
  initNote(hymn.notes[29], D5, quart);
  initNote(hymn.notes[30], C5, half);
  initNote(hymn.notes[31], G4, full);

  { Bring me my bow of burning gold }
  initNote(hymn.notes[32], G4, threeEighth);
  initNote(hymn.notes[33], C5, threeEighth);
  initNote(hymn.notes[34], C5, quart);
  initNote(hymn.notes[35], B4, quart);
  initNote(hymn.notes[36], A4, quart);
  initNote(hymn.notes[37], G4, threeEighth);
  initNote(hymn.notes[38], E4, threeEighth);
  initNote(hymn.notes[39], G4, threeFourth);
  
  initNote(hymn.notes[40], G4, threeEighth);
  initNote(hymn.notes[41], C5, threeEighth);
  initNote(hymn.notes[42], C5, quart);
  initNote(hymn.notes[43], D5, quart);
  initNote(hymn.notes[44], E5, quart);
  initNote(hymn.notes[45], D5, threeEighth);
  initNote(hymn.notes[46], C5, threeEighth);
  initNote(hymn.notes[47], B4, threeFourth);

  initNote(hymn.notes[48], B4, threeEighth);
  initNote(hymn.notes[49], E5, threeEighth);
  initNote(hymn.notes[50], E5, quart);
  initNote(hymn.notes[51], D5, quart);
  initNote(hymn.notes[52], C5, quart);
  initNote(hymn.notes[53], B4, threeEighth);
  initNote(hymn.notes[54], A4, threeEighth);
  initNote(hymn.notes[55], G4, threeFourth);

  initNote(hymn.notes[56], G4, threeEighth);
  initNote(hymn.notes[57], C5, threeEighth);
  initNote(hymn.notes[58], C5, quart);
  initNote(hymn.notes[59], B4, quart);
  initNote(hymn.notes[60], A4, quart);
  initNote(hymn.notes[61], G4, threeEighth);
  initNote(hymn.notes[62], E4, threeEighth);
  initNote(hymn.notes[63], D4, full);

  { I will not cease from mental fight }
  initNote(hymn.notes[64], G4, quart);
  initNote(hymn.notes[65], G4, quart);
  initNote(hymn.notes[66], A4, quart);
  initNote(hymn.notes[67], B4, half);
  initNote(hymn.notes[68], C5, quart);
  initNote(hymn.notes[69], B4, quart);
  initNote(hymn.notes[70], A4, half);
  initNote(hymn.notes[71], G4, threeFourth);

  initNote(hymn.notes[72], B4, quart);
  initNote(hymn.notes[73], B4, quart);
  initNote(hymn.notes[74], C5, quart);
  initNote(hymn.notes[75], D5, half);
  initNote(hymn.notes[76], E5, quart);
  initNote(hymn.notes[77], D5, quart);
  initNote(hymn.notes[78], C5, half);
  initNote(hymn.notes[79], G4, threeFourth);

  initNote(hymn.notes[80], G4, quart);
  initNote(hymn.notes[81], G4, quart);
  initNote(hymn.notes[82], A4, quart);
  initNote(hymn.notes[83], B4, half);
  initNote(hymn.notes[84], C5, quart);
  initNote(hymn.notes[85], B4, quart);
  initNote(hymn.notes[86], A4, half);
  initNote(hymn.notes[87], G4, threeFourth);

  initNote(hymn.notes[88], B4, quart);
  initNote(hymn.notes[89], B4, quart);
  initNote(hymn.notes[90], C5, quart);
  initNote(hymn.notes[91], D5, half);
  initNote(hymn.notes[92], E5, quart);
  initNote(hymn.notes[93], D5, quart);
  initNote(hymn.notes[94], C5, half);
  initNote(hymn.notes[95], G4, full + half);
end;


procedure update;
begin
  updateDeltaTime;
  { updateMouse; }
  PCSpeaker.update;

  { TODO: Your update code here }

  { if isKeyDown(SC_ESC) then done := true; }
  if keyPressed then if readKey = #27 then done := true;
  
  t:=t+dt
end;


procedure draw;
begin
  asmCls($7D);

  { TODO: Your drawing code here }

  asmSpr(imgPiano, 148, 76, 13);

  {
  if (trunc(t * 1.5) and 1) = 0 then
    asmSpr(dosuEXE[0], 148, 76, 13)
  else
    asmSpr(dosuEXE[1], 148, 76, 13);
  }

  print('Playing "Jerusalem" hymn', 160-96, 120, 15);
  print('by Sir Charles Hubert', 160-84, 130, 15);
  print('Hastings Parry', 160-56, 140, 15);
  { drawMouse; }

  asmFlush
end;


begin
  INIT;
  done := false;
  initJerusalemHymn;
  PCSpeaker.playMelody(hymn);

  repeat
    update;
    draw
  until done;

  { TODO: Your cleanup code here }
  freeBMP(imgPiano);
  {
  freeBMP(dosuEXE[0]);
  freeBMP(dosuEXE[1]);
  }

  PCSpeaker.stop;

  { resetMouse; }
  { resetKeyHandler; }
  freeBuffer;
  closeLogger;
  initTextMode
end.
