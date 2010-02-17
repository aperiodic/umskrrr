	.file "save_pc.S"
	
.global save_pc
	.type   save_pc,@function
	
save_pc:
	;; when the interrupt routine is called, gcc pushes r0-1,r27-18, and r31-30
	;; onto the stack so they can be used in the ISR. when it calls this 
	;; assembly function, the return address is pushed on the stack
	;; PC is already on the stack as a byproduct of the interrupt triggering
	;;
	;; stack: 
	;;
	;; | RETURN |
	;; | r31-30 |
	;; | r27-18 |
	;; | SREG   |
	;; | r0-1   |
	;; | PC     |
	;; ----------
	;;
	;; so we need to pop all the stuff on top of the PC
	;; 
	
	mov  r24,r26    ; move the passed address to X
	mov  r25,r27
	
	pop  r31        ; pop the return address from the stack
	pop  r30
	st   X+,r30     ; save the return address to memory
	st   X+,r31
	
	pop  r31        ; restore r31 and r30 from stack
	pop  r30
	
	pop  r25        ; pop saved r27-26 (old X pointer) into r25-24,
	pop  r24        ; so as to not clobber our X
	st   X+,r24     ; save the old X pointer into memory
	st   X+,r25
	
	pop  r25        ; continuing restoring registers from stack
	pop  r24
	pop  r23
	pop  r22
	pop  r21
	pop  r20
	pop  r19
	pop  r18
	
	pop  r0         ; pop SREG val
	st   X+,r0      ; store SREG val in mem
	
	pop  r0         ; restore r0 and r1 from stack
	pop  r1
	
	st   X+,r0      ; save r0 and r1 to mem
	st   X+,r1
	
	pop  r0         ; pop the PC from the stack
	pop  r1
	
	
	;; at this point, we've got everything that was pushed onto the stack after
	;; the interrupt triggered, so the stack is effectively empty
	;; 
	;; we also have some of the registers that were on the stack in memory
	;;
	;; mem:
	;; 
	;; address : value
	;; x-7     : 2nd8(RETURN)
	;; x-6     : 1st8(RETURN)
	;; X-5     : r26
	;; X-4     : r27
	;; X-3     : SREG 
	;; X-2     : r0
	;; X-1     : r1
	
	
	push r18        ; we've got the PC now, so we can use the stack again
	push r19         
	
	ld   r19,-X     ; grab saved r1-r0 from memory & push onto stack
	ld   r18,-X
	push r18        
	push r19
	
	ld   r19,-X     ; grab saved SREG from memory & push onto stack
	push r19
	
	ld   r19,-X     ; grab saved r27-26 from memory & push onto stack
	ld   r18,-X
	push r18
	push r19
	
	ld   r19,-X     ; grab return address from memory 
	ld   r18,-X
	
	st   X+,r0      ; store PC in memory
	st   X+,r1
	
	
	;; alright, now we've stored the PC in memory, but we still need to 
	;; push all the registers we're using back on the stack, since avr-gcc
	;; assumes they've been saved, so they'll be used freely in the ISR
	;;
	;; stack:
	;;
	;; | r27-26 |
	;; | SREG   |
	;; | r1-0   |
	;; | r19-18 |
	;; ----------
	
	
	push r20
	push r21
	push r22
	push r23
	push r24
	push r25
	push r30
	push r31
	
	push r18        ; r18-19 hold return address
	push r19
	
	
	;; so now the stack holds
	;;
	;; | RETURN |
	;; | r31-30 |
	;; | r25-20 |
	;; | r27-26 |
	;; | SREG   |
	;; | r1-0   |
	;; | r19-18 |
	;; ----------
	;;
	;; which is everything that was on the stack when we started, besides the
	;; PC, which we've stored in memory (that was the point of this function)
	
	
	ret
