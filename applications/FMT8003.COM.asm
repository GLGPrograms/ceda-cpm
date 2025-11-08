; This is the disassembly of the "FMT8003.COM" program for the Sanco 8003
; found in the CP/M 2.2 image at this link:
;       https://archive.org/details/sanco-8003-cpm-2.2fr.dsqd
;
; By Giulio Venturini (@BayoDev)
    
    ORG $0100
    
    ld      sp,$0100                        ;[0100]
    call    OUT_STRING                      ;[0103]
    
    DB      $0D
    DB      $0A
    DB      "iBEX 8003 Formatter   Version 1.0"
    DB      $0D
    DB      $0A
    DB      "1024 BYTE/SECTOR"
    DB      $00
    
DRIVE_SEL_PROMPT:
    call    OUT_STRING                      ;[013c]
    
    DB      $0D
    DB      $0A
    DB      $0A
    DB      "INITIALIZE (A-B)? "
    DB      $00
    
    call    IN_LINE                         ;[0155]
    ld      a,($02d8)                       ;[0158] Get lenght of input string
    or      a                               ;[015b]
    jp      z,RST_FLOPPY_AND_CPM            ;[015c] Exit program if the input string is empty
    cp      $02                             ;[015f]
    jr      nc,DRIVE_SEL_PROMPT             ;[0161] Jump if the input string is > 2 char long
    ld      a,($02d9)                       ;[0163] Load first input char
    res     5,a                             ;[0166] Reset 5th bit of the A register
    ld      ($0198),a                       ;[0168] Change the next string to display the drive letter
    cp      $41                             ;[016b] Check if input == 'A'
    jr      c,DRIVE_SEL_PROMPT              ;[016d] Jump if the input is < than 'A' (Invalid input)
    cp      $43                             ;[016f] Check if input == 'B'
    jr      nc,DRIVE_SEL_PROMPT             ;[0171] Jump if the input is > than 'B' (Invalid input)
    dec     a                               ;[0173]
    and     $03                             ;[0174]
    ld      (DRIVE_SEL),a                   ;[0176] Save drive selection in memory
    call    OUT_STRING                      ;[0179]
    
    DB      $0D
    DB      $0A
    DB      "INSERT NEW DISKETTE DRIVE "
    DB      $00                             ;[0198] This will contain the drive letter
    DB      $3A
    DB      $0D
    DB      $0A
    DB      "THEN READY,TYPE RETURN"
    DB      $00
    
    call    IN_CHAR                         ;[01b3]
    cp      $03                             ;[01b6]
    jp      z,RST_FLOPPY_AND_CPM            ;[01b8] Jump if input==0x03 (End of text)
    cp      $0d                             ;[01bb]
    jp      nz,DRIVE_SEL_PROMPT             ;[01bd] Jump if input!=0x0D (Carriage return)
    call    OUT_STRING                      ;[01c0] Print new line
    
    DB $0D
    DB $0A
    DB $00
    
    xor     a                               ;[01c6] Resets register A
    ld      (TRACK_CUR),a                   ;[01c7] Set the current track to $00
    ld      a,$08                           ;[01ca]
    ld      ($03e8),a                       ;[01cc] Set $03e8 to $08
    call    ZERO_SEEK                       ;[01cf]
FORMAT_LOOP:
    call    L0373                           ;[01d2]
    call    OUT_DISK_TRACE                  ;[01d5]
    call    FORMAT_TRACK                    ;[01d8]
    ld      a,(DRIVE_SEL)                   ;[01db]
    bit     2,a                             ;[01de]
    jr      nz,$01ea                        ;[01e0]
    set     2,a                             ;[01e2]
    ld      (DRIVE_SEL),a                   ;[01e4] Set DRIVE_SEL[2] to 1 if not already
    jp      FORMAT_LOOP                     ;[01e7]
    res     2,a                             ;[01ea] Reset 2nd bit of DRIVE_SEL
    ld      (DRIVE_SEL),a                   ;[01ec]
    ld      a,(TRACK_CUR)                   ;[01ef]
    inc     a                               ;[01f2]
    ld      (TRACK_CUR),a                   ;[01f3] Increase current track
    cp      $50                             ;[01f6] Check if end of tracks
    jp      z,START_VERIFY                  ;[01f8] Jump if end of tracks reached
    call    MOVE_HEAD                       ;[01fb] Move head to current track
    jp      FORMAT_LOOP                     ;[01fe]
    
START_VERIFY:
    call    OUT_STRING                      ;[0201]
    
    DB      $0D
    DB      $0A
    DB      "VERIFY START"
    DB      $00
    
    ld      ix,$040d                        ;[0213]
    ld      a,(DRIVE_SEL)                   ;[0217]
    and     $03                             ;[021a]
    ld      (ix+$00),a                      ;[021c] ($040d) = DRIVE_SEL[0:1]
    ld      (ix+$01),$28                    ;[021f]
    ld      (ix+$02),$10                    ;[0223]
    ld      (ix+$03),$05                    ;[0227]
    ld      (ix+$04),$01                    ;[022b]
    ld      (ix+$05),$03                    ;[022f]
    call    READ_DISK                       ;[0233]
    cp      $ff                             ;[0236]
    jp      z,VERIFY_ERROR                  ;[0238] Jump if READ_DISK failed
    call    OUT_STRING                      ;[023b] Print confirmation string
    
    DB      $0D
    DB      $0A
    DB      "VERIFY COMPLETED"
    DB      $00
    
    jp      $0179                           ;[0251] Jump back to disk insertion
    
