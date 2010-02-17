	.file "resume_thread.S"
	
.global resume_thread
	.type   resume_thread,@function
	
resume_thread:
	;; pop all registers from the stack
	pop  r0
	pop  r1
	pop  r2
	pop  r3
	pop  r4
	pop  r5
	pop  r6
	pop  r7
	pop  r8
	pop  r9
	pop  r10
	pop  r11
	pop  r12
	pop  r13
	pop  r14
	pop  r15
	pop  r16
	pop  r17
	pop  r18
	pop  r19
	pop  r20
	pop  r21
	pop  r22
	pop  r23
	pop  r24
	pop  r25
	pop  r26
	pop  r27
	pop  r28
	pop  r29
	pop  r30
	pop  r31
	
	;; push the registers gcc placed on stack at beginning of interrupt
	push r1
	push r0
	
	in   r0,0x3f    ; load SREG value
	push r0         ; push SREG value onto stack
	
	push r16
	push r17
	push r18
	push r19
	push r20
	push r21
	push r22
	push r23
	push r24
	push r25
	push r26
	push r27
	push r30
	push r31
	
	ret
