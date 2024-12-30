; PAR8003.COM, used to reconfigure secondary drive on a Sanco computer.
; Or, at least, this is what I've understood.

    org 0x0100

    nop                                     ;[0100] they like to lose time?
    nop                                     ;[0101]
    nop                                     ;[0102]
main:
    ld      sp,$07ca                        ;[0103] configure stack pointer
    call    initialize                      ;[0106]
    call    putstr                          ;[0109] print the following string on screen until NUL character,
                                            ;       then resume execution from the first instruction after NUL.

                                            ;[010c]
    DB "\r\n"
    DB "\r\n"
    DB "\xed\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xeb"
    DB "\r\n"
    DB "\xef  PARADISC  vers 1.2     SANCO-IBEX 8003          \xef"
    DB "\r\n"
    DB "\xef  Programme de modification de parametres disque  \xef"
    DB "\r\n"
    DB "\xee\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xec"
    DB "\r\n"
    DB "\r\n"
    DB 0

    call    putstr                          ;[01eb] print the following string on screen, until NUL character

                                            ;[01ee]
    DB "\r\n"
    DB "\r\n"
    DB "      ^C    retour sous systeme           "
    DB "\r\n"
    DB "            param\x2eSANCO-IBEX              "
    DB "\r\n"
    DB "      -1-        \"       \"   8103  7103   "
    DB "\r\n"
    DB "      -2-        \"     8001  8102  7102/2 "
    DB "\r\n"
    DB "      -3-        \"       \"    \"    7102   "
    DB "\r\n"
    DB "\r\n"
    DB "               Code ?:"
    DB 0

get_key:
    call    cpm_read                        ;[02e7] wait for keypress
    or      a                               ;[02ea]
    jp      z,get_key                       ;[02eb]
    cp      $03                             ;[02ee] ^C to exit
    jp      z,quit                          ;[02f0]
    ld      (bSelection),a                  ;[02f3] save the inserted character
    ld      hl,table1                       ;[02f6]
    cp      '1'                             ;[02f9]
    jp      z,apply_settings                ;[02fb]
    ld      hl,table2                       ;[02fe]
    cp      '2'                             ;[0301]
    jp      z,apply_settings                ;[0303]
    ld      hl,table3                       ;[0306]
    cp      '3'                             ;[0309]
    jp      z,apply_settings                ;[030b]
    ld      a,'\a'                          ;[030e]
    call    cpm_rawio                       ;[0310] trigger system bell
    jp      main                            ;[0313] restart from the beginning

cpm_read:
    push    hl                              ;[0316]
    push    de                              ;[0317]
    push    bc                              ;[0318]
    ld      c,$01                           ;[0319]
    call    $0005                           ;[031b]
    pop     bc                              ;[031e]
    pop     de                              ;[031f]
    pop     hl                              ;[0320]
    ret                                     ;[0321]

initialize:
    ld      hl,($0001)                      ;[0322] take the system reset entry from the CP/M jump table (WBOOT)
    ld      de,$0018                        ;[0325] add +0x18 to get the address of SELDSK
    add     hl,de                           ;[0328]
    ld      (trampoline+1),hl               ;[0329] make the trampoline point there
    ret                                     ;[032c]

    ; TODO trampoline
trampoline:
    jp      $0000                           ;[032d]
    ret                                     ;[0330] this return is quite useless...

apply_settings:
    ld      a,$43                           ;[0331]
    dec     a                               ;[0333]
    push    hl                              ;[0334] save hl (the value from the previous switch)
    sub     $41                             ;[0335] pretty complicate way to do ld a,$1
    ld      c,a                             ;[0337] copy $1 in c
    ld      b,$01                           ;[0338]
    and     $03                             ;[033a] limit a between 0 and 3
    jr      z,label_0343                    ;[033c] calculate the mask 1 << a
label_033e:
    rlc     b                               ;[033e]
    dec     a                               ;[0340]
    jr      nz,label_033e                   ;[0341]
