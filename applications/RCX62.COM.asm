; This is the disassembly of the "RCX62.COM" program for the Sanco 8003
; found in the CP/M 2.2 image at this link:
;       https://archive.org/details/sanco-8003-cpm-2.2fr.dsqd
;
; By Giulio Venturini (@BayoDev)
    
    org $0100
    
    nop                                     ;[0100]
    nop                                     ;[0101]
    nop                                     ;[0102]
; JUMP START
    jp      INIT                            ;[0103]
    
SIO_SETUP_WRAPPER:
    jp      SIO_SETUP                       ;[0106]
    
SIO_WRITE_WRAPPER:
    jp      SIO_WRITE                       ;[0109]
    
SIO_READ_WRAPPER:
    jp      SIO_READ                        ;[010c]
    
INIT:
    ld      sp,$01ac                        ;[010f] Setup stack pointer
    call    SIO_SETUP_WRAPPER               ;[0112] Setup SIO
    ld      hl,($0001)                      ;[0115]
    ld      de,$0006                        ;[0118]
    add     hl,de                           ;[011b]
    ld      ($01fe),hl                      ;[011c] ($01fe) = $0006
    call    PRINT_NEXT_STR                  ;[011f]
    DB $0d                                  ;[0122]
    DB $0a                                  ;[0123]
    DB "File exchange program vers 6.0 ,4800 Baud (SED)";[0124]
    DB $0d                                  ;[0153]
    DB $0a                                  ;[0154]
    DB $0a                                  ;[0155]
    DB "Ready to receive"               ;[0156]
    DB $0d                                  ;[0166]
    DB $0a                                  ;[0167]
    DB $00                                  ;[0168]
    jp      RCV_FIRST                       ;[0169]
    
; STACK SPACE START
    DB $00                                  ;[016c]
    DB $00                                  ;[016d]
    DB $00                                  ;[016e]
    DB $00                                  ;[016f]
    DB $00                                  ;[0170]
    DB $00                                  ;[0171]
    DB $00                                  ;[0172]
    DB $00                                  ;[0173]
    DB $00                                  ;[0174]
    DB $00                                  ;[0175]
    DB $00                                  ;[0176]
    DB $00                                  ;[0177]
    DB $00                                  ;[0178]
    DB $00                                  ;[0179]
    DB $00                                  ;[017a]
    DB $00                                  ;[017b]
    DB $00                                  ;[017c]
    DB $00                                  ;[017d]
    DB $00                                  ;[017e]
    DB $00                                  ;[017f]
    DB $00                                  ;[0180]
    DB $00                                  ;[0181]
    DB $00                                  ;[0182]
    DB $00                                  ;[0183]
    DB $00                                  ;[0184]
    DB $00                                  ;[0185]
    DB $00                                  ;[0186]
    DB $00                                  ;[0187]
    DB $00                                  ;[0188]
    DB $00                                  ;[0189]
    DB $00                                  ;[018a]
    DB $00                                  ;[018b]
    DB $00                                  ;[018c]
    DB $00                                  ;[018d]
    DB $00                                  ;[018e]
    DB $00                                  ;[018f]
    DB $00                                  ;[0190]
    DB $00                                  ;[0191]
    DB $00                                  ;[0192]
    DB $00                                  ;[0193]
    DB $00                                  ;[0194]
    DB $00                                  ;[0195]
    DB $00                                  ;[0196]
    DB $00                                  ;[0197]
    DB $00                                  ;[0198]
    DB $00                                  ;[0199]
    DB $00                                  ;[019a]
    DB $00                                  ;[019b]
    DB $00                                  ;[019c]
    DB $00                                  ;[019d]
    DB $00                                  ;[019e]
    DB $00                                  ;[019f]
    DB $00                                  ;[01a0]
    DB $00                                  ;[01a1]
    DB $00                                  ;[01a2]
    DB $00                                  ;[01a3]
    DB $00                                  ;[01a4]
    DB $00                                  ;[01a5]
    DB $00                                  ;[01a6]
    DB $00                                  ;[01a7]
    DB $00                                  ;[01a8]
    DB $00                                  ;[01a9]
    DB $00                                  ;[01aa]
    DB $00                                  ;[01ab]
