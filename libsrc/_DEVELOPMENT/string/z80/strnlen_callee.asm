
; ===============================================================
; Dec 2013
; ===============================================================
; 
; size_t strnlen(const char *s, size_t maxlen)
;
; Return minimum of strlen(s) and maxlen.
; Does not examine more than maxlen chars.
;
; ===============================================================

XLIB strnlen_callee
XDEF asm_strnlen

strnlen_callee:

   pop hl
   pop bc
   ex (sp),hl

asm_strnlen:

   ; enter: hl = char *s
   ;        bc = maxlen
   ;
   ; exit : hl = min( strlen(s), maxlen )
   ;        de = char *s
   ;        bc = 0
   ;        z flag set if hl=min is 0
   ;
   ; uses : af, bc, de, hl

   ld e,l
   ld d,h                      ; de = char *s

   ld a,b
   or c
   jr z, zerolen
   
   xor a
   cpir                        ; find end of s, maxlen chars examined

   jr nz, notend               ; if end of s not reached, skip scf
   scf                         ; end of s reached, need to sub 1 extra

notend:

   sbc hl,de                   ; hl = min(strlen, maxlen)
   ret

zerolen:

   ld l,c
   ld h,b
   ret
