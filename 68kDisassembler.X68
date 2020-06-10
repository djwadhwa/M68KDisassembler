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

EndOfMemLoop        dc.b    '---Finished Reading Instructions---',CR,LF,0
FlushScreenMsg      dc.b    'Press ENTER to continue with the next set of instructions',0
HelpMsg             dc.b    'Inputs must be in hexadecimal in this format --> FFFFFFFF',CR,LF,0
ContinueOrNotMsg    dc.b    'Would you like to Disassemble more data or quit (y/n)',0
ExitMsg             dc.b    'Exiting Program',0

*START_ADDR_BUFFER  DS.B    256
*END_ADDR_BUFFER    DS.B    256

*size
long 				DC.B 	'.L ',0
word 				DC.B 	'.W ',0
byte 				DC.B 	'.B ',0

*instructions
nop_ins				DC.B 	'NOP',0
rts_ins				DC.B 	'RTS',0
move_ins			DC.B 	'MOVE',0
moveq_ins			DC.B 	'MOVEQ ',0
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
not_ins				DC.B	'NOT',0
jsr_ins				DC.B	'JSR ',0
lea_ins				DC.B	'LEA ',0
andq_ins			DC.B	'ADDQ',0
bgt_ins				DC.B	'BGT',0
ble_ins				DC.B	'BLE',0
beq_ins				DC.B	'BEQ',0
bra_ins				DC.B	'BRA',0

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
dash				DC.B 	'-',0
slash				DC.B	'/',0
tab                 EQU     $9
return				DC.B	CR,LF,0
data				DC.B	'DATA $',0
dollar				DC.B 	'$',0
    ORG    $1000    *Start at address $1000
START:                  ; first instruction of program

*---------- Test value, will remove in final build ----------*

*	Move.W #$4E75,$00009234 *RTS
*	MOVE.W #$3C05,$00009236 *MOVE.W D5,D6
*	MOVE.W #$2447,$00009238 *MOVEA.L D7,A2
*	MOVE.W #$4E71,$0000923A *NOP
*	MOVE.W #$D95C,$0000923C *ADD.W D0,(A4)+
*	MOVE.W #$D3C2,$0000923E *ADDA.L D2,A1
*	MOVE.W #$9822,$00009240 *SUB.B -(A2),D4
*	MOVE.W #$C246,$00009242 *AND.W D6,D1
*	MOVE.W #$8593,$00009244 *OR.L D2,(A3)
*	MOVE.W #$E0C7,$00009246 *ASR D7
*	MOVE.W #$ED4C,$00009248 *LSL.W #6, D4
*	MOVE.W #$E4BB,$0000924A *ROR.L D2, D3
*	MOVE.W #$7404,$0000924C *MOVEQ #4, D2
*	MOVE.W #$C23C,$0000924E *AND.B #12, D1
*	MOVE.W #$000C,$00009250
*	MOVE.W #$2C3C,$00009252	*MOVE.L #$12345678, D6
*	MOVE.L #$12345678,$00009254
*	MOVE.W #$D4F8,$00009258	*ADDA.W $12, A2
*	MOVE.W #$0012,$0000925A
*	MOVE.W #$4607,$0000925C	*NOT.B D7
*	MOVE.W #$4EB9,$0000925E *JSR $9208
*	MOVE.L #$00009208,$00009260
*	MOVE.W #$4E90,$00009264 *JSR (A0)
*	MOVE.W #$41D0,$00009266 *LEA (A0), A0 
*	MOVE.W #$5E14,$00009268 *ADDQ.B #7, (A4)
*    MOVE.W #$6EFE,$0000926A *BGT.B FE
*    MOVE.W #$6F00,$0000926C *BLE.W FE7A
*    MOVE.W #$FE7A,$0000926E
*    MOVE.W #$6700,$00009270 *BEQ.W FE60
*    MOVE.W #$FE60,$00009272
*    MOVE.W #$4EB9,$00009274 *JSR 00009208
*    MOVE.L #$00009208,$000009276
*    MOVE.W #$48A1,$0000927A
*    MOVE.W #$011F,$0000927C
*    MOVE.W #$4C91,$0000927E
*    MOVE.W #$FE00,$00009280
*	MOVE.W #$C2BC, $00009000
*	MOVE.L #$12345678, $00009002
*	MOVE.W #$82F9 , $00009000
*	MOVE.L #$12345678, $00009002 
*	MOVE.W #$9441, $00009006
*	Move.w #$C27C, $00009008
*	move.w #$1234, $0000900A
*	MOVE.L #$12345678, $00009002
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
    
    jsr         MemSearch
    rts
    