; STACK SPACE END
    
; Data buffer for filename (?)
    DB $00                                  ;[01ac]
    DB $00                                  ;[01ad]
    DB $00                                  ;[01ae]
    DB $00                                  ;[01af]
    DB $00                                  ;[01b0]
    DB $00                                  ;[01b1]
    DB $00                                  ;[01b2]
    DB $00                                  ;[01b3]
    DB $00                                  ;[01b4]
    DB $00                                  ;[01b5]
    DB $00                                  ;[01b6]
    DB $00                                  ;[01b7]
    DB $00                                  ;[01b8]
    DB $00                                  ;[01b9]
    DB $00                                  ;[01ba]
    DB $00                                  ;[01bb]
    
; FCB file structure
    DB $00                                  ;[01bc]
    DB $00                                  ;[01bd]
    DB $00                                  ;[01be]
    DB $00                                  ;[01bf]
    DB $00                                  ;[01c0]
    DB $00                                  ;[01c1]
    DB $00                                  ;[01c2]
    DB $00                                  ;[01c3]
    DB $00                                  ;[01c4]
    DB $00                                  ;[01c5]
    DB $00                                  ;[01c6]
    DB $00                                  ;[01c7]
    DB $00                                  ;[01c8]
    DB $00                                  ;[01c9]
    DB $00                                  ;[01ca]
    DB $00                                  ;[01cb]
    DB $00                                  ;[01cc]
    DB $00                                  ;[01cd]
    DB $00                                  ;[01ce]
    DB $00                                  ;[01cf]
    DB $00                                  ;[01d0]
    DB $00                                  ;[01d1]
    DB $00                                  ;[01d2]
    DB $00                                  ;[01d3]
    DB $00                                  ;[01d4]
    DB $00                                  ;[01d5]
    DB $00                                  ;[01d6]
    DB $00                                  ;[01d7]
    DB $00                                  ;[01d8]
    DB $00                                  ;[01d9]
    DB $00                                  ;[01da]
    DB $00                                  ;[01db]
    DB $00                                  ;[01dc]
    DB $00                                  ;[01dd]
    DB $00                                  ;[01de]
    
; This routine prints all the characters after the "call" function until it encounters a $00
; When that happens the call resume execution from after the $00
PRINT_NEXT_STR:
    ex      (sp),hl                         ;[01df] HL will contain the address where the routine was called (+1)
    ld      a,(hl)                          ;[01e0] Read the content of HL
    inc     hl                              ;[01e1] Increment address
    ex      (sp),hl                         ;[01e2] Put the address back on the stack
    or      a                               ;[01e3]
    ret     z                               ;[01e4] If A=$00 return
    call    C_WRITE                         ;[01e5]
    jp      PRINT_NEXT_STR                  ;[01e8]
    
; Output A to console
C_WRITE:
    push    af                              ;[01eb]
    push    hl                              ;[01ec]
    push    bc                              ;[01ed]
    push    de                              ;[01ee]
    ld      c,$02                           ;[01ef]
    ld      e,a                             ;[01f1]
    call    $0005                           ;[01f2]
    pop     de                              ;[01f5]
    pop     bc                              ;[01f6]
    pop     hl                              ;[01f7]
    pop     af                              ;[01f8]
    ret                                     ;[01f9]
    
; ???
L01FA:
    push    bc                              ;[01fa]
    push    de                              ;[01fb]
    push    hl                              ;[01fc]
    
    call    $0000                           ;[01fd] This will be modified (INIT)
    
    pop     hl                              ;[0200]
    pop     de                              ;[0201]
    pop     bc                              ;[0202]
    ret                                     ;[0203]
    
;================================
;        FILE SYSCALLS
;================================
    
F_OPEN:
    ld      c,$0f                           ;[0204]
    jp      $0005                           ;[0206]
    
F_WRITE:
    ld      c,$15                           ;[0209]
    jp      $0005                           ;[020b]
    
F_CLOSE:
    ld      c,$10                           ;[020e]
    jp      $0005                           ;[0210]
    
F_READ:
    ld      c,$14                           ;[0213]
    jp      $0005                           ;[0215]
    
