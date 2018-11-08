struct drawchunk_t
  created db ? ; Создан ли чанк. Если 0, то чанк считается удалённым и его рисование не произойдёт
  x dd ?       ; Координата чанка по X
  y dd ?       ; Координата чанка по Y
ends

; Создать чанк, в который можно записать информацию о пикселе.
; ! После получения свободного чанка, тот считается созданным (поле created устанавливается в 1) !
proc CreateChunk
  lea eax, [gChunks]

  virtual at eax
    .chunk drawchunk_t
  end virtual

  lea edx, [gLastChunk]

.LOOP:
  cmp [.chunk.created], 0
  je .FOUND
  add eax, sizeof.drawchunk_t

  cmp eax, edx
  je .NOT_FOUND

  jmp .LOOP

.NOT_FOUND:
  xor eax, eax
  ret
.FOUND:
  mov [.chunk.created], 1
  ret
endp

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