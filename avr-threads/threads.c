
#include "threads.h"

#define MAX_THREADS 4

// we're prescaling the system clock (16 MHz) by 1/1024
#define TIMER_CLOCK_FREQ 15625.0

#define INTERRUPT_FREQ 5

// LED output port bits 
#define RED_1_PIN_BIT 0
#define RED_2_PIN_BIT 1
#define GREEN_1_PIN_BIT 2
#define GREEN_2_PIN_BIT 3

#define INT_SIZE sizeof(int)

// size of a thread executions context in terms of bytes, 
// so we know how much mem to malloc
#define CTXT_SIZE 36

// the PC comes at the end of an execution context in memory, because it's the
// very last thing popped off the stack when we're saving stuff.
#define PC_INT_OFFSET 17

extern inline void save_context(int*);
extern inline void load_context(int*);

extern void save_pc(int*);
extern void load_pc(int*);

void TIMER1_OVF_vect (void) __attribute__ (( signal, naked ));


//-- GLOBAL VARS --//
unsigned int timer_init, accum;

thread_context *threads;
int* prog_counters;
unsigned char t_index, threads_running;



//-- TIMER SETUP --//
//-------------------------------------//

unsigned int setup_timer_1(float trigger_frequency) {
	unsigned int result;
	
	result = (int) (65536.0 - (TIMER_CLOCK_FREQ / trigger_frequency));
	
	// clear Timer/Counter1 Control Register A
	TCCR1A = 0;
	
	// set the clock select flags to prescale the sys clock by 1/1024
	TCCR1B = 1 << CS12 | 0 << CS11 | 1 << CS10;
	
	// set the Timer1 Overflow Interrupt flag, clear other flags
	TIMSK1 = 1 << TOIE1;
	
	// load calculated starting value into the timer
	TCNT1 = result;
	
	sei();
	
	return result;
}


//-- TIMER INTERRUPT SERVICE ROUTINE --//
//-------------------------------------//

// macro to suspend the thread by pushing execution context onto stack
#define SUSPEND_THREAD(); \
	asm volatile (  \
		"push r0        \n\t" \
		"push r0        \n\t" \
		"in   r0,0x3f   \n\t" \
		"push r0        \n\t" \
		"push r1        \n\t" \
		"push r2        \n\t" \
		"push r3        \n\t" \
		"push r4        \n\t" \
		"push r5        \n\t" \
		"push r6        \n\t" \
		"push r7        \n\t" \
		"push r8        \n\t" \
		"push r9        \n\t" \
		"push r10       \n\t" \
		"push r11       \n\t" \
		"push r12       \n\t" \
		"push r13       \n\t" \
		"push r14       \n\t" \
		"push r15       \n\t" \
		"push r16       \n\t" \
		"push r17       \n\t" \
		"push r18       \n\t" \
		"push r19       \n\t" \
		"push r20       \n\t" \
		"push r21       \n\t" \
		"push r22       \n\t" \
		"push r23       \n\t" \
		"push r24       \n\t" \
		"push r25       \n\t" \
		"push r26       \n\t" \
		"push r27       \n\t" \
		"push r28       \n\t" \
		"push r29       \n\t" \
		"push r30       \n\t" \
		"push r31       \n\t" \
	);


// macro that resumes a thread by pulling its execution context from the stack
#define RESUME_THREAD(); \
	asm volatile(  \
		"pop  r31       \n\t" \
		"pop  r30       \n\t" \
		"pop  r29       \n\t" \
		"pop  r28       \n\t" \
		"pop  r27       \n\t" \
		"pop  r26       \n\t" \
		"pop  r25       \n\t" \
		"pop  r24       \n\t" \
		"pop  r23       \n\t" \
		"pop  r22       \n\t" \
		"pop  r21       \n\t" \
		"pop  r20       \n\t" \
		"pop  r19       \n\t" \
		"pop  r18       \n\t" \
		"pop  r17       \n\t" \
		"pop  r16       \n\t" \
		"pop  r15       \n\t" \
		"pop  r14       \n\t" \
		"pop  r13       \n\t" \
		"pop  r12       \n\t" \
		"pop  r11       \n\t" \
		"pop  r10       \n\t" \
		"pop  r9        \n\t" \
		"pop  r8        \n\t" \
		"pop  r7        \n\t" \
		"pop  r6        \n\t" \
		"pop  r5        \n\t" \
		"pop  r4        \n\t" \
		"pop  r3        \n\t" \
		"pop  r2        \n\t" \
		"pop  r1        \n\t" \
		"pop  r0        \n\t" \
		"out  0x3f,r0   \n\t" \
		"pop  r0        \n\t" \
		"pop  r0        \n\t" \
	);


// declare this to be an ISR that handles the Timer1 Overflow Interrupt
ISR (TIMER1_OVF_vect) {
	
	SUSPEND_THREAD();
	
	save_context(prog_counters + (t_index * CTXT_SIZE/INT_SIZE));
	t_index++;
	t_index %= threads_running;
	load_context(prog_counters + (t_index * CTXT_SIZE/INT_SIZE));
	
	TCNT1 = timer_init;
	
	RESUME_THREAD();
	
	asm volatile ( "reti" );
}



//-- THREAD FUNCS --//
//-------------------------------------//

void avr_threads_init(void) {
	// malloc memory to hold program counters for all our
	// threads, as well as the main thread
	prog_counters = (int*) malloc(CTXT_SIZE * (MAX_THREADS));
	
	t_index = 0;
	
	// main thread is always running
	threads_running = 1;
}

int avr_threads_create(void* func, void* args) {
	if (threads_running == MAX_THREADS) return 1;
	
	*(prog_counters + (threads_running*CTXT_SIZE/INT_SIZE) + 
	  PC_INT_OFFSET) = (int) func;
	threads_running++;
	
	return 0;
}

void avr_threads_start(void) {
	// if timer_init is zero, interrupts haven't been enabled yet
	if (timer_init == 0) {
		// setup the timer interrupt, and get the timer init value
		timer_init = setup_timer_1((float) INTERRUPT_FREQ);
	}
}



//-- TEST FUNCS --//
//-------------------------------------//

void turn_on(void) {
	for (;;) {
		PORTB |= 1 << GREEN_1_PIN_BIT;
		PORTB |= 1 << RED_1_PIN_BIT;
	}
}

void turn_off(void) {
	for (;;) {
		PORTB &= 255 - (1 << GREEN_1_PIN_BIT);
		PORTB &= 255 - (1 << RED_1_PIN_BIT);
	}
}



//-- STANDARD FARE --//
//-------------------------------------//

void init(void) {
	avr_threads_init();
	
	avr_threads_create(&turn_on, NULL);
	//avr_threads_create(&turn_off, NULL);
	
	// setup ports B & D (Arduino digital pins 0-13) as output pins
	DDRD = DDRD | 252; // 11111100   the zeros are so we don't affect
	DDRB = DDRB | 63;  // 00111111   special pins (TX, RX, and crystals)
	
	avr_threads_start();
}

int main(void) {
	
	init();
	
	turn_off();
	
	for(;;) {
	}
	
	return 0;
}

