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

InputMsg1           dc.b    'Start by giving a starting address in range (00001000,00FFFFFF)',0
InputMsg2           dc.b    'Now give an ending adress in range (00001000,00FFFFFF)',0
InputIsInc          dc.b    'This input is not an address',0
EndAddressInc       dc.b    'The end address is before the starting address, TRY AGAIN',0
ErrorMsg            dc.b    'Error in Input',0

HextoASCIIMsg       dc.b    'Completed hex to ASCII conversion',0
ASCIItoHexMsg       dc.b    'Completed ASCII to hex conversion',CR,LF,0

HelpMsg             dc.b    'Inputs must be in hexadecimal in this format --> FFFFFFFF',CR,LF,0
ContinueOrNotMsg    dc.b    'Would you like to Contunue or quit',0
ExitMsg             dc.b    'Exitting Program',0


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
    
*---------- End of Beginning Messages ----------*

*---------- Start of I/O Section ----------*

MENU:
    move.b      #14, D0
    lea         InputMsg1,A1
    trap        #15
    
    
    
         

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
