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
