
#include "threads.h"

#define MAX_THREADS 4


// we're prescaling the system clock (16 MHz) by 1/1024
#define TIMER_CLOCK_FREQ 15625.0

#define INTERRUPT_FREQ 5

// LED output port bits 
#define RED_PIN_BIT 0
#define GREEN_PIN_BIT 2

// PC SIZE in terms of bytes, so we know how much mem to malloc
#define PC_SIZE 2

extern void suspend_thread(void);
extern void resume_thread(void);
extern void save_context(int*);
extern void load_context(int*);

extern void save_pc(int*);
extern void load_pc(int*);

extern void first(void);
extern void second(void);

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

// declare this to be an ISR that handles the Timer1 Overflow Interrupt
ISR (TIMER1_OVF_vect) {
	
	save_pc(prog_counters + (t_index * PC_SIZE/sizeof(int)));
	t_index++;
	t_index %= threads_running;
	load_pc(prog_counters + (t_index * PC_SIZE/sizeof(int)));
	
	TCNT1 = timer_init;
	
	asm volatile ( "reti" );
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
	//if (timer_init == 0) {
		// setup the timer interrupt, and get the timer init value
	//	timer_init = setup_timer_1((float) INTERRUPT_FREQ);
	//}
	
	return 0;
}



//-- TEST FUNCS --//
//-------------------------------------//

void turn_on(void) {
	for (;;) {
		PORTB &= 255 - (1 << GREEN_PIN_BIT);
		PORTB &= 255 - (1 << RED_PIN_BIT);
		PORTB &= 255 - (1 << GREEN_PIN_BIT);
		PORTB &= 255 - (1 << RED_PIN_BIT);
		PORTB |= 1 << GREEN_PIN_BIT;
		PORTB |= 1 << RED_PIN_BIT;
		PORTB &= 255 - (1 << GREEN_PIN_BIT);
		PORTB &= 255 - (1 << RED_PIN_BIT);
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
	
	//avr_threads_create(&turn_on, NULL);
	//avr_threads_create(&turn_off, NULL);
	
	// setup ports B & D (Arduino digital pins 0-13) as output pins
	DDRD = DDRD | 252; // 11111100   the zeros are so we don't affect
	DDRB = DDRB | 63;  // 00111111   special pins (TX, RX, and crystals)
	
	//accum = 0;
	//timer_init = setup_timer_1((float) INTERRUPT_FREQ);
}

int main(void) {
	
	init();

	PORTB &= 255 - (1 << GREEN_PIN_BIT);
	PORTB &= 255 - (1 << RED_PIN_BIT);
	
//	init();
//	
//	_delay_ms(1000);
//	
//	turn_off();
//	
//	for(;;) {
//	}
	
	first();
	
	turn_off();
	
	return 0;
}