F_MAKE:
    ld      c,$16                           ;[0218]
    jp      $0005                           ;[021a]
    
F_DELETE:
    ld      c,$13                           ;[021d]
    jp      $0005                           ;[021f]
    
F_RENAME:
    ld      c,$17                           ;[0222]
    jp      $0005                           ;[0224]
    
;================================
    
; This routine is used to receive and save to file all the data
; Algorithm:
;       1) 128 blocks of 128 bytes each are read. After a full block is received
;          a special character is expected:
;               - ($17) a kind of acknowledge
;               - ($04) this signal that it was the last block of the file
;           If none of these signal is received an error occured
;       2) After the 128 blocks are received (or $04 encountered) the blocks are written to the file with FCB in $005c
;          if a block that is being written is followed by $04 the file is closed. Otherwise go to step (3)
;       3) The transmitter will be waiting for the receiver to write everything to the file so
;          if 128 blocks were written and the file was not complete an acknowledgment ($06) is sent to the transmitter
;          to resume transmission and the algorithm keep reading from step (1)
RCV_SAVE_FILE:
    ld      b,$80                           ;[0227]
    ld      hl,$1400                        ;[0229] Setup pointer to memory buffer
; Read 128 blocks of 128 bytes (unless file is shorter)
READ_BLOCK_LOOP:
    push    bc                              ;[022c]
    ld      b,$80                           ;[022d] Setup loop counter
; Read 128 bytes from the SIO into memory starting from $1400
READ_128_LOOP:
    call    SIO_READ_WRAPPER                ;[022f] Read value from SIO
    ld      (hl),a                          ;[0232] Store value in HL
    inc     hl                              ;[0233] HL++
    djnz    READ_128_LOOP                   ;[0234] B-- and loop if B!=$00
    call    SIO_READ_WRAPPER                ;[0236]
    ld      (hl),a                          ;[0239] Read value from SIO and store in buffer
    inc     hl                              ;[023a]
    cp      $17                             ;[023b]
    pop     bc                              ;[023d]
    jp      z,$0249                         ;[023e] Jump if value from SIO is $17 (expected control char)
    cp      $04                             ;[0241]
    jp      z,$024b                         ;[0243] Jump if value from SIO is $04 (end of transmission)
    jp      nz,FILE_TRANSFER_ERROR          ;[0246] If neither $17 or $04 error
    djnz    READ_BLOCK_LOOP                 ;[0249]
    ld      b,$80                           ;[024b] Reset loop counter for number of blocks
    ld      hl,$1400                        ;[024d] Reset data buffer to start
WRITE_BLOCKS_LOOP:
    push    bc                              ;[0250]
    ld      bc,$0080                        ;[0251]
    ld      de,$0080                        ;[0254]
    ldir                                    ;[0257] Move 128 bytes from data buffer to $0080
    ld      a,(hl)                          ;[0259] Get control character
    cp      $17                             ;[025a]
    jp      nz,END_CLOSE_FILE               ;[025c] Jump if that was the last block
    push    hl                              ;[025f]
    push    bc                              ;[0260]
    push    de                              ;[0261]
    ld      de,$005c                        ;[0262] Load FCB pointer
    call    F_WRITE                         ;[0265] Write block to file
    pop     de                              ;[0268]
    pop     bc                              ;[0269]
    pop     hl                              ;[026a]
    or      a                               ;[026b]
    pop     bc                              ;[026c]
    jp      nz,FILE_WRITE_ERROR             ;[026d] Jump if error in syscall
    inc     hl                              ;[0270] HL++
    djnz    WRITE_BLOCKS_LOOP               ;[0271] Loop until 128 blocks
    jp  KEEP_RCV                            ;[0273] 128 blocks written without end of file
    
; This routine write the last block to the file and closes it
END_CLOSE_FILE:
    pop     bc                              ;[0276]
    cp      $04                             ;[0277]
    jp      nz,FILE_TRANSFER_ERROR          ;[0279] If not end of file char, error
    ld      de,$005c                        ;[027c]
    call    F_WRITE                         ;[027f] Write last block to file
    or      a                               ;[0282]
    jp      nz,FILE_WRITE_ERROR             ;[0283] jump if error in syscall
    ld      de,$005c                        ;[0286]
    call    F_CLOSE                         ;[0289] Close file
    inc     a                               ;[028c]
    jp      z,CLOSING_ERROR                 ;[028d] Jump if error in syscall
    xor     a                               ;[0290] A=0
    ret                                     ;[0291]
    
