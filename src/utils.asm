;
; ��� �������, ������������ � 'asm_', ����� register ����������.
;

; eax - ����� ������
; edx - ������ ��� ������
; ecx - ����������
proc asm_memset uses edi
  xchg eax, edx
  mov edi, edx
  repnz stosb

  ret
endp

proc memset dest, val, size
  mov eax, [dest]
  mov edx, [val]
  mov ecx, [size]
  call asm_memset

  ret
endp