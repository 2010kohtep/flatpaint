;
; ��������� ��������� �����
;

section '.data' data readable writeable

  ; ���������� ������� �������� � ������� db, ��� ��� �������� ����� FASM
  ; �� ��������� ������� �����.
  gChunks    db sizeof.drawchunk_t * 64 dup(0)
  gLastChunk drawchunk_t 0 ; ���������� ��� ����������� ����� ������� gChunks

  ;
  ; ����� ���������� ���������
  ;

  hInstance   dd ?
  hWindow     dd ?

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

  ; �������� ������� View
  ; ...
