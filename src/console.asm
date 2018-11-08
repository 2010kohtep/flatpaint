; include 'utils.asm'

proc printf c fmt ;...
  locals
    written dd ?
    buf db 4096 dup(?)
  endl

  lea eax, [buf]
  lea edx, [fmt + 4] ; va_list
  cinvoke vsprintf, eax, [fmt], edx

  lea eax, [buf]
  stdcall strlen, eax

  lea edx, [buf]
  lea ecx, [written]
  invoke WriteConsole, [hStdOutput], edx, eax, ecx, 0

  ret
endp