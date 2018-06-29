
	MODULE	generic_console_ioctl
	PUBLIC	generic_console_ioctl

	SECTION	code_clib
	INCLUDE	"ioctl.def"

	EXTERN	generic_console_cls
	EXTERN	__multi8_font32
	EXTERN	__multi8_udg32
	EXTERN	__multi8_mode
	EXTERN	__console_h
	EXTERN	__console_w
	EXTERN	__port29_copy


; a = ioctl
; de = arg
generic_console_ioctl:
	ex	de,hl
	ld	c,(hl)	;bc = where we point to
	inc	hl
	ld	b,(hl)
	cp	IOCTL_GENCON_SET_FONT32
	jr	nz,check_set_udg
	ld	(__multi8_font32),bc
success:
	and	a
	ret
check_set_udg:
	cp	IOCTL_GENCON_SET_UDGS
	jr	nz,check_mode
	ld	(__multi8_udg32),bc
	jr	success
check_mode:
	cp	IOCTL_GENCON_SET_MODE
	jr	nz,failure
	ld	a,c
	cp	1
	jr	z,set_mode_1
	and	a
	jr	z,set_mode_0
	cp	2
	jr	nz,failure
set_mode_2:		;Graphics
	ld	a,(__port29_copy)
	ld	h,40
	and	@10111111		;Bit 6 = 0 = 40 column
set_mode:
	ld	(__port29_copy),a
	out	($29),a
	ld	a,c
	ld	(__multi8_mode),a
	ld	a,h
	ld	(__console_w),a
	call	generic_console_cls
	jr	success
set_mode_1:		; 80 col text
	ld	a,(__port29_copy)
	and	@00111111		;Bit 6 = 1 = 80 column
	or	@01000000		
	ld	h,80
	jr	set_mode
set_mode_0:		; 40 col text
	ld	a,(__port29_copy)
	and	@00111111		;Bit 6 = 0 = 40 column
	ld	h,40
	jr	set_mode
failure:
	scf
	ret