GetStartAddress:         *Display input message
	move.b	#14, D0
	lea         InputMsg1,A1
    trap #15
    MOVEA.L #0, A1
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
    MOVEA.L #0, A1
    move.b      #2,D0
    trap        #15
    
    jsr         ASCIItoHex      *conversion to hex
    * Address Located in D6 (overwrite)
    movea.l     D6,A5           *move into address register 5
    rts


ClearScreen:
    lea     return,A1
    move.b  #14,D0
    trap    #15
    
    *move.b  #9,D0
    *trap    #15
    
    cmp.w   #40,D1
    beq     ClearDone
    add.w   #1,D1
    bra     ClearScreen


ClearScreen_40:
    lea     return,A1
    move.b  #14,D0
    trap    #15
    
    cmp.l   #40,D1
    beq     ClearDone
    add.l   #1,D1
    bra     ClearScreen_40
    
ClearDone:
    rts
    
MemSearch:
    move.l      #0,D1
    jsr         ClearScreen
    * Set up instruction counter and place onto stack
    move.w      #0,D0
    move.w      D0,-(SP)
    
    jsr MemSearchLoop
    rts
    
MemSearchLoop:
    
    * Check if we reached the end address
    cmp.l       A4,A5
    beq         MemSearch_Done
    
    * Get data from memory
    CLR D1
    move.w     (A4),D2
    move.w		D2, D3	mutable copy in D3
    * OPCODE Word Located in D2, mutable copy in D3
    MOVE.L		A4, D1
    MOVE.B 		#16, D2
    MOVE.B 		#15, D0		print address of instruction
    TRAP		#15
    MOVE.W		D3,D2
    LEA			space,A1
    JSR 		print
    jsr         OPCODE_DECODE    
    
    adda.w      #2,A4
    
    * Call back counter from the stack
    move.w      (SP)+,D0
    add.b       #1,D0
    jsr         ScreenFlush_Check
    move.w      D0,-(SP)
    
    bra         MemSearchLoop
    
    
MemSearch_Done
    lea         EndOfMemLoop,A1 
    jsr print
    lea 	return, A1
    jsr print
    lea ContinueOrNotMsg, A1
    jsr print
    MOVE.B #5, D0
    TRAP #15
    lea return, A1
    jsr print
    CMP.B #121, D1    
    beq MENU
    move.b      #14,D0
    lea         ExitMsg,A1 
    trap        #15
    
    move.b      #9,D0
    trap        #15

ScreenFlush_Check:
    cmp.b       #31,D0 * 31
    beq         FlushScreen
    rts 

FlushScreen:
    lea         FlushScreenMsg,A1
    move.b      #14,D0
    trap        #15
    jsr         FlushScreen_Input
    *move.l      #0,D1
    *jsr         ClearScreen_40
    rts

FlushScreen_Input:

    clr     D1

    move.b  #5,D0
    trap    #15
    
    cmp.b   #13,D1
    beq     Enter_Press_True    
    
    bra     FlushScreen_Input
    
Enter_Press_True:
    rts
    

    

* -------- Start of Opcode Section -------*    

OPCODE_DECODE:
    * Begin OPCODE Decoding here
    * Check first four bits and begin
    * if-branch breakdown
    CLR.L D4
    CLR.L D5
    CLR.L D6
    CLR.L D7
    
	CMP.W #$4E71, D2		
	BEQ print_nop			*check if value is NOP
	
	CMP.W #$4E75, D2		
	BEQ print_rts			*check if value is RTS
	
	* Mask out only the first 4 bits
	AND.W #$F000,D3
	
	CMP.W #$9000,D3
	BEQ print_sub_and_or	*check if value is SUB
	
	CMP.W #$6000,D3
	BEQ print_bra_bcc		*check if value is BRA, BEQ, BGT, or BLE
	
	CMP.W #$8000, D3
	BEQ print_sub_and_or	*check if value is OR

	CMP.W #$C000,D3
	BEQ print_sub_and_or	*check if value is AND
	
	CMP.W #$D000,D3
	BEQ	print_add_adda		*check if value is ADD or ADDA
	
	CMP.W #$E000,D3
	BEQ	print_ls_as_ro		*check if value is LSL, LSR, ASL, ASR, ROL, or ROR
	
	CMP.W #$7000,D3
	BEQ print_moveq		*check if value is MOVEQ
	
	CMP.W #$1000,D2
	BLT invalid
	CMP.W #$4000,D2
	BLT print_move_movea 	*check if value is MOVE or MOVEA
	
	* Mask out only the first 8 bits
	MOVE.W D2, D3
	AND.W #$FF00,D3
	
	CMP.W #$4600,D3
	BEQ print_not			*check if value is NOT
	
	CMP.W #$4E00,D3
 	BEQ print_jsr			*check if value is JSR
 	
 	* Mask out only the first 4 bits and the 8th bit
 	MOVE.W D2,D3
 	AND.W #$F100, D3
 	
 	CMP.W #$4000, D3
 	BEQ print_movem			*check if value is MOVEM
 	
 	CMP.W #$4100, D3
 	BEQ print_lea			*check if value is LEA
 	
 	CMP.W #$5000,D3
	BEQ print_addq			*check if value is ANDQ 	
 	
	
