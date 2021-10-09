; Generated LM-8 Assembly Program

; Run initialization code
	jmp __initialize

; Virtual stack
	data
__fp_h: var
__fp_l: var
	rodata
; Library includes
	include "libraries/Math.asm"
	include "libraries/Serial.asm"

; Built-in print function
print:
	ldr [__fp_h],H
	ldr [__fp_l],L
	dea
	ldr [HL],B
	dea
	ldr [HL],A
	push A
	pop H
	push B
	pop L
	jsr print_string_extended
	ret

; Built-in port draw_sprite function
draw_sprite:
	ldr [__fp_h],H
	ldr [__fp_l],L
	dea
	ldr [HL],A
	out {graphics_x},A
	dea
	dea
	ldr [HL],A
	out {graphics_y},A
	dea
	dea
	ldr [HL],B
	dea
	ldr [HL],A
	push A
	pop H
	push B
	pop L
	out {draw_sprite},A
	ret

; Built-in port draw_pixel function
draw_pixel:
	ldr [__fp_h],H
	ldr [__fp_l],L
	dea
	ldr [HL],A
	out {graphics_x},A
	dea
	dea
	ldr [HL],A
	out {graphics_y},A
	dea
	dea
	ldr [HL],A
	out {draw_pixel},A
	ret

; Built-in port write function
write:
	ldr [__fp_h],H
	ldr [__fp_l],L
	dea
	ldr [HL],A
	dea
	dea
	ldr [HL],B
	out B
	ret

; Built-in port read function
read:
	ldr [__fp_h],H
	ldr [__fp_l],L
	dea
	dea
	dea
	ldr [HL],A
	in B
	ina
	push H
	ldr [HL],H
	ina
	ldr [HL],L
	pop H
	ldr $0,A
	str [HL],A
	ina
	str [HL],B
	ret

; Copies [__copy_bytes_h][__copy_bytes_l] bytes from HL to AB, trashes __copy_bytes and registers
	data
__copy_bytes_h: var
__copy_bytes_l: var
__copy_memory_dest_h_: var
__copy_memory_dest_l_: var
	rodata
__copy_memory:
	str [__copy_memory_dest_h_],A
	str [__copy_memory_dest_l_],B
__copy_memory_loop_:
	push H
	push L
	ldr $0,A
	ldr [__copy_bytes_h],H
	ldr [__copy_bytes_l],L
	cmp H
	jr __copy_memory_not_done_,nZ
	cmp L
	jr __copy_memory_not_done_,nZ
	pop L
	pop H
	jr __copy_memory_done_
__copy_memory_not_done_:
	dea
	str [__copy_bytes_h],H
	str [__copy_bytes_l],L
	pop L
	pop H
	ldr [HL],A
	push H
	push L
	ldr [__copy_memory_dest_h_],H
	ldr [__copy_memory_dest_l_],L
	str [HL],A
	ina
	str [__copy_memory_dest_h_],H
	str [__copy_memory_dest_l_],L
	pop L
	pop H
	ina
	jr __copy_memory_loop_
__copy_memory_done_:
	ret


__initialize:
; Run main function
	lda __stack
	str [__fp_h],H
	str [__fp_l],L
	jmp main

	data
__stack:
