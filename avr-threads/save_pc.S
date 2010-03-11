	.file "save_pc.S" 
.global save_pc
	.type   save_pc,@function
	
save_pc:

	mov  r26,r24    ; move passed address to X
	mov  r27,r25
	
	pop  r25        ; pop return address
	pop  r24
	
	pop  r21        ; pop PC
	pop  r20
	
	st   X+,r20     ; store PC
	st   X+,r21
	
	push r24        ; push return address
	push r25
	
	ret
	
	
	

;	;; when the interrupt happens, the PC is pushed onto the stack. we also
;	;; push some registers on the stack, since they're used to calculate the
;	;; memory address passed to this function. finally, when this function is
;	;; called, the return address is pushed, so the stack looks like this:
;	;;
;	;; | RET1   |
;	;; | RET2   |
;	;; | SREG   |
;	;; | r0:1   |
;	;; | r17:19 |
;	;; | r24:25 |
;	;; | PC     |
;	;; ----------
;	;;
;	;; so we need to pop all the stuff on top of the PC
;	;; 
;	
;	push r26        ; push r26:27 onto stack (old X pointer)
;	push r27
;	
;	mov  r24,r26    ; move the passed address to X
;	mov  r25,r27
;	
;	pop  r24        ; pop saved r27-26 (old X pointer) into r25-24,
;	pop  r25        ; so as to not clobber our X
;	
;	pop  r18        ; pop RET1 and RET2 bytes off stack, store in mem
;	pop  r19
;	st   X+,r18
;	st   X+,r19
;	
;	st   X+,r24     ; save the old X pointer into memory
;	st   X+,r25
;	
;	pop  r0         ; pop SREG val
;	st   X+,r0      ; store SREG val in mem
;	
;	pop  r0         ; pop 0 and r1 from stack, store in mem
;	pop  r1
;	st   X+,r0      
;	st   X+,r1
;	
;	pop  r17        ; pop the rest of the registers still on stack
;	pop  r18
;	pop  r19
;	pop  r24
;	pop  r25
;	
;	pop  r0         ; pop the PC from the stack
;	pop  r1
;	
;	st   X+,r0      ; store PC in memory
;	st   X+,r1
;	
;	
;	;; at this point, we've got everything that was pushed onto the stack after
;	;; the interrupt triggered, so the stack is effectively empty
;	;; 
;	;; we also have some of the registers that were on the stack in memory
;	;;
;	;; mem:
;	;; 
;	;; address : value
;	;; 
;	;; X-9     : 1st8(RETURN)
;	;; X-8     : 2nd8(RETURN)
;	;; X-7     : r27
;	;; X-6     : r26
;	;; X-5     : SREG 
;	;; X-4     : r0
;	;; X-3     : r1
;	;; X-2     : lo8(PC)
;	;; X-1     : hi8(PC)
;	
;	
;	subi r26,2      ; move X down to r1's address
;	sbci r26,0
;	
;	ld   r1,-X      ; grab saved r1-r0 from memory & push onto stack
;	ld   r0,-X
;	push r1       
;	push r0
;	
;	ld   r19,-X     ; grab saved SREG from memory & push onto stack
;	push r19
;	
;	ld   r19,-X     ; grab saved r27-26 from memory & push onto stack
;	ld   r18,-X
;	push r18
;	push r19
;	
;	ld   r19,-X     ; grab return address from memory 
;	ld   r18,-X
;	
;	
;	;; alright, now we've stored the PC in memory, but we still need to 
;	;; push all the registers we're using back on the stack, since avr-gcc
;	;; assumes they've been saved, so they'll be used freely in the ISR once
;	;; we return from this call. 
;	
;	
;	;; so now the stack holds
;	;;
;	;; | RETURN |
;	;; | r31-30 |
;	;; | r25-20 |
;	;; | r27-26 |
;	;; | SREG   |
;	;; | r1-0   |
;	;; | r19-18 |
;	;; ----------
;	;;
;	;; which is everything that was on the stack when we started, besides the
;	;; PC, which we've stored in memory (that was the point of this function)
;	
;	
;	ret