invalid 
	LEA data, A1
	JSR	print
	MOVE.L D2, D1
	MOVE.B #16, D2
	MOVE.B 	#15, D0		
    TRAP #15
	JSR enter
out	rts

    
* -------- End of Opcode Section --------*   

* --------- Print Instructions ----------*


print:
	CLR D0 
	MOVE.B #14,D0
	TRAP #15
	RTS

println:
	MOVE.B #13, D0
	TRAP #15
	RTS
	
enter: 
	LEA return, A1
	JSR print
	RTS
	
print_nop
	LEA nop_ins, A1
	JSR println
	BRA out

print_rts
	LEA rts_ins, A1
	JSR println
	BRA out
	
print_moveq
    lea moveq_ins, A1	*print MOVEQ
    jsr	print
    move.w  D2,D3
    and.w   #$00FF,D3	* Figure out the immediate address value
    lea pound,A1		*print '#'
    jsr	print
    LEA dollar, A1
    JSR print
    move.w  D3,D1
    MOVE.W D2,D3
    MOVE.W #16, D2
    move.b  #15,D0
    trap    #15			*print immediate address value
    lea comma,A1		*print comma
   	jsr print
   	MOVE.W D3, D2
    MOVE.W D2, D5
    JSR data_reg_sr	    *figure out data address
    jsr enter     		*print out enter
    bra out
    
print_move_movea
	MOVE.W D2, D3		
	AND.W #$01C0, D3
	CMP.W #$0040, D3	*determine if MOVE or MOVEA
	BEQ move_a
	LEA move_ins, A1 *print Instruction 
	JSR print
	BRA m_size
move_a 			*if instruction is MOVEA
    LEA movea_ins, A1
	JSR print
m_size 				*determine instruction size
	JSR move_size
	JSR addr		*determine the source address
	LEA comma, A1	*print comma
	JSR print
	CLR.B D7
	MOVE.B #1, D7	*determine destination address
	JSR addr
	JSR enter 		*print enter
	BRA out
	
print_add_adda
	MOVE.W D2, D3	
	AND.B #$C0, D3
	CMP.B #$C0, D3		*determine if ADD or ADDA
	BEQ add_a
	*if just ADD then print instruction
	LEA add_ins, A1
	JSR print
	*print instruction size for ADD
	JSR size
	*determine direction of ADD, Dn -> EA or EA -> Dn
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
add_a					*if instruction is ADDA
	LEA adda_ins, A1
	JSR print
	*print instruction size for ADDA (either W or L)
	MOVE.W D2,D3
	AND.W #$0100, D3
	CMP.W #$0100, D3
	BEQ adda_size
	LEA word, A1
	JSR print
	BRA next_add
adda_size
	LEA long,A1
	JSR print
	MOVE.B #$80, D4
next_add				*print effective address for ADDA
	JSR addr 			
	LEA comma, A1
	JSR print
	JSR add_reg_sr
end_add 				*complete instruction printing by printing enter
	JSR enter
	BRA out

print_sub_and_or
	*determine if instruction is SUB, AND, or OR.
	MOVE.W D2, D3
	AND.W #$F0C0, D3
	CMP.W #$C0C0, D3
	BEQ mul_div
	CMP.W #$80C0, D3
	BEQ mul_div
	AND.W #$F000,D3
	CMP.W #$8000, D3
	BEQ print_or
	CMP.W #$9000, D3
	BEQ print_sub
	LEA and_ins, A1
	BRA print_instruction