label_0343:
    ld      a,b                             ;[0343]
    cpl                                     ;[0344] negate the mask a = ~a, should be 0xFD
    ld      hl,$ffc7                        ;[0345] this is populated by FDC routines, keeps the mask of already initialized disks
    and     (hl)                            ;[0348]
    ld      (hl),a                          ;[0349] the result is still 1
    call    trampoline                      ;[034a] manually call SELDSK from CP/M bios.
                                            ;       Invoked with c=1 (disk 1). Undocumented: DE points to the
                                            ;       DPB of selected disk.
    pop     hl                              ;[034d] restore hl, size of the new DPB table
    ld      c,(hl)                          ;[034e]
    inc     hl                              ;[034f]
    ld      b,(hl)                          ;[0350]
    inc     hl                              ;[0351] now hl points to DPB table, bc holds its size
    ldir                                    ;[0352] overwrite old DPB with new one
    ld      a,(bSelection)                  ;[0354]
    cp      '1'                             ;[0357]
    jr      z,label_0381                    ;[0359] treat 1 (and 4 !?!) as special case
    cp      '4'                             ;[035b] (TODO) WHAT THE HELL, THIS IS NOT EVEN POSSIBLE!
    jr      z,label_0381                    ;[035d]
    di                                      ;[035f]
    in      a,($81)                         ;[0360] disable bank switch to access AUX memory
    res     0,a                             ;[0362]
    out     ($81),a                         ;[0364]
    ld      de,$bc00                        ;[0366] copy the new fdc_routines in AUX RAM.
    ld      hl,fdc_routines                 ;[0369] these fdc_routines contain a reimplementation of the rwfs routines
    ld      bc,$02da                        ;[036c]
    ldir                                    ;[036f]
    ld      hl,$bc00                        ;[0371]
    ld      ($b819),hl                      ;[0374] update the pointer to rwfs routine in ROM jump table copy
    in      a,($81)                         ;[0377] enable bank switch
    set     0,a                             ;[0379]
    out     ($81),a                         ;[037b]
    ei                                      ;[037d]
    jp      quit                            ;[037e]
label_0381:
    di                                      ;[0381]
    in      a,($81)                         ;[0382]
    res     0,a                             ;[0384]
    out     ($81),a                         ;[0386]
    ld      hl,$c018                        ;[0388] just keep ROM's rwfs as the right fdc routine
    ld      ($b819),hl                      ;[038b]
    in      a,($81)                         ;[038e]
    set     0,a                             ;[0390]
    out     ($81),a                         ;[0392]
    ei                                      ;[0394]
    jp      quit                            ;[0395]

