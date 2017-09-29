; dump.asm - 2017.09.29 - ern0@linkbroker.hu
; Simple dump for 80186 assembly developers
;----------------------------------------------------------------------
;
; MEMDUMP_REG	equ	0
;
;   Register pointing to memory to dump
; 	0: DI, 2: SI, 4: BP, 6: SP,
; 	8: BX, 10: DX, 12: CX, 14: AX
;
; MEMDUMP_LEN	equ	6
;
;   Number of words to dump
;
;----------------------------------------------------------------------
dump:	
	push 	es
	pusha

	push 	cs
	pop 	es

	xor	dx,dx
	mov	bh,0
	mov	ah,2
	int	10H

	mov 	cx,8
	lea 	si,[dump_regmap]
	lea 	bx,[3 + dump_template]

dump_xreg:
	mov 	bp,sp
	add 	bp,[si]
	mov 	ax,[bp]
	mov 	[dump_value],ax
	mov 	[dump_target],bx
	call 	dump_word

	add 	bx,8
	add 	si,2
	loop 	dump_xreg

dump_qreg:
	lea 	dx,[dump_template]
	mov 	ah,9
	int 	21H

; dump memory
	mov	bp,sp
	mov	si,[bp + MEMDUMP_REG]
	mov	[dump_target],dump_mem
	mov	cx,MEMDUMP_LEN

dump_xmem:
	lodsw
	mov	[dump_value],ax
	call	dump_word
	lea	dx,[dump_mem] 
	mov	ah,9
	int	21H
	loop	dump_xmem

	lea	dx,[dump_crlf]
	mov	ah,9
	int	21H

; sleep some
	xor	ah,ah
	int	1aH
	mov	bx,dx
dump_sleep:
	xor	ah,ah
	int	1aH
	cmp	bx,dx
	je	dump_sleep

	test	[dump_flood],-1
	jz	dump_rkey

	mov	ah,1
	int	16H
	jz	dump_return

dump_rkey:
	xor	ah,ah
	int	16H
	cmp	al,1bH
	je	dump_qkey
	cmp	al,20H
	jne	dump_return
	not	[dump_flood]

dump_return:
	popa
	pop 	es
	ret

dump_qkey:	
	mov	ax,4c00H
	int	21H

dump_flood	db	0
;----------------------------------------------------------------------
dump_nibble:
	and 	al,0fH
	lea 	bx,[dump_nums]
	xlat 	[bx]
	stosb
	ret
;----------------------------------------------------------------------
dump_byte:
	mov 	ah,al
	shr 	al,4
	call 	dump_nibble
	mov 	al,ah
	call 	dump_nibble
	ret
;----------------------------------------------------------------------
dump_word:
	pusha

	mov 	di,[dump_target]
	mov 	al,byte [1 + dump_value]
	call 	dump_byte
	mov 	al,byte [dump_value]
	call 	dump_byte	

	popa
	ret
;----------------------------------------------------------------------
dump_value 	dw 0
dump_target 	dw 0
dump_nums 	db "0123456789ABCDEF"

dump_template:
	db 	"AX=.... "
	db 	"BX=.... "
	db 	"CX=.... "
	db 	"DX=....",10
	db 	"SI=.... "
	db 	"DI=.... "
	db 	"BP=.... "
	db 	"SP=....",10
	db 	"[DI]=$"

dump_mem:
	db 	".... $"

dump_crlf:
	db 	13,10,10,"$"

dump_regmap:
	; DI, SI, BP, SP, BX, DX, CX, AX
	dw 	14	; AX
	dw	8	; BX
	dw	12	; CX
	dw	10	; DX
	dw	2	; SI
	dw	0	; DI
	dw	4	; BP
	dw	6	; SP
;----------------------------------------------------------------------

