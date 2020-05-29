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
ExitMsg             dc.b    'Exiting Program',0

START_ADDR_BUFFER  DS.B    256
END_ADDR_BUFFER    DS.B    256

*size
long 				DC.B 	'.L ',0
word 				DC.B 	'.W ',0
byte 				DC.B 	'.B ',0

*instructions
nop_ins				DC.B 	'NOP',0
rts_ins				DC.B 	'RTS',0
move_ins			DC.B 	'MOVE',0
moveq_ins			DC.B 	'MOVEQ',0
movem_ins			DC.B 	'MOVEM',0
movea_ins			DC.B 	'MOVEA',0
add_ins				DC.B	'ADD',0
adda_ins			DC.B	'ADDA',0
addq_ins			DC.B	'ADDQ',0
or_ins				DC.B	'OR',0
and_ins				DC.B	'AND',0
sub_ins				DC.B	'SUB',0
ls_ins				DC.B	'LS',0
as_ins				DC.B	'AS',0
ro_ins				DC.B	'RO',0

*direction
right				DC.B	'R',0
left				DC.B	'L',0

*EA
D_reg				DC.B	'D',0
A_reg				DC.B 	'A',0
open_paran			DC.B 	'(A',0
close_paran			DC.B	')',0
post_inc			DC.B	')+',0
pre_dec				DC.B	'-(A',0

*extra
space 				DC.B	' ',0
comma				DC.B	', ',0
pound				DC.B	'#',0
tab                 EQU     $9
return				DC.B	CR,LF,0

    ORG    $1000    *Start at address $1000
START:                  ; first instruction of program

*---------- Test value, will remove in final build ----------*

	Move.W #$4E75,$00009234 *RTS
	MOVE.W #$3C05,$00009236 *MOVE.W D5,D6
	MOVE.W #$2447,$00009238 *MOVE.L D7,A2
	MOVE.W #$4E71,$0000923A *NOP
	MOVE.W #$D95C,$0000923C *ADD.W D0,(A4)+
	MOVE.W #$D3C2,$0000923E *ADDA.L D2,A1
	MOVE.W #$9822,$00009240 *SUB.B -(A2),D4
	MOVE.W #$C246,$00009242 *AND.W D6,D1
	MOVE.W #$8593,$00009244 *OR.L D2,(A3)
	MOVE.W #$E0C7,$00009246 *ASR D7
	MOVE.W #$ED4C,$00009248 *LSL.W #6, D4
	MOVE.W #$E4BB,$0000924A *ROR.L D2, D3
	
*---------- END Test ----------*



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

Clear_Registers:
    clr.l     D0
    clr.l     D1
    clr.l     D2
    clr.l     D3
    clr.l     D4
    clr.l     D5
    clr.l     D6
    clr.l     D7
    
    movea.l   #0,A0
    movea.l   #0,A1
    movea.l   #0,A2
    movea.l   #0,A3
    movea.l   #0,A4
    movea.l   #0,A5
    movea.l   #0,A6
    rts

MENU:
    jsr         Clear_Registers
    jsr         GetStartAddress
    jsr         GetEndAddress
    jsr         CheckAddress
    
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
    cmp.l       A4,A5
    beq         Menu

    
MemSearch:
    jsr MemSearchLoop
    rts
    
MemSearchLoop:
    
    * Check if we reached the end address
    cmp.l       A4,A5
    beq         MemSearch_Done
    
    * Get data from memory
    move.w     (A4),D2
    move.w		D2, D3	mutable copy in D3
    * OPCODE Word Located in D2, mutable copy in D3
    jsr         OPCODE_DECODE    
    
    adda.w      #2,A4
    bra         MemSearchLoop
    
    
MemSearch_Done:
    move.b      #14,D0
    lea         EndOfMemLoop,A1 
    trap        #15
    rts
    
TerminateOrCont:
    * Used to check if user would like to terminate the program or continue to disassemble more data
    move.b      #14,D0
    lea         ContinueOrNotMsg,A1 
    trap        #15
    
    rts 

* -------- Start of Opcode Section -------*    

OPCODE_DECODE:
    * Begin OPCODE Decoding here
    * Check first four bits and begin
    * if-branch breakdown
    CLR D4
    CLR D5
    CLR D6
    CLR D7
    
	CMP.W #$4E71, D2		
	BEQ print_nop			*check if value is NOP
	
	CMP.W #$4E75, D2		
	BEQ print_rts			*check if value is RTS
	
	* Mask out only the first 4 bits
	AND.W #$F000,D3
	
	CMP.W #$9000,D3
	BEQ print_sub_and_or	*check if value is SUB
	
	CMP.W #$8000, D3
	BEQ print_sub_and_or			*check if value is OR

	CMP.W #$C000,D3
	BEQ print_sub_and_or			*check if value is AND
	
	CMP.W #$D000,D3
	BEQ	print_add_adda		*check if value is ADD or ADDA
	
	CMP.W #$E000,D3
	BEQ	print_ls_as_ro		*check if value is LSL, LSR, ASL, ASR, ROL, or ROR
	
	CMP.W #$1000,D2
	BLT invalid
	CMP.W #$4000, D2
	BLT print_move_movea 	*check if value is MOVE or MOVEA
	
	CMP.W   #$7000,D3
	BEQ     print_moveq
	
	
