; This is the basic MonitorOS for Titan.
; When assembled and the binary entered into Titan's memory, MonitorOS will show '>' prompt at the serial terminal
; Bytes can be loaded into memory by typing a two byte address in hex, then a space, then the byte to be dumped.
;
; The below example shows 0xFE being entered into the address 0x0F07.
;
; > 0F07 FE
; >
;
; Currently there are three "commands" '/' 'C' and ' '
; 
; 'R' - Read byte
; 'W' - Write byte (followed by a byte to write)
; 'C' - Clear byte
;
; This file is the MonitorOS for Marc Cleave's Titan Processor
; Copyright (C) 2012 Marc Cleave, bootnecklad@gmail.com
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

.ORIG BEGIN ; NOT IMPLEMENTED IN ASSEMBLER YET

.WORD SERIAL_PORT_0 0xFFFF   ; still need to decide which address the serial port will be at

.DATA HASH_TABLE 0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x0A 0x0B 0x0C 0x0D 0x0E 0x0F 

.DATA HASH_TABLE_BYTE 0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x41 0x42 0x43 0x44 0x45 0x46

BEGIN:
   LDC R0,0x0A          ; ASCII value for LF (Line feed)
   STM R0,SERIAL_PORT_0 ; Outputs to terminal
   LDC R0,0x0D          ; ASCII value for CR (Carriage return)
   STM R0,SERIAL_PORT_0 ; Outputs to terminal
   LDC R0,0x3E          ; ASCII value for '>'
   STM R0,SERIAL_PORT_0 ; Outputs to terminal


GET_INPUT:
   LDC R1,0x05           ; Number of bytes of input to get
   LDC R2,0x01           ; Value need for incrementing/decrementing
   LDM R0,SERIAL_PORT_0  ; Gets byte from input
   TST R0                ; test to see if byte contains anything (if not, nothing was fetched)
   JPZ GET_INPUT         ; try again
   LDC RF,0x1B           ; ASCII value for ESC (Escape)
   XOR R0,RF             ; Checks if input byte was an ESC
   JPZ BEGIN             ; If the byte was an ESC, return to '>' prompt
   SUB R2,R1            ; Decrement byte count
   PSH R0                ; Pushes byte onto stack
   JPZ PARSE_INPUT       ; No more bytes to fetch so lets parse them!
   JMP GET_INPUT         ; Get another byte


PARSE_INPUT:
   POP R0       ; Pops latest value off the stack
   LDC R1,0x2F  ; ASCII value for '/' this is a READ command
   XOR R0,R1    ; Checks if byte is a '/'
   JPZ READ     ; Goes off to create address, read memory and output
   LDC R1,0x43  ; ASCII value for 'C' this is a CLEAR command
   XOR R0,R1    ; Checks if byte is a 'C'
   JPZ CLEAR    ; Goes off to create address and write a 00
   LDC R1,0x20  ; ASCII value for ' ' this is a WRITE command
   XOR R0,R1    ; Checks if byte is a space
   JPZ BYTE     ; Need to get two more bytes of input
   NOP          ; Its really easy to add functions to this program!
   JMP BEGIN    ; Obviously it was an invalid character and the user forgot to press ESC.


READ:
   JSR CREATE_ADDRESS  ; Creates address from ASCII
   LDI R0,[R1,R2]      ; Loads the byte to be read, uses indexed load with NO offset, address in R1 and R2.
   PSH R0              ; Saves byte before manipulation
   LDC R1,0x0F         ; Part of byte to remove
   AND R0,R1           ; Upper nybble removed, ie bits UNSET, lower nybble left intact
   LDI R2,HASH_TABLE_BYTE  ; Data byte used to fetch the ASCII equvilent, ie if data is 0x5 then 0x35 is needed to be output to terminal
   POP R0
   SHR R1
   SHR R1
   SHR R1
   SHR R1              ; Shift the byte right four times, moves data to lower nybble
   LDC R1,0xF0
   AND R0,R1           ; Lower nybble removed, bits set to 0
   LDI R3,HASH_TABLE_BYTE  ; Data -> ASCII complete
   STI R3,SERIAL_PORT_0   ; Output high ASCII byte to serial terminal
   STI R2,SERIAL_PORT_0   ; Outputs low ASCII byte
   JMP BEGIN


CREATE_ADDRESS:
   POP RA
   POP RB     ; DONT BREAK THE RETURN ADDRESS!
   POP R1       ; Low nybble of low address
   LDC R0,0x30  ; Remove constant from ASCII value, makes table smaller.
   SUB R0,R1    ; R1 = R1 - R0
   LDI R2,HASH_TABLE
   POP R1       ; High nybble of low address
   SUB R0,R1    ; Removes constant
   LDI R3,HASH_TABLE
   ADD R3,R2    ; Combines high and low nybbles to create low byte of address
   POP R1       ; Low nybble of high address
   SUB R0,R1
   LDI R3,HASH_TABLE
   POP R1       ; High nybble of high address
   SUB R0,R1
   LDI R4,HASH_TABLE
   ADD R4,R3    ; Combines high and low nybbles to create high byte of address
   MOV R3,R1    ; Puts high byte address in correct place
   PSH RB
   PSH RA       ; PUTS BACK RETURN ADDRESS :)
   RTN


CLEAR:
   JSR CREATE_ADDRESS  ; Creates address from ASCII input
   CLR R0              ; Clears R0
   STI R0,[R1,R2]              ; Indexed store to memory, uses address in registers
   JMP BEGIN           ; That was quick!


BYTE:
   LDC R1,0x02           ; Number of bytes of input to get
   LDC R2,0x01           ; Value need for incrementing/decrementing
   LDM R0,SERIAL_PORT_0  ; Gets byte from input
   TST R0                ; test to see if byte contains anything (if not, nothing was fetched)
   JPZ BYTE              ; try again
   LDC RF,0x1B           ; ASCII value for ESC (Escape)
   XOR RF,R0             ; Checks if input byte was an ESC
   JPZ BEGIN             ; If the byte was an ESC, return to '>' prompt
   SUB R1,R2             ; Decrement byte count
   PSH R0                ; Pushes byte onto stack
   JPZ WRITE             ; No more bytes to fetch so lets convert them
   JMP BYTE              ; Get another byte
   

WRITE:
   POP R1       ; Low nybble of data
   LDC R0,0x30  ; Remove constant from ASCII value, makes table smaller.
   SUB R0,R1    ; R0 = R0 - R1
   LDI R2,HASH_TABLE ; Value of low nybble in R2
   POP R0       ; High nybble of data
   SUB R1,R0    ; Removes constant
   LDI R3,HASH_TABLE ; Value of high nybble in R3
   ADD R3,R2    ; Combines high and low nybbles to create low byte of address
   MOV R2,R0
   JSR CREATE_ADDRESS
   STI R0,[R1,R2]       ; Uses address in R1(high byte) and R2(low byte)
   JMP BEGIN