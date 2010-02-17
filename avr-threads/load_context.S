	.file "load_context.S"
	
.global load_context
	.type   load_context,@function
	
load_context:
	mov  r25,r27    ; move the context's address to X
	mov  r26,r28
	
	ld   r20,X+     ; load the SREG value
	sts  0x003f,r20 ; put SREG value in SREG
	
	subi r27,-32    ; move X to memory location of PC
	ld   r20,X+     ; load the PC
	ld   r21,X+
	
	push r20        ; put the PC on the stack
	push r21
	
	ldi  r18,32     ; set loop counter to 32
	add  r27,r18    ; move X to right above memory destination for r31
	inc  r27
	
.loop:
	subi r18,1      ; decrement loop counter
	brmi .end       ; if loop counter < 0, end loop
	
	ld   r20,-X     ; load register from memory
	push r20        ; push the register onto the stack
	
	jmp .loop
	
.end:
	ret