invalid CLR D0    *need to add stuff to this
	
out	rts

    
* -------- End of Opcode Section --------*   

* --------- Print Instruction ----------*

print_moveq:
    * now write that it is moveq
    lea     moveq_ins,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #tab,D1
    move.b  #6,D0
    trap    #15
    
    * Figure out the immediate data
    
    move.w  D2,D3
    and.w   #$00FF,D3
    
    lea     pound,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #3,D0
    move.w  D3,D1
    trap    #15

    lea     comma,A1
    move.b  #14,D0
    trap    #15
    
    move.w  D2,D3
    and.w   #%0000111000000000,D3
    move.b  #9,D0
    lsr.l   D0,D3
    
    move.b  #'D',D1
    move.b  #6,D0
    trap    #15
    
    move.b  #3,D0
    move.w  D3,D1
    trap    #15
    
    lea     return,A1
    move.b  #14,D0
    trap    #15
    
    jsr println
    
        
    rts


print:
	CLR D0 
	MOVE.B #14,D0
	TRAP #15
	RTS

println:
	MOVE.B #13, D0
	TRAP #15
	RTS
	
print_nop
	LEA nop_ins, A1
	JSR println
	BRA out

print_rts
	LEA rts_ins, A1
	JSR println
	BRA out

print_move_movea
	LSR.W #6, D3
	AND.B #$3, D3
	CMP.B #1, D3
	BEQ move_a
	LEA move_ins, A1
	JSR print
	BRA m_size
move_a 
    LEA movea_ins, A1
	JSR print
m_size 
	MOVE.W D2, D4
	AND.W #$3000, D4
	JSR move_size
	JSR addr
	LEA comma, A1
	JSR print
	MOVE.B #1, D7
	JSR addr
	LEA return, A1
	JSR print
	BRA out
	
print_add_adda
	MOVE.W D2, D3
	AND.B #$C0, D3
	CMP.B #$C0, D3
	BEQ add_a
	LEA add_ins, A1
	JSR print
	JSR size
	MOVE.W D2,D3
	AND.W #$0100, D3
	CMP.W #$0100, D3
	BEQ ea_dest_add 
	JSR addr 			*if Direction bit is 0
	LEA comma, A1
	JSR print
	MOVE.W D2,D5
	JSR data_reg_sr
	BRA end_add
ea_dest_add 			*if Direction bit is 1
	MOVE.W D2,D5
	JSR data_reg_sr
	LEA comma, A1
	JSR print
	JSR addr
	BRA end_add
add_a
	LEA adda_ins, A1
	JSR print
	MOVE.W D2,D3
	AND.W #$0100, D3
	CMP.W #$0100, D3
	BEQ add_size
	LEA word, A1
	JSR print
	BRA next_add
add_size
	LEA long,A1
	JSR print
next_add
	JSR addr 			
	LEA comma, A1
	JSR print
	JSR add_reg_sr
end_add 
	LEA return, A1
	JSR print
	BRA out


print_sub_and_or
	CMP.W #$8000, D3
	BEQ print_or
	CMP.W #$9000, D3
	BEQ print_sub
	LEA and_ins, A1
	BRA print_value
print_sub
	LEA sub_ins, A1
	BRA print_value
print_or
	LEA or_ins, A1
print_value
	JSR print
	JSR size
	MOVE.W D2,D3
	AND.W #$0100, D3
	CMP.W #$0100, D3
	BEQ ea_dest_sub_and_or
	JSR addr 			*if Direction bit is 0
	LEA comma, A1
	JSR print
	MOVE.W D2,D5
	JSR data_reg_sr
	BRA end_add
ea_dest_sub_and_or		*if Direction bit is 1
	MOVE.W D2,D5
	JSR data_reg_sr
	LEA comma, A1
	JSR print
	JSR addr
	LEA return, A1
	JSR print
	BRA out
	
print_ls_as_ro					
	MOVE.W D2, D3
	AND.B #$C0, D3
	CMP.B #$C0, D3
	BEQ ls_as_ro_mem
	MOVE.W D2, D3
	LSR.B #3, D3
	JSR print_correct_shift_rotation
	JSR print_direction
	JSR size
	MOVE.W D2, D3
	AND.B #$20,D3
	CMP.B #$20, D3
	BEQ ls_as_ro_reg
	LEA pound, A1
	JSR print
	MOVE.W D2,D6
	ROL.W #7,D6
	AND.W #$0007, D6
	JSR Xn
	LEA comma, A1
	JSR print
	MOVE.W D2,D5
	ROR.W #7,D5
	JSR data_reg_sr
	BRA next_ls_as_ro
