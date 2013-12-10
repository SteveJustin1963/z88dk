
; ===============================================================
; Dec 2013
; ===============================================================
; 
; void *memswap_callee(void *s1, void *s2, size_t n)
;
; Swap n bytes pointed at by s1 and s2.
;
; ===============================================================

XLIB memswap_callee
XDEF asm_memswap, asm0_memswap

memswap_callee:

   pop hl
   pop bc
   pop de
   ex (sp),hl

asm_memswap:

   ; enter : bc = size_t n
   ;         de = void *s2
   ;         hl = void *s1
   ;
   ; exit  : hl = void *s1
   ;         de = ptr in s2 to byte after last one written
   ;         bc = 0
   ;
   ; uses  : af, bc, de

   ld a,b
   or c
   ret z

asm0_memswap:

   push hl

loop:
   
   ld a,(de)
   ldi
   dec hl
   ld (hl),a
   inc hl
   
   jp pe, loop

   pop hl
   ret
