section '.data' data readable writeable

  ;
  ; ����� ���������� ���������
  ;

  hInstance   dd ?

  ;
  ; ���������� �������
  ;

  ps PAINTSTRUCT ?
  hdc dd ?

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
