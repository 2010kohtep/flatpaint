;
; Секция импорта
;

section '.idata' import data readable

; Подключить набор библиотек

library kernel32, 'kernel32.dll', \
        user32,   'user32.dll',\
        gdi32,    'gdi32.dll',\
        ntdll,    'ntdll.dll'

; Подключить набор функций

include 'api\kernel32.inc'
include 'api\user32.inc'
include 'api\gdi32.inc'

import ntdll, vsprintf, 'vsprintf'