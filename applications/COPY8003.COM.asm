; COPY8003, used to copy disks on a Sanco computer.
; z80asm COPY8003.COM.asm -b -o COPY8003.COM

    org        $0100

C_WRITE := $02
C_WRITESTR       := $09
C_READSTR := $0a

SYSCALL := $0005

stack_top:

    jp entrypoint                           ;[0100]

STR_WELCOME:
    DB "\r\n"
    DB "iBEX 8003 COPY  Version 1.0"
    DB "$"

STR_INSERT:
    DB "\r\n"
    DB "INSERT NEW DISKETTE DRIVE B:"
    DB "\r\n"
    DB "THEN READY,TYPE RETURN"
    DB "$"

entrypoint:
    ld sp,stack_top                         ;[0158] initialize stack pointer
    ld de,STR_WELCOME                       ;[015b] print welcome message
    ld c,C_WRITESTR                         ;[015e]
    call SYSCALL                            ;[0160]
main_prompt:
    ld de,STR_INSERT                        ;[0163] print insert disk message
    ld c,C_WRITESTR                         ;[0166]
    call SYSCALL                            ;[0168]
    call BDOS_READSTR                       ;[016b] wait for a keypress
    ld a,(read_buf+1)                       ;[016e] TODO don't remember how C_READSTR works
    or a                                    ;[0171]
    jp z,begin_copy                         ;[0172]
    call clear_screen                       ;[0175]
    jp main_prompt                          ;[0178]

begin_copy:
    ld de,STR_NEWLINE                       ;[017b]
    ld c,$09                                ;[017e]
    call SYSCALL                            ;[0180]
    xor a                                   ;[0183]
    ld (cur_track),a                        ;[0184] zero current track and current side
    ld (cur_side),a                         ;[0187]
    ld a,$08                                ;[018a] number of TxSx to be printed before reaching...
    ld (margin_ctr),a                       ;[018c] ..screen border
    call print_track_side                   ;[018f]
    call copy_boot_track                    ;[0192] copy separately the boot track (track 0 side 0)
    ld a,$04                                ;[0195] force side to 1 (since track 0 side 0 was already copied)
    ld (cur_side),a                         ;[0197]
copy_loop:
    call print_track_side                   ;[019a]
    call read_track                         ;[019d]
    call write_track                        ;[01a0]
    call verify_track                       ;[01a3]
    ld a,(cur_side)                         ;[01a6]
    bit 2,a                                 ;[01a9] check current disk side
    jr nz,next_track                        ;[01ab] if side 1 done, move track forward
    set 2,a                                 ;[01ad] switch side
    ld (cur_side),a                         ;[01af] update side
    jp copy_loop                            ;[01b2] repeat perform copy of the other side
next_track:
    res 2,a                                 ;[01b5] reset side to 0
    ld (cur_side),a                         ;[01b7]
    ld a,(cur_track)                        ;[01ba]
    inc a                                   ;[01bd] move track forward
    ld (cur_track),a                        ;[01be] update it
    cp 80                                   ;[01c1]
    jp nz,copy_loop                         ;[01c3] repeat loop until track 80
    jp main_prompt                          ;[01c6]

read_track:
    ld b,$44                                ;[01c9] read, sector burst = 4
    ld a,(cur_side)                         ;[01cb] side
    ld c,a                                  ;[01ce]
    res 0,c                                 ;[01cf] set A: drive
    ld a,(cur_track)                        ;[01d1] current track
    ld d,a                                  ;[01d4]
    ld e,$00                                ;[01d5] sector 0
    set 7,e                                 ;[01d7] SBE enabled (read whole track)
    ld hl,$1000                             ;[01d9] read buffer
    ld a,$03                                ;[01dc] ssf = 3 (1024 bps)
    call ROM_FDC_RWFS                       ;[01de] read track from A: drive
    cp $ff                                  ;[01e1]
    ret nz                                  ;[01e3] return on success
read_error:
    ld de,STR_READERROR                     ;[01e4]
    ld c,C_WRITESTR                         ;[01e7]
    call SYSCALL                            ;[01e9]
    jp exit                                 ;[01ec]

STR_READERROR:
    DB "\r\n"
    DB "READ ERROR"
    DB "$"

