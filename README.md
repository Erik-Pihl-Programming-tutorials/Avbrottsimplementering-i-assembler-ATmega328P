# Demonstration av PCI-avbrott i AVR assembler för mikrodator ATmega328P
Demonstration av avbrottsimplementering via avbrottsvektorer samt motsvarande avbrottsrutiner i assembler.
Även motsvarande C-kod demonstreras.

En lysdiod ansluten till pin 8 (PORTB0) togglas via nedtryckning av en tryckknapp ansluten till pin 13 (PORTB5). 
För att åstadkomma detta aktiveras PCI-avbrott på tryckknappens pin, som medför programhopp till motsvarande
avbrottsvektor PCINT0_vect på adress 0x06 vid logisk förändring av insignalen (nedtryckning eller uppsläppning).

I filen "main.asm" implementeras systemet i assembler. 
I filen "main.c" demonstreras motsvarande C-program.

Se video tutorial här:
https://youtu.be/Vrg4Pjf8LZY
