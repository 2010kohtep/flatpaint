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

  pPrevChunk  dd ? ; Указатель на предыдущий чанк. Необходим для связывания линиями.

  ;
  ; Переменные окна программы
  ;

  szClassName db 'CustomClass001',0
  szWndName   db 'flatpaint',0

  ;
  ; Переменные меню программы
  ;

  szFile  db 'File', 0
  szEdit  db 'Edit', 0
  szView  db 'View', 0
  szAbout db 'About', 0

  ; Элементы подменю File
  szOpen db 'Open', 0
  szNew  db 'New', 0
  szSave db 'Save', 0
  szExit db 'Exit', 0

  ; Элементы подменю Edit
  szUndo db 'Undo', 0

  ; Элементы подменю View
  ; ...
