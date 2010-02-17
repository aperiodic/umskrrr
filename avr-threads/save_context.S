	.file "save_context.S"
	
.global save_context
	.type  save_context,@function
	
save_context:
	mov  r24,r26    ; move the passed address to X
	mov  r25,r27
	
	push r20        ; load SREG from stack
	st   X+,r20     ; store SREG in mem
	
	ldi  r18,32     ; 32 registers to load & save
	
.loop:
	subi r18,1      ; decrement loop counter
	brmi .end       ; if loop counter < 0, break out of loop
	
	pop  r20        ; load a saved register from stack
	st   X+,r20     ; store saved register in memory
	
	jmp  .loop
	
.end:
	push r21        ; load PC from stack
	push r20
	st   X+,r20     ; store PC in mem
	st   X+,r21
	
	ret
