; z80dasm 1.1.6
; command line: z80dasm -t -a -l ../from-cpmls/sg8003.com

    org	00100h

P_TERMCPM := $00
C_WRITE := $02
C_WRITESTR := $09
C_READSTR := $0a

SYSCALL := $0005

main:
    ld sp,main                              ;[0100]
    ld a,002h                               ;[0103] this is useless...
    ld a,001h                               ;[0105]
    ld (short_buffer),a                     ;[0107]
    or 030h                                 ;[010a]
    ld (STR_WELCOME+17),a                   ;[010c]
    ld de,STR_WELCOME                       ;[010f]
    call BDOS_WRITESTR                      ;[0112]
souce_loop:
    ld de,STR_SOUCE                         ;[0115]
    call BDOS_WRITESTR                      ;[0118]
    call BDOS_READSTR_SHORT                 ;[011b]
    cp '.'                                  ;[011e]
    jp z,00000h                             ;[0120] exit
    cp '\r'                                 ;[0123]
    jp z,set_dest_loop                      ;[0125]
    cp '*'                                  ;[0128]
    jp z,set_dest_loop                      ;[012a]
    res 5,a                                 ;[012d]
    cp 'A'                                  ;[012f]
    jp z,valid_drive                        ;[0131]
    cp 'B'                                  ;[0134]
    jp nz,souce_loop                        ;[0136]
valid_drive:
    ld (STR_RETURN+11),a                    ;[0139] Replace drive ID in string with the inserted one
    and 003h                                ;[013c]
    dec a                                   ;[013e] Take 0 or 1 if A or B was inserted
    ld (CUR_DRIVE),a                        ;[013f]
return_loop:
    ld de,STR_RETURN                        ;[0142]
    call BDOS_WRITESTR                      ;[0145]
    call BDOS_READSTR_SHORT                 ;[0148]
    cp '.'                                  ;[014b]
    jp z,souce_loop                         ;[014d]
    cp '\r'                                 ;[0150]
    jp nz,return_loop                       ;[0152]
    call FDC_READ_BOOT_TRACK                ;[0155]
set_autostart_loop:
    ld de,STR_AUTOSTART                     ;[0158]
    call BDOS_WRITESTR                      ;[015b]
    call BDOS_READSTR_SHORT                 ;[015e]
    cp '.'                                  ;[0161]
    jp z,00000h                             ;[0163]
    cp '\r'                                 ;[0166]
    jp z,set_dest_loop                      ;[0168]
    res 5,a                                 ;[016b]
    cp 'N'                                  ;[016d]
    jp z,set_dest_loop                      ;[016f]
    cp 'Y'                                  ;[0172]
    jp nz,set_autostart_loop                ;[0174]
    call set_autostart_cmd                  ;[0177]
set_dest_loop:
    ld de,STR_DISTINATION                   ;[017a]
    call BDOS_WRITESTR                      ;[017d]
    call BDOS_READSTR_SHORT                 ;[0180]
    cp '.'                                  ;[0183]
    jp z,00000h                             ;[0185]
    cp '\r'                                 ;[0188]
    jp z,BDOS_TERMCPM                       ;[018a]
    res 5,a                                 ;[018d]
    cp 'A'                                  ;[018f]
    jp z,set_dest                           ;[0191]
    cp 'B'                                  ;[0194]
    jp z,set_dest                           ;[0196]
    jp set_dest_loop                        ;[0199]
set_dest:
    ld (STR_DISTINATION_ON+17),a            ;[019c] update destination drive letter in message
    and 003h                                ;[019f]
    dec a                                   ;[01a1]
    ld (CUR_DRIVE),a                        ;[01a2]
dest_on_loop:
    ld de,STR_DISTINATION_ON                ;[01a5]
    call BDOS_WRITESTR                      ;[01a8]
    call BDOS_READSTR_SHORT                 ;[01ab]
    cp 003h                                 ;[01ae]
    jp z,00000h                             ;[01b0]
    cp '\r'                                 ;[01b3]
    jp nz,dest_on_loop                      ;[01b5]
    call FDC_WRITE_BOOT_TRACK               ;[01b8]
    jp set_dest_loop                        ;[01bb]

BDOS_TERMCPM:
    ld c,P_TERMCPM                          ;[01be]
    jp SYSCALL                              ;[01c0]

STR_WELCOME:
    DB "\r\n"
    DB "SG8003 Version =.0"
    DB "$"

; [sic]
STR_SOUCE:
    DB "\r\n"
    DB "SOUCE DRIVE NAME ? "
    DB "$"

; [sic]
STR_RETURN:
    DB "\r\n"
    DB "SOUCE ON \x00 THEN TYPE RETURN"
    DB "$"

; [sic]
STR_DISTINATION:
    DB "\r\n"
    DB "DISTINATION DRIVE NAME ? "
    DB "$"

; [sic]
STR_DISTINATION_ON:
    DB "\r\n"
    DB "DISTINATION ON > THEN TYPE RETURN"
    DB "$"

STR_AUTOSTART:
    DB "\r\n"
    DB "IF SET AUTO START THEN \"Y\" ELSE RETURN "
    DB "$"

STR_AUTOSTART_CMD:
    DB "\r\n"
    DB "SET AUTO START COMMAND "
    DB "$"

CUR_DRIVE:
    DB 0