ls_as_ro_reg
	MOVE.W D2,D5
	JSR data_reg_sr
	LEA comma, A1
	JSR print
	MOVE.W D2,D5
	ROR.W #7,D5
	JSR data_reg_sr
	BRA next_ls_as_ro
ls_as_ro_mem
	MOVE.W D2, D3
	AND.B #$3F, D3
	CMP.B #$3C, D3
	BEQ invalid 	*ROL #4 <- not allowed (immediate addressing)
	MOVE.W D2, D3
	ROL.W #7, D3
	JSR print_correct_shift_rotation
	MOVE.W D2,D3
	JSR print_direction
	LEA space, A1
	JSR print
	JSR addr
next_ls_as_ro
	LEA return, A1
	JSR print
	BRA out
	


print_direction:
	AND.W #$0100, D3
	CMP.W #$0100, D3
	BEQ print_left
	LEA right, A1
	JSR print
	BRA out
print_left
	LEA left, A1
	JSR print
	RTS
	

print_correct_shift_rotation:
	AND.B #$03, D3
	CMP.B #$00, D3
	BEQ print_as
	CMP.B #$01, D3
	BEQ print_ls
	CMP.B #$03, D3
	LEA ro_ins, A1
	JSR print
	BRA out
print_as
	LEA as_ins, A1
	JSR print
	BRA out
print_ls
	LEA ls_ins, A1
	JSR print
	RTS
* --------- End Print Instruction ----------*

* ------- Instruction sizes ---------*

move_size:
	CMP.W #$1000, D4
	BEQ print_b
	CMP.W #$3000, D4
	BEQ print_w
	CMP.W #$2000, D4
	BEQ print_l
	RTS
	
print_b
	LEA byte, A1
	JSR print
	BRA out
	
print_w
	LEA word, A1
	JSR print
	BRA out
	
print_l:
	LEA long, A1
	JSR print
	BRA out

size:
	CLR D4
	MOVE.B D2,D4
	AND.B #$C0, D4
	CMP.B #$00, D4
	BEQ print_b
	CMP.B #$40,D4
	BEQ print_w
	CMP.B #$80, D4
	BEQ print_l
	RTS
	
* ------- End Instruction sizes ---------*

* ------- Effective Address -------*
addr:
    MOVE.W D2, D5
	MOVE.W D2, D6				
	CMP.B #1, D7
	BEQ destination
cont
	AND.B #$38, D6
	CMP.B #0, D6
	BEQ data_reg
	CMP.B #$08, D6
	BEQ add_reg
	CMP.B #$10, D6
	BEQ add_indirect
	CMP.B #$18, D6
	BEQ post_increment
	CMP.B #$20, D6
	BEQ pre_decrement
	BRA out *needs Immediate, Abs Long, and Abs Word
	
destination
	MOVE.W D5,D6
	ROL.W #7,D5
	LSR.W #3,D6
	BRA cont
	RTS

data_reg
	MOVE.W D5,D6	
	AND.B #$07, D6	
	LEA D_reg, A1	
	JSR print
	JSR Xn
	BRA out

add_reg
	MOVE.W D5,D6	
	AND.B #$07, D6
	LEA A_reg, A1	
	JSR print
	JSR Xn
	BRA out
	
add_indirect
	MOVE.W D5,D6	
	AND.B #$07, D6
	LEA open_paran, A1	
	JSR print
	JSR Xn
	LEA close_paran, A1	
	JSR print
	BRA out
	
post_increment
	MOVE.W D5,D6	
	AND.B #$07, D6
	LEA open_paran, A1	
	JSR print
	JSR Xn
	LEA post_inc, A1	
	JSR print
	BRA out
	
pre_decrement
	MOVE.W D5,D6	
	AND.B #$07, D6
	LEA pre_dec, A1	
	JSR print
	JSR Xn
	LEA close_paran, A1	
	JSR print
	BRA out
	
Xn:
	CLR D1
	MOVE.B D6,D1
	MOVE.B #3, D0
	TRAP #15
	RTS

data_reg_sr:
	CLR D6
	MOVE.W D5,D6
	ROL.W #7,D6
	AND.B #$07, D6	
	LEA D_reg, A1	
	JSR print
	JSR Xn
	RTS
	
add_reg_sr:
	CLR D6
	MOVE.W D2,D6
	ROL.W #7,D6
	AND.B #$07, D6	
	LEA A_reg, A1	
	JSR print
	JSR Xn
	RTS

* ------- End Effective Address -------*

* ----- Hex to ASCII & ASCII to HEX -----*

ASCIItoHex:
        jsr     ASCII2Hex_init  
        jsr     conversion_loop
        rts                    

ASCII2Hex_init:   
        move.b  #0,D2       *set up counter    
        rts         
        
conversion_loop:            
        add.l   #1,D2       *increment counter
        cmp.l   #9,D2       *ends at 9
        BEQ     DONE        *branch when compare is true
        move.b  (A1)+,D4    *Get first num
        
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