fdc_routines:                               ;[0398]
    ;; RELOCATED CODE!!!
    ; This code is relocated from $bc00 to $beda.
    ; See PAR8003.relocated.asm
    DB $C5,$D5,$E5,$21,$D7,$BE,$36,$00,$CB,$7F,$28,$02,$36,$01,$CB,$BF
    DB $32,$B8,$FF,$E1,$E5,$3E,$0A,$32,$BF,$FF,$ED,$43,$B9,$FF,$ED,$53
    DB $BB,$FF,$22,$BD,$FF,$CD,$9E,$BE,$3A,$BA,$FF,$E6,$F0,$CA,$58,$BC
    DB $FE,$40,$CA,$4E,$BC,$FE,$80,$CA,$49,$BC,$FE,$20,$CA,$53,$BC,$FE
    DB $F0,$CA,$5D,$BC,$3E,$FF,$C3,$62,$BC,$CD,$66,$BC,$18,$14,$CD,$BC
    DB $BC,$18,$0F,$CD,$1B,$BE,$18,$0A,$CD,$03,$BE,$18,$05,$CD,$55,$BD
    DB $18,$00,$E1,$D1,$C1,$C9,$CD,$1B,$BE,$CD,$29,$BD,$D5,$CD,$97,$BE
    DB $0E,$C5,$3A,$B8,$FF,$B7,$20,$02,$CB,$B1,$CD,$90,$BE,$F3,$CD,$C0
    DB $BD,$D1,$0E,$C1,$43,$2A,$BD,$FF,$DB,$82,$CB,$57,$28,$FA,$DB,$C0
    DB $CB,$6F,$28,$07,$ED,$A3,$20,$F0,$15,$20,$ED,$D3,$DC,$FB,$CD,$6F
    DB $BE,$3A,$C0,$FF,$E6,$C0,$FE,$40,$20,$10,$CD,$12,$BD,$3A,$BF,$FF
    DB $3D,$32,$BF,$FF,$C2,$69,$BC,$3E,$FF,$C9,$AF,$C9,$CD,$1B,$BE,$CD
    DB $29,$BD,$D5,$CD,$97,$BE,$0E,$C6,$3A,$B8,$FF,$B7,$20,$02,$CB,$B1
    DB $CD,$90,$BE,$F3,$CD,$C0,$BD,$D1,$0E,$C1,$43,$2A,$BD,$FF,$DB,$82
    DB $CB,$57,$28,$FA,$DB,$C0,$CB,$6F,$28,$07,$ED,$A2,$20,$F0,$15,$20
    DB $ED,$D3,$DC,$FB,$CD,$6F,$BE,$3A,$C0,$FF,$E6,$C0,$FE,$40,$20,$10
    DB $CD,$12,$BD,$3A,$BF,$FF,$3D,$32,$BF,$FF,$C2,$BF,$BC,$3E,$FF,$C9
    DB $AF,$C9,$3A,$C2,$FF,$CB,$67,$28,$04,$CD,$03,$BE,$C9,$3A,$C1,$FF
    DB $CB,$47,$28,$04,$CD,$03,$BE,$C9,$C9,$1E,$00,$3A,$B8,$FF,$FE,$03
    DB $20,$14,$16,$04,$3A,$BB,$FF,$CB,$7F,$28,$19,$3A,$BA,$FF,$E6,$0F
    DB $07,$07,$82,$57,$18,$0E,$B7,$20,$02,$1E,$80,$3A,$BA,$FF,$E6,$0F
    DB $16,$01,$82,$57,$C9,$CD,$1B,$BE,$FE,$FF,$C8,$06,$14,$3A,$B8,$FF
    DB $FE,$03,$28,$02,$06,$40,$C5,$CD,$97,$BE,$0E,$4D,$CD,$90,$BE,$ED
    DB $4B,$B9,$FF,$CD,$90,$BE,$3A,$B8,$FF,$4F,$CD,$90,$BE,$0E,$05,$3A
    DB $B8,$FF,$FE,$03,$28,$02,$0E,$10,$CD,$90,$BE,$0E,$28,$CD,$90,$BE
    DB $F3,$0E,$E5,$CD,$90,$BE,$C1,$0E,$C1,$2A,$BD,$FF,$DB,$82,$CB,$57
    DB $28,$FA,$DB,$C0,$CB,$6F,$28,$04,$ED,$A3,$20,$F0,$D3,$DC,$FB,$CD
    DB $6F,$BE,$3A,$C0,$FF,$E6,$C0,$FE,$40,$20,$03,$3E,$FF,$C9,$AF,$C9
    DB $ED,$4B,$B9,$FF,$CD,$90,$BE,$ED,$5B,$BB,$FF,$4A,$CD,$90,$BE,$ED
    DB $4B,$B9,$FF,$79,$E6,$04,$0F,$0F,$4F,$CD,$90,$BE,$CB,$BB,$4B,$0C
    DB $CD,$90,$BE,$3A,$B8,$FF,$4F,$CD,$90,$BE,$0E,$05,$3A,$B8,$FF,$FE
    DB $03,$28,$02,$0E,$10,$CD,$90,$BE,$0E,$28,$CD,$90,$BE,$0E,$FF,$CD
    DB $90,$BE,$C9,$CD,$97,$BE,$0E,$07,$CD,$90,$BE,$ED,$4B,$B9,$FF,$CB
    DB $91,$CD,$90,$BE,$CD,$4D,$BE,$28,$EA,$AF,$C9,$ED,$5B,$BB,$FF,$7A
    DB $B7,$CA,$03,$BE,$CD,$97,$BE,$0E,$0F,$CD,$90,$BE,$ED,$4B,$B9,$FF
    DB $CD,$90,$BE,$21,$D7,$BE,$CB,$46,$28,$02,$CB,$22,$4A,$CD,$90,$BE
    DB $CD,$4D,$BE,$20,$06,$CD,$03,$BE,$C3,$1B,$BE,$AF,$C9,$DB,$82,$CB
    DB $57,$CA,$4D,$BE,$CD,$97,$BE,$CD,$7E,$BE,$3E,$08,$D3,$C1,$CD,$87
    DB $BE,$DB,$C1,$47,$CD,$87,$BE,$DB,$C1,$78,$E6,$C0,$FE,$40,$C9,$21
    DB $C0,$FF,$06,$07,$0E,$C1,$CD,$87,$BE,$ED,$A2,$20,$F9,$C9,$DB,$C0
    DB $07,$30,$FB,$07,$38,$F8,$C9,$DB,$C0,$07,$30,$FB,$07,$30,$F8,$C9
    DB $CD,$7E,$BE,$79,$D3,$C1,$C9,$DB,$C0,$CB,$67,$20,$FA,$C9,$06,$01
    DB $79,$E6,$03,$B7,$28,$05,$CB,$00,$3D,$20,$FB,$3A,$C7,$FF,$4F,$A0
    DB $C0,$79,$B0,$32,$C7,$FF,$CD,$03,$BE,$C9,$C5,$E5,$21,$D8,$BE,$CD
    DB $97,$BE,$0E,$03,$CD,$90,$BE,$4E,$23,$CD,$90,$BE,$4E,$CD,$90,$BE
    DB $AF,$32,$C7,$FF,$E1,$C1,$C9,$00,$6F,$1B
