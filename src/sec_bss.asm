;
; ������ �������������������� ������
;

section '.bss' data readable writable

  ; ���������� ������� �������� � ������� db, ��� ��� �������� ����� FASM
  ; �� ��������� ������� �����.
  gChunks    db sizeof.drawchunk_t * 4096 dup(?)
  gLastChunk drawchunk_t ? ; ���������� ��� ����������� ����� ������� gChunks