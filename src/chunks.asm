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

; ����� ���� �� ������������ ����������� ��� ����������. ���� ���� �� ������ - ������� ���������.
; � ����� ������ ������������� ������ ��� �������� �������� ������ ������� ��������� CreateChunk,
; ��� ��� ��� ����������� ������ � ��� ������������ ���� - ���������� ���, ���� ���������� ������,
; � �� ����� ��� CreateChunk ������ ��������� ������������� ���� � ����� ������. ������, � �����
; ������ ������������������ ������ ������� �������� CreateChunk ��-�� ����, ��� �� ����������
; ��������� ������������� ���� ������ ������, ����� ����� �������������. ��������, ���� ������ �����
; ��������������, ���� �������� ����� �� ������� ������������ ����� � ����� ������� �� ����������
; ������������� � ������.
proc CreateChunkEx uses ebx, x, y
  lea eax, [gChunks]

  virtual at eax
    .chunk drawchunk_t
  end virtual

  ;
  ; �������� � EDX ��������� �� ��������� ���� ��� �������� ����������� ���������� ����� �������
  ;
  lea edx, [gLastChunk]

  ;
  ; EBX - ��������� �������
  ;
  xor ebx, ebx
.LOOP:
  ;
  ; ���� �� ��� �� ����� ��������� ���� �� ����� �������, �� �������� ��� � EBX, � ��������� ������
  ; ���������� ����� ����� �� ��������� � ���������� �����������.
  ;
  test ebx, ebx
  jnz .A
  cmp byte [.chunk.created], 0
  jne .A
  lea ebx, [.chunk]

.A:
  ;
  ; ���� �� ����� ������� ����, �� ���������� ��������� ��� ���������� � ������������
  ; �� ����������. � ��������� ������ ���������� �����.
  ;
  cmp byte [.chunk.created], 1
  jne .EMPTY

  mov ecx, [.chunk.x]
  cmp ecx, [x]
  jne .NOT_EQU
  mov ecx, [.chunk.y]
  cmp ecx, [y]
  jne .NOT_EQU

  ;
  ; ������� ���� � ������ �� ������������ ������
  ;
  lea ebx, [.chunk]
  jmp .EXIT2

.EMPTY:
.NOT_EQU:
  add eax, sizeof.drawchunk_t

  cmp eax, edx
  je .EXIT

  jmp .LOOP

.EXIT:
  test ebx, ebx
  jz .EXIT2
   mov byte [ebx + drawchunk_t.created], 1

.EXIT2:
  mov eax, ebx
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