print_sub
	MOVE.W D2, D3
	AND.W #$00C0, D3
	CMP.B #$C0, D3
	BEQ invalid
	LEA sub_ins, A1
	BRA print_instruction
print_or
	LEA or_ins, A1
print_instruction		*print correct instruction
	JSR print
	JSR size			*print instruction size
	MOVE.W D2,D3
*determine direction of ADD, Dn -> EA or EA -> Dn	
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
	*complete instruction printing by printing enter
	JSR enter
	BRA out
	
mul_div				*deal with MULU and DIVU cases
	CLR.L D3
	MOVE.W D2,D3
	AND.W #$00FF, D3
	CMP.L #$00F8, D3
	BLT invalid
	CMP.L #$00F9, D3
	BEQ mul_div_long
	ADDA.W #2,A4
	BRA invalid
mul_div_long
	ADDA.W #4,A4
	BRA invalid
	
print_ls_as_ro
	*figure out if shift or rotation are memory or register based				
	MOVE.W D2, D3
	AND.B #$C0, D3
	CMP.B #$C0, D3
	BEQ ls_as_ro_mem
	MOVE.W D2, D3
	LSR.B #3, D3
	*print correct instruction type (logical shift, arithmetic shift, or rotation)
	JSR print_correct_shift_rotation
	JSR print_direction		*print direction
	JSR size				*print size
	MOVE.W D2, D3
	AND.B #$20,D3
	CMP.B #$20, D3
	*determine if instruction is using immediate address or register
	BEQ ls_as_ro_reg	 
	LEA pound, A1		 *if immediate address print '#'
	JSR print
	*print immediate address rotation value
	MOVE.W D2,D6
	ROL.W #7,D6
	AND.W #$0007, D6
	LEA dollar, A1
	JSR print
	CLR.L D1
	MOVE.W D6, D1
	MOVE.W D2, D3
	MOVE.B #16, D2
	MOVE.B #15, D0
	TRAP #15
	MOVE.W D3,D2
	BRA continue_instruction_ls_as_ro
ls_as_ro_reg			*if instruction is using register to shift values in another register
	MOVE.W D2,D5
	JSR data_reg_sr
continue_instruction_ls_as_ro *complete instrcuction
	LEA comma, A1		*print comma
	JSR print
	MOVE.W D2,D5
	ROR.W #7,D5			*rotate instruction to allow for subroutine reuse
	JSR data_reg_sr 	*determine destination data register to perform instruction on
	BRA next_ls_as_ro 	*finish printing instruction
ls_as_ro_mem			*check if immediate address is being shifted or rotated
	MOVE.W D2, D3
	AND.B #$3F, D3
	CMP.B #$3C, D3
	BEQ invalid 	*ROL #4 <- not allowed (immediate addressing)
	*if not immediate adress print normally 
	MOVE.W D2, D3
	ROL.W #7, D3	
	JSR print_correct_shift_rotation
	MOVE.W D2,D3
	JSR print_direction
	LEA word, A1
	JSR print
	JSR addr
next_ls_as_ro
	JSR enter
	BRA out
	
print_not
	LEA not_ins, A1	*print instruction
	JSR print
	JSR size
	MOVE.W D2, D3
	AND.B #$3F, D3
	CMP.B #$3C, D3
	BEQ invalid 	*NOT #4 <- not allowed (immediate addressing)
	JSR addr
	JSR enter
	BRA out

print_jsr
	LEA jsr_ins, A1 *print instruction
	JSR print
	JSR addr	*print address
	JSR enter	*print enter (next line)
	BRA out

print_lea
	LEA lea_ins, A1 *print instruction
	JSR print	
	JSR addr	*print address
	LEA comma, A1	*print comma
	JSR print
	JSR add_reg_sr *print destination address register
	JSR enter
	BRA out

print_addq
	LEA addq_ins, A1	*print instruction
	JSR print
	JSR size			*print instruction size
	LEA pound, A1
	JSR print			*print '#' for immediate addressing
	MOVE.W D2,D6
	ROL.W #7,D6			*appropriately rotate opcode to allow for sub-routine reuse
	AND.W #$0007, D6
	JSR Xn
	LEA comma, A1		*print comma
	JSR print
	JSR addr			*print destination address
	JSR enter
	BRA out