; This routine is called after 128 blocks of 128 bytes were successfully saved
; to ask the transmitter to resume transmission
KEEP_RCV:
    ld      a,$06                           ;[0292]
    call    SIO_WRITE_WRAPPER               ;[0294] Send acknowledge
    jp      RCV_SAVE_FILE                   ;[0297] Start receiving again
    
    
TRANSMISSION_END:
    call    PRINT_NEXT_STR                  ;[029a]
    DB $0D                                  ;[029b]
    DB $0A                                  ;[029c]
    DB $0A                                  ;[029d]
    DB "End of transmission"            ;[02a0]
    DB $0D                                  ;[02b3]
    DB $0A                                  ;[02b4]
    DB $00                                  ;[02b5]
    jp      $0000                           ;[02b6] EXIT FROM CP/M
    
RCV_FIRST_WRAPPER:
    jp      RCV_FIRST                       ;[02b9]
    
    
RCV_SETUP:
    call    GET_FILENAME                    ;[02bc] Read 12 bytes in $01bd (?) (Probably read filename)
    cp      $03                             ;[02bf]
    jp      nz,FILE_NAME_ERROR              ;[02c1] Jump if filename didnt end with $03 (bad data)
    ld      hl,$01ac                        ;[02c4]
    ld      de,$005c                        ;[02c7]
    ld      bc,$0010                        ;[02ca]
    ldir                                    ;[02cd] Setup the FCB for the syscalls with the input filename (in $005c)
    ld      de,$005c                        ;[02cf]
    call    F_OPEN                          ;[02d2] Open file with FCB in $005c (?)
    inc     a                               ;[02d5]
    jp      nz,START_RCV                    ;[02d6] Jump if no error in F_OPEN (file already exists)
    ld      de,$005c                        ;[02d9]
    call    F_MAKE                          ;[02dc] Create file
    inc     a                               ;[02df]
    jp      z,DIR_FULL_ERROR                ;[02e0] Jump if error (directory full)
START_RCV:
    ld      de,$005c                        ;[02e3]
    xor     a                               ;[02e6]
    ld      hl,$0020                        ;[02e7]
    add     hl,de                           ;[02ea] HL = $7C
    ld      (hl),$00                        ;[02eb] ($7C) = $00
    ld      de,$01bc                        ;[02ed]
    call    PRINT_FILENAME                  ;[02f0] Print filename located at $01bc
    ld      a,$06                           ;[02f3]
    call    SIO_WRITE_WRAPPER               ;[02f5] Write $06 to SIO (Acknowledge)
    call    RCV_SAVE_FILE                   ;[02f8] Receive and save file
    or      a                               ;[02fb] If routine ended correctly, A should be $00
    jp      nz,FILE_ERROR                   ;[02fc] If A!=$00 error
    ld      de,$01bc                        ;[02ff]
    call    F_DELETE                        ;[0302] Delete file (?)
    ld      de,$01ac                        ;[0305]
    call    F_RENAME                        ;[0308] Rename file from $01ac as the file from $01bc
    ld      a,$20                           ;[030b]
    call    C_WRITE                         ;[030d] Prints ' ' to CRT
    ld      a,$2a                           ;[0310]
    call    C_WRITE                         ;[0312] Prints '*' to CRT
    ld      a,$06                           ;[0315]
    call    SIO_WRITE_WRAPPER               ;[0317] Send acknowledge to SIO
    jp      RCV_FIRST                       ;[031a] Wait for new file
    
; This routine gets 12 bytes from the SIO containing the filename and extension
; followed by 0x03 (end of text)
GET_FILENAME:
    ld      c,$0c                           ;[031d]
    ld      hl,$01bd                        ;[031f]
