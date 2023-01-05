/********************************************************************************
* main.c: Demonstration av enkelt C-program f�r att demonstrera PCI-avbrott.
*         En lysdiod ansluts till pin 8 (PORTB0) och en tryckknapp ansluts 
*         till pin 13 (PORTB). PCI-avbrott aktiveras p� tryckknappens pin. 
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
* ISR: Avbrottsrutin f�r PCI-avbrott p� I/O-port B, som �ger rum vid nedtryckning 
*      samt uppsl�ppning av tryckknappen. Vid nedtryckning togglas lysdioden, 
*      annars g�rs ingenting.
*
*      - PCINT0_vect: Avbrottsvektor f�r PCI-avbrott p� I/O-port B, som ligger
*                     p� adress 0x06 i programminnet.
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
* setup: Initierar I/O-portar (lysdioden s�tts till utport och den interna 
*        pullup-resistorn p� tryckknappens pin aktiveras) samt aktiverar 
*        PCI-avbrott p� tryckknappens pin.
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
* main: Initierar I/O-portar samt PCI-avbrott vid start. Programmet h�lls
*       sedan ig�ng kontinuerligt s� l�nge matningssp�nning tillf�rs.
********************************************************************************/
int main(void)
{
   setup(); 

   while (1)
   {

   }

   return 0;
}

