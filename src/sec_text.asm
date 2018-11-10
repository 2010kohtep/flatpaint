;
; ������ ����
;

section '.text' code readable executable

include 'utils.asm'
include 'chunks.asm'
include 'console.asm'

proc Paint, hWnd
  locals
    ps PAINTSTRUCT ?
    hdc dd ?
  endl

  lea eax, [ps]
  invoke BeginPaint, [hWnd], eax
  mov [hdc], eax

  push edi
  push esi

  lea edi, [gChunks]
  lea esi, [gLastChunk]

  virtual at edi
    .chunk drawchunk_t
  end virtual

.FILL:
  cmp [.chunk.created], 0
  je .DONT_DRAW

  invoke SetPixel, [hdc], [.chunk.x], [.chunk.y], 0x000000

.DONT_DRAW:
  add edi, sizeof.drawchunk_t

  cmp edi, esi
  jne .FILL

  pop esi
  pop edi

  ;invoke ValidateRect, [hWnd], 0
  invoke EndPaint, [hWnd], 0

  ret
endp

proc WndProc, hWnd, uMsg, wParam, lParam

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
  mov eax, [wParam]
  test eax, MK_LBUTTON
    jz .EXIT ; �������� ����������, ���� ��� �� ������

  call CreateChunk
  test eax, eax
    jnz .CHUNK_CREATED

   ; �� ������� �������� ��������� ����, �����
   ccall printf, szOutOfChunks
   jmp .EXIT

.CHUNK_CREATED:

  virtual at eax
    .chunk drawchunk_t
  end virtual

  ; �������� � ECX ���������� �����
  mov ecx, [lParam]
  ; �������� � EDX ��� X
  mov edx, ecx
  and edx, 0xFFFF
  ; �������� � ECX ��� Y
  shr ecx, 0x10

  mov [.chunk.x], edx
  mov [.chunk.y], ecx

  invoke InvalidateRect, [hWnd], 0, 0

  jmp .EXIT

.WM_COMMAND:
  mov eax, [wParam]
  and eax, 0xFFFF

  ;ccall printf, szWM_CommandDebug, eax

  cmp eax, 0x1000
   je .CMD_CLEAR

  cmp eax, 0x1003
   je .WM_DESTROY

  cmp eax, 0x3000
   je .CMD_ABOUT

  jmp .EXIT

.CMD_CLEAR:
  stdcall FreeChunks
  invoke InvalidateRect, [hWnd], 0, 1

  jmp .EXIT
.CMD_ABOUT:
  invoke MessageBoxA, HWND_DESKTOP, szAboutText, szAboutHeader, MB_ICONINFORMATION + MB_SYSTEMMODAL
  jmp .EXIT

;.WM_MENUSELECT:
;
;  ; �������� � ECX ���������� ����, �� �������� �������� �����
;  mov ecx, [lParam]
;
;  mov eax, [wParam]
;  ; �������� � EDX ����� ���� ��� ������ �������
;  mov edx, eax
;  and edx, 0xFFFF
;  ; �������� � EAX ����� ����
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
    invoke AppendMenu, [hPopMenuFile], MF_STRING,    0x1000, szNew
    invoke AppendMenu, [hPopMenuFile], MF_STRING,    0x1001, szSave
    invoke AppendMenu, [hPopMenuFile], MF_SEPARATOR, 0x1002, szEmptyStr
    invoke AppendMenu, [hPopMenuFile], MF_STRING,    0x1003, szExit

  ;invoke AppendMenu, [hMainMenu], MF_STRING + MF_POPUP, [hPopMenuEdit], szEdit
  ;  invoke AppendMenu, [hPopMenuEdit], MF_STRING, 0x2000, szUndo

  ;invoke AppendMenu, [hMainMenu], MF_STRING + MF_POPUP, [hPopMenuView], szView
  invoke AppendMenu, [hMainMenu], MF_STRING, 0x3000, szAbout

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