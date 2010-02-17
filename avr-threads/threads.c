
#include "threads.h"

#define MAX_THREADS 4


// we're prescaling the system clock (16 MHz) by 1/8, so timer clock is 2 MHz
#define TIMER_CLOCK_FREQ 2000000.0

// let's generate an interrupt every millis
#define INTERRUPT_FREQ 1000

// LED output port bits 
#define RED_PIN_BIT 0
#define GREEN_PIN_BIT 2

// PC SIZE in terms of bytes, so we know how much mem to malloc
#define PC_SIZE 10

extern void suspend_thread(void);
extern void resume_thread(void);
extern void save_context(int*);
extern void load_context(int*);

extern void save_pc(int*);
extern void load_pc(int*);


//-- GLOBAL VARS --//
unsigned int timer_init, accum;

thread_context *threads;
int* prog_counters;
unsigned char t_index, threads_running;



//-- TIMER SETUP --//
//-------------------------------------//

unsigned int setup_timer_1(float trigger_frequency) {
	unsigned int result;
	
	result = (int) (65537.0 - (TIMER_CLOCK_FREQ / trigger_frequency) + 0.5);
	
	// clear Timer/Counter1 Control Register A
	TCCR1A = 0;
	
	// set the clock select flags to prescale the sys clock by 1/8
	TCCR1B = 0 << CS12 | 1 << CS11 | 0 << CS10;
	
	// set the Timer1 Overflow Interrupt flag, clear other flags
	TIMSK1 = _BV (TOIE1);
	
	// load calculated starting value into the timer
	TCNT1 = result;
	
	sei();
	
	return result;
}


//-- TIMER INTERRUPT SERVICE ROUTINE --//
//-------------------------------------//

// declare this to be an ISR that handles the Timer1 Overflow Interrupt
ISR (TIMER1_OVF_vect) {
	if (threads_running == 1) {
		// if we're only running main thread, bail
		return;
	}
	
	// save current thread's pc
	save_pc(prog_counters + (t_index * PC_SIZE/2));
	
	// increment thread index
	t_index++;
	
	t_index %= threads_running;
	
	// load next thread's pc and place it on the stack
	load_pc(prog_counters + (t_index * PC_SIZE/2));
	
	// set Timer1 so we get another interrupt at proper time
	TCNT1 = timer_init;
	
//	// push the context of the currently executing thread on the stack
//	suspend_thread();
//	
//	save_context((int*) (t_index * sizeof(thread_context) + threads));
//	
//	t_index++;
//	t_index = t_index % threads_running;
//	
//	load_context((int*) (t_index * sizeof(thread_context) + threads));
//	
//	resume_thread();
}



//-- THREAD FUNCS --//
//-------------------------------------//

void avr_threads_init(void) {
	// malloc memory to hold program counters for all our
	// threads, as well as the main thread
	prog_counters = (int*) malloc(PC_SIZE * (MAX_THREADS + 1));
	
	t_index = 0;
	
	// main thread is always running
	threads_running = 1;
	
}

int avr_threads_create(void* func, void* args) {
	if (threads_running == MAX_THREADS) return 1;
	
	*(prog_counters + (threads_running*PC_SIZE/2)) = (int) func;
	threads_running++;
	
	// if timer_init is zero, interrupts haven't been enabled yet
	if (timer_init == 0) {
		// setup the timer interrupt, and get the timer init value
		timer_init = setup_timer_1((float) INTERRUPT_FREQ);
	}
	
	return 0;
	
//	int *t_address =(int*) (threads_running * sizeof(thread_context) + threads);
//	
//	
//	int i;
//	// clear the memory allocated for the thread context
//	for (i = 0; i < sizeof(thread_context); i++) {
//		*(t_address + i) = 0;
//	}
//	
//	// put the pointer to the arguments in the 
//	// appropriate registers
//	*(t_address + 24) = (int)args & 0x00FF;
//	*(t_address + 25) = (int)args & 0xFF00;
//	
//	// store the address of the program in the program counter
//	*(t_address + 33) = (int)func & 0x00FF;
//	*(t_address + 34) = (int)func & 0xFF00;
//	
//	threads_running++;
//	return 0;
}



//-- TEST FUNCS --//
//-------------------------------------//

void turn_on(void) {
	for (;;) {
		PORTB |= 1 << GREEN_PIN_BIT;
		PORTB |= 1 << RED_PIN_BIT;
	}
}

void turn_off(void) {
	for (;;) {
		PORTB &= 255 - (1 << GREEN_PIN_BIT);
		PORTB &= 255 - (1 << RED_PIN_BIT);
	}
}



//-- STANDARD FARE --//
//-------------------------------------//

void init(void) {
	avr_threads_init();
	
	// setup ports B & D (Arduino digital pins 0-13) as output pins
	DDRD = DDRD | 252; // 11111100   the zeros are so we don't affect
	DDRB = DDRB | 63;  // 00111111   special pins (TX, RX, and crystals)
	
	//PORTB = 1 << OUTPUT_PIN_BIT;
	
	accum = 0;
}

int main(void) {

	init();
	
	//avr_threads_create(&green_led, NULL);
	//avr_threads_create(&red_led, NULL);
	
	for(;;) {
		_delay_ms(1000);	
	}
	
	return 0;
}

