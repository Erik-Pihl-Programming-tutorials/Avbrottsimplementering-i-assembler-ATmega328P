/********************************************************************************
* main.c: Demonstration av enkelt C-program för att demonstrera PCI-avbrott.
*         En lysdiod ansluts till pin 8 (PORTB0) och en tryckknapp ansluts 
*         till pin 13 (PORTB). PCI-avbrott aktiveras på tryckknappens pin. 
*         Vid nedtryckning av tryckknappen togglas lysdioden.
********************************************************************************/
#include <avr/io.h>
#include <avr/interrupt.h>

/* Makrodefinitioner: */
#define LED1 PORTB0    /* Lysdiod 1 ansluten till pin 8 (PORTB0). */
#define BUTTON1 PORTB5 /* Tryckknapp 1 ansluten till pin 13 (PORTB5). */

#define LED1_TOGGLE PINB = (1 << LED1)             /* Togglar lysdiod 1. */
#define BUTTON1_IS_PRESSED (PINB & (1 << BUTTON1)) /* Indikerar nedtryckning. */

/********************************************************************************
* ISR: Avbrottsrutin för PCI-avbrott på I/O-port B, som äger rum vid nedtryckning 
*      samt uppsläppning av tryckknappen. Vid nedtryckning togglas lysdioden, 
*      annars görs ingenting.
*
*      - PCINT0_vect: Avbrottsvektor för PCI-avbrott på I/O-port B, som ligger
*                     på adress 0x06 i programminnet.
********************************************************************************/
ISR (PCINT0_vect)
{
   if (BUTTON1_IS_PRESSED)
   {
      LED1_TOGGLE;
   }
   return;
}

/********************************************************************************
* setup: Initierar I/O-portar (lysdioden sätts till utport och den interna 
*        pullup-resistorn på tryckknappens pin aktiveras) samt aktiverar 
*        PCI-avbrott på tryckknappens pin.
********************************************************************************/
static inline void setup(void)
{
   DDRB = (1 << LED1);
   PORTB = (1 << BUTTON1);

   asm("SEI"); 
   PCICR = (1 << PCIE0);
   PCMSK0 = (1 << BUTTON1);
   return;
}

/********************************************************************************
* main: Initierar I/O-portar samt PCI-avbrott vid start. Programmet hålls
*       sedan igång kontinuerligt så länge matningsspänning tillförs.
********************************************************************************/
int main(void)
{
   setup(); 

   while (1)
   {

   }

   return 0;
}

