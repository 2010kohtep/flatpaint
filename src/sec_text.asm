section '.text' code readable executable

include 'utils.asm'
include 'chunks.asm'

proc Paint, hWnd
  locals
    ps PAINTSTRUCT ?
    hdc dd ?
  endl

  lea eax, [ps]
  invoke BeginPaint, [hWnd], eax
  mov [hdc], eax

  ; TODO: ��������� �����

  invoke SetPixel, [hdc], 150, 25, 0x000000
  invoke SetPixel, [hdc], 151, 25, 0x000000
  invoke SetPixel, [hdc], 152, 25, 0x000000
  invoke SetPixel, [hdc], 153, 25, 0x000000
  invoke SetPixel, [hdc], 154, 25, 0x000000
  invoke SetPixel, [hdc], 155, 25, 0x000000
  invoke SetPixel, [hdc], 156, 25, 0x000000
  invoke SetPixel, [hdc], 157, 25, 0x000000
  invoke SetPixel, [hdc], 158, 25, 0x000000

  ;invoke ValidateRect, [hWnd], 0
  invoke EndPaint, [hWnd], 0

  ret
endp

proc WndProc, hWnd, uMsg, wParam, lParam
  mov eax, [uMsg]

  cmp eax, WM_CREATE
   je .WM_CREATE
  cmp eax, WM_DESTROY
   je .WM_DESTROY
  cmp eax, WM_PAINT
   je .WM_PAINT

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

  ; �������� "������" ���� (�����, ��� ������������� ��������� ������)
  invoke CreateMenu
  mov [hMainMenu], eax

  ; �������� ������� ��� ������
  invoke CreatePopupMenu
  mov [hPopMenuFile], eax
  invoke CreatePopupMenu
  mov [hPopMenuEdit], eax
  invoke CreatePopupMenu
  mov [hPopMenuView], eax

  ; �������� ������ ���� � �������
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

  ; �������� ���� � ����
  invoke SetMenu, [hWnd], [hMainMenu]

  ret
endp

; ��������� - ATOM ������������������� ������
proc CreateWindowClass
  ; �������� ���������� 'class' �� �����
  local .class WNDCLASSEX

  ; �������� ��������� �� ���������� 'class' � ������� ebx
  lea eax, [.class]

  ; �������� ���������� 'class'
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

  ; ����������� ������
  lea eax, [.class]
  invoke RegisterClassEx, eax

  ret
endp

proc EntryPoint
  local msg MSG

  stdcall FreeChunks
  stdcall CreateChunk

  push ebx
  lea ebx, [msg]
  stdcall memset, ebx, 0, sizeof.MSG

  invoke GetModuleHandle, 0
  mov [hInstance], eax

  call CreateWindowClass
  test eax, eax
  jz .EXIT ; TODO: ��������� �� ������

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

  ; ��������� � edi ����� ���������� ����
  ;push edi
  mov edi, eax

  invoke ShowWindow, edi, SW_SHOWNORMAL
  invoke UpdateWindow, edi

  ;pop edi

.LOOP:
  invoke GetMessage, ebx, 0, 0, 0
  test eax, eax
  jz .EXIT
  cmp eax, -1
  je .EXIT

  invoke TranslateMessage, ebx
  invoke DispatchMessage, ebx
  invoke Sleep, 10

  ;invoke InvalidateRect, edi, 0, 1

  jmp .LOOP

.EXIT:
  invoke ExitProcess, 0
  ret

endp