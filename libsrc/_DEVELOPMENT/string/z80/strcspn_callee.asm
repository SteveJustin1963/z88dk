
; ===============================================================
; Dec 2013
; ===============================================================
; 
; size_t strcspn(const char *s1, const char *s2)
;
; Return length of prefix of s1 not containing chars in s2.
;
; ===============================================================

XLIB strcspn_callee
XDEF asm_strcspn

LIB asm_strchr

strcspn_callee:

   pop hl
   pop de
   ex (sp),hl

asm_strcspn:

   ; enter : de = char *s2 = prefix chars
   ;         hl = char *s1 = string
   ;
   ; exit  : hl = max prefix length
   ;         bc = char *s1
   ;
   ;         z flag set if prefix length == 0
   ;         carry set if all of s1 contains no chars from s2
   ;
   ; uses  : af, bc, hl

   push hl                     ; save string
   
loop:

   ld a,(hl)
   or a
   jr z, end_string
   
   ; see if this char from string is in prefix
   
   push hl                     ; save current string
   
   ld c,a                      ; c = char
   ld l,e
   ld h,d                      ; hl = prefix
   call asm_strchr             ; is c in prefix?
   
   pop hl                      ; current string

   jr nc, done                 ; char found
   
   inc hl
   jp loop

end_string:

   pop bc
   sbc hl,bc
   
   scf
   ret

done:

   pop bc
   sbc hl,bc
   ret
