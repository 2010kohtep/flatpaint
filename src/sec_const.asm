; Секция константных данных

section '.const' data readable

  szEmptyStr db 0

  szWMDebug         db 'WndProc: hWnd=%08X, uMsg=%08X, wParam=%08X, lParam=%08X',10,0

  szConsoleTitle    db 'FlatPaint Debug Console',0

  szWM_MenuSelectDebug db 'WndProc: WM_MENUSELECT : uItem=%d, fuFlags=%d, hmenu=%d',10,0
  szWM_CommandDebug    db 'WndProc: WM_COMMAND : uItem=%d',10,0
  szOutOfChunks        db 'Out of chunks.',10,0
  szChunkCreated       db 'Chunk created; X: %d, Y: %d, Color: %06X, Inherited: %d',10,0
  szColorChanged       db 'Color changed from %06X to %06X,',10,0
  szCanvasCleared      db 'Canvas has been cleared.',10,0

  szSaveDCDebug1       db 'SaveDCToBitmap: Rectangle information retrieved; Left: %d, Right: %d, Top: %d, Bottom: %d',10,0
  szSaveDCDebug2       db 'SaveDCToBitmap: Width: %d, Height: %d',10,0
  szSaveNotSet         db 'SaveDCToBitmap: File name was not set or an internal error happened (%d).',10,0

  szAboutHeader db 'About Box',0
  szAboutText   db 'FlatPaint - Paint, written in FASM.',10,10,'Alexander B. (c) 2018-2019',0

  szFileFilter db 'All Files (*.*)',0,"*.*",0,0
  szBmp db 'bmp',0

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
  szSave db 'Save as...', 0
  szExit db 'Exit', 0

  ; Элементы подменю Edit
  szUndo db 'Undo', 0
  szSetColor db 'Choose color', 0

  ; Элементы подменю View
  ; ...