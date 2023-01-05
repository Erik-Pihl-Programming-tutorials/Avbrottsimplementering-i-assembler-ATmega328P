;/********************************************************************************
;* main.asm: Demonstration av enkelt assemblerprogram för att demonstrera 
;*           PCI-avbrott. En lysdiod ansluts till pin 8 (PORTB0) och en 
;*           tryckknapp ansluts till pin 13 (PORTB). PCI-avbrott aktiveras på
;*           tryckknappens pin. Vid nedtryckning av tryckknappen togglas 
;*           lysdioden, annars görs ingenting.
;*
;*           Assemblerdirektiv:
;*           .EQU (Equal)        : Används för makrodefinitioner.
;*           .ORG (Origin)       : Används för att specificera en adress.
;*           .CSEG (Code segment): Programminnet, här lagras programkoden.
;*
;*           Assemblerinstruktioner:
;*           RJMP (Relative jump)  : Hoppar till angiven adress.
;*           LDI (Load immediage)  : Läser in en konstant i ett CPU-register.
;*           OUT                   : Skriver till ett I/O-register såsom PORTB.
;*           IN                    : Läser från ett I/O-register såsom PINB.
;*           ANDI (And immediate)  : Bitvis multiplikation med en konstant.
;*           SEI (Set Interrupt)   : Ettställer I-flaggan i statusregister SREG
;*                                   för att aktivera avbrott globalt.
;*           BREQ (Branch if equal): Genomför hopp till angiven adress om
;*                                   resultatet från föregående aritmetiska
;*                                   eller logiska operation blev noll.
;*                                   Detta indikeras via Z-flaggan (Zero) i
;*                                   statusregistret SREG, som då blir ettställd.
;********************************************************************************/

; Makrodefinitioner:
.EQU LED1 = PORTB0    ; Lysdiod 1 ansluten till pin 8 (PORTB0).
.EQU BUTTON1 = PORTB5 ; Tryckknapp 1 ansluten till pin 13 (PORTB5).

.EQU RESET_vect = 0x00  ; Reset-vektor, anropas vid systemåterställning samt start av programmet.
.EQU PCINT0_vect = 0x06 ; Avbrottsvektor för PCI-avbrott på I/O-port B.

;/********************************************************************************
;* .CSEG: Kodsegmentet (programminnet) - Här lagras programkoden.
;********************************************************************************/
.CSEG 

;/********************************************************************************
;* RESET_vect: Programmets startadress. Programmet startar genom att hopp sker
;*             till subrutinen main. Programmet hoppar även till denna adress
;*             vid systemåterställning.
;********************************************************************************/
.ORG RESET_vect 
   RJMP main    ; Hoppar till subrutinen main för att starta programmet.

;/********************************************************************************
;* PCINT0_vect: Avbrottsvektor för PCI-avbrott på I/O-port B. Vid avbrott sker
;*              programhopp till motsvarande avbrottsrutin ISR_PCINT0.
;********************************************************************************/
.ORG PCINT0_vect 
   RJMP ISR_PCINT0 ; Hoppar till motsvarande avbrottsrutin ISR_PCINT0.

;/********************************************************************************
;* ISR_PCINT0: Avbrottsrutin för PCI-avbrott på I/O-port B, som äger rum vid
;*             nedtryckning och uppsläppning av tryckknappen. Vid nedtryckning 
;*             togglas lysdioden, annars görs ingenting.
;********************************************************************************/
ISR_PCINT0:
   IN R17, PINB             ; Läser insignaler från PINB, sparar en kopia i R17.
   ANDI R17, (1 << BUTTON1) ; Multiplicerar bitvis med 0010 0000.
   BREQ ISR_PCINT0_end      ; Om kvarvarande värde är lika med 0x00 görs ingenting.x
   OUT PINB, R16            ; Annars togglas lysdioden (0000 0001 ligger kvar i R16).
ISR_PCINT0_end:
   RETI                     ; Avslutar avbrottet och återställer systemet.

;/********************************************************************************
;* main: Initierar I/O-portar samt PCI-avbrott vid start. Programmet hålls
;*       sedan igång kontinuerligt så länge matningsspänning tillförs.
;********************************************************************************/
main:

;/********************************************************************************
;* setup: Initierar I/O-portar (lysdioden sätts till utport och den interna 
;*        pullup-resistorn på tryckknappens pin aktiveras) samt aktiverar 
;*        PCI-avbrott på tryckknappens pin. Denna subrutin placeras inline i
;*        i main för att effektivisera programmet (vi slipper programhopp samt
;*        återhopp).
;********************************************************************************/
setup:                    
   LDI R16, (1 << LED1)    ; Läser in värdet 0000 0001 i CPU-register R16.
   OUT DDRB, R16           ; Sätter lysdioden till utport.
   LDI R17, (1 << BUTTON1) ; Läser in värdet 0010 0000 i CPU-register R17.
   OUT PORTB, R17          ; Aktiverar den interna pullup-resistorn på tryckknappens pin.
   SEI                     ; Aktiverar avbrott globalt.
   STS PCICR, R16          ; Aktiverar PCI-avbrott på I/O-port B.
   STS PCMSK0, R17         ; Aktiverar PCI-avbrott på tryckknappens pin 13 (PORTB5).

;/********************************************************************************
;* main_loop: Tom kontinuerlig loop som håller igång programmet så länge
;*            matningsspänning tillförs.
;********************************************************************************/  
main_loop:                
   RJMP main_loop          ; Återstartar loopen.                  
