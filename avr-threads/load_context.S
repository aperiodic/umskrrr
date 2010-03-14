	.file "load_context.S"
	
.global load_context
	.type   load_context,@function
	
load_context:
	mov  r26,r24        ; move the context's address to X
	mov  r27,r25
	
	pop  r22            ; pop return address off of stack
	pop  r23
	
	ldi  r24,36         ; 36 bytes of saved context to push onto stack
	
	subi r26,lo8(-36)   ; move the X pointer to *end* of the saved context
	sbci r26,hi8(-36)
	
.loop:
	ld   r25,-X         ; load byte from memory
	push r25            ; push the byte onto the stack
	
	subi r24,1          ; decrement loop counter
	cpi  r24,1          ; compare loop counter w/one
	
	brge .loop          ; jump back to loop if counter is >= 1 (i.e. !0)
	
.end:	
	push r23            ; push return address back onto stack
	push r22
	
	ret
