	.file "first.S"
	
.global first
	.type first,@function
	
	
first:
	pop  r24                    ; pop the return address which was on the stack
	pop  r25
	
	ldi  r24, lo8(pm(first))    ; push our address onto the stack in place of
	ldi  r25, hi8(pm(first))    ; the original return address
	push r24
	push r25
	
	ldi  r24, lo8(pm(second))   ; push second's address onto the stack after us
	ldi  r25, hi8(pm(second))
	push r24
	push r25
	
	cbi  0x05, 2                ; turn off the LEDs
	cbi  0x05, 0
	
;	ldi  r24, lo8(1000)         ; delay for 1 second
;	ldi  r25, hi8(1000)
;	call _delay_ms
	
	ret
