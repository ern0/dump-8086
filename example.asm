;----------------------------------------------------------------------
; Example for dump.asm
;   ESC to exit, space to animate, other keys to step
;----------------------------------------------------------------------
MEMDUMP_REG	equ	0	; DI (see dump.asm for list)
MEMDUMP_LEN	equ	5
;----------------------------------------------------------------------
	org	100H

	mov	ax,13H
	int	10H

	lea	di,[abc]
	mov	cx,24
next:	call	dump
	loop	next

	xor	ah,ah
	int	16H

	int	20H

abc:	dw	1,2,3,4,5,6
;----------------------------------------------------------------------
include	"dump.asm"
