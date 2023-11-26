; Head 0, Track 0, Sector 0
; CP/M loader

cpm_loader:
    ld      sp,$0080                        ;[0080] set stack pointer
    call    $00c5                           ;[0083] same as fdc_wait_busy in ROM
    ld      c,$03                           ;[0086] specify command
    call    $00cc                           ;[0088] send command to FDC?
    ld      c,$ef                           ;[008b] first argument
    call    $00cc                           ;[008d] send to FDC (same as fdc_send_cmd)
    ld      c,$1b                           ;[0090] second argument
    call    $00cc                           ;[0092] send to FDC (same as fdc_send_cmd)
    ld      hl,$e000                        ;[0095] buffer address ($e000)
    ld      d,$00                           ;[0098] track number = 0
    ld      e,$00                           ;[009a] sector number = 0
    set     7,e                             ;[009c] sector burst enabled
    ld      c,$04                           ;[009e] head = 1, drive# = 0
    ld      b,$44                           ;[00a0] read, sector burst = 4
    ld      a,$03                           ;[00a2] bytes per sector = 1024
    call    $00d8                           ;[00a4] ... read 5120 bytes (0x1400)
    ld      hl,$e000                        ;[00a7] move $e000 -> $dc00
    ld      de,$dc00                        ;[00aa]
    ld      bc,$1400                        ;[00ad]
    ldir                                    ;[00b0] while (bc--) (*de++) = (*hl++); 

    ld      hl,$f000                        ;[00b2] buffer address
    ld      d,$00                           ;[00b5] track number = 0
    ld      e,$01                           ;[00b7] sector address = 1
    set     7,e                             ;[00b9] sector burst enabled
    ld      b,$4e                           ;[00bb] read, sector burst = 14
    ld      a,$01                           ;[00bd] bytes per sector = 256
    call    $00d8                           ;[00bf] ... read 3840 bytes (0x0F00)
    jp      $f200                           ;[00c2] jump to just loaded code

    in      a,($c0)                         ;[00c5]
    bit     4,a                             ;[00c7]
    jr      nz,$00c5                        ;[00c9]
    ret                                     ;[00cb]

    in      a,($c0)                         ;[00cc]
    rlca                                    ;[00ce]
    jr      nc,$00cc                        ;[00cf]
    rlca                                    ;[00d1]
    jr      c,$00cc                         ;[00d2]
    ld      a,c                             ;[00d4]
    out     ($c1),a                         ;[00d5]
    ret                                     ;[00d7]

    push    af                              ;[00d8]
    in      a,($81)                         ;[00d9]
    res     0,a                             ;[00db]
    out     ($81),a                         ;[00dd]
    pop     af                              ;[00df]
    ld      ($00fd),a                       ;[00e0] write to ram?
    ld      a,($00fd)                       ;[00e3] read from ram?
    call    $c018                           ;[00e6] call fdc_rwfs
    or      a                               ;[00e9] check if zero was returned
    jr      z,$00f3                         ;[00ea] if zero, return successfully
    out     ($da),a                         ;[00ec] else beep...
    ld      a,($00fd)                       ;[00ee] ...then load something...
    jr      $00e3                           ;[00f1] ...then retry
    push    af                              ;[00f3] epilogue and return
    in      a,($81)                         ;[00f4]
    set     0,a                             ;[00f6]
    out     ($81),a                         ;[00f8]
    pop     af                              ;[00fa]
    ret                                     ;[00fb]
    
    BYTE $e5 ;[00fc]
    BYTE $d5 ;[00fd]
    BYTE $2a ;[00fe]
    BYTE $c3
    BYTE $c3
    BYTE $5c ;[0101]
    BYTE $df ;[0102]
    BYTE $c3 ;[0103]
    BYTE $58
    BYTE $df
    BYTE $7f ;[0106]
    BYTE $00 ;[0107]

    BYTE "                COPYRIGHT (C) 1979, DIGITAL RESEARCH  "

    ; [013e]
    REPT 66
    nop
    ENDR