VERIFY_ERROR:
    push    de                              ;[0254]
    call    OUT_STRING                      ;[0255]
    
    DB      $0D
    DB      $0A
    DB      $07
    DB      "VERIFY ERROR!"
    DB      $00
    
    pop     de                              ;[0269]
    push    de                              ;[026A]
    call    OUT_STRING                      ;[026B] Print track where the error occurred
    
    DB      $0D
    DB      $0A
    DB      "TRACK  "
    DB      $00
    
    ld      e,d                             ;[0278]
    call    OUT_DEC                         ;[0279]
    call    OUT_STRING                      ;[027c] Print side where the error occurred
    
    DB      $0D
    DB      $0A
    DB      "SIDE   "
    DB      $00
    
    ld      a,b                             ;[0289]
    and     $04                             ;[028a]
    rrca                                    ;[028c]
    rrca                                    ;[028d]
    or      $30                             ;[028e]
    ld      e,a                             ;[0290]
    call    OUT_CHAR                        ;[0291]
    call    OUT_STRING                      ;[0294] Print sector where the error occurred
    
    DB      $0D
    DB      $0A
    DB      "SECTOR "
    DB      $00
    
    pop     de                              ;[02a1]
    call    OUT_DEC                         ;[02a2]
    jp      RST_FLOPPY_AND_CPM              ;[02a5]
    
; Converts the E register from binary to decimal and then
; prints it
OUT_DEC:
    push    bc                              ;[02a8]
    push    de                              ;[02a9]
    ld      a,e                             ;[02aa]
    ld      b,$0a                           ;[02ab]
    ld      c,$ff                           ;[02ad]
    inc     c                               ;[02af]
    sub     b                               ;[02b0]
    jr      nc,$02af                        ;[02b1] Subtract $0a from the A register and increment C until A<0
    add     b                               ;[02b3] In the end this is A=A%B and C=A/B
    ld      b,a                             ;[02b4]
    ld      a,c                             ;[02b5]
    or      $30                             ;[02b6] Binary number to ASCII
    ld      e,a                             ;[02b8]
    call    OUT_CHAR                        ;[02b9] Print second decimal digit (most significant)
    ld      a,b                             ;[02bc]
    or      $30                             ;[02bd] Binary number to ASCII
    ld      e,a                             ;[02bf]
    call    OUT_CHAR                        ;[02c0] Print first decimal digit
    pop     de                              ;[02c3]
    pop     bc                              ;[02c4]
    ret                                     ;[02c5]
    
; Use the bdos call to read from keyboard until RETURN is pressed
IN_LINE:
    push    af                              ;[02c6]
    push    bc                              ;[02c7]
    push    de                              ;[02c8]
    push    hl                              ;[02c9]
    ld      de,$02d7                        ;[02ca]
    ld      c,$0a                           ;[02cd]
    call    $0005                           ;[02cf]
    pop     hl                              ;[02d2]
    pop     de                              ;[02d3]
    pop     bc                              ;[02d4]
    pop     af                              ;[02d5]
    ret                                     ;[02d6]
    
; Text input buffer used in the IN_LINE function
    DB $0a                                  ;[02d7]
    DB $b8                                  ;[02d8]
    DB $00                                  ;[02d9]
    DB $00                                  ;[02da]
    DB $00                                  ;[02db]
    DB $00                                  ;[02dc]
    DB $00                                  ;[02dd]
    DB $00                                  ;[02de]
    DB $00                                  ;[02df]
    DB $00                                  ;[02e0]
    DB $00                                  ;[02e1]
    DB $00                                  ;[02e2]
    
    call    OUT_STRING                      ;[02e3]
    
    DB      "ERR"
    DB      $00
    
    jr      RST_FLOPPY_AND_CPM              ;[02ea]
    
RST_FLOPPY_AND_CPM:
    call    ZERO_SEEK                       ;[02ec]
CPM_RST:
    ld      c,$00                           ;[02ef]
    jp      $0005                           ;[02f1] Issue bdos call for system reset
    
ZERO_SEEK:
    ld      b,$00                           ;[02f4] Set "move to track 0" operation
    ld      a,(DRIVE_SEL)                   ;[02f6]
    ld      c,a                             ;[02f9] Set drive number
    call    FDC_WRAPPER                     ;[02fa] Call ROM routine
    cp      $ff                             ;[02fd]
    ret     nz                              ;[02ff] Return if A!=$FF
    call    OUT_STRING                      ;[0300] Print error
    
    DB      $0D
    DB      $0A
    DB      "ZERO SEEK ERROR!"
    DB      $00
    
    jp      CPM_RST                         ;[0339]
    
; Move head to the track TRACK_CUR
MOVE_HEAD:
    ld      b,$20                           ;[0319]
    ld      a,(TRACK_CUR)                   ;[031b]
    ld      d,a                             ;[031e]
    ld      a,(DRIVE_SEL)                   ;[031f]
    ld      c,a                             ;[0322]
    call    FDC_WRAPPER                     ;[0323]
    cp      $ff                             ;[0326]
    ret     nz                              ;[0328] Jump if everything went good
    call    OUT_STRING                      ;[0329] Print error and reset CP/M if failed
    
    DB      $0D
    DB      $0A
    DB      "SEEK ERROR!"
    DB      $00
    
    jp      CPM_RST                         ;[0370]
    
FORMAT_TRACK:
    ld      b,$f0                           ;[033d] B=$f0 (command for format operation)
    ld      a,(DRIVE_SEL)                   ;[033f]
    ld      c,a                             ;[0342] C = DRIVE_SEL
    ld      a,(TRACK_CUR)                   ;[0343]
    ld      d,a                             ;[0346] D = TRACK_CUR
    or      a                               ;[0347]
    jr      nz,$0352                        ;[0348] Jump if TRUCK_CUR!=0
    bit     2,c                             ;[034a]
    jr      nz,$0352                        ;[034c] Jump if DRIVE_SEL[2] != 0
    ld      a,$01                           ;[034e]
    jr      $0354                           ;[0350]
    ld      a,$03                           ;[0352] If DRIVE_SEL[2]==1 -> A=$03 , ELSE -> A=$01
    ld      hl,$5000                        ;[0354] Address where the
    call    FDC_WRAPPER                     ;[0357] Call sanco's FDC routine for "format desired track"
    cp      $ff                             ;[035a]
    ret     nz                              ;[035c] Return FDC routine didn't fail
    call    OUT_STRING                      ;[035d] Otherwise print error
    
    DB      $0D
    DB      $0A
    DB      "FORMAT ERROR!"
    DB      $00
    
    jp      CPM_RST                         ;[0370]
    
