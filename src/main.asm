; Интересные факты
;
; * Аргумент GetMessage() необходимо занул¤ть, иначе возможна ошибка

format PE GUI 4.0

entry EntryPoint

include 'win32a.inc'
include 'macro\proc32.inc'

section '.text' code readable executable

include 'utils.asm'

proc Paint, hWnd
  locals
    ps PAINTSTRUCT
  endl

  lea eax, [ps]
  invoke BeginPaint, [hWnd], eax

  ; TODO: Рисование здесь

  invoke ValidateRect, [hWnd], 0
  invoke EndPaint, [hWnd], 0

  ret
endp

proc WndProc, hWnd, uMsg, wParam, lParam
  mov eax, [uMsg]

  cmp eax, WM_CREATE
   je .WM_CREATE
  cmp eax, WM_DESTROY
   je .WM_DESTROY

  jmp .DEFAULT

.WM_CREATE:
  stdcall BuildMenu, [hWnd]
  jmp .EXIT

.WM_DESTROY:
  invoke PostQuitMessage, WM_QUIT
  jmp .EXIT

.WM_PAINT:
  stdcall Paint, [hWnd]
  jmp .EXIT

.DEFAULT:
  invoke DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
  ret

.EXIT:
  xor eax, eax
  ret
endp

proc BuildMenu, hWnd
  locals
    hMainMenu dd ?

    hPopMenuFile dd ?
    hPopMenuEdit dd ?
    hPopMenuView dd ?
  endl

  ; Создание "основы" меню (места, где располагаютс¤ первичные кнопки)
  invoke CreateMenu
  mov [hMainMenu], eax

  ; Создание подменю дл¤ кнопок
  invoke CreatePopupMenu
  mov [hPopMenuFile], eax
  invoke CreatePopupMenu
  mov [hPopMenuEdit], eax
  invoke CreatePopupMenu
  mov [hPopMenuView], eax

  ; Создание кнопок меню и подменю
  invoke AppendMenu, [hMainMenu], MF_STRING + MF_POPUP, [hPopMenuFile], szFile
    invoke AppendMenu, [hPopMenuFile], MF_STRING, 1000, szNew
    invoke AppendMenu, [hPopMenuFile], MF_STRING, 1001, szOpen
    invoke AppendMenu, [hPopMenuFile], MF_STRING, 1002, szSave
    invoke AppendMenu, [hPopMenuFile], MF_SEPARATOR, 1003, szEmptyStr
    invoke AppendMenu, [hPopMenuFile], MF_STRING, 1004, szExit

  invoke AppendMenu, [hMainMenu], MF_STRING + MF_POPUP, [hPopMenuEdit], szEdit
    invoke AppendMenu, [hPopMenuEdit], MF_STRING, 1000, szUndo

  invoke AppendMenu, [hMainMenu], MF_STRING + MF_POPUP, [hPopMenuView], szView
  invoke AppendMenu, [hMainMenu], MF_STRING, 0, szAbout

  ; Привязка меню к окну
  invoke SetMenu, [hWnd], [hMainMenu]

  ret
endp

; Результат - ATOM зарегистрированного класса
proc CreateWindowClass
  ; Добавить переменную 'class' на стеке
  local class WNDCLASSEX

  ; Положить указатель на переменную 'class' в регистр ebx
  lea eax, [class]

  ; Занулить переменную 'class'
  stdcall memset, eax, 0, sizeof.WNDCLASS

  mov eax, [hInstance]
  mov [class.hInstance], eax

  mov [class.cbSize], sizeof.WNDCLASSEX
  mov [class.style], CS_HREDRAW + CS_VREDRAW
  mov [class.lpfnWndProc], WndProc
  mov [class.lpszClassName], szClassName

  invoke LoadIcon, eax, IDI_APPLICATION
  mov [class.hIcon], eax
  mov [class.hIconSm], eax

  invoke LoadCursor, 0, IDC_ARROW
  mov [class.hCursor], eax

  mov [class.hbrBackground], COLOR_APPWORKSPACE

  ; Регистрация класса
  lea eax, [class]
  invoke RegisterClassEx, eax

  ret
endp

proc EntryPoint
  local msg MSG

  push ebx
  lea ebx, [msg]
  stdcall memset, ebx, 0, sizeof.MSG

  invoke GetModuleHandle, 0
  mov [hInstance], eax

  call CreateWindowClass
  test eax, eax
  jz .EXIT ; TODO: Рообщение об ошибке

  invoke CreateWindowEx,\
    WS_EX_OVERLAPPEDWINDOW,\ ; ExtStyle
    szClassName,\            ; ClassName
    szWndName,\              ; WindowName
    WS_OVERLAPPEDWINDOW,\    ; style
    100,\ ; x
    120,\ ; y
    800,\ ; width
    600,\ ; height
    0,\   ; hParent
    0,\   ; hMenu
    [hInstance],\ ; hInstance
    0             ; lParam

  ; Сохраняем в edi хендл созданного окна
  push edi
  mov edi, eax

  invoke ShowWindow, edi, SW_SHOWNORMAL
  invoke UpdateWindow, edi

  pop edi

.LOOP:
  invoke GetMessage, ebx, 0, 0, 0
  test eax, eax
  jz .EXIT
  cmp eax, -1
  je .EXIT

  invoke TranslateMessage, ebx
  invoke DispatchMessage, ebx
  invoke Sleep, 10
  jmp .LOOP

.EXIT:
  invoke ExitProcess, 0
  ret

endp

section '.const' data readable

  szEmptyStr db 0

section '.data' data readable writeable

  ;
  ; Общие переменные программы
  ;

  hInstance   dd ?

  ;
  ; Переменные окна программы
  ;

  szClassName db 'CustomClass001',0
  szWndName   db 'flatpaint',0

  ;
  ; Переменные подменю программы
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

section '.idata' import data readable

; Подключить набор библиотек

library kernel32, 'kernel32.dll', \
        user32,   'user32.dll'

; Подключить набор функций

include 'api\kernel32.inc'
include 'api\user32.inc'