;; END OF RELOCATION

putstr:
    pop     de                              ;[0672] take the return address from the stack
putstr_loop:
    ld      a,(de)                          ;[0673] take its content (it should be a character)
    or      a                               ;[0674] if NUL...
    jp      z,putstr_epilogue               ;[0675] ...terminate the execution
    call    cpm_rawio                       ;[0678] put a on screen
    inc     de                              ;[067b] move data pointer and repeat
    jp      putstr_loop                     ;[067c]
putstr_epilogue:
    inc     de                              ;[067f] skip NUL character
    ex      de,hl                           ;[0680]
    jp      (hl)                            ;[0681] then manually return to the first instruction after NUL

; TODO: rawio outputs character if e < 0xFF, else will read
; What's the difference with putchar???
cpm_rawio:
    push    hl                              ;[0682]
    push    de                              ;[0683]
    push    bc                              ;[0684]
    ld      c,$06                           ;[0685] TODO C_RAWIO
    ld      e,a                             ;[0687]
    call    $0005                           ;[0688]
    pop     bc                              ;[068b]
    pop     de                              ;[068c]
    pop     hl                              ;[068d]
    ret                                     ;[068e]

quit:
    jp      $0000                           ;[068f] TODO invoke CP/M warm reset

table1:
    DB      $1d,$00                         ;[0692]
    ; DPB, choice "1"
    ; This is not even used, since if "1" is selected, this is discarded and
    ; the ROM rwfs is used.
    DW      80                              ; Number of 128-byte records per track
    DB      5                               ; Block shift. 3 => 1k, 4 => 2k, 5 => 4k
    DB      0x1f                            ; Block mask. 7 => 1k, 0Fh => 2k, 1Fh => 4k...
    DB      03                              ; Extent mask
    DW      195                             ; (no. of blocks on the disk)-1
    DW      0x7f                            ; (no. of directory entries)-1
    DB      0x80                            ; Directory allocation bitmap, first byte
    DB      0                               ; Directory allocation bitmap, second byte
    DW      0x0020                          ; Checksum vector size, 0 for a fixed disk
                                            ; No. directory entries/4, rounded up.
    DB      1                               ; Offset, number of reserved tracks

    ; Just garbage, I think...
    DB      $00,$20,$50,$07,$03,$01,$03,$05,$00,$00,$00,$02,$04,$01,$03

table2:
    DB      $1d,$00                         ;[06b1]
    ; DPB, choice "2"
    DW      80                              ; Number of 128-byte records per track
    DB      4                               ; Block shift. 3 => 1k, 4 => 2k, 5 => 4k
    DB      0x0f                            ; Block mask. 7 => 1k, 0Fh => 2k, 1Fh => 4k...
    DB      00                              ; Extent mask
    DW      194                             ; (no. of blocks on the disk)-1
    DW      0x3f                            ; (no. of directory entries)-1
    DB      0x80                            ; Directory allocation bitmap, first byte
    DB      0                               ; Directory allocation bitmap, second byte
    DW      0x0010                          ; Checksum vector size, 0 for a fixed disk
                                            ; No. directory entries/4, rounded up.
    DB      1                               ; Offset, number of reserved tracks

    ; Just garbage, I think...
    DB      $00,$10,$50,$07,$83,$01,$03,$05,$00,$00,$00,$02,$04,$01,$03