print_bra_bcc			*needs comments
	MOVE.W D2,D3
	AND.W #$0F00, D3
	CMP.W #$0000, D3
	BEQ print_bra
	CMP.W #$0700, D3
	BEQ print_beq
	CMP.W #$0E00, D3
	BEQ print_bgt
	CMP.W #$0F00, D3
	BEQ print_ble
	BRA invalid
print_bra
	LEA bra_ins, A1
	JSR print
	BRA next_bra_bcc
print_beq
	LEA beq_ins, A1
	JSR print
	BRA next_bra_bcc
print_ble
	LEA ble_ins, A1
	JSR print
	BRA next_bra_bcc
print_bgt
	LEA bgt_ins, A1
	JSR print
next_bra_bcc
	MOVE.W D2, D3
	AND.W #$00FF, D3
	CMP.W #$0000, D3
	BEQ check_word
	LEA byte, A1
	JSR print
	LEA dollar, A1
    JSR print
    MOVE.W D3, D1
    MOVE.W D2, D3
    MOVE.W #16, D2
    MOVE.W #15,D0
    trap #15			*print immediate address value
	MOVE.W D3, D2
	BRA end_bra_bcc
check_word
	LEA word, A1
	JSR print
	LEA dollar, A1
    JSR print
	ADDA.W #2,A4		*update current address
	MOVE.W (A4),D1		*retrieve word data stored in the new current address
	MOVE.W D2, D3		*temporarily copy OPCODE to register D3
	MOVE.W #16, D2		*store #16 to allow for use of base 16 output
	MOVE.B #15, D0		*use trap instruction that allows use of base 16
	TRAP #15
	MOVE.W D3,D2		*copy opcode back to register D2
end_bra_bcc
	JSR enter
	BRA out

print_movem			*needs comments
	LEA movem_ins, A1
	JSR print
	MOVE.W D2,D3
	AND.W #$0040,D3
	CMP.W #$0040,D3
	BEQ movem_long
	LEA word, A1
	JSR print
	BRA movem_direction
movem_long
	LEA long, A1
	JSR print
movem_direction
	MOVE.W D2,D3
	AND.W #$0400,D3
	CMP.W #$0400,D3
	BEQ mem_to_reg
	JSR movem_predec
	LEA comma, A1
	JSR print
	JSR addr
	BRA end_movem
mem_to_reg
	JSR addr
	LEA comma, A1
	JSR print
	JSR movem_postinc
end_movem
	JSR enter
	BRA out

print_direction:
*print correct direction given direction bit
	AND.W #$0100, D3
	CMP.W #$0100, D3
	BEQ print_left	*print left
	LEA right, A1
	JSR print
	BRA out
print_left
	LEA left, A1
	JSR print *print right
	RTS
	
print_correct_shift_rotation:
*determine if instruction is logical, arithmetic, or rotation 
	AND.B #$03, D3
	CMP.B #$00, D3
	BEQ print_as
	CMP.B #$01, D3
	BEQ print_ls
	CMP.B #$03, D3
	LEA ro_ins, A1	print rotation
	BRA print_it
print_as
	LEA as_ins, A1	print arithmetic shift
	BRA print_it
print_ls
	LEA ls_ins, A1 print logical shift
print_it
	JSR print
	RTS
* --------- End Print Instruction ----------*

* ------- Instruction sizes ---------*

move_size: 	*print size for MOVE and MOVEA instruction
	CLR.L D4
	MOVE.W D2, D4
	AND.W #$3000, D4
	CMP.W #$1000, D4
	BEQ print_b
	CMP.W #$3000, D4
	BEQ print_w
	CMP.W #$2000, D4
	BEQ print_l
	RTS
	
print_b		*print '.B'
	LEA byte, A1
	JSR print
	BRA out
	
print_w		*print '.W'
	LEA word, A1
	JSR print
	BRA out
	
print_l:	*print '.L'
	LEA long, A1
	JSR print
	BRA out

size: 		*print size for non "move" instructions
	CLR.L D4
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
addr:			*use if dealing with Mode, Xn (source) or Xn, Mode (destination, set D7 to 1)
    MOVE.W D2, D5
	MOVE.W D2, D6				
	CMP.B #1, D7
	BEQ destination *check if evaluating destination address (used for MOVE)
