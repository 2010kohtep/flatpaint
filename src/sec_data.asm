;
; ������ ������������������ ������
;

section '.data' data readable writeable

  ;
  ; ����� ���������� ���������
  ;

  hInstance   dd ?
  hWindow     dd ?
  hStdOutput  dd ?

  acrCustomColor dd 16 dup(0xFFFFFF)
  gCurColor dd 0x000000

  pPrevChunk  dd ? ; ��������� �� ���������� ����. ��������� ��� ���������� �������.

  ;
  ; ���������� ���� ���������
  ;

  szClassName db 'CustomClass001',0
  szWndName   db 'flatpaint',0

  ;
  ; ���������� ���� ���������
  ;

  szFile  db 'File', 0
  szEdit  db 'Edit', 0
  szView  db 'View', 0
  szAbout db 'About', 0

  ; �������� ������� File
  szOpen db 'Open', 0
  szNew  db 'New', 0
  szSave db 'Save', 0
  szExit db 'Exit', 0

  ; �������� ������� Edit
  szUndo db 'Undo', 0
  szSetColor db 'Choose color', 0

  ; �������� ������� View
  ; ...