; This loop will be executed 12 times
GET_FILENAME_LOOP:
    call    SIO_READ_WRAPPER                ;[0322] Read value from SIO (=A)
    and     $7f                             ;[0325] Remove parity (?) (Not needed for ASCII anyway)
    cp      $03                             ;[0327]
    jp      z,END_FILENAME                  ;[0329] Check for END OF TEXT (0x03)
    ld      (hl),a                          ;[032c] (HL) = A
    inc     hl                              ;[032d] HL++
    dec     c                               ;[032e] C--
    jp      nz,GET_FILENAME_LOOP            ;[032f] Loop if C!=0
    ret                                     ;[0332]
END_FILENAME:
    ld      de,$01ac                        ;[0333]
    ld      hl,$01bc                        ;[0336]
    ld      bc,$0009                        ;[0339]
    ldir                                    ;[033c] Move 9 bytes from $01bc to $01ac
    ld      hl,$01b5                        ;[033e]
    ld      (hl),$24                        ;[0341] ($01b5) = $24
    inc     hl                              ;[0343]
    ld      (hl),$24                        ;[0344] ($01b6) = $24
    inc     hl                              ;[0346]
    ld      (hl),$24                        ;[0347] ($01b7) = $24
    ret                                     ;[0349]
    
    
;=======================
;   ERROR MESSAGES
;=======================
    
FILE_NAME_ERROR:
    call    PRINT_NEXT_STR                  ;[034a]
    DB $0D                                  ;[034d]
    DB $0A                                  ;[034e]
    DB "File name error"                ;[034f]
    DB $00                                  ;[035e]
    ld      a,$0d                           ;[035f]
    call    SIO_WRITE_WRAPPER               ;[0361]
    jp      RCV_FIRST                       ;[0364]
    
DIR_FULL_ERROR:
    call    PRINT_NEXT_STR                  ;[0367]
    DB $0D                                  ;[036a]
    DB $0A                                  ;[036b]
    DB "Directory full"                 ;[036c]
    DB $00                                  ;[037a]
    ld      a,$0d                           ;[037b]
    call    SIO_WRITE_WRAPPER               ;[037d]
    jp      RCV_FIRST                       ;[0380]
    
FILE_TRANSFER_ERROR:
    call    PRINT_NEXT_STR                  ;[0383]
    DB $0D                                  ;[0386]
    DB $0A                                  ;[0387]
    DB "File transfer error"            ;[0388]
    nop                                     ;[039b]
    ld      a,$0d                           ;[039c]
    call    SIO_WRITE_WRAPPER               ;[039e]
    jp      RCV_FIRST                       ;[03a1]
    
FILE_WRITE_ERROR:
    call    PRINT_NEXT_STR                  ;[03a4]
    DB $0D                                  ;[03a7]
    DB $0a                                  ;[03a8]
    DB "File write error"               ;[03a9]
    DB $00                                  ;[03b9]
    ld      a,$0d                           ;[03ba]
    call    SIO_WRITE_WRAPPER               ;[03bc]
    jp      RCV_FIRST                       ;[03bf]
    
CLOSING_ERROR:
    call    PRINT_NEXT_STR                  ;[03c2]
    DB $0D                                  ;[03c5]
    DB $0A                                  ;[03c6]
    DB "Closing error"                  ;[03c7]
    DB $00                                  ;[03d4]
    ld      a,$0d                           ;[03d5]
    call    SIO_WRITE_WRAPPER               ;[03d7]
    jp      RCV_FIRST                       ;[03da]
    
FILE_ERROR:
    call    PRINT_NEXT_STR                  ;[03dd]
    DB $0D                                  ;[03e0]
    DB $0A                                  ;[03e1]
    DB "File error"                     ;[03e2]
    DB $00                                  ;[03ec]
    ld      a,$0d                           ;[03ed]
    call    SIO_WRITE_WRAPPER               ;[03ef]
    jp      RCV_FIRST                       ;[03f2]
    
    
RENAME_ERROR:
    call    PRINT_NEXT_STR                  ;[03f5]
    DB $0D                                  ;[03f8]
    DB $0A                                  ;[03f9]
    DB "Rename error"                   ;[03fa]
    DB $00                                  ;[0406]
    ld      a,$0d                           ;[0407]
    call    SIO_WRITE_WRAPPER               ;[0409]
    jp      RCV_FIRST                       ;[040c]
    
;=======================
    
