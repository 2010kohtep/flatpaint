section '.idata' import data readable

; ���������� ����� ���������

library kernel32, 'kernel32.dll', \
        user32,   'user32.dll'

; ���������� ����� �������

include 'api\kernel32.inc'
include 'api\user32.inc'