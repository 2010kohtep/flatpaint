;
; —труктура рисовани€ точки
;

section '.data' data readable writeable

  ; ќбъ€вление массива структур с помощью db, так как средства €зыка FASM
  ; не позвол€ют сделать иначе.
  gChunks    db sizeof.drawchunk_t * 64 dup(0)
  gLastChunk drawchunk_t 0 ; ѕеременна€ дл€ обозначени€ конца массива gChunks

  ;
  ; ќбщие переменные программы
  ;

  hInstance   dd ?
  hWindow     dd ?

  ;
  ; ѕеременные окна программы
  ;

  szClassName db 'CustomClass001',0
  szWndName   db 'flatpaint',0

  ;
  ; ѕеременные меню программы
  ;

  szFile  db 'File', 0
  szEdit  db 'Edit', 0
  szView  db 'View', 0
  szAbout db 'About', 0

  ; Ёлементы подменю File
  szOpen db 'Open', 0
  szNew  db 'New', 0
  szSave db 'Save', 0
  szExit db 'Exit', 0

  ; Ёлементы подменю Edit
  szUndo db 'Undo', 0

  ; Ёлементы подменю View
  ; ...