; Load boot tracks in memory
; TODO don't understand how much
FDC_READ_BOOT_TRACK:
    ld b,040h                               ;[0291] Read command
    call FDC_SETUP_PARAMS                   ;[0293]
    ret                                     ;[0296]

FDC_WRITE_BOOT_TRACK:
    ld b,080h                               ;[0297] Write command
    call FDC_SETUP_PARAMS                   ;[0299]
    ret                                     ;[029c]

; Setup common parameters to do things with boot tracks of the disk,
; like rw buffer, track and side indexes, and sector size factor value
FDC_SETUP_PARAMS:
; Load "loader" (sector 0 side 0 track 0)
    ld a,(CUR_DRIVE)                        ;[029d]
    ld c,a                                  ;[02a0]
    ld de,0000h                             ;[02a1]
    ld hl,0900h                             ;[02a4] Destination buffer
    ld a,001h                               ;[02a7] 256 bytes per sector (ssf)
    call ROM_FDC_RWFS                       ;[02a9]
; Load entire side 1 track 0
    ld a,04h                                ;[02ac] Sector burst size = 4
    add a,b                                 ;[02ae] Change only sector burst size without affecting command
    ld b,a                                  ;[02af]
    ld a,(CUR_DRIVE)                        ;[02b0]
    ld c,a                                  ;[02b3]
    set 2,c                                 ;[02b4] set head=1
    ld d,000h                               ;[02b6]
    ld e,000h                               ;[02b8]
    set 7,e                                 ;[02ba] SBE=1
    ld hl,00980h                            ;[02bc] Note: part of the loader's sector is overwritten. But loader is less than 128 bytes
    ld a,003h                               ;[02bf] 1024 bytes per sector (ssf)
; Load sectors 1-15 from side 0 track 0
    call ROM_FDC_RWFS                       ;[02c1]
    ld a,00ah                               ;[02c4] sector burst size = 4 + 10 = 14
    add a,b                                 ;[02c6]
    ld b,a                                  ;[02c7]
    ld a,(CUR_DRIVE)                        ;[02c8]
    ld c,a                                  ;[02cb]
    ld d,000h                               ;[02cc]
    ld e,001h                               ;[02ce]
    ld hl,01d80h                            ;[02d0]
    ld a,001h                               ;[02d3]
    call ROM_FDC_RWFS                       ;[02d5]
    ret                                     ;[02d8]

ROM_FDC_RWFS:
    push af                                 ;[02d9]
    call 0ffa3h                             ;[02da]
    call 0c018h                             ;[02dd]
    call 0ffa6h                             ;[02e0]
    cp 0ffh                                 ;[02e3]
    jr nz,ROM_FDC_RWFS_EPILOGUE             ;[02e5]
    pop af                                  ;[02e7]
    jr ROM_FDC_RWFS                         ;[02e8]
ROM_FDC_RWFS_EPILOGUE:
    pop af                                  ;[02ea]
    ret                                     ;[02eb]

BDOS_READSTR_SHORT:
    ld c,C_READSTR                          ;[02ec]
    ld de,short_buffer                      ;[02ee]
    call SYSCALL                            ;[02f1]
    ld a,(short_buffer+1)                   ;[02f4]
    or a                                    ;[02f7]
    jr z,empty_buffer                       ;[02f8]
    ld a,(short_buffer+2)                   ;[02fa]
    ret                                     ;[02fd]
empty_buffer:
    ld a,'\r'                               ;[02fe] default return value in case of empty buffer
    ret                                     ;[0300]

short_buffer:
    DB 0                                    ; Buffer size
    DB 0                                    ; Enterd char len
    DB 0,0                                  ; Actual data buffer

BDOS_WRITESTR:
    ld c,C_WRITESTR                         ;[0305]
    call SYSCALL                            ;[0307]
    ret                                     ;[030a]

BDOS_READSTR_LONG:
    ld de,long_buffer                       ;[030b]
    ld c,C_READSTR                          ;[030e]
    call SYSCALL                            ;[0310]
    ret                                     ;[0313]

; TODO Set autostart?
set_autostart_cmd:
    ld de,STR_AUTOSTART_CMD                 ;[0314]
    call BDOS_WRITESTR                      ;[0317]
    call BDOS_READSTR_LONG                  ;[031a]
    ld hl,long_buffer+1                     ;[031d] copy the autostart command
    ld de,00987h                            ;[0320] TODO where?
    ld bc,16+1                              ;[0323] string length + actual string
    ldir                                    ;[0326]
    ret                                     ;[0328]

long_buffer:
    DB 16                                   ;Buffer size
    DB "\xfe"                               ;Enterd char len
    REPT 16                                 ;Actual data buffer
    DB 0
    ENDR

; junk, just a copy of a piece of this program
    DB "\xFB\x21\x80\x09\x3E\x03\xCD\xD9\x02\x3E\x0A\x80\x47\x3A\x90\x02"
    DB "\x4F\x16\x00\x1E\x01\x21\x80\x1D\x3E\x01\xCD\xD9\x02\xC9\xF5\xCD"
    DB "\xA3\xFF\xCD\x18\xC0\xCD\xA6\xFF\xFE\xFF\x20\x03\xF1\x18\xEF\xF1"
    DB "\xC9\x0E\x0A\x11\x01\x03\xCD\x05\x00\x3A\x02\x03\xB7\x28\x04\x3A"
    DB "\x03\x03\xC9\x3E\x0D"