; This routine:
;       1) prints a new line (CR,LF)
;       2) prints 8 bytes starting from (de+1)
;       3) prints '.'
;       4) prints 3 bytes located after the previous 8 bytes
; i.e. prints a filename on the CRT
PRINT_FILENAME:
    ld      a,$0d                           ;[040f]
    call    C_WRITE                         ;[0411] Print 'Carriage return' to CRT
    ld      a,$0a                           ;[0414]
    call    C_WRITE                         ;[0416] Print 'Line feed' to CRT
    ex      de,hl                           ;[0419]
    inc     hl                              ;[041a]
    ld      b,$08                           ;[041b]
PRINT_NAME:
    ld      a,(hl)                          ;[041d] A = (HL)
    call    C_WRITE                         ;[041e] Print A to CRT
    inc     hl                              ;[0421] HL++
    djnz    PRINT_NAME                     ;[0422] Decrement B and if B!=$00 jump. (Will jump 8 times)
    ld      a,$2e                           ;[0424]
    call    C_WRITE                         ;[0426] Print '.'
    ld      b,$03                           ;[0429]
PRINT_EXT:
    ld      a,(hl)                          ;[042b] A = (HL)
    call    C_WRITE                         ;[042c] Print A to CRT
    inc     hl                              ;[042f] HL++
    djnz    PRINT_EXT                      ;[0430] B-- and jump if B!=$00 (Will jump 3 times)
    ex      de,hl                           ;[0432]
    ret                                     ;[0433]
    
; This receives the first character of a transmission and act accordingly
RCV_FIRST:
    call    SIO_READ_WRAPPER                ;[0434] Read an input character from the SIO (=A)
    cp      $18                             ;[0437]
    jp      z,TRANSMISSION_END              ;[0439] If A=$18 then end transmission and exit program
    cp      $11                             ;[043c]
    jp      z,RCV_FIRST_WRAPPER             ;[043e] Skip loop if A=$11
    cp      $02                             ;[0441]
    jp      z,RCV_SETUP                     ;[0443] If A=$02 then ready to transmit a file
    cp      $12                             ;[0446]
    call    z,SIO_SETUP_WRAPPER             ;[0448] if A=$12 jump
    jp      RCV_FIRST                       ;[044b]
    
; Sends to port $b1 data from $0458 to $0460 (SIO SETUP)
SIO_SETUP:
    ld      c,$b1                           ;[044e] Output port
    ld      b,$09                           ;[0450] Number of repetitions
    ld      hl,SIO_SETUP_COMMANDS           ;[0452] Starting address
    otir                                    ;[0455]
    ret                                     ;[0457]
    
SIO_SETUP_COMMANDS:
    DB $18                                  ;[0458] ; Reset channel 0
    DB $04                                  ;[0459] ; Access WR4
    DB $4c                                  ;[045A] ; Parity Disabled, 2 stop bits (?), 8 bit sync,Data Rate x16 = Clock rate
    DB $01                                  ;[045B] ; Access WR1
    DB $00                                  ;[045C] ; Disable all interrupts
    DB $05                                  ;[045D] ; Access WR5
    DB $ea                                  ;[045E] ; TX CRC disabled, RTS enabled, CRC-16 disabled, Transmit enabled, Send break disabled, 8 bits/character, dtr enabled
    DB $03                                  ;[045F] ; Access WR3
    DB $c1                                  ;[0460] ; Receive enabled, the rest disabled, 8 bits/character
    
; Write the character stored in the A register to port B of the SIO (Blocks until can transmit)
SIO_WRITE:
    push af                                 ;[0461]
SIO_WRITE_LOOP:
    in      a,($b1)                         ;[0462]
    and     $04                             ;[0464]
    jp      z,SIO_WRITE_LOOP               ;[0466] Loop until SIO is ready to transmit
    pop     af                              ;[0469]
    out     ($b0),a                         ;[046a] Write A to SIO
    ret                                     ;[046c]
    
; Receive a character from the SIO and stores it in A (it blocks until there is something available to read)
SIO_READ:
    in      a,($b1)                         ;[046d]
    and     $01                             ;[046f] Check if character is available to read
    jp      z,SIO_READ                      ;[0471] Loop if not
    in      a,($b0)                         ;[0474] Read character from SIO into A
    ret                                     ;[0476]
    
