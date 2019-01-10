;
; Секция инициализированных данных
;

section '.data' data readable writeable

  ;
  ; Общие переменные программы
  ;

  hInstance   dd ?
  hWindow     dd ?
  hStdOutput  dd ?

  acrCustomColor dd 16 dup(0xFFFFFF)
  gCurColor dd 0x000000

  pPrevChunk  dd ? ; Указатель на предыдущий чанк. Необходим для связывания линиями.