; ???????
L0373:
    ld      hl,$5000                        ;[0373]
    ld      e,$01                           ;[0376]
    ld      a,(DRIVE_SEL)                   ;[0378] Load drive number
    and     $04                             ;[037b]
    rrca                                    ;[037d]
    rrca                                    ;[037e]
    ld      b,a                             ;[037f] byte 2 of DRIVE_SEL becomes byte 0 of B
    ld      a,(TRACK_CUR)                   ;[0380]
    ld      d,a                             ;[0383]
    or      a                               ;[0384]
    jr      nz,$0392                        ;[0385] Jump if TRACK_CUR!=0
    bit     0,b                             ;[0387] Test DRIVE_SEL[2]
    jr      nz,$0392                        ;[0389] Jump if !=0 (i.e. =1)
    ld      c,$01                           ;[038b]
    ld      a,$10                           ;[038d] Write 16 times with C=$01
    jp      $0396                           ;[038f]
    ld      a,$05                           ;[0392]
    ld      c,$03                           ;[0394] Write 5 times with C=$03
    ld      (hl),d                          ;[0396] Load TRACK_CUR
    inc     hl                              ;[0397]
    ld      (hl),b                          ;[0398] Load DRIVE_SEL[2]
    inc     hl                              ;[0399]
    ld      (hl),e                          ;[039a] Load counter
    inc     hl                              ;[039b]
    ld      (hl),c                          ;[039c] Load C (depenging on DRIVE_SEL[2] $01 or $03)
    inc     hl                              ;[039d]
    inc     e                               ;[039e] Increase counter
    dec     a                               ;[039f] Decrease limit
    jp      nz,$0396                        ;[03a0] Jump if limit!=0
    ret                                     ;[03a3]
    
FDC_WRAPPER:
    call    $ffa3                           ;[03a4]
    call    $c018                           ;[03a7]
    call    $ffa6                           ;[03aa]
    ret                                     ;[03ad]
    
    
OUT_DISK_TRACE:
    call    OUT_STRING                      ;[03ae]
    
; Print current track
    DB      "T"
    DB      $00
    
    ld      a,(TRACK_CUR)                   ;[03b3]
    ld      e,a                             ;[03b6]
    call    OUT_DEC                         ;[03b7]
    call    OUT_STRING                      ;[03ba]
    
; Print current side
    DB      $20
    DB      "S"
    DB      $00
    
    ld      a,(DRIVE_SEL)                   ;[03c0]
    and     $04                             ;[03c3]
    rrca                                    ;[03c5]
    rrca                                    ;[03c6]
    or      $30                             ;[03c7]
    ld      e,a                             ;[03c9]
    call    OUT_CHAR                        ;[03ca]
    call    OUT_STRING                      ;[03cd]
    
    DB      $20                             ;" "
    DB      $20                             ;" "
    DB      $20                             ;" "
    DB      $00
    
    ld      a,($03e8)                       ;[03d4]
    dec     a                               ;[03d7] Decrement line counter
    ld      ($03e8),a                       ;[03d8]
    ret     nz                              ;[03db] return if line counter != 0
    ld      a,$08                           ;[03dc]
    ld      ($03e8),a                       ;[03de] Set ($03e8) to $08 again
    call    OUT_STRING                      ;[03e1]
    
    DB      $0D
    DB      $0A
    DB      $00
    
    ret
    
    DB $3A                                  ;[03e8]
    
; This funcion keeps printing characters starting from the address where
; the function was called + 1 until it encounters $00
OUT_STRING:
    EX      (SP),HL                         ;[03e9]
    ld      a, (hl)                         ;[03ea]
    inc     hl                              ;[03eb]
    or      a                               ;[03ec]
    jr      z,$03f5                         ;[03ed]
    ld      e,a                             ;[03ef]
    call    OUT_CHAR                        ;[03f0]
    jr      $03ea                           ;[03f3]
    ex      (sp),hl                         ;[03f5]
    ret                                     ;[03f6]
    
; Use the bdos call to print to console the ascii character
; stored in the E register
OUT_CHAR:
    push    af                              ;[03f7]
    push    bc                              ;[03f8]
    push    de                              ;[03f9]
    push    hl                              ;[03fa]
    ld      c,$02                           ;[03fb]
    call    $0005                           ;[03fd]
    pop     hl                              ;[0400]
    pop     de                              ;[0401]
    pop     bc                              ;[0402]
    pop     af                              ;[0403]
    ret                                     ;[0404]
    
; Use the bdos call to input an ascii character from the console
; and stores it in register A and L
IN_CHAR:
    ld      c,$01                           ;[0405]
    call    $0005                           ;[0407]
    ret                                     ;[040a]
    
    
TRACK_CUR:
    DB 00                                   ;[040b]
DRIVE_SEL:
; Drive selection(A: 0x00 or B: 0x01)[0:1], Side selection (?) [2]
    DB 00                                   ;[040c]
    
; Reference values used in the verification process
    DB 00                                   ;[040d] $XX     Drive selection (Same format as DRIVE_SEL)
    DB 00                                   ;[040e] $28     Max number of tracks
    DB 00                                   ;[040f] $10     Sectors/track in side 0
    DB 00                                   ;[0410] $05     Sectors/track in side 1
    DB 00                                   ;[0411] $01     Bps shift factor in side 0 (256 byte/sector)
    DB 00                                   ;[0412] $03     Bps shift factor in side 1 (1024 byte/sector)
    
READ_DISK:
    ld      a,(ix+$00)                      ;[0413]
    ld      ($04ba),a                       ;[0416] ($04ba) = selected drive = (DRIVE_SEL[0:1])
    xor     a                               ;[0419]
    ld      ($04b5),a                       ;[041a] Set ($04b5) = $00
    call    READ_TRACK                      ;[041d]
    or      a                               ;[0420]
    ret     nz                              ;[0421] Return if A!=$00 (failed)
    ld      a,($04ba)                       ;[0422]
    bit     2,a                             ;[0425]
    jr      nz,$0431                        ;[0427]
    set     2,a                             ;[0429]
    ld      ($04ba),a                       ;[042b]
    jp      $041d                           ;[042e]
    res     2,a                             ;[0431]
    ld      ($04ba),a                       ;[0433] Invert side bit of select drive
    ld      a,($04b5)                       ;[0436]
    inc     a                               ;[0439]
    ld      ($04b5),a                       ;[043a] Increase current track
    ld      b,a                             ;[043d]
    ld      a,(ix+$01)                      ;[043e]
    cp      b                               ;[0441]
    jp      nz,$041d                        ;[0442] Jump if current track != number of sectors ($28)
    xor     a                               ;[0445]
    ret                                     ;[0446] Return A=$00
    