; From now on this is unused
    
    ld      bc,$0a0d                        ;[0477]
    ld      d,d                             ;[047a]
    ld      h,l                             ;[047b]
    ld      l,(hl)                          ;[047c]
    ld      h,c                             ;[047d]
    ld      l,l                             ;[047e]
    ld      h,l                             ;[047f]
    ld      (bc),a                          ;[0480]
    cp      $43                             ;[0481]
    jp      nz,$0296                        ;[0483]
    call    $0145                           ;[0486]
    or      $04                             ;[0489]
    call    $0151                           ;[048b]
    ld      a,c                             ;[048e]
    call    $0151                           ;[048f]
    ld      a,b                             ;[0492]
    jp      $0151                           ;[0493]
    cp      $52                             ;[0496]
    jp      nz,$0518                        ;[0498]
    call    $011d                           ;[049b]
    or      $c0                             ;[049e]
    jp      $0151                           ;[04a0]
    ld      hl,($000e)                      ;[04a3]
    push    de                              ;[04a6]
    ex      de,hl                           ;[04a7]
    ld      hl,($000c)                      ;[04a8]
    ld      a,e                             ;[04ab]
    sub     l                               ;[04ac]
    ld      a,d                             ;[04ad]
    sbc     h                               ;[04ae]
    jp      nc,$02b7                        ;[04af]
    ld      hl,($0013)                      ;[04b2]
    ld      sp,hl                           ;[04b5]
    ret                                     ;[04b6]
    
    pop     de                              ;[04b7]
    ld      a,(hl)                          ;[04b8]
    inc     hl                              ;[04b9]
    ld      ($000c),hl                      ;[04ba]
    ret                                     ;[04bd]
    
    inc     a                               ;[04be]
    and     $07                             ;[04bf]
    cp      $06                             ;[04c1]
    jp      c,$02c8                         ;[04c3]
    add     $03                             ;[04c6]
    cp      $05                             ;[04c8]
    jp      c,$02cf                         ;[04ca]
    add     $02                             ;[04cd]
    add     $41                             ;[04cf]
    ld      c,a                             ;[04d1]
    jp      $0015                           ;[04d2]
    ld      b,a                             ;[04d5]
    and     $f0                             ;[04d6]
    rrca                                    ;[04d8]
    rrca                                    ;[04d9]
    rrca                                    ;[04da]
    rrca                                    ;[04db]
    add     $90                             ;[04dc]
    daa                                     ;[04de]
    adc     $40                             ;[04df]
    daa                                     ;[04e1]
    ld      c,a                             ;[04e2]
    call    $0015                           ;[04e3]
    ld      a,b                             ;[04e6]
    and     $0f                             ;[04e7]
    add     $90                             ;[04e9]
    daa                                     ;[04eb]
    adc     $40                             ;[04ec]
    daa                                     ;[04ee]
    ld      c,a                             ;[04ef]
    jp      $0015                           ;[04f0]
    ld      b,$04                           ;[04f3]
    ld      c,(hl)                          ;[04f5]
    call    $0015                           ;[04f6]
    inc     hl                              ;[04f9]
    dec     b                               ;[04fa]
    jp      nz,$02f5                        ;[04fb]
    ld      c,$20                           ;[04fe]
    jp      $0015                           ;[0500]
    ld      a,d                             ;[0503]
    and     $38                             ;[0504]
    rrca                                    ;[0506]
    rrca                                    ;[0507]
    rrca                                    ;[0508]
    ret                                     ;[0509]
    
    call    $0303                           ;[050a]
    add     a                               ;[050d]
    ld      c,a                             ;[050e]
    ld      hl,$0642                        ;[050f]
    add     hl,bc                           ;[0512]
    ld      c,(hl)                          ;[0513]
    call    $0015                           ;[0514]
    inc     hl                              ;[0517]
    ld      c,(hl)                          ;[0518]
    call    $0015                           ;[0519]
    ld      c,$20                           ;[051c]
    call    $0015                           ;[051e]
    jp      $0015                           ;[0521]
    call    $0303                           ;[0524]
    and     $06                             ;[0527]
    cp      $06                             ;[0529]
    jp      nz,$02be                        ;[052b]
    ld      c,$53                           ;[052e]
    call    $0015                           ;[0530]
    ld      c,$50                           ;[0533]
    jp      $0015                           ;[0535]
    call    $002e                           ;[0538]
    ld      hl,($000c)                      ;[053b]
    ld      a,h                             ;[053e]
    call    $02d5                           ;[053f]
    ld      a,l                             ;[0542]
    call    $02d5                           ;[0543]
    ld      c,$20                           ;[0546]
    call    $0015                           ;[0548]
    call    $0015                           ;[054b]
    ret                                     ;[054e]
    
    ld      hl,$0000                        ;[054f]
    add     hl,sp                           ;[0552]
    ld      ($0013),hl                      ;[0553]
    ld      a,($0010)                       ;[0556]
    or      a                               ;[0559]
    jp      z,$0371                         ;[055a]
    ld      hl,$ffff                        ;[055d]
    ld      ($000e),hl                      ;[0560]
    inc     a                               ;[0563]
    jp      nz,$0371                        ;[0564]
    inc     a                               ;[0567]
    ld      ($0010),a                       ;[0568]
    ld      hl,($000c)                      ;[056b]
    jp      $0397                           ;[056e]
    call    $069e                           ;[0571]
    jp      nz,$0540                        ;[0574]
    ld      hl,$0010                        ;[0577]
    ld      a,(hl)                          ;[057a]
    or      a                               ;[057b]
    jp      z,FILE_TRANSFER_ERROR           ;[057c]
    dec     (hl)                            ;[057f]
    jp      z,$0540                         ;[0580]
    ld      hl,($000c)                      ;[0583]
    call    $06a1                           ;[0586]
    call    $002e                           ;[0589]
    ld      c,$20                           ;[058c]
    call    $0015                           ;[058e]
    call    $0015                           ;[0591]
    call    $033b                           ;[0594]
    call    $02a3                           ;[0597]
    ld      d,a                             ;[059a]
    ld      hl,$0545                        ;[059b]
    ld      bc,$0011                        ;[059e]
    cp      (hl)                            ;[05a1]
    jp      z,$04fd                         ;[05a2]
    inc     hl                              ;[05a5]
    dec     c                               ;[05a6]
    jp      nz,$03a1                        ;[05a7]
    ld      c,$0a                           ;[05aa]
    cp      (hl)                            ;[05ac]
    jp      z,$04e9                         ;[05ad]
    inc     hl                              ;[05b0]
    dec     c                               ;[05b1]
    jp      nz,$03ac                        ;[05b2]
    ld      c,$06                           ;[05b5]
    cp      (hl)                            ;[05b7]
    jp      z,$04ce                         ;[05b8]
    inc     hl                              ;[05bb]
    dec     c                               ;[05bc]
    jp      nz,$03b7                        ;[05bd]
    and     $c0                             ;[05c0]
    cp      $40                             ;[05c2]
    jp      z,$04b4                         ;[05c4]
    cp      $80                             ;[05c7]
    jp      z,$04a5                         ;[05c9]
    ld      a,d                             ;[05cc]
    and     $c7                             ;[05cd]
    sub     $04                             ;[05cf]
    jp      z,$0496                         ;[05d1]
    dec     a                               ;[05d4]
    jp      z,$0490                         ;[05d5]
    dec     a                               ;[05d8]
    jp      z,$047c                         ;[05d9]
    ld      a,d                             ;[05dc]
    and     $c0                             ;[05dd]
    jp      z,$044a                         ;[05df]
    ld      a,d                             ;[05e2]
    and     $07                             ;[05e3]
    jp      z,$043f                         ;[05e5]
    sub     $02                             ;[05e8]
    jp      z,RCV_FIRST                     ;[05ea]
    sub     $02                             ;[05ed]
    jp      z,$0429                         ;[05ef]
    sub     $03                             ;[05f2]
    jp      z,$041a                         ;[05f4]
    ld      a,d                             ;[05f7]
    and     $08                             ;[05f8]
    jp      nz,$050b                        ;[05fa]
    ld      a,d                             ;[05fd]
    and     $07                             ;[05fe]