write_track:
    ld b,$84                                ;[01fc] write, sector burst = 4
    ld a,(cur_side)                         ;[01fe] side
    ld c,a                                  ;[0201]
    set 0,c                                 ;[0202] set B: drive
    ld a,(cur_track)                        ;[0204] current track
    ld d,a                                  ;[0207]
    ld e,$00                                ;[0208] sector 0
    set 7,e                                 ;[020a] SBE enabled (write whole track)
    ld hl,$1000                             ;[020c] data buffer
    ld a,$03                                ;[020f] ssf = 3 (1024 bps)
    call ROM_FDC_RWFS                       ;[0211] write track to B: drive
    cp $ff                                  ;[0214]
    ret nz                                  ;[0216] return on success
write_error:
    ld de,STR_WRITEERROR                    ;[0217]
    ld c,C_WRITESTR                         ;[021a]
    call SYSCALL                            ;[021c]
    jp exit                                 ;[021f]

STR_WRITEERROR:
    DB "\r\n"
    DB "WRITE ERROR"
    DB "$"

verify_track:
    ld b,$44                                ;[0230] read, sector burst = 4
    ld a,(cur_side)                         ;[0232] side
    ld c,a                                  ;[0235]
    set 0,c                                 ;[0236] set B: drive
    ld a,(cur_track)                        ;[0238] current track
    ld d,a                                  ;[023b]
    ld e,$00                                ;[023c] sector 0
    set 7,e                                 ;[023e] SBE enabled (read whole track)
    ld hl,$2400                             ;[0240] verify buffer
    ld a,$03                                ;[0243] ssf = 3 (1024 bps)
    call ROM_FDC_RWFS                       ;[0245] read track from B: drive
    cp $ff                                  ;[0248]
    jp z,verify_error                       ;[024a] proceed with verification on success
    ld hl,$1000                             ;[024d] memcmp(read_buffer, write_buffer, 0x1400)
    ld de,$2400                             ;[0250]
    ld bc,$1400                             ;[0253]
verify_loop:
    ld a,(de)                               ;[0256]
    cp (hl)                                 ;[0257]
    jp nz,verify_error                      ;[0258]
    inc hl                                  ;[025b]
    inc de                                  ;[025c]
    dec bc                                  ;[025d]
    ld a,b                                  ;[025e]
    or c                                    ;[025f]
    jp nz,verify_loop                       ;[0260]
    ret                                     ;[0263]
verify_error:
    ld de,STR_VERIFYERROR                   ;[0264]
    ld c,C_WRITESTR                         ;[0267]
    call SYSCALL                            ;[0269]
    call clear_screen                       ;[026c]
    jp exit                                 ;[026f]
STR_VERIFYERROR:
    DB "\r\n"
    DB "VERIFY ERROR"
    DB "$"

copy_boot_track:
    ld b,$4f                                ;[0281] read, sector burst = 15
    ld c,$00                                ;[0283] set a: drive
    ld d,$00                                ;[0285] track 0
    ld e,$00                                ;[0287] sector 0 (SBE disabled?)
    ld hl,$1000                             ;[0289] read buffer
    ld a,$01                                ;[028c] ssf = 1 (256 bps)
    call ROM_FDC_RWFS                       ;[028e] read whole track from A: drive
    cp $ff                                  ;[0291]
    jp z,read_error                         ;[0293]
    ld b,$8f                                ;[0296] write, sector burst = 15
    ld c,$01                                ;[0298] set b: drive
    ld d,$00                                ;[029a] track 0
    ld e,$00                                ;[029c] sector 0 (SBE disabled?)
    ld hl,$1000                             ;[029e] buffer to be written
    ld a,$01                                ;[02a1] ssf = 1 (256 bps)
    call ROM_FDC_RWFS                       ;[02a3] write whole track to B: drive
    cp $ff                                  ;[02a6]
    jp z,write_error                        ;[02a8]
    ld b,$4f                                ;[02ab] read, sector burst = 15
    ld c,$01                                ;[02ad] set b: drive
    ld d,$00                                ;[02af] track 0
    ld e,$00                                ;[02b1] sector 0 (SBE disabled?)
    ld hl,$2000                             ;[02b3] verify buffer
    ld a,$01                                ;[02b6] ssf = 1 (256 bps)
    call ROM_FDC_RWFS                       ;[02b8] read whole track from B: drive
    cp $ff                                  ;[02bb]
    jp z,verify_error                       ;[02bd]
    ld hl,$1000                             ;[02c0] memcmp(read_buffer, write_buffer, 0x1000)
    ld de,$2000                             ;[02c3]
    ld bc,$1000                             ;[02c6]