cont
	AND.B #$38, D6
	CMP.B #0, D6
	BEQ data_reg		*check if EA mode is data register
	CMP.B #$08, D6
	BEQ add_reg			*check if EA mode is address register
	CMP.B #$10, D6
	BEQ add_indirect	*check if EA mode is address indirect
	CMP.B #$18, D6
	BEQ post_increment	*check if EA mode is post increment
	CMP.B #$20, D6
	BEQ pre_decrement	*check if EA mode is pre_decrement
	CMP.B #$38, D6
	BEQ absolute_or_immediate
	BRA out *needs Immediate, Abs Long, and Abs Word
destination		*perform correct rotation to retrieve destination address
	MOVE.W D5,D6
	ROL.W #7,D5
	LSR.W #3,D6
	BRA cont
	RTS

data_reg	*used with addr sub routine
	MOVE.W D5,D6	
	AND.B #$07, D6	
	LEA D_reg, A1	
	JSR print
	JSR Xn
	BRA out

add_reg		*used with addr sub routine
	MOVE.W D5,D6	
	AND.B #$07, D6
	LEA A_reg, A1	
	JSR print
	JSR Xn
	BRA out
	
add_indirect	*used with addr sub routine
	MOVE.W D5,D6	
	AND.B #$07, D6
	LEA open_paran, A1	
	JSR print
	JSR Xn
	LEA close_paran, A1	
	JSR print
	BRA out
	
post_increment	*used with addr sub routine
	MOVE.W D5,D6	
	AND.B #$07, D6
	LEA open_paran, A1	
	JSR print
	JSR Xn
	LEA post_inc, A1	
	JSR print
	BRA out
	
pre_decrement	*used with addr sub routine
	MOVE.W D5,D6	
	AND.B #$07, D6
	LEA pre_dec, A1	
	JSR print
	JSR Xn
	LEA close_paran, A1	
	JSR print
	BRA out

absolute_or_immediate *check if EA is immediate or absolute address
	MOVE.W D5,D6	
	AND.B #$07, D6
	CMP.B #$00, D6
	BEQ w_imm
	CMP.B #$01, D6
	BEQ l_imm
	CMP.B #04, D6
	BEQ immediate
	
immediate
	LEA pound, A1
	JSR print
	CMP.L #$4000, D2	*using CMP.L to avoid sign extention for value in D2 caused previously by CMP.W
	BLT move_movea		*check if instruction is move or movea
	CMP.L #$0040, D4		*if not move or movea
	BLE w_imm			*byte and word check the next 2 addresses in mem
	CMP.L #$0080, D4
	BEQ l_imm			*long checks the next 4 addresses in mem
move_movea				*similar comparisons, but for different bits in OPCODE
	CMP.W #$1000, D4
	BEQ w_imm
	CMP.W #$3000, D4
	BEQ w_imm
	CMP.W #$2000, D4
	BEQ l_imm
imm_complete
	BRA out
	
w_imm
	LEA dollar, A1		*print '$'
	JSR print
	ADDA.W #2,A4		*update current address
	MOVE.W (A4),D1		*retrieve word data stored in the new current address
	MOVE.W D2, D3		*temporarily copy OPCODE to register D3
	MOVE.W #16, D2		*store #16 to allow for use of base 16 output
	MOVE.B #15, D0		*use trap instruction that allows use of base 16
	TRAP #15
	MOVE.W D3,D2		*copy opcode back to register D2
	BRA imm_complete	*exit addr subroutine
	
l_imm
	LEA dollar, A1		*print '$'
	JSR print
	ADDA.W  #2,A4		*update current address
	MOVE.L (A4),D1		*retrieve long data stored in the new current address
	MOVE.W D2, D3
	MOVE.W #16, D2
	MOVE.B #15, D0
	TRAP #15
	MOVE.W D3,D2
	ADD.W  #2,A4		*update current address again since 2 more address were occupied by long data
	BRA imm_complete	*exit addr subroutine

Xn:						*retieve signed decimal value of data stored in register D6
	CLR.L D1
	MOVE.B D6,D1
	MOVE.B #3, D0
	TRAP #15
	RTS

data_reg_sr:	*use if dealing with Dn only
	CLR.L D6
	MOVE.W D5,D6
	ROL.W #7,D6
	AND.B #$07, D6	
	LEA D_reg, A1	
	JSR print
	JSR Xn
	RTS
	
