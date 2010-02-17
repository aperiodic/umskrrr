	.file "load_pc.S"
	
.global load_pc
	.type   load_pc,@function
	
load_pc:
	
	;; so, since the return address is pushed onto the stack as a side-effect
	;; of the call instruction, the stack looks like:
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
	;; our job is to make it look like this:
	;;
	;; | RETURN |
	;; | r31-30 |
	;; | r27-18 |
	;; | SREG   |
	;; | r0-1   |
	;; | PC     |
	;; ----------
	;;
	;; where PC is stored at the memory location passed to this function
	
	mov  r24,r26    ; move the passed address to X
	mov  r25,r27
	
	subi r26,-10    ; move X to the end of the memory range we'll be using
	sbci r27,0
	
	pop  r31        ; pop return address from stack and store it to memory
	pop  r30
	st   -X,r30
	st   -X,r31
	
	pop  r31
	pop  r30
	
	pop  r25
	pop  r24
	pop  r23
	pop  r22
	pop  r21
	pop  r20
	
	pop  r19        ; pop stored values of r27-26, store it to memory
	pop  r18
	st   -X,r18
	st   -X,r19
	
	pop  r0         ; pop SREG value, store it to memory
	st   -X,r0
	
	pop  r1         ; pop r1-0, store to memory
	pop  r0
	st   -X,r0
	st   -X,r1
	
	pop  r19
	pop  r18
	
	subi r26,2      ; move X down to PC address
	sbci r27,0
	
	;; we've gotten everything off the stack. however, there's a bunch of stuff
	;; we had to stick in memory in order to have enough free registers to hold
	;; everything from the stack
	;;
	;; address : value
	;; X       : lo8(PC)
	;; X+1     : hi8(PC)
	;; X+2     : r1
	;; X+3     : r0
	;; X+4     : SREG
	;; X+5     : r27
	;; X+6     : r26
	;; X+7     : 1st8 RETURN
	;; X+8     : 2nd8 RETURN
	
	ld   r0,X+      ; load PC, push onto stack
	ld   r1,X+
	push r0         
	push r1
	
	ld   r1,X+      ; load r1-0, push onto stack
	ld   r0,X+
	push r1
	push r0
	
	ld   r0,X+      ; load SREG, push onto stack
	push r0
	
	push r18
	push r19
	push r20
	push r21
	push r22
	push r23
	push r24
	push r25
	
	ld   r0,X+      ; load r27-26, push onto stack
	ld   r1,X+
	push r1
	push r0
	
	push r30
	push r31
	
	ld   r0,X+      ; load RETURN, push onto stack
	ld   r1,X+
	push r1
	push r0
	
	;; whew! the stack now looks exactly like it did before the interrupt,
	;; except the PC now points to a different thread's PC

	ret
