;/********************************************************************************
;* main.asm: Demonstration av enkelt assemblerprogram f�r att demonstrera 
;*           PCI-avbrott. En lysdiod ansluts till pin 8 (PORTB0) och en 
;*           tryckknapp ansluts till pin 13 (PORTB). PCI-avbrott aktiveras p�
;*           tryckknappens pin. Vid nedtryckning av tryckknappen togglas 
;*           lysdioden, annars g�rs ingenting.
;*
;*           Assemblerdirektiv:
;*           .EQU (Equal)        : Anv�nds f�r makrodefinitioner.
;*           .ORG (Origin)       : Anv�nds f�r att specificera en adress.
;*           .CSEG (Code segment): Programminnet, h�r lagras programkoden.
;*
;*           Assemblerinstruktioner:
;*           RJMP (Relative jump)  : Hoppar till angiven adress.
;*           LDI (Load immediage)  : L�ser in en konstant i ett CPU-register.
;*           OUT                   : Skriver till ett I/O-register s�som PORTB.
;*           IN                    : L�ser fr�n ett I/O-register s�som PINB.
;*           ANDI (And immediate)  : Bitvis multiplikation med en konstant.
;*           SEI (Set Interrupt)   : Ettst�ller I-flaggan i statusregister SREG
;*                                   f�r att aktivera avbrott globalt.
;*           BREQ (Branch if equal): Genomf�r hopp till angiven adress om
;*                                   resultatet fr�n f�reg�ende aritmetiska
;*                                   eller logiska operation blev noll.
;*                                   Detta indikeras via Z-flaggan (Zero) i
;*                                   statusregistret SREG, som d� blir ettst�lld.
;********************************************************************************/

; Makrodefinitioner:
.EQU LED1 = PORTB0    ; Lysdiod 1 ansluten till pin 8 (PORTB0).
.EQU BUTTON1 = PORTB5 ; Tryckknapp 1 ansluten till pin 13 (PORTB5).

.EQU RESET_vect = 0x00  ; Reset-vektor, anropas vid system�terst�llning samt start av programmet.
.EQU PCINT0_vect = 0x06 ; Avbrottsvektor f�r PCI-avbrott p� I/O-port B.

;/********************************************************************************
;* .CSEG: Kodsegmentet (programminnet) - H�r lagras programkoden.
;********************************************************************************/
.CSEG 

;/********************************************************************************
;* RESET_vect: Programmets startadress. Programmet startar genom att hopp sker
;*             till subrutinen main. Programmet hoppar �ven till denna adress
;*             vid system�terst�llning.
;********************************************************************************/
.ORG RESET_vect 
   RJMP main    ; Hoppar till subrutinen main f�r att starta programmet.

;/********************************************************************************
;* PCINT0_vect: Avbrottsvektor f�r PCI-avbrott p� I/O-port B. Vid avbrott sker
;*              programhopp till motsvarande avbrottsrutin ISR_PCINT0.
;********************************************************************************/
.ORG PCINT0_vect 
   RJMP ISR_PCINT0 ; Hoppar till motsvarande avbrottsrutin ISR_PCINT0.

;/********************************************************************************
;* ISR_PCINT0: Avbrottsrutin f�r PCI-avbrott p� I/O-port B, som �ger rum vid
;*             nedtryckning och uppsl�ppning av tryckknappen. Vid nedtryckning 
;*             togglas lysdioden, annars g�rs ingenting.
;********************************************************************************/
ISR_PCINT0:
   IN R17, PINB             ; L�ser insignaler fr�n PINB, sparar en kopia i R17.
   ANDI R17, (1 << BUTTON1) ; Multiplicerar bitvis med 0010 0000.
   BREQ ISR_PCINT0_end      ; Om kvarvarande v�rde �r lika med 0x00 g�rs ingenting.x
   OUT PINB, R16            ; Annars togglas lysdioden (0000 0001 ligger kvar i R16).
ISR_PCINT0_end:
   RETI                     ; Avslutar avbrottet och �terst�ller systemet.

;/********************************************************************************
;* main: Initierar I/O-portar samt PCI-avbrott vid start. Programmet h�lls
;*       sedan ig�ng kontinuerligt s� l�nge matningssp�nning tillf�rs.
;********************************************************************************/
main:

;/********************************************************************************
;* setup: Initierar I/O-portar (lysdioden s�tts till utport och den interna 
;*        pullup-resistorn p� tryckknappens pin aktiveras) samt aktiverar 
;*        PCI-avbrott p� tryckknappens pin. Denna subrutin placeras inline i
;*        i main f�r att effektivisera programmet (vi slipper programhopp samt
;*        �terhopp).
;********************************************************************************/
setup:                    
   LDI R16, (1 << LED1)    ; L�ser in v�rdet 0000 0001 i CPU-register R16.
   OUT DDRB, R16           ; S�tter lysdioden till utport.
   LDI R17, (1 << BUTTON1) ; L�ser in v�rdet 0010 0000 i CPU-register R17.
   OUT PORTB, R17          ; Aktiverar den interna pullup-resistorn p� tryckknappens pin.
   SEI                     ; Aktiverar avbrott globalt.
   STS PCICR, R16          ; Aktiverar PCI-avbrott p� I/O-port B.
   STS PCMSK0, R17         ; Aktiverar PCI-avbrott p� tryckknappens pin 13 (PORTB5).

;/********************************************************************************
;* main_loop: Tom kontinuerlig loop som h�ller ig�ng programmet s� l�nge
;*            matningssp�nning tillf�rs.
;********************************************************************************/  
main_loop:                
   RJMP main_loop          ; �terstartar loopen.                  
