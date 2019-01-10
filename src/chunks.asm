; TODO: Родительский чанк для создания соединительных линий между чанками

struct drawchunk_t
  created   db ? ; Создан ли чанк. Если 0, то чанк считается удалённым и его рисование не произойдёт
  inherited db ? ; Если не 0, то необходимо связать текущий и предыдущий чанки линиями
  x dd ?         ; Координата чанка по X
  y dd ?         ; Координата чанка по Y
  color dd ?     ; Цвет чанка
ends

; Создать чанк, в который можно записать информацию о пикселе.
; ! После получения свободного чанка, тот считается созданным (поле created устанавливается в 1) !
;
; cl - значение inherited
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

; Найти чанк по существующим координатам для перезаписи. Если чанк не найдет - вернуть свободный.
; С точки зрения использования чанков для хранения пикселей данная функция опережает CreateChunk,
; так как при обнаружении записи в уже существующий чанк - возвращает тот, куда происходит запись,
; в то время как CreateChunk просто сохраняет повторяющийся чанк в новую ячейку. Однако, с точки
; зрения производительности данная функция уступает CreateChunk из-за того, что ей приходится
; полностью просматривать весь массив чанков, чтобы найти повторяющийся. Возможно, этот момент можно
; оптимизировать, если начинать поиск от первого существущего чанка с левой стороны до последнего
; существующего в правой.
proc CreateChunkEx uses ebx, x, y
  lea eax, [gChunks]

  virtual at eax
    .chunk drawchunk_t
  end virtual

  ;
  ; Записать в EDX указатель на последний чанк для быстрого определения достижения конца массива
  ;
  lea edx, [gLastChunk]

  ;
  ; EBX - результат функции
  ;
  xor ebx, ebx
.LOOP:
  ;
  ; Если мы ещё не нашли свободный чанк до этого момента, то записать его в EBX, в противном случае
  ; продолжить поиск чанка по указанным в аргументах координатам.
  ;
  test ebx, ebx
  jnz .A
  cmp byte [.chunk.created], 0
  jne .A
  lea ebx, [.chunk]

.A:
  ;
  ; Если мы нашли занятый чанк, то необходимо проверить его координаты с координатами
  ; из аргументов. В противном случае продолжить поиск.
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
  ; Занятый чанк с такими же координатами найден
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

; Удалить все существующие чанки
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