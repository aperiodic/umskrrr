	.file "suspend_thread.S"
	
	
.global suspend_thread
	.type   suspend_thread,@function


suspend_thread:
	;; get the registers which gcc pushed onto the stack back from the stack
	pop  r31
	pop  r30
	pop  r27
	pop  r26
	pop  r25
	pop  r24
	pop  r23
	pop  r22
	pop  r21
	pop  r20
	pop  r19
	pop  r18
	pop  r17
	pop  r16
	
	pop  r0         ; pop SREG value into r0
	out  0x3f,r0    ; put SREG value in SREG
	
	pop  r0
	pop  r1
	
	;; immediately push all registers onto the stack
	push r31
	push r30
	push r29
	push r28
	push r27
	push r26
	push r25
	push r24
	push r23
	push r22
	push r21
	push r20
	push r19
	push r18
	push r17
	push r16
	push r15
	push r14
	push r13
	push r12
	push r11
	push r10
	push r9
	push r8
	push r7
	push r6
	push r5
	push r4
	push r3
	push r2
	push r1
	push r0
	
	in   r22,0x3f   ; get status register value
	push r22        ; put the status register on the stack
	
	ret
	
	
;	in   r22,0x003F ; store the status register
;	ldi  r18,35     ; 35 is the size of a thread context
;	lds  r19,0x018C ; load the index of thread which was executing
;	mul  r18,r19    ; calculate the address offset for the thread
;	clr  r27        ; clear high byte of X
;	mov  r0,r26     ; move the memory address to X 
;
;
;loop:
;	subi r18,1      ; decrement loop counter
;	brmi end        ; branch if loop counter was zero
;
;	pop  r20        ; load a register from the stack
;	st   X+,r20     ; store that register in memory
;	
;	jmp  loop
;	
;end:
;	st   x+,r22     ; store status reg in memory
;
;	pop  r20        ; get the program counter from the stack
;	pop  r21
;	
;	st   X+,r20     ; store the program counter in memory
;	st   X+,r21
;
;	
;	subi r19,-1     ; increment thread index
;	cpi  r19,2      ; test to see if thread index == 2
;	
;	brlo ld_contex  ; if index < 2, skip ahead to loading the context
;	
;	subi r19,2
;	
;ld_context:
;	ldi  r18,35     ; calculate new thread's context address
;	mul  r18,r19
;	clr  r27        ; move the address to X
;	mov  r0,r26
;	
;	
;
;
;	push r21        ; push the program counter back on the stack
;	push r20
;	
;	;subi r19,-1     ; increment current thread index
;	
;	call _green_led
;	reti
