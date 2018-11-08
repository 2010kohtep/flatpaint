; Секция константных данных

section '.const' data readable

  szEmptyStr db 0

  szWMDebug         db 'WndProc: hWnd=%08X, uMsg=%08X, wParam=%08X, lParam=%08X',10,0

  szWM_MenuSelectDebug db 'WndProc: WM_MENUSELECT : uItem=%d, fuFlags=%d, hmenu=%d',10,0
  szWM_CommandDebug    db 'WndProc: WM_COMMAND : uItem=%d',10,0
  szOutOfChunks     db 'Out of chunks.',10,0

  szAboutHeader db 'About Box',0
  szAboutText   db 'FlatPaint - Paint, written in FASM',10,10,'Alexander B. (c) 2018',0