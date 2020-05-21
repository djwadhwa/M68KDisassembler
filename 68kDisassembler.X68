*-----------------------------------------------------------
* Title      :  68k Disassebler
* Written by :  Dj Wadhwa, Mohammed Ali, Tarcisius Hartanto
* Date       :  June 2nd, 2020
* Description:  This program decodes machine code and turns it into assembly code for the 68k processor
*-----------------------------------------------------------
CR  EQU $0D
LF  EQU $0A

StartingMsg         dc.b    'This is our 68k Disassembler',CR,LF,0
Creators            dc.b    'Creators: Mohammed Ali, DJ Wadhwa, Tarcisius',CR,LF,0

InputMsg1           dc.b    'Start by giving a starting address in range (00009000,00FFFFFF) ',0
InputMsg2           dc.b    'Now give an ending adress in range (00009000,00FFFFFF) ',0
InputIsInc          dc.b    'This input is not an address',0
EndAddressInc       dc.b    'The end address is before the starting address, TRY AGAIN',0
ErrorMsg            dc.b    'Error in Input',0

HextoASCIIMsg       dc.b    'Completed hex to ASCII conversion',0
ASCIItoHexMsg       dc.b    'Completed ASCII to hex conversion',CR,LF,0

EndOfMemLoop        dc.b    '-------End of mem loop----',CR,LF,0
HelpMsg             dc.b    'Inputs must be in hexadecimal in this format --> FFFFFFFF',CR,LF,0
ContinueOrNotMsg    dc.b    'Would you like to Contunue or quit',0
ExitMsg             dc.b    'Exitting Program',0

START_ADDR_BUFFER  DS.B    256
END_ADDR_BUFFER    DS.B    256


    ORG    $1000    *Start at address $1000
START:                  ; first instruction of program

*---------- Beginning Messages ----------*
    
    move.b      #14,D0
    lea         StartingMsg,A1 
    trap        #15
    
    move.b      #14,D0
    lea         Creators,A1
    trap        #15
    
    jsr         MENU
    
    
* ---------- END OF PROGRAM -------------*

    move.b      #14,D0
    lea         ExitMsg,A1 
    trap        #15
    
    move.b      #9,D0
    trap        #15
* ---------------------------------------*
    
*-- End of Opening and Ending Messages --*

*--------- Start of I/O Section ---------*

MENU:
    jsr         GetStartAddress
    jsr         GetEndAddress
    
    jsr         MemSearch
    rts
    
GetStartAddress:
    
    move.b      #14, D0         *Display input message
    lea         InputMsg1,A1
    trap        #15
    
    move.b      #2,D0
    trap        #15
        
    jsr ASCIItoHex              *conversion to Hex
    * Address Located in D6
    movea.l     D6,A4           *move into address register 4
    rts
    
    
GetEndAddress:
    move.b      #14,D0          *Display input message
    lea         InputMsg2,A1
    trap        #15
    
    move.b      #2,D0
    trap        #15
    
    jsr         ASCIItoHex      *conversion to hex
    * Address Located in D6 (overwrite)
    movea.l     D6,A5           *move into address register 5
    rts
    
CheckAddress:
    
MemSearch:
    jsr MemSearchLoop
    rts
    
MemSearchLoop:
    
    * Check if we reached the end address
    cmp.l       A4,A5
    beq         MemSearch_Done
    
    * Get data from memory
    move.w     (A4),D0
    * OPCODE Word Located in D0
    jsr         OPCODE_DECODE
        
    
    
    
    adda.w      #2,A4
    bra         MemSearchLoop
    
    
MemSearch_Done:
    move.b      #14,D0
    lea         EndOfMemLoop,A1 
    trap        #15
    rts

    
OPCODE_DECODE:
    * Begin OPCODE Decoding here
    * Check first four bits and begin
    * if-branch breakdown
    rts

    

* ----- Hex to ASCII & ASCII to HEX -----*

ASCIItoHex:
        jsr     ASCII2Hex_init  
        jsr     conversion_loop
        rts                    

ASCII2Hex_init:   
        move.b  #0,D2      
        rts         
        
conversion_loop:            
        add.l   #1,D2     
        cmp.l   #9,D2 
        BEQ     DONE        
        move.b  (A1)+,D4    
        
        cmp.b   #$40,D4        
        bgt     Letters_Cap  
        
        cmp.b   #$39,D4
        BLE     Numbers      
        rts
        
Letters_Cap:      
        cmp.b   #$46,D4          
        bgt     ERROR  
        sub.b   #$37,D4     
        asl.l   #4,D6       
        add.l   D4,D6     
        bra     conversion_loop 
Numbers:
        cmp.b   #$30,D4         
        blt     ERROR        
        sub.b   #$30,D4      
        asl.l   #4,D6        
        add.l   D4,D6     
        bra     conversion_loop
        
ERROR:
        lea     ErrorMsg,A1    
        move.b  #14,D0
        trap    #15
    
        move.b  #9,D0
        trap    #15
        
DONE:
   
        clr     D1
        clr     D2
        clr     D4
    
        lea     ASCIItoHexMsg,A1
        move.b  #14,D0
        trap    #15

        rts
        
* -- End of Hex to ASCII & ASCII to HEX --*

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
