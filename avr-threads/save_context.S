	.file "save_context.S"
	
.global save_context
	.type  save_context,@function
	
save_context:
	mov  r26,r24    ; move context storage pointer to X registers
	mov  r27,r25
	
	pop  r22        ; pop return address off of stack
	pop  r23
	
	ldi  r24,36     ; 36 bytes (r0:32, SREG, filler, PC) on the stack to save
	
.loop:
	pop  r25        ; pop saved register off of the stack
	st   X+,r25     ; save the register to memory
	
	subi r24,1      ; decrement loop counter
	cpi  r24,1      ; compare loop counter w/one
	
	brge .loop      ; jump back to loop if counter is >= 1 (i.e. !0)
	
.end:
	push r23        ; push return address back on the stack
	push r22
	
	ret
