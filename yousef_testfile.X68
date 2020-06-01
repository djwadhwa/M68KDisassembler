*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $6000
START:                  ; first instruction of program

* Put program code here
    moveq   #253,D0
    move.b  #5,D7
    movem.w     D1-D3/A3-A6,(SP)-
    
    

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
