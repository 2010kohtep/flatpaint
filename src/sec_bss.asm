;
; —екци€ неинициализированных данных
;

section '.bss' data readable writable

  ; ќбъ€вление массива структур с помощью db, так как средства €зыка FASM
  ; не позвол€ют сделать иначе.
  gChunks db sizeof.drawchunk_t * 65536 dup(?)
  gLastChunk drawchunk_t ? ; ѕеременна€ дл€ обозначени€ конца массива gChunks