add_reg_sr:		*use if dealing with An only
	CLR.L D6
	MOVE.W D2,D6
	ROL.W #7,D6
	AND.B #$07, D6	
	LEA A_reg, A1	
	JSR print
	JSR Xn
	RTS
	
movem_predec:			*needs to be worked on
	CLR.L D5
	ADDA.W  #2,A4		*update current address
	MOVE.W (A4),D5		*retrieve long data stored in the new current address
	CMP.B #$00, D5
	BEQ predec_skip_to_d
	MOVE.W D5,D6
	CLR.L D1
	MOVE.B #0, D1
a_loop1
	ROL.B #1,D6
	BCS a_loop1_done
	ADD.B #1,D1
	BRA a_loop1
a_loop1_done
	LEA A_reg,A1
	JSR print
	MOVE.B #3,D0
	TRAP #15
	CLR.L D7
	MOVE.B #0, D7
a_loop2
	ROL.B #1,D6
	BCC a_loop2_done
	ADD.B #1,D7
	ADD.B #1,D1
	CMP.B #7, D1
	BEQ a_loop2_done
	BRA a_loop2
a_loop2_done
	CMP.B #0, D7
	BEQ predec_no_dash
	LEA dash, A1
	JSR print
	LEA A_reg,A1
	JSR print
	MOVE.B #3,D0
	TRAP #15
predec_no_dash
	CMP.L #$00FF,D5
	BLE end_movem_predec
	LEA slash, A1
	JSR print
predec_skip_to_d	
	MOVE.W D5,D6
	LSR.W #8,D6
	CLR.L D1
	MOVE.B #0, D1
d_loop1
	ROL.B #1,D6
	BCS d_loop1_done
	ADD.B #1,D1
	BRA d_loop1
d_loop1_done
	LEA D_reg,A1
	JSR print
	MOVE.B #3,D0
	TRAP #15
	CLR.L D7
	MOVE.B #0, D7
d_loop2
	ROL.B #1,D6
	BCC d_loop2_done
	ADD.B #1,D1
	CMP.B #7, D1
	BEQ d_loop2_done
	BRA d_loop2
d_loop2_done
	CMP.B #0, D7
	BLE end_movem_predec
	LEA dash, A1
	JSR print
	LEA D_reg,A1
	JSR print
	MOVE.B #3,D0
	TRAP #15
end_movem_predec
	RTS
	
movem_postinc:			*needs to be worked on
	CLR.L D5
	ADDA.W  #2,A4		*update current address
	MOVE.W (A4),D5		*retrieve long data stored in the new current address
	MOVE.W D5,D6
	LSR.W #8,D6
	CMP.B #$00, D6
	BEQ postinc_skip_to_d
	CLR.L D1
	MOVE.B #0, D1
a_loop3
	ROR.B #1,D6
	BCS a_loop3_done
	ADD.B #1,D1
	BRA a_loop3
a_loop3_done
	LEA A_reg,A1
	JSR print
	MOVE.B #3,D0
	TRAP #15
	CLR.L D7
	MOVE.B #0, D7
a_loop4
	ROR.B #1,D6
	BCC a_loop4_done
	ADD.B #1,D7
	ADD.B #1,D1
	CMP.B #7, D1
	BEQ a_loop4_done
	BRA a_loop4
a_loop4_done
	CMP.B #0, D7
	BEQ postinc_no_dash
	LEA dash, A1
	JSR print
	LEA A_reg,A1
	JSR print
	MOVE.B #3,D0
	TRAP #15
postinc_no_dash
	CMP.B #$00, D5
	BEQ end_movem_postinc
	LEA slash, A1
	JSR print
postinc_skip_to_d	
	MOVE.W D5,D6
	CLR.L D1
	MOVE.B #0, D1
d_loop3
	ROR.B #1,D6
	BCS d_loop3_done
	ADD.B #1,D1
	BRA d_loop3
d_loop3_done
	LEA D_reg,A1
	JSR print
	MOVE.B #3,D0
	TRAP #15
	CLR.L D7
	MOVE.B #0, D7
d_loop4
	ROR.B #1,D6
	BCC d_loop4_done
	ADD.B #1,D1
	CMP.B #7, D1
	BEQ d_loop4_done
	BRA d_loop4
d_loop4_done
	CMP.B #0, D7
	BLE end_movem_postinc
	LEA dash, A1
	JSR print
	LEA D_reg,A1
	JSR print
	MOVE.B #3,D0
	TRAP #15
end_movem_postinc
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
