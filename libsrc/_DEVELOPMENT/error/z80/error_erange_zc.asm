INCLUDE "../../errorno.inc"

XLIB error_erange_zc

LIB errno_zc

   pop hl
   
error_erange_zc:

   ; set hl = 0
   ; set carry flag
   ; set errno=ERANGE
   
   ld hl,__ERANGE
   jp errno_zc
