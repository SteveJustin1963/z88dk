
; ===============================================================
; Dec 2013
; ===============================================================
; 
; char *itoa(int num, char *buf, int radix)
;
; Write number to ascii buffer in radix indicated and zero
; terminate.  Does not skip initial whitespace.
;
; If radix==10, the number is treated as signed and a minus
; sign may be written to the buffer.
;
; ===============================================================

XLIB itoa_callee
XDEF asm_itoa, asm0_itoa

LIB error_zc, l_valid_base, asm1_utoa, l_neg_hl

itoa_callee:

   pop hl
   pop bc
   pop de
   ex (sp),hl

asm_itoa:

   ; enter : hl = uint num
   ;         bc = int radix [2,36]
   ;         de = char *buf
   ;
   ; exit  : hl = address of terminating 0 in buf
   ;         carry reset no errors
   ;
   ; error : (*) if buf == 0
   ;             carry set, hl = 0
   ;
   ;         (*) if radix is invalid
   ;             carry set, hl = 0, errno=EINVAL
   ;
   ; uses  : af, bc, de, hl, ix

   ld a,d                      ; check for NULL string
   or e
   jp z, error_zc

asm0_itoa:                     ; bypasses NULL check of buf

   call l_valid_base           ; radix in [2,36]?
   jp nc, error_einval_zc  
   
   ; base 10 is signed
   
   cp 10
   jp nz, asm1_utoa

   bit 7,h                     ; number positive?
   jp z, asm1_utoa
   
   call l_neg_hl
   
   ld a,'-'
   ld (de),a
   inc de

   ld a,10
   jp asm1_utoa