READ_TRACK:
    xor     a                               ;[0447] Reset A
    ld      ($04b6),a                       ;[0448] Set ($04b6) (i.e. current sector) = $00
    ld      a,(ix+$03)                      ;[044b]
    ld      ($04b7),a                       ;[044e] Set ($04b7) (i.e. max sector) = ($0410) = $05
    ld      a,(ix+$05)                      ;[0451]
    ld      ($04b8),a                       ;[0454] Set ($04b8) (i.e. bts shift factor) = ($0412)
    ld      b,$43                           ;[0457] ??
    ld      a,($04b5)                       ;[0459]
    or      a                               ;[045c]
    jp      nz,$0474                        ;[045d] Jump if ($04b5) (i.e. current track) == $00
    ld      a,($04ba)                       ;[0460]
    bit     2,a                             ;[0463]
    jp      nz,$0474                        ;[0465] Jump if ($04ba)[2]!=0 (Should be == DRIVE_SEL[2] so side select (?))
    ld      a,(ix+$02)                      ;[0468]
    ld      ($04b7),a                       ;[046b] Set ($04b7) (i.e. number of sectors) = ($040f) = $10
    ld      a,(ix+$04)                      ;[046e]
    ld      ($04b8),a                       ;[0471] Set ($04b8) = ($0411) = bps shift factor = $01
    ld      b,$40                           ;[0474] Set operation command for sanco's routine (read sector in the HL buffer)
    ld      a,($04ba)                       ;[0476]
    ld      c,a                             ;[0479] c = drive number = ($04ba)
    ld      a,($04b5)                       ;[047a]
    ld      d,a                             ;[047d] d = current track = ($04b5)
    ld      a,($04b6)                       ;[047e]
    ld      e,a                             ;[0481] e = current sector = ($04b6)
    ld      hl,$04bb                        ;[0482] hl = read buffer address = $04bb
    ld      a,($04b8)                       ;[0485] a = bytes per sector shift factor = ($04b8)
    call    $ffa3                           ;[0488]
    call    $c018                           ;[048b] Use sanco's routine to read sector in the HL buffer
    call    $ffa6                           ;[048e]
    or      a                               ;[0491]
    jp      nz,READ_TRACK_ERR               ;[0492] Jump if a!=0 <=> failed sanco's routine
    ld      a,($04b6)                       ;[0495]
    inc     a                               ;[0498]
    ld      ($04b6),a                       ;[0499] Increase ($04b6) = current sector
    ld      b,a                             ;[049c]
    ld      a,($04b7)                       ;[049d]
    cp      b                               ;[04a0]
    jp      nz,$0474                        ;[04a1] Jump if sector!=number of sectors
    xor     a                               ;[04a4] A = 0
    ret                                     ;[04a5] return
    
READ_TRACK_ERR:
    ld      a,($04b5)                       ;[04a6]
    ld      d,a                             ;[04a9] d = current track
    ld      a,($04b6)                       ;[04aa]
    ld      e,a                             ;[04ad] e = current sector
    ld      a,($04ba)                       ;[04ae]
    ld      b,a                             ;[04b1] b = drive number
    ld      a,$ff                           ;[04b2] a = $ff
    ret                                     ;[04b4]
    
; Used in the verify process
    DB $7a                                  ;[04b5] Current track
    DB $b3                                  ;[04b6] Current sector
    DB $2f                                  ;[04b7] Number of sectors
    DB $ca                                  ;[04b8] Bytes per sector, shift factor
    DB $35                                  ;[04b9] Seems to be unused
    DB $29                                  ;[04ba] Drive number
    
    
