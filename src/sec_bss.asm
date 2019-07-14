;
; Секции неинициализированных данных
;

section '.bss' data readable writable

  ; Объявление массива структур с помощью db, так как средства языка FASM
  ; не позволяют сделать иначе.
  gChunks db sizeof.drawchunk_t * 65536 dup(?)
  gLastChunk drawchunk_t ? ; Переменная для обозначения конца массива gChunks