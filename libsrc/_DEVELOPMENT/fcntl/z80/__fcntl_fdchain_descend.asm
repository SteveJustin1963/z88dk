
SECTION seg_code_fcntl

PUBLIC __fcntl_fdchain_descend
PUBLIC __0_fcntl_fdchain_descend

__fcntl_fdchain_descend:

   ; descend the fdstruct chain
   ;
   ; enter : ix = FDSTRUCT *
   ;
   ; exit  : success
   ;
   ;            ix = de = next FDSTRUCT *
   ;            nz flag set
   ;
   ;         fail if cannot descend
   ;
   ;            ix unchanged
   ;            z flag set
   ;
   ; uses  : af, de, ix
   
   bit 7,(ix+6)
   ret z                       ; if cannot descend

   ; filter fdstruct
   
   xor a                       ; filters are not implemented yet
   ret