; From now on this is used as a data section used
; to store data from the READ_TRACK routine
    
    DB      $AF
    DB      $C3
    DB      $35                             ;'5'
    DB      $29                             ;')'
    DB      $3A                             ;':'
    DB      $D1
    DB      $3C                             ;'<'
    DB      $CD
    DB      $3A                             ;':'
    DB      $0B
    DB      $3D                             ;'='
    DB      $C3
    DB      $35                             ;'5'
    DB      $29                             ;')'
    DB      $3A                             ;':'
    DB      $D1
    DB      $3C                             ;'<'
    DB      $CD
    DB      $3A                             ;':'
    DB      $0B
    DB      $B7
    DB      $C3
    DB      $35                             ;'5'
    DB      $29                             ;')'
    DB      $F6
    DB      $37                             ;'7'
    DB      $F5
    DB      $3A                             ;':'
    DB      $0D
    DB      $3D                             ;'='
    DB      $B7
    DB      $CA
    DB      $BD
    DB      $29                             ;')'
    DB      $CD
    DB      $4F                             ;'O'
    DB      $0B
    DB      $CD
    DB      $1E
    DB      $0C
    DB      $C2
    DB      $A5
    DB      $29                             ;')'
    DB      $E6
    DB      $A0
    DB      $C2
    DB      $B0
    DB      $29                             ;')'
    DB      $CD
    DB      $08
    DB      $0C
    DB      $CA
    DB      $B0
    DB      $29                             ;')'
    DB      $F1
    DB      $9F
    DB      $C3
    DB      $35                             ;'5'
    DB      $29                             ;')'
    DB      $F1
    DB      $3F                             ;'?'
    DB      $9F
    DB      $C3
    DB      $35                             ;'5'
    DB      $29                             ;')'
    DB      $3A                             ;':'
    DB      $0D
    DB      $3D                             ;'='
    DB      $B7
    DB      $C2
    DB      $A9
    DB      $28                             ;'('
    DB      $C1
    DB      $AF
    DB      $21                             ;'!'
    DB      $85
    DB      $0D
    DB      $22                             ;'"'
    DB      $2B                             ;'+'
    DB      $3D                             ;'='
    DB      $C3
    DB      $35                             ;'5'
    DB      $29                             ;')'
    DB      $F6
    DB      $37                             ;'7'
    DB      $F5
    DB      $CD
    DB      $17
    DB      $2A                             ;'*'
    DB      $C2
    DB      $BD
    DB      $29                             ;')'
    DB      $22                             ;'"'
    DB      $2B                             ;'+'
    DB      $3D                             ;'='
    DB      $78                             ;'x'
    DB      $B1
    DB      $CA
    DB      $B0
    DB      $29                             ;')'
    DB      $C3
    DB      $AB
    DB      $29                             ;')'
    DB      $F6
    DB      $37                             ;'7'
    DB      $F5
    DB      $CD
    DB      $17
    DB      $2A                             ;'*'
    DB      $C2
    DB      $BD
    DB      $29                             ;')'
    DB      $D5
    DB      $C5
    DB      $7E                             ;'~'
    DB      $FE
    DB      $2C                             ;','
    DB      $C2
    DB      $0F
    DB      $2A                             ;'*'
    DB      $23                             ;'#'
    DB      $22                             ;'"'
    DB      $2B                             ;'+'
    DB      $3D                             ;'='
    DB      $CD
    DB      $17
    DB      $2A                             ;'*'
    DB      $C2
    DB      $12
    DB      $2A                             ;'*'
    DB      $22                             ;'"'
    DB      $2B                             ;'+'
    DB      $3D                             ;'='
    DB      $79                             ;'y'
    DB      $C1
    DB      $E1
    DB      $B9
    DB      $C2
    DB      $AB
    DB      $29                             ;')'
    DB      $1A
    DB      $BE
    DB      $C2
    DB      $AB
    DB      $29                             ;')'
    DB      $13
    DB      $23                             ;'#'
    DB      $0D
    DB      $C2
    DB      $01
    DB      $2A                             ;'*'
    DB      $C3
    DB      $B0
    DB      $29                             ;')'
    DB      $CD
    DB      $BB
    DB      $04
    DB      $E1
    DB      $E1
    DB      $C3
    DB      $BD
    DB      $29                             ;')'
    DB      $CD
    DB      $C2
    DB      $0B
    DB      $FE
    DB      $3C                             ;'<'
    DB      $C4
    DB      $97
    DB      $04
    DB      $CD
    DB      $1D
    DB      $0B
    DB      $B7
    DB      $C2
    DB      $37                             ;'7'
    DB      $2A                             ;'*'
    DB      $CD
    DB      $E4
    DB      $0A
    DB      $CD
    DB      $1D
    DB      $0B
    DB      $FE
    DB      $26                             ;'&'
    DB      $C2
    DB      $37                             ;'7'
    DB      $2A                             ;'*'
    DB      $CD
    DB      $E4
    DB      $0A
    DB      $C3
    DB      $1F
    DB      "**+=+"
    DB      $11
    DB      $00
    DB      $00
    DB      $23                             ;'#'
    DB      $7E                             ;'~'
    DB      $FE
    DB      $3E                             ;'>'
    DB      $C2
    DB      $47                             ;'G'
    DB      $2A                             ;'*'
    DB      $54                             ;'T'
    DB      $5D                             ;']'
    DB      $FE
    DB      $2C                             ;','
    DB      $C2
    DB      $51                             ;'Q'
    DB      $2A                             ;'*'
    DB      $7A                             ;'z'
    DB      $B3
    DB      $C2
    DB      $57                             ;'W'
    DB      $2A                             ;'*'
    DB      $FE
    DB      $0D
    DB      $C2
    DB      $3E                             ;'>'
    DB      $2A                             ;'*'
    DB      $23                             ;'#'
    DB      $E5
    DB      $2A                             ;'*'
    DB      $2B                             ;'+'
    DB      $3D                             ;'='
    DB      $7A                             ;'z'
    DB      $B3
    DB      $CC
    DB      $97
    DB      $04
    DB      $EB
    DB      $7D                             ;'}'
    DB      $93
    DB      $4F                             ;'O'
    DB      $7C                             ;'|'
    DB      $9A
    DB      $47                             ;'G'
    DB      $E1
    DB      $3A                             ;':'
    DB      $F6
    DB      $3D                             ;'='
    DB      $FE
    DB      $20                             ;' '
    DB      $C9
    DB      $CD
    DB      $4F                             ;'O'
    DB      $0B
    DB      $4F                             ;'O'
    DB      $C5
    DB      $C4
    DB      $97
    DB      $04
    DB      $37                             ;'7'
    DB      $CD
    DB      $F6
    DB      $0C
    DB      $23                             ;'#'
    DB      $7E                             ;'~'
    DB      $F6
    DB      $40                             ;'@'
    DB      $77                             ;'w'
    DB      $C1
    DB      $E6
    DB      $20                             ;' '
    DB      $CC
    DB      $D3
    DB      $04
    DB      $7E                             ;'~'
    DB      $E6
    DB      $80
    DB      $C4
    DB      $AF
    DB      $04
    DB      $1F
    DB      $1F
    DB      $1F
    DB      $B6
    DB      $77                             ;'w'
    DB      $79                             ;'y'
    DB      $FE
    DB      $2C                             ;','
    DB      $CA
    DB      $6E                             ;'n'
    DB      $2A                             ;'*'
    DB      $C9
    DB      $11
    DB      $16
    DB      $3E                             ;'>'
    DB      $01
    DB      $00
    DB      $4F                             ;'O'
    DB      $C3
    DB      $A7
    DB      $2A                             ;'*'
    DB      $0E
    DB      $00
    DB      $11
    DB      $66                             ;'f'
    DB      $3E                             ;'>'
    DB      $06
    DB      $3B                             ;';'
    DB      $CD
    DB      $C2
    DB      $0B
    DB      "*+=+~#"
    DB      $FE
    DB      $0D
    DB      $CA
    DB      $C4
    DB      $2A                             ;'*'
    DB      $B9
    DB      $CA
    DB      $C4
    DB      $2A                             ;'*'
    DB      $04
    DB      $05
    DB      $CA
    DB      $AE
    DB      $2A                             ;'*'
    DB      $12
    DB      $13
    DB      $05
    DB      $C3
    DB      $AE
    DB      $2A                             ;'*'
    DB      $AF
    DB      $12
    DB      $23                             ;'#'
    DB      $22                             ;'"'
    DB      $2B                             ;'+'
    DB      $3D                             ;'='
    DB      $C9
    DB      $CD
    DB      $C2
    DB      $0B
    DB      $FE
    DB      $28                             ;'('
    DB      $C2
    DB      $97
    DB      $04
    DB      $CD
    DB      $23                             ;'#'
    DB      $0B
    DB      $FE
    DB      $27                             ;'''
    DB      $C2
    DB      $97
    DB      $04
    DB      $4F                             ;'O'
    DB      $CD
    DB      $A2
    DB      $2A                             ;'*'
    DB      $CD
    DB      $30                             ;'0'
    DB      $0B
    DB      $CD
    DB      $23                             ;'#'
    DB      $0B
    DB      $FE
    DB      $29                             ;')'
    DB      $C4
    DB      $97
    DB      $04
    DB      $C3
    DB      $3A                             ;':'
    DB      $0B
    DB      $3E                             ;'>'
    DB      $01
    DB      $32                             ;'2'
    DB      $14
    DB      $3D                             ;'='
    DB      $C3
    DB      $3B                             ;';'
    DB      $2B                             ;'+'
    DB      $AF
    DB      $32                             ;'2'
    DB      $14
    DB      $3D                             ;'='
    DB      $C3
    DB      $3B                             ;';'
    DB      $2B                             ;'+'
    DB      $AF
    DB      $32                             ;'2'
    DB      $12
    DB      $3D                             ;'='
    DB      $C3
    DB      $3B                             ;';'
    DB      $2B                             ;'+'
    DB      $CD
    DB      $4F                             ;'O'
    DB      $0B
    DB      $C2
    DB      $29                             ;')'
    DB      $2B                             ;'+'
    DB      $0C
    DB      $0D
    DB      $CA
    DB      $29                             ;')'
    DB      $2B                             ;'+'
    DB      $F5
    DB      $CD
    DB      $08
    DB      $0C
    DB      $C4
    DB      $1E
    DB      $0C
    DB      $C2
    DB      $1C
    DB      $2B                             ;'+'
    DB      $7E                             ;'~'
    DB      $F6
    DB      $40                             ;'@'
    DB      $77                             ;'w'
    DB      $F1
    DB      $FE
    DB      $2C                             ;','
    DB      $C0
    DB      $CD
    DB      $4F                             ;'O'
    DB      $0B
    DB      $C2
    DB      $BB
    DB      $04
    DB      $C3
    DB      $0E
    DB      $2B                             ;'+'
    DB      $3E                             ;'>'
    DB      $01
    DB      $32                             ;'2'
    DB      $12
    DB      $3D                             ;'='
    DB      $C9
    DB      $3E                             ;'>'
    DB      $FF
    DB      $32                             ;'2'
    DB      $13
    DB      $3D                             ;'='
    DB      $C3
    DB      $3B                             ;';'
    DB      $2B                             ;'+'
    DB      $AF
    DB      $32                             ;'2'
    DB      $13
    DB      $3D                             ;'='
    DB      $C3
    DB      $3A                             ;':'
    DB      $0B
    DB      $3E                             ;'>'
    DB      $01
    DB      $32                             ;'2'
    DB      $13
    DB      $3D                             ;'='
    DB      $C3
    DB      $3B                             ;';'
    DB      $2B                             ;'+'
    DB      $AF
    DB      $C3
    DB      $5F                             ;'_'
    DB      $2B                             ;'+'
    DB      $3E                             ;'>'
    DB      $FF
    DB      $C3
    DB      "_+:r@/o:"
    DB      $D1
    DB      $3C                             ;'<'
    DB      $B7
    DB      $CA
    DB      "                               ;+}2r@2
    DB      $0F
    DB      $3D                             ;'='
    DB      $C3
    DB      $3B                             ;';'
    DB      $2B                             ;'+'
    DB      $3E                             ;'>'
    DB      $01
    DB      $32                             ;'2'
    DB      $CF
    DB      $3C                             ;'<'
    DB      $C3
    DB      $3B                             ;';'
    DB      $2B                             ;'+'
    DB      $AF
    DB      $32                             ;'2'
    DB      $CF
    DB      $3C                             ;'<'
    DB      $C3
    DB      $3B                             ;';'
    DB      $2B                             ;'+'
    DB      $3E                             ;'>'
    DB      $FF
    DB      $32                             ;'2'
    DB      $D7
    DB      $3C                             ;'<'
    DB      $CD
    DB      $A9
    DB      $28                             ;'('
    DB      $AF
    DB      $32                             ;'2'
    DB      $D7
    DB      $3C                             ;'<'
    DB      $7A                             ;'z'
    DB      $B7
    DB      $C2
    DB      $97
    DB      $04
    DB      $3A                             ;':'
    DB      $F6
    DB      $3D                             ;'='
    DB      $FE
    DB      $20                             ;' '
    DB      $C0
    DB      $7B                             ;'{'
    DB      $3D                             ;'='
    DB      $F8
    DB      $CA
    DB      $97
    DB      $04
    DB      $FE
    DB      $10
    DB      $D2
    DB      $97
    DB      $04
    DB      $3C                             ;'<'
    DB      $32                             ;'2'
    DB      $D6
    DB      $3C                             ;'<'
    DB      $AF
    DB      $67                             ;'g'
    DB      $6B                             ;'k'
    DB      $C3
    DB      $2E                             ;'.'
    DB      $1B
    DB      $CD
    DB      $A9
    DB      $28                             ;'('
    DB      $7A                             ;'z'
    DB      $B7
    DB      $C2
    DB      $97
    DB      $04
    DB      $3A                             ;':'
    DB      $D1
    DB      $3C                             ;'<'
    DB      $B7
    DB      $C8
    DB      $7B                             ;'{'
    DB      $B7
    DB      $CA
    DB      $C3
    DB      $2B                             ;'+'
    DB      $FE
    DB      $0A
    DB      $DC
    DB      $97
    DB      $04
    DB      $3A                             ;':'
    DB      $F6
    DB      $3D                             ;'='
    DB      $FE
    DB      $20                             ;' '
    DB      $C2
    DB      $C3
    DB      $2B                             ;'+'
    DB      $7B                             ;'{'
    DB      $32                             ;'2'
    DB      $17
    DB      $3D                             ;'='
    DB      $CD
    DB      $25                             ;'%'
    DB      $19
    DB      $CD
    DB      $39                             ;'9'
    DB      $04
    DB      $C3
    DB      $6A                             ;'j'
    DB      $1A
    DB      $CD
    DB      $4F                             ;'O'
    DB      $0B
    DB      $C2
    DB      $97
    DB      $04
    DB      $F5
    DB      $3A                             ;':'
    DB      $CE
    DB      $3D                             ;'='
    DB      $FE
    DB      $08
    DB      $DA
    DB      $E0
    DB      $2B                             ;'+'
    DB      $CD
    DB      $C7
    DB      $04
    DB      $3E                             ;'>'
    DB      $07
    DB      $21                             ;'!'
    DB      $C7
    DB      $3D                             ;'='
    DB      $77                             ;'w'
    DB      $23                             ;'#'
    DB      $22                             ;'"'
    DB      $24                             ;'$'
    DB      $3D                             ;'='
    DB      $3A                             ;':'
    DB      $D1
    DB      $3C                             ;'<'
    DB      $B7
    DB      $0E
    DB      $03
    DB      $C4
    DB      $A3
    DB      $1B
    DB      $F1
    DB      $FE
    DB      $2C                             ;','
    DB      $CA
    DB      $CC
    DB      $2B                             ;'+'
    DB      $C9
    DB      $3A                             ;':'
    DB      $11
    DB      $3D                             ;'='
    DB      $B7
    DB      $C2
    DB      $BB
    DB      $04
    DB      $CD
    DB      $C2
    DB      $0B
    DB      $2A                             ;'*'
    DB      $2B                             ;'+'
    DB      $3D                             ;'='
    DB      $2B                             ;'+'
    DB      $CD
    DB      $33                             ;'3'
    DB      $4E                             ;'N'
    DB      $B7
    DB      $CA
    DB      $13
    DB      $2C                             ;','
    DB      $CD
    DB      $F6
    DB      $4E                             ;'N'
    DB      $C3
    DB      $D9
    DB      $04
    DB      $3D                             ;'='
    DB      $32                             ;'2'
    DB      $11
    DB      "=*+=~#"
    DB      $22                             ;'"'
    DB      $2B                             ;'+'
    DB      $3D                             ;'='
    DB      $FE
    DB      $21                             ;'!'
    DB      $D2
    DB      $17
    DB      $2C                             ;','
    DB      $C9
    DB      $CD
    DB      $C2
    DB      $0B
    DB      $FE
    DB      $28                             ;'('
    DB      $C2
    DB      $97
    DB      $04
    DB      $CD
    DB      $23                             ;'#'
    DB      $0B
    DB      $FE
    DB      $27                             ;'''
    DB      $C2
    DB      $97
    DB      $04
    DB      $CD
    DB      $4F                             ;'O'
    DB      $0B
    DB      $C2
    DB      $97
    DB      $04
    DB      $FE
    DB      $27                             ;'''
    DB      $C2
    DB      $97
    DB      $04
    DB      $CD
    DB      $23                             ;'#'
    DB      $0B
    DB      $FE
    DB      $29                             ;')'
    DB      $C2
    DB      $97
    DB      $04
    DB      $CD
    DB      $3A                             ;':'
    DB      $0B
    DB      $3A                             ;':'
    DB      $D1
    DB      $3C                             ;'<'
    DB      $B7
    DB      $C0
    DB      $3A                             ;':'
    DB      $CE
    DB      $3D                             ;'='
    DB      $FE
    DB      $06
    DB      $DA
    DB      $5A                             ;'Z'
    DB      $2C                             ;','
    DB      $3E                             ;'>'
    DB      $06
    DB      $11
    DB      $CF
    DB      "=!B?G~"
    DB      $B7
    DB      $C2
    DB      $AF
    DB      $04
    DB      $1A
    DB      $77                             ;'w'
    DB      $23                             ;'#'
    DB      $13
    DB      $05
    DB      $C2
    DB      $66                             ;'f'
    DB      $2C                             ;','
    DB      $70                             ;'p'
    DB      $C9
    DB      $CD
    DB      $B6
    DB      $2C                             ;','
    DB      $CD
    DB      $C2
    DB      $0B
    DB      $FE
    DB      $2F                             ;'/'
    DB      $C2
    DB      $97
    DB      $04
    DB      $CD
    DB      $4F                             ;'O'
    DB      $0B
    DB      $C4
    DB      $AE
    DB      $2C                             ;','
    DB      $FE
    DB      $2F                             ;'/'
    DB      $C2
    DB      $97
    DB      $04
    DB      $CD
    DB      $3A                             ;':'
    DB      $0B
    DB      $CD
    DB      $F6
    DB      $0C
    DB      $23                             ;'#'
    DB      $7E                             ;'~'
    DB      $E6
    DB      $D0
    DB      $C2
    DB      $AF
    DB      $04
    DB      $E5
    DB      $7E                             ;'~'
    DB      $F6
    DB      $24                             ;'$'
    DB      $77                             ;'w'
    DB      $CD
    DB      $17
    DB      $27                             ;'''
    DB      $E1
    DB      $2B                             ;'+'
    DB      $22                             ;'"'
    DB      $BF
    DB      $3D                             ;'='
    DB      $3E                             ;'>'
    DB      $03
    DB      $32                             ;'2'
    DB      $B6
    DB      $3D                             ;'='
    DB      $21                             ;'!'
    DB      $00
    DB      $00
    DB      $22                             ;'"'
    DB      $B7
    DB      $3D                             ;'='
    DB      $C3
    DB      $96
    DB      $26                             ;'&'
    DB      $F5
    DB      $3E                             ;'>'
    DB      $01
    DB      $32                             ;'2'
    DB      $CE
    DB      $3D                             ;'='
    DB      $F1
    DB      $C9
    DB      $3A                             ;':'
    DB      $C9
    DB      $3D                             ;'='
    DB      $B7
    DB      $C8
    DB      $C1
    DB      $C3
    DB      $C1
    DB      $04
    DB      $11
    DB      $80
    DB      $00
    DB      $CD
    DB      $4F                             ;'O'
    DB      $0B
    DB      $C2
    DB      $E8
    DB      $2C                             ;','
    DB      $F5
    DB      $B7
    DB      $D5
    DB      $CD
    DB      $F6
    DB      $0C
    DB      $CD
    DB      $F7
    DB      $2C                             ;','
    DB      $D1
    DB      $7E                             ;'~'
    DB      $B2
    DB      $77                             ;'w'
    DB      $23                             ;'#'
    DB      $7E                             ;'~'
    DB      $E6
    DB      $64                             ;'d'
    DB      $C2
    DB      $EE
    DB      $2C                             ;','
    DB      $7E                             ;'~'
    DB      $E6
    DB      $03
    DB      $B3
    DB      $77                             ;'w'
    DB      $F1
    DB      $FE
    DB      $2C                             ;','
    DB      $CA
    DB      $C2
    DB      $2C                             ;','
    DB      $C9
    DB      $CD
    DB      $97
    DB      $04
    DB      $C3
    DB      $E2
    DB      $2C                             ;','
    DB      $F6
    DB      $10
    DB      $77                             ;'w'
    DB      $CD
    DB      $AF
    DB      $04
    DB      $C3
    DB      $E1
    DB      $2C                             ;','
    DB      $7E                             ;'~'
    DB      $FE
    DB      $40                             ;'@'
    DB      $C8
    DB      $FE
    DB      $C0
    DB      $C8
    DB      $E6
    DB      $40                             ;'@'
    DB      $C8
    DB      $7E                             ;'~'
    DB      $AF
    DB      $77                             ;'w'
    DB      $E5
    DB      $AF
    DB      "#w#w#w"
    DB      $E1
    DB      $C9
    DB      $CD
    DB      $4F                             ;'O'
    DB      $0B
    DB      $CD
    DB      $0F
    DB      $05
    DB      $7E                             ;'~'
    DB      $87
    DB      $D4
    DB      $BB
    DB      $04
    DB      $23                             ;'#'
    DB      $7E                             ;'~'
    DB      $FE
    DB      $10
    DB      $CA
    DB      $25                             ;'%'
    DB      $2D                             ;'-'
    DB      $FE
    DB      $0F
    DB      $C4
    DB      $BB
    DB      $04
    DB      $11
    DB      $80
    DB      $04
    DB      $C3
    DB      $C2
    DB      $2C                             ;','
    DB      $22                             ;'"'
    DB      $28                             ;'('
    DB      $3D                             ;'='
    DB      $CD
    DB      $54                             ;'T'
    DB      $2D                             ;'-'
    DB      $3A                             ;':'
    DB      $F6
    DB      $3D                             ;'='
    DB      $32                             ;'2'
    DB      $16
    DB      $3D                             ;'='
    DB      $FE
    DB      $55                             ;'U'
    DB      $C8
    DB      $78                             ;'x'
    DB      $E6
    DB      $80
    DB      $C2
    DB      $A9
    DB      $04
    DB      $78                             ;'x'
    DB      $F6
    DB      $20                             ;' '
    DB      $32                             ;'2'
    DB      $15
    DB      $3D                             ;'='
    DB      $2A                             ;'*'
    DB      $28                             ;'('
    DB      $3D                             ;'='
    DB      $22                             ;'"'
    DB      $24                             ;'$'
    DB      $3D                             ;'='
    DB      $CD
    DB      $D5
    DB      $0D
    DB      $EB
    DB      $78                             ;'x'
    DB      $C3
    DB      $2E                             ;'.'
    DB      $1B
    DB      $CD
    DB      $68                             ;'h'
    DB      $20                             ;' '
    DB      $3A                             ;':'
    DB      $A7
    DB      $3E                             ;'>'
    DB      $B7
    DB      $C8
    DB      $C3
    DB      $C7
    DB      $04
    DB      $22                             ;'"'
    DB      $28                             ;'('
    DB      $3D                             ;'='
    DB      $7E                             ;'~'
    DB      $F6
    DB      $80
    DB      $77                             ;'w'
    DB      $7C                             ;'|'
    DB      $32                             ;'2'
    DB      $16
    DB      $3D                             ;'='
    DB      $CD
    DB      $54                             ;'T'
    DB      $2D                             ;'-'
    DB      $78                             ;'x'
    DB      $E6
    DB      $80
    DB      $C2
    DB      $A9
    DB      $04
    DB      $2A                             ;'*'
    DB      $28                             ;'('
    DB      $E1
    DB      $2C                             ;','
    DB      $7E                             ;'~'
    DB      $FE
    DB      $40                             ;'@'
    DB      $C8
    DB      $FE
    DB      $C0
    DB      $C8
    DB      $E6
    DB      $40                             ;'@'
    DB      $C8
    DB      $7E                             ;'~'
    DB      $AF
    DB      $77                             ;'w'
    DB      $E5
    DB      $AF
    DB      "#w#w#w"
    DB      $E1
    DB      $C9
    DB      $CD
    DB      $4F                             ;'O'
    DB      $0B
    DB      $CD
    DB      $0F
    DB      $05
    DB      $7E                             ;'~'
    DB      $87
    DB      $D4
    DB      $BB
    DB      $04
    DB      $23                             ;'#'
    DB      $7E                             ;'~'
    DB      $FE
    DB      $10
    DB      $CA
    DB      $25                             ;'%'
    DB      $2D                             ;'-'
    DB      $FE
    DB      $0F
    DB      $C4
    DB      $BB
    DB      $04
    DB      $11
    DB      $80
    DB      $04
    DB      $C3
    DB      $C2
    DB      $2C                             ;','
    DB      $22                             ;'"'
    DB      $28                             ;'('
    DB      $3D                             ;'='
    DB      $CD
    DB      $54                             ;'T'
    DB      $2D                             ;'-'
    DB      $3A                             ;':'
    DB      $F6
    DB      $3D                             ;'='
    DB      $32                             ;'2'
    DB      $16
    DB      $3D                             ;'='
    DB      $FE
    DB      $55                             ;'U'
    DB      $C8