verify_boot_loop:
    ld a,(de)                               ;[02c9]
    cp (hl)                                 ;[02ca]
    jp nz,verify_error                      ;[02cb]
    inc hl                                  ;[02ce]
    inc de                                  ;[02cf]
    dec bc                                  ;[02d0]
    ld a,b                                  ;[02d1]
    or c                                    ;[02d2]
    jp nz,verify_boot_loop                  ;[02d3]
    ret                                     ;[02d6]

print_track_side:
    ld de,STR_TRACK                         ;[02d7]
    ld c,C_WRITESTR                         ;[02da]
    call SYSCALL                            ;[02dc]
    ld a,(cur_track)                        ;[02df]
    ld e,a                                  ;[02e2]
    call sub_0329h                          ;[02e3] print dec(e)
    ld e,' '                                ;[02e6]
    call BDOS_WRITE                         ;[02e8] print space
    ld e,'S'                                ;[02eb]
    call BDOS_WRITE                         ;[02ed] print "S"
    ld a,(cur_side)                         ;[02f0] take head currently being formatted (bit 2)
    and $04                                 ;[02f3]
    rrca                                    ;[02f5]
    rrca                                    ;[02f6] make it a value 0/1
    or $30                                  ;[02f7] convert number to ASCII ('0'/'1')
    ld e,a                                  ;[02f9]
    call BDOS_WRITE                         ;[02fa] print the side number (head)
    ld a,(margin_ctr)                       ;[02fd]
    dec a                                   ;[0300] decrement remaining margin to screen border
    ld (margin_ctr),a                       ;[0301]
    ret nz                                  ;[0304]
    ld de,STR_NEWLINE                       ;[0305] add a newline once reached screen border
    ld c,C_WRITESTR                         ;[0308]
    call SYSCALL                            ;[030a]
    ld a,$08                                ;[030d] reload screen margin
    ld (margin_ctr),a                       ;[030f]
    ret                                     ;[0312]

STR_TRACK:
    DB "   T"
    DB "$"

STR_NEWLINE:
    DB "\r\x00\n\x00"
    DB "$"

    nop                                     ;[031d]

margin_ctr:
    DB "\x0b"

ROM_FDC_RWFS:
    call $ffa3                              ;[031f]
    call $c018                              ;[0322]
    call $ffa6                              ;[0325]
    ret                                     ;[0328]

; TODO I imagine this is a decimal print of e
sub_0329h:
    push bc                                 ;[0329]
    push de                                 ;[032a]
    ld a,e                                  ;[032b]
    ld b,$0a                                ;[032c]
    ld c,$ff                                ;[032e]
l0330h:
    inc c                                   ;[0330]
    sub b                                   ;[0331]
    jr nc,l0330h                            ;[0332]
    add a,b                                 ;[0334] TODO  a = a + 9 + 8 + ... + 1
l0335h:
    ld b,a                                  ;[0335]
    ld a,c                                  ;[0336] TODO c should be 10?
    or $30                                  ;[0337] number to ASCII
    ld e,a                                  ;[0339] take x10 number
    call BDOS_WRITE                         ;[033a] print ascii in e
    ld a,b                                  ;[033d] take x1 number
    or $30                                  ;[033e] number to ASCII
    ld e,a                                  ;[0340]
    call BDOS_WRITE                         ;[0341]
    pop de                                  ;[0344]
    pop bc                                  ;[0345]
    ret                                     ;[0346]

BDOS_WRITE:
    push af                                 ;[0347]
    push bc                                 ;[0348]
    push de                                 ;[0349]
    push hl                                 ;[034a]
    ld c,C_WRITE                            ;[034b]
    call SYSCALL                            ;[034d]
    pop hl                                  ;[0350]
    pop de                                  ;[0351]
    pop bc                                  ;[0352]
    pop af                                  ;[0353]
    ret                                     ;[0354]

BDOS_READSTR:
    ld de,read_buf                          ;[0355]
    ld c,C_READSTR                          ;[0358]
    call SYSCALL                            ;[035a]
    ret                                     ;[035d]

read_buf:
    DB "\x10"
    REPT 17
    DB 0
    ENDR

clear_screen:
    ld e,$07                                ;[0370]
    ld c,C_WRITE                            ;[0372]
    call SYSCALL                            ;[0374]
    ret                                     ;[0377]

exit:
    ld c,$00                                ;[0378]
    jp $0005                                ;[037a]

cur_track:
    DB $23
cur_side:
    DB 0

    DB $03
