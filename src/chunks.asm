; TODO: ������������ ���� ��� �������� �������������� ����� ����� �������

struct drawchunk_t
  created   db ? ; ������ �� ����. ���� 0, �� ���� ��������� �������� � ��� ��������� �� ���������
  inherited db ? ; ���� �� 0, �� ���������� ������� ������� � ���������� ����� �������
  x dd ?         ; ���������� ����� �� X
  y dd ?         ; ���������� ����� �� Y
  color dd ?     ; ���� �����
ends

; ������� ����, � ������� ����� �������� ���������� � �������.
; ! ����� ��������� ���������� �����, ��� ��������� ��������� (���� created ��������������� � 1) !
;
; cl - �������� inherited
proc CreateChunk
  lea eax, [gChunks]

  virtual at eax
    .chunk drawchunk_t
  end virtual

  lea edx, [gLastChunk]

.LOOP:
  cmp byte [.chunk.created], 0
  je .FOUND
  add eax, sizeof.drawchunk_t

  cmp eax, edx
  je .NOT_FOUND

  jmp .LOOP

.NOT_FOUND:
  xor eax, eax
  ret
.FOUND:
  mov byte [.chunk.created], 1
  mov byte [.chunk.inherited], cl
  ret
endp

; ������� ��� ������������ �����
proc FreeChunks
  lea eax, [gChunks]

  virtual at eax
    .chunk drawchunk_t
  end virtual

  lea edx, [gLastChunk]

.LOOP:
  mov [.chunk.created], 0
  add eax, sizeof.drawchunk_t

  cmp eax, edx
  jne .LOOP

  ret
endp