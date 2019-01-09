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

proc strlen str
  push edi

  xor eax, eax
  or ecx, -1
  mov edi, [str]
  repne scasb
  not ecx
  dec ecx

  pop edi
  mov eax, ecx
  ret
endp

; eax - value
proc abs
  test eax, eax
  jns .NOT_SIGNED
  not eax
  inc eax

.NOT_SIGNED:
  ret
endp

; eax - value1
; edx - value2
proc max
  cmp eax, edx
  jae .EXIT
  xchg eax, edx
.EXIT:
  ret
endp