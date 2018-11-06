section '.data' data readable writeable

  ;
  ; ќбщие переменные программы
  ;

  hInstance   dd ?

  ;
  ; ѕеременные графики
  ;

  ps PAINTSTRUCT ?
  hdc dd ?

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