table3:
    DB      $28,$00                         ;[06d0]
    ; DPB for disk, choice "3"
    DW      64                              ; Number of 128-byte records per track
    DB      3                               ; Block shift. 3 => 1k, 4 => 2k, 5 => 4k
    DB      0x07                            ; Block mask. 7 => 1k, 0Fh => 2k, 1Fh => 4k...
    DB      00                              ; Extent mask
    DW      255                             ; (no. of blocks on the disk)-1
    DW      0x3f                            ; (no. of directory entries)-1
    DB      192                             ; Directory allocation bitmap, first byte
    DB      0                               ; Directory allocation bitmap, second byte
    DW      0x0010                          ; Checksum vector size, 0 for a fixed disk
                                            ; No. directory entries/4, rounded up.
    DB      1                               ; Offset, number of reserved tracks

    ; Just garbage, I think...
    DB      $00,$08,$40,$01,$81,$01,$00,$10,$00,$00,$00,$02,$04,$06,$08,$0a,$0c,$0e,$01,$03,$05,$07,$09,$0b,$0d,$0f

    DB      $32,$00                         ;[06fa]
    ; DPB for disk 0, fake choice "4"
    DW      128                             ; Number of 128-byte records per track
    DB      5                               ; Block shift. 3 => 1k, 4 => 2k, 5 => 4k
    DB      0x1f                            ; Block mask. 7 => 1k, 0Fh => 2k, 1Fh => 4k...
    DB      00                              ; Extent mask
    DW      299                             ; (no. of blocks on the disk)-1
    DW      0x7f                            ; (no. of directory entries)-1
    DB      128                             ; Directory allocation bitmap, first byte
    DB      0                               ; Directory allocation bitmap, second byte
    DW      0x0020                          ; Checksum vector size, 0 for a fixed disk
                                            ; No. directory entries/4, rounded up.
    DB      2                               ; Offset, number of reserved tracks

    ; Just garbage, I think...
    DB      $00,$20,$80,$07,$03,$82,$03,$08,$00,$00,$00,$03,$06,$01,$04,$07,$02,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

    DB      $32,$00                         ;[072e]
    ; DPB for disk 0, fake choice "5"
    DW      104                             ; Number of 128-byte records per track
    DB      5                               ; Block shift. 3 => 1k, 4 => 2k, 5 => 4k
    DB      0x1f                            ; Block mask. 7 => 1k, 0Fh => 2k, 1Fh => 4k...
    DB      00                              ; Extent mask
    DW      242                             ; (no. of blocks on the disk)-1
    DW      0x7f                            ; (no. of directory entries)-1
    DB      128                             ; Directory allocation bitmap, first byte
    DB      0                               ; Directory allocation bitmap, second byte
    DW      0x0020                          ; Checksum vector size, 0 for a fixed disk
                                            ; No. directory entries/4, rounded up.
    DB      2                               ; Offset, number of reserved tracks

    ; Just garbage, I think...
    DB      $00,$20,$68,$01,$01,$82,$00,$1A,$00,$00,$00,$06,$0C,$12,$18,$04,$0A,$10,$16,$02,$08,$0E,$14,$01,$07,$0D,$13,$19,$05,$0B,$11,$17,$03,$09,$0F,$15

    DB      $32,$00                         ;[0762]
    ; DPB for disk 0, fake choice "6"
    DW      26                              ; Number of 128-byte records per track
    DB      3                               ; Block shift. 3 => 1k, 4 => 2k, 5 => 4k
    DB      0x07                            ; Block mask. 7 => 1k, 0Fh => 2k, 1Fh => 4k...
    DB      00                              ; Extent mask
    DW      242                             ; (no. of blocks on the disk)-1
    DW      0x3f                            ; (no. of directory entries)-1
    DB      192                             ; Directory allocation bitmap, first byte
    DB      0                               ; Directory allocation bitmap, second byte
    DW      0x0010                          ; Checksum vector size, 0 for a fixed disk
                                            ; No. directory entries/4, rounded up.
    DB      2                               ; Offset, number of reserved tracks

    ; Just garbage, I think...
    DB      $00,$08,$1a,00,$00,$82,$00,$1A,$00,$00,$00,$06,$0C,$12,$18,$04,$0A,$10,$16,$02,$08,$0E,$14,$01,$07,$0D,$13,$19,$05,$0B,$11,$17,$03,$09,$0F,$15,$3c

    ; inserted value when choosing SANCO model
bSelection:
    DB      $00

    ; other garbage                         ;[0798]
    DB      $C0,$3A,$CE,$3D,$FE,$06,$DA,$5A,$2C,$3E,$06,$11,$CF,$3D,$21,$42,$3F,$47,$7E,$B7,$C2,$AF,$04,$1A,$77,$23,$13,$05,$C2,$66,$2C,$70,$C9,$CD,$B6,$2C,$CD,$C2,$0B,$FE,$2F,$C2,$97,$04,$CD,$4F,$0B,$C4,$AE,$2C,$0C,$12,$18,$04,$0A,$10,$16,$02,$08,$0E,$14,$01,$07,$0D,$13,$19,$05,$0B,$11,$17,$03,$09,$0F,$15,$32,$00,$1A,$00,$03,$07,$00,$F2,$00,$3F,$00,$C0,$00,$10,$00,$02,$00,$08,$1A,$00,$00,$82,$00,$1A,$00,$00,$00,$06,$0C,$12
