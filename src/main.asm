; ���������� �����
;
; * �������� GetMessage() ���������� ��������, ����� �������� ������
;
; TODO
; * ������ ��� ������������ ���� ��� ���������� � ����

format PE GUI 4.0

entry EntryPoint

include 'win32a.inc'
include 'macro\proc32.inc'

include 'sec_text.asm'
include 'sec_bss.asm'
include 'sec_const.asm'
include 'sec_data.asm'
include 'sec_idata.asm'
