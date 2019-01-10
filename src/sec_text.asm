;
; Секция кода
;

section '.text' code readable executable

include 'utils.asm'
include 'chunks.asm'
include 'console.asm'

szFileName db 'C:\saved.bmp',0

; typedef struct tagBITMAPINFO {
;    BITMAPINFOHEADER    bmiHeader;
;    RGBQUAD             bmiColors[1];
;} BITMAPINFO, FAR *LPBITMAPINFO, *PBITMAPINFO;

struct RGBQUAD
  rgbBlue     db ?
  rgbGreen    db ?
  rgbRed      db ?
  rgbReserved db ?
ends

struct BITMAPINFO
  bmiHeader BITMAPINFOHEADER ?
  bmiColors RGBQUAD ?
ends

proc SaveDCToBitmap uses edi esi ebx, hWnd
  locals
    .bmfh BITMAPFILEHEADER ?
    .bmih BITMAPINFOHEADER ?
    .bi   BITMAPINFO ?
    .rc RECT ?
    .dibvalues dd ?
    .hdc1 dd ?
    .hdc2 dd ?
    .OldObj dd ?
  endl

  lea eax, [.bmfh]
  stdcall memset, eax, 0, sizeof.BITMAPFILEHEADER
  lea eax, [.bmih]
  stdcall memset, eax, 0, sizeof.BITMAPINFOHEADER

  ; hdc1 = GetWindowDC(hStatic);
  invoke GetWindowDC, [hWnd]
  mov [.hdc1], eax
  ; hdc2 = CreateCompatibleDC(hdc1);
  invoke CreateCompatibleDC, eax
  mov [.hdc2], eax

  ; GetWindowRect(hStatic, &rc);
  lea eax, [.rc]
  invoke GetClientRect, [hWnd], eax
  ;lea eax, [.rc]
  ;invoke AdjustWindowRectEx, eax, WS_CAPTION + WS_SYSMENU + WS_MINIMIZEBOX, FALSE, 0

  ; w = rc.right-rc.left;
  mov eax, [.rc.right]
  sub eax, [.rc.left]
  mov edi, eax ; width

  ; h = rc.bottom-rc.top;
  mov eax, [.rc.bottom]
  sub eax, [.rc.top]
  mov esi, eax ; height

  mov [.bmih.biSize], sizeof.BITMAPINFOHEADER
  mov [.bmih.biWidth], edi
  mov [.bmih.biHeight], esi
  mov [.bmih.biPlanes], 1
  mov [.bmih.biBitCount], 24
  mov [.bmih.biCompression], BI_RGB

   ; imul cl           ;AX = AL * CL
   ; imul si           ;DX:AX = AX * SI
   ; imul bx,ax        ;BX = BX * AX
   ; imul cx,-5        ;CX = CX * (-5)
   ; imul dx,bx,134h   ;DX = BX * 134h

  ; bmih.biWidth * bmih.biBitCount
  mov eax, edi
  imul eax, 24
  ; ((bmih.biWidth * bmih.biBitCount) + 31)
  add eax, 31
  ; (((bmih.biWidth * bmih.biBitCount) + 31) & ~31)
  and eax, not 31
  ; ((((bmih.biWidth * bmih.biBitCount) + 31) & ~31) >> 3)
  shr eax, 3
  ; ((((bmih.biWidth * bmih.biBitCount) + 31) & ~31) >> 3) * bmih.biHeight
  imul eax, esi
  ; bmih.biSizeImage = ((((bmih.biWidth * bmih.biBitCount) + 31) & ~31) >> 3) * bmih.biHeight;
  mov [.bmih.biSizeImage], eax

  ;  bi.bmiHeader = bmih;
  lea eax, [.bmih]
  lea edx, [.bi.bmiHeader]
  stdcall memcpy, edx, eax, sizeof.BITMAPINFOHEADER
  ;lea eax, [.bmih]
  ;mov [.bi], eax

  ; aBmp = CreateDIBSection(hdc1, &bi ,DIB_RGB_COLORS, (void**)&dibvalues, NULL, NULL);
  lea eax, [.bi]
  lea edx, [.dibvalues]
  invoke CreateDIBSection, [.hdc1], eax, 0, edx, NULL, NULL ; DIB_RGB_COLORS - 0

  ; OldObj = SelectObject(hdc2, aBmp);
  invoke SelectObject, [.hdc2], eax
  mov [.OldObj], eax

  ; BitBlt(hdc2, 0, 0, w, h, hdc1, 0, 0, SRCCOPY);
  invoke BitBlt, [.hdc2], 0, 0, edi, esi, [.hdc1], 0, 0, SRCCOPY

  mov [.bmfh.bfOffBits], sizeof.BITMAPFILEHEADER + sizeof.BITMAPINFOHEADER

  mov eax, [.bmih.biHeight]
  imul eax, [.bmih.biWidth]
  imul eax, 3 ; lea eax, [eax+eax*2]
  add eax, sizeof.BITMAPFILEHEADER + sizeof.BITMAPINFOHEADER
  mov [.bmfh.bfSize], eax

  mov [.bmfh.bfType], 0x4D42

  local .f dd ?
  local .byteswritten dd ?

  ; fileHandle = CreateFile(pszFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
  lea eax, [szFileName]
  invoke CreateFileA, eax, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
  mov [.f], eax

  lea ebx, [.byteswritten]

  ; WriteFile(fileHandle, &bmfh, bytes_write, &bytes_written, NULL);
  lea eax, [.bmfh]
  invoke WriteFile, [.f], eax, sizeof.BITMAPFILEHEADER, ebx, NULL
  ; WriteFile(fileHandle, &bmih, bytes_write, &bytes_written, NULL);
  lea eax, [.bmih]
  invoke WriteFile, [.f], eax, sizeof.BITMAPINFOHEADER, ebx, NULL
  ; WriteFile(fileHandle, (void*)dibvalues, bytes_write, &bytes_written, NULL);
  invoke WriteFile, [.f], [.dibvalues], [.bmih.biSizeImage], ebx, NULL

  invoke CloseHandle, [.f]
  invoke SelectObject, [.hdc2] , [.OldObj]
  invoke DeleteObject, eax
  invoke DeleteDC, [.hdc2]
  invoke ReleaseDC, [hWnd], [.hdc1]

  ret
endp

proc GetHDCWidth hdc
  locals
    .bmpHdr BITMAP ?
  endl

  lea eax, [.bmpHdr]
  xor edx, edx
  mov ecx, sizeof.BITMAP
  stdcall asm_memset, [.bmpHdr]

  invoke GetCurrentObject, [hdc], 7 ; OBJ_BITMAP

  lea edx, [.bmpHdr]
  push edx
  push sizeof.BITMAP
  push eax
  call [GetObject]
  ;invoke GetObject, eax, sizeof.BITMAP, [.bmpHdr]

  mov eax, [.bmpHdr.bmWidth]

  ret
endp

  szFFFF db 'C:\\ffff.bmp', 0

proc LoadBitmapImage uses edi ebx, hWnd
  locals
    .rect RECT ?
  endl

  invoke GetDC, [hWnd]
  mov ebx, eax ; hdc

  invoke LoadImage, 0, szFFFF, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
  invoke CreatePatternBrush, eax
  mov edi, eax ; brush

  lea eax, [.rect]
  invoke GetWindowRect, [hWnd], eax
  lea eax, [.rect]
  invoke FillRect, ebx, eax, edi
  invoke DeleteObject, edi

  ret
endp

proc WritePixel uses edi esi ebx, hdc, chunk, size
  mov ecx, [chunk]
  virtual at ecx
    .chunk drawchunk_t
  end virtual

  mov edi, [.chunk.x]
  mov esi, [.chunk.y]

  cmp [size], 0
  je .EXIT

  locals
    .left dd ?      ; Количество линий, которое осталось пройти
  endl

  mov eax, [size]
  mov edx, [.chunk.x]
  lea ebx, [eax + edx] ; Последний X пиксель, достигнув которого мы должны спуститься на один пиксель ниже

  mov eax, [size]
  mov [.left], eax

.LOOP_Y:
  mov ecx, [chunk]
  mov edi, [.chunk.x]
.LOOP_X:
  invoke SetPixel, [hdc], edi, esi, [gCurColor]
  inc edi
  cmp edi, ebx
  jl .LOOP_X

  dec [.left]
  jz .EXIT

  inc esi
  jmp .LOOP_Y

.EXIT:
  ret
endp

proc Paint uses edi esi ebx, hWnd
  locals
    ps PAINTSTRUCT ?
    hdc dd ?
  endl

  lea eax, [ps]
  invoke BeginPaint, [hWnd], eax
  mov [hdc], eax

  lea edi, [gChunks]
  lea esi, [gLastChunk]

  virtual at edi
    .chunk drawchunk_t
  end virtual

  xor ebx, ebx
.FILL:
  virtual at ebx
    .prev_chunk drawchunk_t ?
  end virtual

  cmp [.chunk.created], 0
  je .DONT_DRAW

  cmp [.chunk.inherited], 0
  je .DONT_CONNECT

  invoke GetStockObject, 19 ; DC_PEN
  invoke SelectObject, [hdc], eax
  invoke SetDCPenColor, [hdc], [.chunk.color]

  invoke MoveToEx, [hdc], [.prev_chunk.x], [.prev_chunk.y], NULL
  invoke LineTo, [hdc], [.chunk.x], [.chunk.y]

.DONT_CONNECT:

  ;lea eax, [.chunk]
  ;stdcall WritePixel, [hdc], eax, 4

  invoke SetPixel, [hdc], [.chunk.x], [.chunk.y], [.chunk.color]

.DONT_DRAW:
  mov ebx, edi ; Предыдущий чанк

  add edi, sizeof.drawchunk_t

  cmp edi, esi
  jne .FILL

  ;invoke ValidateRect, [hWnd], 0
  invoke EndPaint, [hWnd], 0

  ret
endp

proc SetPenColor
  local .color CHOOSECOLOR

  lea eax, [acrCustomColor]
  mov ecx, [gCurColor]
  mov edx, [hWindow]

  mov [.color.lStructSize], sizeof.CHOOSECOLOR
  mov [.color.Flags], CC_FULLOPEN + CC_RGBINIT
  mov [.color.lpCustColors], eax
  mov [.color.hwndOwner], edx
  mov [.color.rgbResult], ecx
  lea eax, [.color]
  invoke ChooseColor, eax

  test eax, eax
   jz .EXIT

  ccall printf, szColorChanged, [gCurColor], [.color.rgbResult]

  mov eax, [.color.rgbResult]
  mov [gCurColor], eax

.EXIT:
  ret
endp

proc WndProc uses edi esi ebx, hWnd, uMsg, wParam, lParam

  ;ccall printf, szWMDebug, [hWnd], [uMsg], [wParam], [lParam]

  mov eax, [uMsg]

  cmp eax, WM_CREATE
   je .WM_CREATE

  cmp eax, WM_DESTROY
   je .WM_DESTROY
  cmp eax, WM_PAINT
   je .WM_PAINT
  cmp eax, WM_MOUSEMOVE
   je .WM_MOUSEMOVE
  cmp eax, WM_LBUTTONDOWN
   je .WM_LBUTTONDOWN
;  cmp eax, WM_MENUSELECT
;   je .WM_MENUSELECT
  cmp eax, WM_COMMAND
   je .WM_COMMAND

  jmp .DEFAULT

.WM_CREATE:
  stdcall BuildMenu, [hWnd]
  jmp .EXIT

.WM_DESTROY:
  invoke PostQuitMessage, 0 ; EXIT_SUCCESS
  jmp .EXIT

.WM_PAINT:
  stdcall Paint, [hWnd]
  jmp .EXIT

.WM_MOUSEMOVE:
.WM_LBUTTONDOWN:
  mov ecx, [wParam]
  test ecx, MK_LBUTTON
    jz .EXIT ; Покинуть обработчик, если ЛКМ не нажата

  cmp eax, WM_MOUSEMOVE
  sete bl

  ; Положить в ECX координаты точки
  mov edx, [lParam]
  ; Положить в ESI ось X
  mov esi, edx
  and esi, 0xFFFF
  ; Положить в EDI ось Y
  shr edi, 0x10

  ;stdcall CreateChunkEx, esi, edi
  stdcall CreateChunk
  test eax, eax
    jnz .CHUNK_CREATED

   ; Не удалось получить свободный чанк, выход
   ccall printf, szOutOfChunks
   jmp .EXIT

.CHUNK_CREATED:
  virtual at eax
    .chunk drawchunk_t
  end virtual

  mov [.chunk.x], esi
  mov [.chunk.y], edi
  mov edx, [gCurColor]
  mov [.chunk.color], edx
  mov [.chunk.inherited], bl

  movzx edx, [.chunk.inherited]
  ccall printf, szChunkCreated, [.chunk.x], [.chunk.y], [.chunk.color], edx

  invoke InvalidateRect, [hWnd], 0, 0

  jmp .EXIT

.WM_COMMAND:
  mov eax, [wParam]
  and eax, 0xFFFF

  ;ccall printf, szWM_CommandDebug, eax

  cmp eax, 0x1000
   je .CMD_CLEAR

  cmp eax, 0x1001
   je .CMD_OPEN

  cmp eax, 0x1002
   je .CMD_SAVE

  cmp eax, 0x1004
   je .WM_DESTROY

  cmp eax, 0x2000
   je .CMD_SET_COLOR

  cmp eax, 0x3000
   je .CMD_ABOUT

  jmp .EXIT

.CMD_SAVE:
  stdcall SaveDCToBitmap, [hWnd]
  jmp .EXIT

.CMD_SET_COLOR:
   stdcall SetPenColor

   jmp .EXIT

.CMD_CLEAR:
  stdcall FreeChunks
  invoke InvalidateRect, [hWnd], 0, 1

  ccall printf, szCanvasCleared

  jmp .EXIT

.CMD_OPEN:
  stdcall LoadBitmapImage, [hWnd]

  jmp .EXIT

.CMD_ABOUT:
  invoke MessageBoxA, HWND_DESKTOP, szAboutText, szAboutHeader, MB_ICONINFORMATION + MB_SYSTEMMODAL
  jmp .EXIT

;.WM_MENUSELECT:
;
;  ; Положить в ECX дескриптор меню, по которому щёлкнули мышью
;  mov ecx, [lParam]
;
;  mov eax, [wParam]
;  ; Положить в EDX пункт меню или индекс подменю
;  mov edx, eax
;  and edx, 0xFFFF
;  ; Положить в EAX флаги меню
;  shr eax, 0x10
;
;  ccall printf, szMenuSelectDebug, edx, eax, ecx
;  jmp .EXIT

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

  ; Создание "основы" меню (места, где располагаются первичные кнопки)
  invoke CreateMenu
  mov [hMainMenu], eax

  ; Создание подменю для кнопок
  invoke CreatePopupMenu
  mov [hPopMenuFile], eax
  invoke CreatePopupMenu
  mov [hPopMenuEdit], eax
  invoke CreatePopupMenu
  mov [hPopMenuView], eax

  ; Создание кнопок меню и подменю
  invoke AppendMenu, [hMainMenu], MF_STRING + MF_POPUP, [hPopMenuFile], szFile
    invoke AppendMenu, [hPopMenuFile], MF_STRING,    0x1000, szNew
    invoke AppendMenu, [hPopMenuFile], MF_STRING,    0x1001, szOpen
    invoke AppendMenu, [hPopMenuFile], MF_STRING,    0x1002, szSave
    invoke AppendMenu, [hPopMenuFile], MF_SEPARATOR, 0x1003, szEmptyStr
    invoke AppendMenu, [hPopMenuFile], MF_STRING,    0x1004, szExit

  invoke AppendMenu, [hMainMenu], MF_STRING + MF_POPUP, [hPopMenuEdit], szEdit
    invoke AppendMenu, [hPopMenuEdit], MF_STRING, 0x2000, szSetColor

  ;invoke AppendMenu, [hMainMenu], MF_STRING + MF_POPUP, [hPopMenuView], szView
  invoke AppendMenu, [hMainMenu], MF_STRING, 0x3000, szAbout

  ; Привязка меню к окну
  invoke SetMenu, [hWnd], [hMainMenu]

  ret
endp

; Результат - ATOM зарегистрированного класса
proc CreateWindowClass
  ; Добавить переменную 'class' на стеке
  local .class WNDCLASSEX

  ; Положить указатель на переменную 'class' в регистр ebx
  lea eax, [.class]

  ; Занулить переменную 'class'
  stdcall memset, eax, 0, sizeof.WNDCLASS

  mov eax, [hInstance]
  mov [.class.hInstance], eax

  mov [.class.cbSize],        sizeof.WNDCLASSEX
  mov [.class.style],         CS_HREDRAW + CS_VREDRAW
  mov [.class.lpfnWndProc],   WndProc
  mov [.class.lpszClassName], szClassName

  invoke LoadIcon, eax, IDI_APPLICATION
  mov [.class.hIcon],   eax
  mov [.class.hIconSm], eax

  invoke LoadCursor, 0, IDC_ARROW
  mov [.class.hCursor],  eax

  ;mov [class.hbrBackground], COLOR_APPWORKSPACE
  invoke CreateSolidBrush, 0xFFFFFF
  mov [.class.hbrBackground], eax

  ; Регистрация класса
  lea eax, [.class]
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

  invoke AllocConsole

  invoke GetStdHandle, STD_OUTPUT_HANDLE
  mov [hStdOutput], eax

  call CreateWindowClass
  test eax, eax
  jz .EXIT ; TODO: Сообщение об ошибке

  invoke CreateWindowEx,\
    WS_EX_OVERLAPPEDWINDOW,\ ; ExtStyle
    szClassName,\            ; ClassName
    szWndName,\              ; WindowName
    WS_OVERLAPPEDWINDOW,\    ; style
    100,\ ; x
    120,\ ; y
    800,\ ; width
    600,\ ; height
    HWND_DESKTOP,\   ; hParent
    0,\   ; hMenu
    [hInstance],\ ; hInstance
    0             ; lParam

  ; Сохраняем в edi хендл созданного окна
  push edi
  mov edi, eax

  invoke ShowWindow, edi, SW_SHOWNORMAL
  invoke UpdateWindow, edi

.LOOP:
  invoke GetMessage, ebx, 0, 0, 0
  test eax, eax
  jz .EXIT
  cmp eax, -1
  je .EXIT

  invoke TranslateMessage, ebx
  invoke DispatchMessage, ebx

  jmp .LOOP

.EXIT:
  invoke ExitProcess, 0
  ret

endp