	.file "second.S"
	
	
.global second
	.type second,@function
	

second:
	ldi  r24, lo8(pm(first))    ; push first's address onto the stack in place 
	ldi  r25, hi8(pm(first))    ; of the original return address
	push r24
	push r25
	
	sbi  0x05, 2                ; turn on the LEDs
	sbi  0x05, 0
	
;	ldi  r24,lo8(1000)          ; delay for 1 second
;	ldi  r25,hi8(1000)
;	call _delay_ms
	
	ret
