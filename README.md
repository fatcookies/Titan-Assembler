Titan Assemler
==============
Java Desktop
------------
### Usage:
    java Assembler InputFile OutputFile StartAddress OutputWidth
* InputFile: The file to be assembled, can be any extension.
* OuputFile: Dumps the assembled bytes as hexadecimal to this file.
* StartAddress: The address at which the assembler starts "counting" from.
* OutputWidth: The number of bytes printed on a line.

### Example Usage
    >java Assembler monitor.txt mointor.hex 0 16
    Program starts at BEGIN Address: 002E
    
    0000   00 01 02 03 04 05 06 07 08 09 00 00 00 00 00 00
    0010   00 0A 0B 0C 0D 0E 0F 30 31 32 33 34 35 36 37 38
    0020   39 00 00 00 00 00 00 00 41 42 43 44 45 46 D0 0A
    0030   F0 FF FF D0 0D F0 FF FF D0 3E F0 FF FF D1 05 D2
    0040   01 E0 FF FF 15 00 A1 00 3D DF 1B 15 0F A1 00 2E
    0050   12 21 70 A1 00 59 A0 00 3D 80 D1 2F 15 01 A1 00
    0060   73 D1 43 15 01 A1 00 BE D1 20 15 01 A1 00 C7 00
    0070   A0 00 2E A5 00 99 B8 12 70 D1 0F 13 01 CA 00 17
    0080   80 17 10 17 10 17 10 17 10 D1 F0 13 01 CB 00 17
    0090   C3 FF FF C2 FF FF A0 00 2E 8A 8B 81 D0 30 12 01
    00A0   CA 00 00 81 12 01 CB 00 00 10 32 81 12 01 CB 00
    00B0   00 81 12 01 CC 00 00 10 43 90 31 7B 7A A6 A5 00
    00C0   99 60 B0 12 A0 00 2E D1 02 D2 01 E0 FF FF 15 00
    00D0   A1 00 C7 DF 1B 15 F0 A1 00 2E 12 12 70 A1 00 E3
    00E0   A0 00 C7 81 D0 30 12 01 CA 00 00 80 12 10 CB 00
    00F0   00 10 32 90 20 A5 00 99 B0 12 A0 00 2E
The assembly in the file "monitor.txt" is assembled, starting at address 0000, with 16 bytes printed per line.
The addresses of the first byte of the line are given on the left.
All values are printed in hexadecimal.
"monitor.hex" will contain the similar output, just without the addresses.

Android Assembler
-----------------