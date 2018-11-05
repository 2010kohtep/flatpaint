;
; Все функции, начинающиеся с 'asm_', имеют register соглашение.
;

; eax - адрес записи
; edx - символ для записи
; ecx - количество
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