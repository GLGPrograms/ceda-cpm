; FUNK00, used to remap keyboard layout on a Sanco computer.
; More information will come later, I hope.
; z80asm FUNK00.COM.asm -b -o FUNK00.COM

    org 0x0100

;; Functions
SYSCALL: = $0005

;; CP/M loaded program starts from here
    jp      entrypoint                      ;[0100]

comm_sio_cfg:                               ;[0103]
    DB $00                                  ; Register 0
    DB $1b                                  ;  Channel reset? but with another register pointer (which is forbidden by the manual)
    DB $00                                  ; Register 0
    DB $10                                  ;  Reset interrupts
    DB $00                                  ; Register 0
    DB $10                                  ;  Reset interrupts
    DB $04                                  ; Register 4
    DB $4c                                  ;  2 stop bits + x16 clock mode
    DB $01                                  ; Register 1
    DB $00                                  ;  no interrupts
    Db $03                                  ; Register 3
    DB $e1                                  ;  Rx enable + Auto enables + 8 bit per character (Rx)
    DB $05                                  ; Register 5
    DB $68                                  ;  Tx enable + 8 bit per character (Tx)

timer12_cfg:                                ;[0111]
    DB $05, $01, $41                        ; Timer 1: time constant 1, counter mode, no irq
    DB $05, $10, $41                        ; Timer 2: time constant 16, counter mode, no irq
    DB $00

    ;[0118]
    DB $00,$00,$00,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$e0,$80,$e3,$03
    DB $e3,$05,$e3,$01,$e3,$c1,$ff,$cb,$00,$00,$00,$00,$80,$00
    DB $cd,$30,$01,$0e,$09,$cd,$05,$00,$c1,$21,$07,$00,$7e,$3d
    DB $90
    ; Stack grows from here, so this is meaningless data that
    ; will be overwritten. Just here for coherence with the
    ; binary

    ; The following code is unreachable, so it is at the moment
    ; ignored and will be disassembled in second place.
    ; Kept just for coherence with binary file.
unreach0:
    DB $57,$1E,$00,$D5,$21,$00,$02,$78,$B1,$CA,$65,$01,$0B,$7E
    DB $12,$13,$23,$C3,$58,$01,$D1,$C1,$E5,$62,$78,$B1,$CA,$87
    DB $01,$0B,$7B,$E6,$07,$C2,$7A,$01,$E3,$7E,$23,$E3,$6F,$7D
    DB $17,$6F,$D2,$83,$01,$1A,$84,$12,$13,$C3,$69,$01,$D1,$2E
    DB $00,$E9,$0E,$10,$CD,$05,$00,$32,$5F,$1E,$C9,$21,$66,$1E
    DB $70,$2B,$71,$2A,$65,$1E,$EB,$0E,$11,$CD,$05,$00,$32,$5F
    DB $1E,$C9,$11,$00,$00,$0E,$12,$CD,$05,$00,$32,$5F,$1E,$C9
    DB $21,$68,$1E,$70,$2B,$71,$2A,$67,$1E,$EB,$0E,$13,$CD,$05
    DB $00,$C9,$21,$6A,$1E,$70,$2B,$71,$2A,$69,$1E,$EB,$0E,$14
    DB $CD,$05,$00,$C9,$21,$6C,$1E,$70,$2B,$71,$2A,$6B,$1E,$EB
    DB $0E,$15,$CD,$05,$00,$C9,$21,$6E,$1E,$70,$2B,$71,$2A,$6D
    DB $1E,$EB,$0E,$16,$CD,$05,$00,$32,$5F,$1E,$C9,$21,$70,$1E
    DB $70,$4A,$01,$00,$C6,$B4,$13

welcome_str:                                ;[0200]
    DB "\x1B\x46\x1A\x1B\x5F\x30\x1B\x5F\x34\x0D\x0A\x1B\x4F\x1B\x47\x1B\x41\x1B\x3D"
    DB "**\x1b\x578003\x1b\x42 CP/M 2.2 vers 1.7FR\x1B\x58\x0D\x0A$"

                                            ;[0236]
    DB "s 2.2\x0D\x0A\x09      BIOS vers 1.0\x0D\x0A\x09"
    DB "Initial device assignment\x0D\x0A\x09"
    DB "  CON:=TTY:  RDR:=TTY:  PUN:=TTY:  LST:=LPT:\x0D\x0A\x09"
    DB "Iobyte Assignment\x0D\x0A\x09"
    DB "  CON:\x09\x09\x09\x09  LST:\x0D\x0A\x09    TTY:  Key Buffer Off\x09"
    DB "    TTY:  No Display\x0D\x0A\x09    CRT:  Serial I/O\x09\x09"
    DB "    CRT:  CRT Display\x0D\x0A\x09    BAT:  Key Buffer Off\x09"
    DB "    LPT:  Parallel Printer\x0D\x0A\x09    UC1:  Key Buffer On\x09\x09"
    DB "    UL1:  Serial Printer\x0D\x0A\x0A\x09 FRANCE KEY BOARD\x0D\x0A\x0A"
    DB "\x1BA\x09\x09Bon jour!\x0D\x0A\x0A\x1BB$"

unreach1:
    DB $31,$00,$CD,$93,$00,$47,$0E,$40,$CD,$DB,$00,$B1,$B0,$C3
    DB $51,$01,$0E,$08,$21,$0A,$06,$CD,$B7,$00,$C2,$DC,$01,$0D
    DB $79,$CD,$93,$00,$47,$0E,$80,$C3,$BE,$01,$0E,$02,$21,$12
    DB $06,$CD,$B7,$00,$C2,$F4,$01,$0C,$0C,$0C,$CD,$DB,$00,$CD
    DB $93,$00,$B1,$C3,$51,$01,$0E,$01,$21,$16,$06,$CD,$B7,$00
    DB $C2,$10,$02,$CD,$DB,$00,$CD,$93,$00,$F6,$06,$CD,$51,$01
    DB $CD,$8C,$00,$C3,$51,$01,$0E,$06,$21,$2E,$06,$CD,$B7,$00
    DB $C2,$36,$02,$79,$FE,$04,$DA,$23,$02,$C6,$05,$47,$CD,$07
    DB $01,$CD,$99,$00,$B0,$CD,$51,$01,$E6,$CF,$FE,$01,$C0,$C3
    DB $A0,$01,$0E,$01,$21,$32,$06,$CD,$B7,$00,$C2,$51,$02,$CD
    DB $8C,$00,$FE,$08,$D2,$18,$05,$CD,$93,$00,$F6,$C7,$C3,$51
    DB $01,$0E,$02,$21,$3E,$06,$CD,$B7,$00,$C2,$71,$02,$0D,$C2
    DB $65,$02,$0E,$C1,$C3,$67,$02,$0E,$C5,$CD,$10,$01,$CD,$99
    DB $00,$B1,$C3,$51,$01,$3A,$7A,$06,$FE,$4A,$C2,$81,$02,$CD
    DB $45,$01,$F6,$02,$C3,$8B,$02,$FE,$43,$C2,$96,$02,$CD,$45
    DB $01,$F6,$04,$CD,$51,$01,$79,$CD,$51,$01,$78,$C3,$51,$01
    DB $FE,$52,$C2,$18,$05,$CD,$1D,$01,$F6,$C0,$C3,$51,$01,$2A
    DB $0E,$00,$D5,$EB,$2A,$0C,$00,$7B,$95,$7A,$9C,$D2,$B7,$02
    DB $2A,$13,$00,$F9,$C9,$D1,$7E,$23,$22,$0C,$00,$C9,$3C,$E6
    DB $07,$FE,$06,$DA,$C8,$02,$C6,$03,$FE,$05,$DA,$CF,$02,$C6
    DB $02,$C6,$41,$4F,$C3,$15,$00,$47,$E6,$F0,$0F,$0F,$0F,$0F
    DB $C6,$90,$27,$CE,$40,$27,$4F,$CD,$15,$00,$78,$E6,$0F,$C6
    DB $90,$27,$CE,$40,$27,$4F,$C3,$15,$00,$06,$04,$4E,$CD,$15
    DB $00,$23,$05,$C2,$F5,$02,$0E,$20,$C3,$15,$00,$7A,$E6,$38
    DB $0F,$0F,$0F,$C9,$CD,$03,$03,$87,$4F,$21,$42,$06,$09,$4E
    DB $CD,$15,$00,$23,$4E,$CD,$15,$00,$0E,$20,$CD,$15,$00,$C3
    DB $15,$00,$CD,$03,$03,$E6,$06,$FE,$06,$C2,$BE,$02,$0E,$53
    DB $CD,$15,$00,$0E,$50,$C3,$15,$00,$CD,$2E,$00,$2A,$0C,$00
    DB $7C,$CD,$D5,$02,$7D,$CD,$D5,$02,$0E,$20,$CD,$15,$00,$CD
    DB $15,$00,$C9,$21,$00,$00,$39,$22,$13,$00,$3A,$10,$00,$B7
    DB $CA,$71,$03,$21,$FF,$FF,$22,$0E,$00,$3C,$C2,$71,$03,$3C
    DB $32,$10,$00,$2A,$0C,$00,$C3,$97,$03,$CD,$9E,$06,$C2,$40
    DB $05,$21,$10,$00,$7E,$B7,$CA,$83,$03,$35,$CA,$40,$05,$2A
    DB $0C,$00,$CD,$A1,$06,$CD,$2E,$00,$0E,$20,$CD,$15,$00,$CD
    DB $15,$00,$CD,$3B,$03,$CD,$A3,$02,$57,$21,$45,$05,$01,$11
    DB $00,$BE,$CA,$FD,$04,$23,$0D,$C2,$A1,$03,$0E,$0A,$BE,$CA
    DB $E9,$04,$23,$0D,$C2,$AC,$03,$0E,$06,$BE,$CA,$CE,$04,$23
    DB $0D,$C2,$B7,$03,$E6,$C0,$FE,$40,$CA,$B4,$04,$FE,$80,$CA
    DB $A5,$04,$7A,$E6,$C7,$D6,$04,$CA,$96,$04,$3D,$CA,$90,$04
    DB $3D,$CA,$7C,$04,$7A,$E6,$C0,$CA,$4A,$04,$7A,$E6,$07,$CA
    DB $3F,$04,$D6,$02,$CA,$34,$04,$D6,$02,$CA,$29,$04,$D6,$03
    DB $CA,$1A,$04,$7A,$E6,$08,$C2,$0B,$05,$7A,$E6,$07,$4F,$3D
    DB $21,$39,$06,$09,$CD,$F3,$02,$CD,$03,$03,$FE,$06,$C2,$9F
    DB $04,$21,$36,$06,$CD,$F3,$02,$C3,$71,$03,$21,$32,$06,$CD
    DB $F3,$02,$CD,$03,$03,$CD,$D5,$02,$C3,$71,$03,$0E,$43,$CD
    DB $15,$00,$CD,$0A,$03,$C3,$D9,$04,$0E,$4A,$CD,$15,$00,$CD
    DB $0A,$03,$C3,$D9,$04,$0E,$52,$CD,$15,$00,$CD,$0A,$03,$C3
    DB $71,$03,$21,$1A,$06,$7A,$E6,$07,$CA,$0B,$05,$7A,$E6,$0F
    DB $3D,$CA,$6E,$04,$FE,$03,$DA,$61,$04,$D6,$05,$87,$87,$4F
    DB $09,$CD,$F3,$02,$CD,$24,$03,$C3,$71,$03,$CD,$F3,$02,$CD
    DB $24,$03,$0E,$2C,$CD,$15,$00,$C3,$D9,$04,$21,$16,$06,$CD
    DB $F3,$02,$CD,$03,$03,$CD,$BE,$02,$0E,$2C,$CD,$15,$00,$C3
    DB $F4,$04,$21,$12,$06,$C3,$99,$04,$21,$0E,$06,$CD,$F3,$02
    DB $CD,$03,$03,$CD,$BE,$02,$C3,$71,$03,$7A,$E6,$38,$0F,$4F
    DB $21,$EE,$05,$09,$CD,$F3,$02,$C3,$C5,$04,$21,$EA,$05,$CD
    DB $F3,$02,$CD,$03,$03,$CD,$BE,$02,$0E,$2C,$CD,$15,$00,$7A
    DB $E6,$07,$CD,$BE,$02,$C3,$71,$03,$79,$87,$87,$4F,$21,$CE
    DB $05,$09,$CD,$F3,$02,$CD,$A3,$02,$F5,$CD,$A3,$02,$57,$F1
    DB $5F,$CD,$95,$06,$C3,$71,$03,$79,$87,$87,$4F,$21,$A6,$05
    DB $09,$CD,$F3,$02,$CD,$A3,$02,$CD,$92,$06,$C3,$71,$03,$79
    DB $87,$87,$4F,$21,$62,$05,$09,$CD,$F3,$02,$C3,$71,$03,$21
    DB $76,$06,$CD,$F3,$02,$7A,$CD,$92,$06,$C3,$71,$03,$CD,$2E
    DB $00,$0E,$3F,$CD,$15,$00,$2A,$13,$00,$F9,$21,$00,$00,$39
    DB $22,$13,$00,$CD,$38,$03,$22,$11,$00,$CD,$89,$06,$CD,$5A
    DB $01,$2A,$11,$00,$22,$0C,$00,$C3,$2B,$05,$2A,$13,$00,$F9
    DB $C9,$00,$07,$0F,$17,$1F,$27,$2F,$37,$3F,$76,$C9,$E3,$E9
    DB $EB,$F3,$F9,$FB,$C6,$CE,$D3,$D6,$DB,$DE,$E6,$EE,$F6,$FE
    DB $22,$2A,$32,$3A,$C3,$CD,$45,$49,$20,$20,$53,$50,$48,$4C
    DB $44,$49,$20,$20,$58,$43,$48,$47,$50,$43,$48,$4C,$58,$54
    DB $48,$4C,$52,$45,$54,$20,$48,$4C,$54,$20,$43,$4D,$43,$20
    DB $53,$54,$43,$20,$43,$4D,$41,$20,$44,$41,$41,$20,$52,$41
    DB $52,$20,$52,$41,$4C,$20,$52,$52,$43,$20,$52,$4C,$43,$20
    DB $4E,$4F,$50,$20,$43,$50,$49,$20,$4F,$52,$49,$20,$58,$52
    DB $49,$20,$41,$4E,$49,$20,$53,$42,$49,$20,$49,$4E,$20,$20
    DB $53,$55,$49,$20,$4F,$55,$54,$20,$41,$43,$49,$20,$41,$44
    DB $49,$20,$43,$41,$4C,$4C,$4A,$4D,$50,$20,$4C,$44,$41,$20
    DB $53,$54,$41,$20,$4C,$48,$4C,$44,$53,$48,$4C,$44,$4D,$4F
    DB $56,$20,$41,$44,$44,$20,$41,$44,$43,$20,$53,$55,$42,$20
    DB $53,$42,$42,$20,$41,$4E,$41,$20,$58,$52,$41,$20,$4F,$52
    DB $41,$20,$43,$4D,$50,$20,$49,$4E,$52,$20,$44,$43,$52,$20
    DB $4D,$56,$49,$20,$4C,$58,$49,$20,$53,$54,$41,$58,$49,$4E
    DB $58,$20,$44,$41,$44,$20,$4C,$44,$41,$58,$44,$43,$58,$20
    DB $52,$53,$54,$20,$50,$53,$57,$20,$50,$4F,$50,$20,$50,$55
    DB $53,$48,$4E,$5A,$5A,$20,$4E,$43,$43,$20,$50,$4F,$50,$45
    DB $50,$20,$4D,$20,$42,$20,$43,$20,$44,$20,$45,$20,$48,$20
    DB $4C,$20,$4D,$20,$41,$20,$42,$20,$20,$20,$44,$20,$20,$20
    DB $48,$20,$20,$20,$53,$50,$20,$20,$50,$53,$57,$20,$3F,$3F
    DB $3D,$20,$1E,$4D,$06,$00,$21,$45,$C3,$A2,$06,$C3,$AA,$06
    DB $C3,$CF,$0D,$C3,$B6,$0B,$C3,$DD,$0B,$C3,$C7,$0B,$C3,$05
    DB $0C,$C3,$2D,$0C,$C3,$90,$0C,$C3,$66,$0C,$C3,$1F,$0C,$C9
    DB $E3,$22,$4A,$0F,$E3,$C3,$00,$00,$2A,$06,$00,$22,$A8,$06
    DB $21,$A2,$06,$22,$01,$00,$21,$00,$00,$22,$06,$00,$AF,$32
    DB $4F,$0F,$21,$00,$01,$22,$0C,$00,$22,$5D,$0F,$22,$87,$0F
    DB $22,$B9,$0F,$21,$00,$01,$31,$B7,$0F,$E5,$21,$02,$00,$E5
    DB $2B,$2B,$22,$B7,$0F,$E5,$E5,$22,$4D,$0F,$3E,$C3,$32,$38
    DB $00,$21,$86,$06,$22,$39,$00,$3A,$5D,$00,$FE,$20,$CA,$FE
    DB $06,$21,$00,$00,$E5,$C3,$AD,$09,$31,$AF,$0F,$CD,$93,$09
    DB $DA,$0D,$07,$21,$80,$06,$22,$06,$00,$CD,$15,$0C,$3E,$2D
    DB $CD,$C7,$0B,$CD,$B6,$0B,$CD,$DD,$0B,$FE,$0D,$CA,$FE,$06
    DB $D6,$41,$DA,$AB,$0B,$FE,$1A,$D2,$AB,$0B,$5F,$16,$00,$21
    DB $37,$07,$19,$19,$5E,$23,$56,$EB,$E9,$7E,$07,$AB,$0B,$AB
    DB $0B,$C6,$07,$AB,$0B,$5C,$08,$70,$08,$DA,$08,$04,$09,$AB
    DB $0B,$AB,$0B,$97,$07,$5A,$09,$AB,$0B,$AB,$0B,$AB,$0B,$AB
    DB $0B,$9C,$09,$7A,$0A,$C3,$0A,$BF,$0A,$AB,$0B,$AB,$0B,$E7
    DB $0A,$AB,$0B,$AB,$0B,$E5,$D5,$C5,$AF,$32,$5B,$00,$0E,$0F
    DB $11,$5C,$00,$CD,$A2,$06,$C1,$D1,$E1,$C9,$CD,$93,$09,$D2
    DB $AB,$0B,$CD,$90,$0C,$3D,$C2,$AB,$0B,$CD,$66,$0C,$22,$0C
    DB $00,$CD,$09,$00,$C3,$FE,$06,$CD,$93,$09,$D2,$AB,$0B,$CD
    DB $90,$0C,$CA,$BB,$07,$CD,$66,$0C,$22,$0C,$00,$3D,$CA,$BB
    DB $07,$CD,$66,$0C,$22,$0E,$00,$3D,$C2,$AB,$0B,$AF,$C3,$BD
    DB $07,$3E,$0C,$32,$10,$00,$CD,$06,$00,$C3,$FE,$06,$CD,$90
    DB $0C,$CA,$E5,$07,$CD,$66,$0C,$DA,$D5,$07,$22,$5D,$0F,$E6
    DB $7F,$3D,$CA,$E5,$07,$CD,$66,$0C,$3D,$C2,$AB,$0B,$C3,$F0
    DB $07,$2A,$5D,$0F,$7D,$E6,$F0,$6F,$11,$BF,$00,$19,$22,$5F
    DB $0F,$CD,$15,$0C,$CD,$1F,$0C,$C2,$FE,$06,$2A,$5D,$0F,$22
    DB $61,$0F,$CD,$2E,$0C,$CD,$C5,$0B,$7E,$CD,$05,$0C,$23,$CD
    DB $45,$0C,$DA,$19,$08,$7D,$E6,$0F,$C2,$05,$08,$22,$5D,$0F
    DB $2A,$61,$0F,$EB,$CD,$C5,$0B,$1A,$CD,$36,$0C,$13,$2A,$5D
    DB $0F,$7D,$93,$C2,$23,$08,$7C,$92,$C2,$23,$08,$2A,$5D,$0F
    DB $CD,$45,$0C,$DA,$FE,$06,$C3,$F3,$07,$CD,$90,$0C,$FE,$03
    DB $C2,$AB,$0B,$CD,$66,$0C,$E5,$CD,$66,$0C,$E5,$CD,$66,$0C
    DB $D1,$C1,$C9,$7B,$91,$7A,$98,$C9,$CD,$41,$08,$7C,$B7,$C2
    DB $AB,$0B,$CD,$57,$08,$DA,$FE,$06,$7D,$02,$03,$C3,$64,$08
    DB $CD,$15,$0C,$CD,$90,$0C,$CD,$66,$0C,$E5,$CD,$66,$0C,$E5
    DB $CD,$66,$0C,$44,$4D,$D1,$E1,$F3,$CA,$A1,$08,$DA,$8F,$08
    DB $22,$B9,$0F,$E6,$7F,$3D,$CA,$A1,$08,$CD,$B2,$08,$3D,$CA
    DB $A1,$08,$59,$50,$CD,$B2,$08,$31,$AF,$0F,$D1,$C1,$F1,$E1
    DB $F9,$2A,$B9,$0F,$E5,$2A,$B7,$0F,$FB,$C9,$F5,$C5,$21,$4F
    DB $0F,$7E,$34,$B7,$CA,$CD,$08,$23,$7E,$23,$46,$23,$BB,$C2
    DB $CD,$08,$78,$BA,$C2,$CD,$08,$7E,$12,$23,$73,$23,$72,$23
    DB $1A,$77,$3E,$FF,$12,$C1,$F1,$C9,$CD,$90,$0C,$FE,$02,$C2
    DB $AB,$0B,$CD,$66,$0C,$E5,$CD,$66,$0C,$D1,$E5,$CD,$15,$0C
    DB $19,$CD,$2E,$0C,$CD,$C5,$0B,$E1,$AF,$95,$6F,$3E,$00,$9C
    DB $67,$19,$CD,$2E,$0C,$C3,$FE,$06,$AF,$32,$7C,$00,$32,$5C
    DB $00,$CD,$DD,$0B,$0E,$09,$21,$5D,$00,$77,$23,$0D,$CA,$AB
    DB $0B,$CD,$DD,$0B,$FE,$2E,$CA,$26,$09,$FE,$0D,$C2,$13,$09
    DB $0D,$CA,$30,$09,$36,$20,$23,$C3,$26,$09,$0E,$04,$FE,$2E
    DB $C2,$4B,$09,$21,$65,$00,$CD,$DD,$0B,$FE,$0D,$CA,$4B,$09
    DB $77,$23,$0D,$CA,$AB,$0B,$C3,$3A,$09,$0D,$CA,$55,$09,$36
    DB $20,$23,$C3,$4B,$09,$36,$00,$C3,$FE,$06,$CD,$41,$08,$CD
    DB $57,$08,$DA,$FE,$06,$0A,$03,$77,$23,$C3,$5D,$09,$21,$65
    DB $00,$7E,$E6,$7F,$FE,$48,$C0,$23,$7E,$E6,$7F,$FE,$45,$C0
    DB $23,$7E,$E6,$7F,$FE,$58,$C9,$EB,$2A,$87,$0F,$7D,$93,$7C
    DB $9A,$EB,$C9,$CD,$81,$09,$D0,$22,$87,$0F,$C9,$E5,$21,$00
    DB $00,$CD,$81,$09,$E1,$C9,$CD,$90,$0C,$21,$00,$00,$CA,$AC
    DB $09,$3D,$C2,$AB,$0B,$CD,$66,$0C,$E5,$CD,$6B,$07,$FE,$FF
    DB $CA,$AB,$0B,$CD,$6A,$09,$CA,$E1,$09,$E1,$11,$00,$01,$19
    DB $E5,$11,$5C,$00,$0E,$14,$CD,$A2,$06,$E1,$B7,$C2,$46,$0A
    DB $11,$80,$00,$0E,$80,$1A,$13,$77,$23,$0D,$C2,$D3,$09,$CD
    DB $8B,$09,$C3,$C0,$09,$CD,$74,$0B,$FE,$1A,$CA,$AB,$0B,$DE
    DB $3A,$C2,$E1,$09,$57,$E1,$E5,$CD,$26,$0A,$5F,$CD,$26,$0A
    DB $F5,$CD,$26,$0A,$C1,$4F,$09,$7B,$B7,$C2,$0C,$0A,$60,$69
    DB $22,$B9,$0F,$C3,$46,$0A,$CD,$26,$0A,$CD,$26,$0A,$77,$23
    DB $1D,$C2,$0F,$0A,$CD,$26,$0A,$F5,$CD,$8B,$09,$F1,$C2,$AB
    DB $0B,$C3,$E1,$09,$C5,$E5,$D5,$CD,$74,$0B,$CD,$59,$0C,$07
    DB $07,$07,$07,$E6,$F0,$F5,$CD,$74,$0B,$CD,$59,$0C,$C1,$B0
    DB $47,$D1,$82,$57,$78,$E1,$C1,$C9,$0E,$0C,$CD,$A2,$06,$21
    DB $6F,$0A,$7E,$B7,$CA,$5A,$0A,$CD,$C7,$0B,$23,$C3,$4E,$0A
    DB $CD,$15,$0C,$2A,$87,$0F,$CD,$2E,$0C,$CD,$C5,$0B,$2A,$B9
    DB $0F,$CD,$2E,$0C,$C3,$FE,$06,$0D,$0A,$4E,$45,$58,$54,$20
    DB $20,$50,$43,$00,$CD,$90,$0C,$3D,$C2,$AB,$0B,$CD,$66,$0C
    DB $CD,$15,$0C,$E5,$CD,$2E,$0C,$CD,$C5,$0B,$E1,$7E,$E5,$CD
    DB $05,$0C,$CD,$C5,$0B,$CD,$B6,$0B,$CD,$DD,$0B,$E1,$FE,$0D
    DB $CA,$BB,$0A,$FE,$2E,$CA,$FE,$06,$E5,$CD,$93,$0C,$3D,$C2
    DB $AB,$0B,$CD,$66,$0C,$7C,$B7,$C2,$AB,$0B,$7D,$E1,$77,$23
    DB $C3,$84,$0A,$AF,$C3,$C5,$0A,$3E,$FF,$32,$4C,$0F,$CD,$90
    DB $0C,$21,$00,$00,$CA,$DE,$0A,$3D,$C2,$AB,$0B,$CD,$66,$0C
    DB $7D,$B4,$CA,$AB,$0B,$2B,$22,$4D,$0F,$CD,$44,$0D,$C3,$85
    DB $08,$CD,$DD,$0B,$FE,$0D,$C2,$F5,$0A,$CD,$44,$0D,$C3,$FE
    DB $06,$01,$0B,$00,$21,$B3,$0D,$BE,$CA,$08,$0B,$23,$04,$0D
    DB $C2,$FB,$0A,$C3,$AB,$0B,$CD,$DD,$0B,$FE,$0D,$C2,$AB,$0B
    DB $C5,$CD,$15,$0C,$CD,$1A,$0D,$CD,$C5,$0B,$CD,$B6,$0B,$CD
    DB $90,$0C,$B7,$CA,$FE,$06,$3D,$C2,$AB,$0B,$CD,$66,$0C,$C1
    DB $78,$FE,$05,$D2,$59,$0B,$7C,$B7,$C2,$AB,$0B,$7D,$FE,$02
    DB $D2,$AB,$0B,$CD,$E3,$0C,$67,$41,$3E,$FE,$CD,$53,$0B,$A4
    DB $41,$67,$7D,$CD,$53,$0B,$B4,$12,$C3,$FE,$06,$05,$C8,$07
    DB $C3,$53,$0B,$C2,$69,$0B,$7C,$B7,$C2,$AB,$0B,$7D,$21,$B4
    DB $0F,$77,$C3,$FE,$06,$E5,$CD,$01,$0D,$D1,$73,$23,$72,$C3
    DB $FE,$06,$E5,$D5,$C5,$3A,$5B,$00,$E6,$7F,$CA,$94,$0B,$16
    DB $00,$5F,$21,$80,$00,$19,$7E,$FE,$1A,$CA,$A6,$0B,$21,$5B
    DB $00,$34,$B7,$C3,$A7,$0B,$0E,$14,$11,$5C,$00,$CD,$A2,$06
    DB $B7,$C2,$A6,$0B,$32,$5B,$00,$C3,$7F,$0B,$37,$C1,$D1,$E1
    DB $C9,$CD,$15,$0C,$3E,$3F,$CD,$C7,$0B,$C3,$FE,$06,$0E,$0A
    DB $11,$65,$0F,$CD,$A2,$06,$21,$67,$0F,$22,$63,$0F,$C9,$3E
    DB $20,$E5,$D5,$C5,$5F,$0E,$02,$CD,$A2,$06,$C1,$D1,$E1,$C9
    DB $FE,$7F,$C8,$FE,$61,$D8,$E6,$5F,$C9,$E5,$21,$66,$0F,$7E
    DB $B7,$3E,$0D,$CA,$F4,$0B,$35,$2A,$63,$0F,$7E,$23,$22,$63
    DB $0F,$CD,$D4,$0B,$E1,$C9,$FE,$0A,$D2,$00,$0C,$C6,$30,$C3
    DB $C7,$0B,$C6,$37,$C3,$C7,$0B,$F5,$1F,$1F,$1F,$1F,$E6,$0F
    DB $CD,$F6,$0B,$F1,$E6,$0F,$C3,$F6,$0B,$3E,$0D,$CD,$C7,$0B
    DB $3E,$0A,$C3,$C7,$0B,$C5,$D5,$E5,$0E,$0B,$CD,$A2,$06,$E6
    DB $01,$E1,$D1,$C1,$C9,$EB,$7C,$CD,$05,$0C,$7D,$C3,$05,$0C
    DB $FE,$7F,$D2,$40,$0C,$FE,$20,$D2,$C7,$0B,$3E,$2E,$C3,$C7
    DB $0B,$EB,$2A,$5F,$0F,$7D,$93,$6F,$7C,$9A,$EB,$C9,$FE,$0D
    DB $C8,$FE,$2C,$C8,$FE,$20,$C9,$D6,$30,$FE,$0A,$D8,$C6,$F9
    DB $FE,$10,$D8,$C3,$AB,$0B,$EB,$5E,$23,$56,$23,$EB,$C9,$EB
    DB $21,$00,$00,$CD,$59,$0C,$29,$29,$29,$29,$B5,$6F,$CD,$DD
    DB $0B,$CD,$50,$0C,$C2,$71,$0C,$EB,$C9,$73,$23,$72,$23,$E5
    DB $21,$56,$0F,$34,$E1,$C9,$CD,$DD,$0B,$21,$56,$0F,$36,$00
    DB $23,$FE,$0D,$CA,$D5,$0C,$FE,$2C,$C2,$AE,$0C,$3E,$80,$32
    DB $56,$0F,$11,$00,$00,$C3,$B1,$0C,$CD,$6D,$0C,$CD,$85,$0C
    DB $FE,$0D,$CA,$D5,$0C,$CD,$DD,$0B,$CD,$6D,$0C,$CD,$85,$0C
    DB $FE,$0D,$CA,$D5,$0C,$CD,$DD,$0B,$CD,$6D,$0C,$CD,$85,$0C
    DB $FE,$0D,$C2,$AB,$0B,$11,$56,$0F,$1A,$FE,$81,$CA,$AB,$0B
    DB $13,$B7,$07,$0F,$C9,$E5,$21,$C3,$0D,$58,$16,$00,$19,$4E
    DB $21,$B3,$0F,$7E,$EB,$E1,$C9,$CD,$E3,$0C,$0D,$CA,$FE,$0C
    DB $1F,$C3,$F6,$0C,$E6,$01,$C9,$D6,$06,$21,$BE,$0D,$5F,$16
    DB $00,$19,$5E,$16,$FF,$21,$BB,$0F,$19,$C9,$CD,$01,$0D,$5E
    DB $23,$56,$EB,$C9,$7E,$CD,$C7,$0B,$78,$FE,$05,$D2,$2B,$0D
    DB $CD,$F3,$0C,$CD,$F6,$0B,$C9,$F5,$3E,$3D,$CD,$C7,$0B,$F1
    DB $C2,$3D,$0D,$21,$B4,$0F,$7E,$CD,$05,$0C,$C9,$CD,$12,$0D
    DB $CD,$2E,$0C,$C9,$21,$B3,$0D,$06,$00,$CD,$15,$0C,$C5,$E5
    DB $CD,$1A,$0D,$E1,$C1,$04,$23,$78,$FE,$0B,$D2,$66,$0D,$FE
    DB $05,$DA,$4C,$0D,$CD,$C5,$0B,$C3,$4C,$0D,$CD,$C5,$0B,$CD
    DB $85,$0E,$F5,$D5,$C5,$CD,$93,$09,$D2,$86,$0D,$2A,$B9,$0F
    DB $22,$0C,$00,$21,$10,$00,$36,$FF,$CD,$06,$00,$C3,$AF,$0D
    DB $2B,$22,$5F,$0F,$2A,$B9,$0F,$7E,$CD,$05,$0C,$23,$CD,$45
    DB $0C,$DA,$AF,$0D,$F5,$CD,$C5,$0B,$F1,$B3,$CA,$AB,$0D,$5E
    DB $23,$56,$EB,$CD,$2E,$0C,$C3,$AF,$0D,$7E,$CD,$05,$0C,$C1
    DB $D1,$F1,$C9,$43,$5A,$4D,$45,$49,$41,$42,$44,$48,$53,$50
    DB $F6,$F4,$FC,$FA,$FE,$01,$07,$08,$03,$05,$21,$00,$00,$22
    DB $4D,$0F,$C9,$F3,$22,$B7,$0F,$E1,$2B,$22,$B9,$0F,$F5,$21
    DB $02,$00,$39,$F1,$31,$B7,$0F,$E5,$F5,$C5,$D5,$2A,$B9,$0F
    DB $7E,$FE,$FF,$F5,$E5,$21,$4F,$0F,$7E,$36,$00,$B7,$CA,$04
    DB $0E,$3D,$47,$23,$5E,$23,$56,$23,$7E,$12,$78,$C3,$F3,$0D
    DB $E1,$F1,$CA,$28,$0E,$23,$22,$B9,$0F,$EB,$21,$A8,$06,$4E
    DB $23,$46,$CD,$57,$08,$DA,$28,$0E,$CD,$C8,$0D,$2A,$4A,$0F
    DB $EB,$3E,$82,$B7,$37,$C3,$85,$08,$FB,$2A,$4D,$0F,$7C,$B5
    DB $CA,$4E,$0E,$2B,$22,$4D,$0F,$CD,$1F,$0C,$C2,$4E,$0E,$3A
    DB $4C,$0F,$B7,$C2,$48,$0E,$CD,$85,$0E,$C3,$85,$08,$CD,$44
    DB $0D,$C3,$85,$08,$CD,$C8,$0D,$3E,$2A,$CD,$C7,$0B,$2A,$B9
    DB $0F,$CD,$93,$09,$D2,$62,$0E,$22,$0C,$00,$CD,$2E,$0C,$2A
    DB $B7,$0F,$22,$5D,$0F,$C3,$FE,$06,$11,$0D,$00,$21,$2F,$0F
    DB $7E,$A0,$23,$BE,$23,$CA,$81,$0E,$14,$1D,$C2,$74,$0E,$5A
    DB $16,$00,$C9,$2A,$B9,$0F,$46,$23,$E5,$CD,$6E,$0E,$21,$49
    DB $0F,$73,$21,$9C,$0E,$19,$19,$5E,$23,$56,$EB,$E9,$B8,$0E
    DB $E0,$0E,$B8,$0E,$E0,$0E,$BE,$0E,$F2,$0E,$04,$0F,$26,$0F
    DB $26,$0F,$23,$0F,$23,$0F,$19,$0F,$26,$0F,$14,$0F,$CD,$CE
    DB $0E,$C2,$29,$0F,$CD,$D9,$0E,$C3,$29,$0F,$3A,$A8,$06,$BB
    DB $C0,$3A,$A9,$06,$BA,$C9,$C1,$E1,$5E,$23,$56,$23,$E5,$C5
    DB $C3,$C4,$0E,$2A,$B5,$0F,$5E,$23,$56,$C9,$CD,$CE,$0E,$CA
    DB $ED,$0E,$C1,$C5,$3E,$02,$C3,$2B,$0F,$D1,$D5,$C3,$29,$0F
    DB $78,$FE,$FF,$C2,$FC,$0E,$AF,$C3,$2D,$0F,$E6,$38,$5F,$16
    DB $00,$C3,$29,$0F,$2A,$B7,$0F,$EB,$CD,$C4,$0E,$C2,$29,$0F
    DB $C3,$BE,$0E,$C3,$29,$0F,$D1,$D5,$C3,$29,$0F,$CD,$D9,$0E
    DB $C1,$C5,$3E,$02,$C3,$2B,$0F,$D1,$13,$D5,$D1,$13,$D5,$3E
    DB $01,$3C,$37,$E1,$C9,$FF,$C3,$C7,$C2,$FF,$CD,$C7,$C4,$FF
    DB $C9,$C7,$C7,$FF,$E9,$C7,$06,$C7,$C6,$CF,$01,$E7,$22,$C7
    DB $C0,$F7,$D3,$03,$CD,$39,$08,$CD,$2E,$08,$CD,$13,$08,$FE
    DB $1A,$C2,$59,$18,$C9,$C3,$DB,$17,$C9,$01,$8F,$03,$CD,$AF
    DB $09,$C9,$2A,$20,$1D,$4D,$CD,$5E,$08,$11,$9E,$03,$01,$E1
    DB $1D,$CD,$FD,$15,$32,$B6,$1D,$01,$E1,$1D,$C5,$1E,$03,$01
    DB $55,$1F,$CD,$18,$0A,$3A,$E1,$1D,$E6,$7F,$32,$E1,$1D,$3A
    DB $E2,$1D,$E6,$7F,$32,$E2,$1D,$01,$A2,$03,$CD,$EA,$15,$01
    DB $D8,$1D,$CD,$B3,$08,$01,$D8,$1D,$CD,$E3,$08,$3A,$5F,$1E
    DB $FE,$FF,$C2,$B3,$18,$01,$A5,$03,$CD,$AF,$09,$21,$F8,$1D
    DB $36,$00,$21,$00,$00,$00,$20,$90,$00,$40,$00,$08,$21,$10
    DB $92,$10,$21,$12,$42,$48,$00,$09,$10,$02,$40,$00,$10,$40
    DB $08,$08,$41,$02,$00,$82,$42,$48,$09,$09,$20,$42,$21,$01
    DB $20,$08,$22,$12,$11,$10,$10,$88,$42,$48,$49,$24,$24,$92
    DB $42,$49,$24,$42,$49,$20,$84,$24,$84,$10,$92,$09,$10,$92
    DB $48,$49,$09,$20,$82,$44,$04,$24,$90,$90,$84,$91,$08,$48
    DB $90,$90,$84,$84,$44,$24,$24,$20,$48,$08,$04,$08,$08,$00
    DB $04,$00,$20,$84,$20,$08,$42,$10,$92,$04,$21,$24,$44,$24
    DB $04,$88,$22,$24,$92,$42,$24,$90,$92,$44,$08,$41,$08,$21
    DB $02,$10,$11,$10,$41,$08,$42,$08,$08,$90,$92,$49,$24,$84
    DB $90,$92,$12,$48,$20,$42,$01,$24,$90,$92,$49,$09,$24,$92
    DB $48,$08,$92,$49,$08,$24,$08,$91,$04,$81,$12,$48,$11,$24
    DB $89,$21,$20,$24,$92,$49,$20,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$24,$92,$49,$24,$84,$01,$24,$81,$04,$92
    DB $08,$02,$10,$10,$02,$04,$92,$41,$09,$21,$08,$41,$00,$AA
    DB $AA,$AA,$AA,$AA,$AA,$A0,$00,$40,$92,$24,$92,$49,$24,$89
    DB $22,$21,$24,$92,$48,$24,$49,$00,$24,$92,$49,$11,$20,$92
    DB $22,$21,$09,$24,$90,$91,$10,$02,$12,$41,$24,$88,$80,$92
    DB $09,$10,$90,$11,$02,$08,$04,$20,$00,$08,$48,$84,$48,$00
    DB $90,$04,$00,$90,$84,$41,$02,$08,$41,$22,$08,$49,$20,$40
    DB $00,$00,$08,$04,$42,$42,$08,$91,$09,$20,$00,$84,$00,$24
    DB $90,$84,$11,$10,$10,$92,$41,$22,$24,$12,$00,$90,$00,$24
    DB $24,$49,$24,$92,$00,$08,$92,$24,$12,$48,$21,$11,$21,$02
    DB $21,$20,$89,$08,$92,$42,$48,$22,$09,$21,$12,$49,$11,$20
    DB $42,$09,$02,$04,$20,$90,$88,$88,$10,$02,$00,$10,$10,$11
    DB $04,$04,$24,$24,$90,$01,$00,$00,$81,$10,$90,$21,$08,$02
    DB $08,$42,$02,$00,$44,$21,$08,$80,$00,$00,$04,$00,$10,$09
    DB $20,$08,$24,$04,$21,$04,$90,$92,$42,$49,$09,$04,$02,$02
    DB $04,$44,$04,$01,$08,$04,$12,$40,$89,$11,$22,$10,$80,$21
    DB $24,$90,$49,$24,$24,$48,$89,$10,$81,$22,$00,$00,$00,$04
    DB $21,$00,$81,$01,$02,$00,$10,$88,$82,$49,$01,$10,$89,$24
    DB $49,$24,$84,$92,$49,$24,$10,$10,$81,$04,$88,$05,$55,$55
    DB $55,$24,$92,$10,$00,$90,$24,$08,$41,$10,$12,$24,$90,$90
    DB $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00
    DB $00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02
    DB $00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$22,$48,$40
    DB $02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00
    DB $00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02
    DB $00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00
    DB $02,$00,$00,$22,$48,$42,$02,$00,$00,$02,$00,$00,$02,$00
    DB $00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$08
    DB $48,$69,$08,$6F,$48,$0E,$48,$00,$02,$00,$00,$02,$00,$00
    DB $02,$00,$00,$02,$00,$00,$02,$00,$00,$22,$48,$48,$08,$48
    DB $6F,$12,$48,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02
    DB $00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00
    DB $0F,$6B,$00,$13,$6B,$00,$08,$6D,$68,$02,$00,$00,$02,$00
    DB $00,$22,$48,$46,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02
    DB $00,$00,$02,$00,$00,$02,$00,$00,$AA,$20,$60,$A6,$60,$20
    DB $2E,$44,$40,$08,$6F,$40,$8E,$00,$00,$92,$00,$00,$D2,$30
    DB $00,$0A,$39,$27,$AA,$21,$60,$A6,$60,$21,$26,$44,$40,$08
    DB $40,$6F,$02,$00,$00,$96,$00,$00,$02,$00,$00,$0A,$3A,$27
    DB $AA,$22,$60,$A6,$60,$22,$2E,$44,$42,$08,$6F,$42,$02,$00
    DB $00,$02,$00,$00,$D2,$31,$00,$0A,$27,$39,$AA,$23,$60,$A6
    DB $60,$23,$26,$44,$42,$08,$42,$6F,$02,$00,$00,$02,$00,$00
    DB $D2,$32,$00,$0A,$27,$3A,$AA,$24,$60,$A6,$60,$24,$2E,$44
    DB $44,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$9A
    DB $00,$00,$AA,$25,$60,$A6,$60,$25,$26,$44,$44,$02,$00,$00
    DB $02,$00,$00,$02,$00,$00,$02,$00,$00,$9E,$00,$00,$AA,$26
    DB $60,$A6,$60,$26,$2E,$44,$46,$08,$6F,$46,$02,$00,$00,$02
    DB $00,$00,$02,$00,$00,$02,$00,$00,$AA,$27,$60,$A6,$60,$27
    DB $26,$44,$46,$08,$46,$6F,$02,$00,$00,$02,$00,$00,$02,$00
    DB $00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02
    DB $00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00
    DB $02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00
    DB $00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02
    DB $00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00
    DB $02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00
    DB $00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$02
    DB $00,$00,$E0,$00,$00,$E1,$00,$00,$E2,$00,$00,$E3,$00,$00
    DB $02,$00,$00,$02,$00,$00,$02,$00,$00,$02,$00,$00,$E4,$00
    DB $00,$E5,$00,$00,$E6,$00,$C3,$00,$00,$C3,$00,$00,$C3,$00
    DB $00,$C3,$00,$00,$C3,$00,$00,$C3,$00,$00,$C3,$00,$00,$C3
    DB $00,$00,$C3,$00,$00,$C3,$00,$00,$C3,$00,$00

    ; This strange string is inside this unreachable blob
    ; kept here, with its address, just for reference
    ; strange_str:                          ;[0768]
    ; DB "  SPHLDI  XCHGPCHLXTHLRET HLT CMC STC CMA DAA RAR RAL"
    ; DB " RRC RLC NOP CPI ORI XRI ANI SBI IN  SUI OUT ACI ADI "
    ; DB "CALLJMP LDA STA LHLDSHLDMOV ADD ADC SUB SBB ANA XRA O"
    ; DB "RA CMP INR DCR MVI LXI STAXINX DAD LDAXDCX RST PSW PO"
    ; DB "P PUSHNZZ NCC POPEP M B C D E H L M A B   D   H   SP "
    ; DB " PSW "

    ;; The following code will be relocated to $b821
relocated_area:                             ;[1621]
    REPT 640
    nop
    ENDR

                                            ;[18a1] d0
    DB $D0,$5C,$00,$D1,$7E,$00,$D2,$7B,$00,$D3,$7D,$00,$D4,$40
    DB $00,$D5,$7C,$00,$D6,$7E,$61,$D7,$7E,$65,$D8,$7E,$69,$D9
    DB $7E,$6F,$DA,$7E,$75,$DB,$5E,$61,$DC,$5E,$65,$DD,$5E,$69
    DB $DE,$5E,$6F,$DF,$5E,$75,$E0,$5B,$00,$E1,$5C,$00,$E2,$5D
    DB $00,$00,$61,$DB,$D6,$65,$DC,$D7,$69,$DD,$D8,$6F,$DE,$D9
    DB $75,$DF,$DA,$00,$00,$79,$FE,$F1,$28,$08,$FE,$F2,$20,$0B
    DB $3E,$02,$18,$02,$3E,$01,$32,$EB,$BA,$37,$C9,$3A,$EB,$BA
    DB $B7,$28,$12,$21,$DB,$BA,$06,$05,$7E,$B9,$28,$0A,$23,$23
    DB $23,$10,$F7,$AF,$32,$EB,$BA,$C9,$3A,$EB,$BA,$06,$00,$4F
    DB $09,$4E,$18,$F1,$C3,$26,$BB,$79,$CB,$7F,$C8,$21,$A1,$BA
    DB $7E,$B7,$C8,$B9,$23,$28,$04,$23,$23,$18,$F5,$4E,$23,$22
    DB $5B,$BB,$7E,$B7,$C8,$79,$11,$46,$BB,$18,$0F,$3E,$08,$11
    DB $4D,$BB,$18,$08,$2A,$5B,$BB,$4E,$AF,$11,$26,$BB,$ED,$53
    DB $24,$BB,$B7,$C9,$00,$00,$C9
                                            ;[195e]
    REPT 1164
    nop
    ENDR

    DB "TT"                                 ;[1dea]
    DB 00
    DB 00
    DB 00
    DB 00
    DB 00
    DB 00
                                            ;[1df2]
    DB $21,$b8,$00
    DB $00
    DB $ec,$ba,$23
    DB $bb
    DB $5d
    DB $bb

    DB "8.10"                               ;[1dfc]
    ;;  - - - - Relocated code ends here - - - -

kbdlayout:                                  ;[1e00]
    DB $00,$1b,$24,$2a,$d2,$22,$27,$28,$29,$d3,$5f,$d0,$d4,$21,$3f,$7f
    DB $5c,$03,$09,$61,$7a,$65,$72,$74,$79,$75,$69,$6f,$70,$26,$f1,$5d
    DB $71,$73,$64,$66,$67,$68,$6a,$6b,$6c,$6d,$d5,$0d,$5b,$18,$77,$78
    DB $63,$76,$62,$6e,$2c,$3b,$3a,$3d,$0a,$20,$0b,$0a,$08,$0c,$37,$38
    DB $39,$15,$34,$35,$36,$2d,$31,$32,$33,$2e,$30,$00,$0d,$00,$80,$81
    DB $82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$1b,$3c,$31,$32,$33,$34,$35,$36,$37,$38,$39,$30,$23,$40,$7f
    DB $5e,$03,$09,$41,$5a,$45,$52,$54,$59,$55,$49,$4f,$50,$3e,$f2,$7d
    DB $51,$53,$44,$46,$47,$48,$4a,$4b,$4c,$4d,$25,$0d,$7b,$18,$57,$58
    DB $43,$56,$42,$4e,$2f,$2e,$2d,$2b,$0a,$20,$0b,$0a,$08,$0c,$37,$38
    DB $39,$05,$34,$35,$36,$2d,$31,$32,$33,$2e,$30,$00,$0d,$00,$80,$81
    DB $82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$1b,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$00,$00,$00,$00,$7f
    DB $1c,$03,$09,$01,$1a,$05,$12,$14,$19,$15,$09,$0f,$10,$00,$1e,$1d
    DB $11,$13,$04,$06,$07,$08,$0a,$0b,$0c,$0d,$00,$0d,$1b,$18,$17,$18
    DB $03,$16,$02,$0e,$00,$00,$00,$00,$0a,$20,$0b,$0a,$08,$0c,$37,$38
    DB $39,$15,$34,$35,$36,$2d,$31,$32,$33,$2e,$30,$00,$0d,$00,$80,$81
    DB $82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00


    ; This is a piece of a system ROM copied from $c180 to
    ; $1f80. It is not exactly the same ROM we have in our Sanco
    ; 8003, but the code structure matches.
    ; Here, is just filled with DB since it has no meaning in
    ; this code.
romjunk0:
    DB $EB,$CD,$49,$C4,$18,$F5,$E3,$C9,$C5,$D5,$E5,$32,$B8,$FF
    DB $3E,$0A,$32,$BF,$FF,$ED,$43,$B9,$FF,$ED,$53,$BB,$FF,$22
    DB $BD,$FF,$CD,$0E,$C4,$3A,$BA,$FF,$E6,$F0,$CA,$D1,$C1,$FE
    DB $40,$CA,$C7,$C1,$FE,$80,$CA,$C2,$C1,$FE,$20,$CA,$CC,$C1
    DB $FE,$F0,$CA,$D6,$C1,$3E,$FF,$C3,$DB,$C1,$CD,$DF,$C1,$18
    DB $14,$CD,$35,$C2,$18,$0F,$CD,$94,$C3,$18,$0A,$CD,$7C,$C3
    DB $18,$05,$CD,$CE,$C2,$18,$00,$E1,$D1,$C1,$C9,$CD,$94,$C3
    DB $CD,$A2,$C2,$D5,$CD,$07,$C4,$0E,$C5,$3A,$B8,$FF,$B7,$20
    DB $02,$CB,$B1,$CD,$00,$C4,$F3,$CD,$39,$C3,$D1,$0E,$C1,$43
    DB $2A,$BD,$FF,$DB,$82,$CB,$57,$28,$FA,$DB,$C0,$CB,$6F,$28
    DB $07,$ED,$A3,$20,$F0,$15,$20,$ED,$D3,$DC,$FB,$CD,$DF,$C3
    DB $3A,$C0,$FF,$E6,$C0,$FE,$40,$20,$10,$CD,$8B,$C2,$3A,$BF
    DB $FF,$3D,$32,$BF,$FF,$C2,$E2,$C1,$3E,$FF,$C9,$AF,$C9,$CD
    DB $94,$C3,$CD,$A2,$C2,$D5,$CD,$07,$C4,$0E,$C6,$3A,$B8,$FF
    DB $B7,$20,$02,$CB,$B1,$CD,$00,$C4,$F3,$CD,$39,$C3,$D1,$0E
    DB $C1,$43,$2A,$BD,$FF,$DB,$82,$CB,$57,$28,$FA,$DB,$C0,$CB
    DB $6F,$28,$07,$ED,$A2,$20,$F0,$15,$20,$ED,$D3,$DC,$FB,$CD
    DB $DF,$C3,$3A,$C0,$FF,$E6,$C0,$FE,$40,$20,$10,$CD,$8B,$C2
    DB $3A,$BF,$FF,$3D

shortcuts_str:                              ;[2080]
    DB " F1:DIR \x7F      F2:STAT \x7F     F3:MBASIC\x0D\x7F   F4:PIP \x7F      F5:TYPE \x7F              "

    ;; The system ROM code starts back here, same as before
romjunk1:
    DB $3F,$FE,$FF,$C8,$06,$14,$3A,$B8,$FF,$FE,$03,$28,$02,$06
    DB $40,$C5,$3A,$31,$2E,$31,$31,$39,$00,$C4,$ED,$4B,$B9,$FF
    DB $CD,$00,$C4,$3A,$B8,$FF,$4F,$CD,$00,$C4,$0E,$05,$3A,$B8
    DB $FF,$FE,$03,$28,$02,$0E

entrypoint:
    di                                      ;[2100] Beginning of the critical section
    im      2                               ;[2101]
    ld      a,$ff                           ;[2103]
    ld      i,a                             ;[2105]
    ld      sp,$0151                        ;[2107] Setup stack pointer
    ld      a,$01                           ;[210a] Configure the CRTC Horizontal disp character
    out     ($a0),a                         ;[210c]  register (address 1)
    ld      a,$00                           ;[210e]  to 0
    out     ($a1),a                         ;[2110]  (no displayed character?)
    ld      a,$00                           ;[2112]
    ld      ($0003),a                       ;[2114] I/O byte: set to zero (see below)
    call    $2145                           ;[2117] TODO
    call    loadkeys                        ;[211a] load the keyboard layout in the proper area
    call    loadshortcuts                   ;[211d] load the content of the shortcuts bar
    ld      a,($011b)                       ;[2120] TODO $80
    ld      ($0003),a                       ;[2123] I/O byte [TODO: https://www.mark-ogden.uk/mirrors/www.cirsovius.de/CPM/Projekte/Artikel/Grundlagen/IOByte/IOByte-de.html]
    ld      c,$09                           ;[2126] C_WRITESTR(welcome_str)
    ld      de,welcome_str                  ;[2128] the  welcome string with CP/M version
    call    SYSCALL                         ;[212b]
    ld      a,$01                           ;[212e] Configure the CRTC Horizontal disp character
    out     ($a0),a                         ;[2130]  register (address 1)
    ld      a,$50                           ;[2132]  to 80
    out     ($a1),a                         ;[2134]  (number of columns)
    call    initialize                      ;[2136] Initialize all the other peripherals
    in      a,($81)                         ;[2139] PORTB |= 0x02
    set     1,a                             ;[213b]  which is: mute parity error
    out     ($81),a                         ;[213d]
    ei                                      ;[213f] End of the critical section
    ld      c,$00                           ;[2140] P_TERMCPM - System reset
    call    SYSCALL                         ;[2142]

    ; in here: the content of some configuration variables
    ; TODO
    call    bank_off                        ;[2145] TODO
    ld      de,$b821                        ;[2148]
    ld      hl,relocated_area               ;[214b] TODO what's here?
    ld      bc,$07db                        ;[214e]
    ldir                                    ;[2151]
    call    bank_on                         ;[2153]
    ret                                     ;[2156]

loadkeys:
    call    bank_off                        ;[2157]
    ld      hl,($bff2)                      ;[215a] load the pointer to the designated keymap area
    ld      de,kbdlayout                    ;[215d] load pointer to keymap table
    ex      de,hl                           ;[2160]
    ld      bc,$0280                        ;[2161] keymap table length
    ldir                                    ;[2164] memcpy(*$bff2, kbdlayout, 0x0280)
    call    bank_on                         ;[2166]
    ret                                     ;[2169]

    ; This routine loads the content of the 25th line on the
    ; screen, which containts the shortcuts (F1, F2, ...)
loadshortcuts:
    call    bank_off                        ;[216a]
    ld      hl,($ffad)                      ;[216d] *$ffad=$feb4, loaded by cp/m bios
    ld      ($bff4),hl                      ;[2170] store the shortcuts address in a local variable (TODO)
    ld      de,shortcuts_str                ;[2173]
    ex      de,hl                           ;[2176]
    ld      bc,$0050                        ;[2177] length of shortcuts string
    ldir                                    ;[217a] memcpy(*$ffad, shortcuts_str, 0x0050)
    call    bank_on                         ;[217c]
    ret                                     ;[217f]

    ; This initialization is more or less the same as V1.01 ROM
initialize:
    call    kbd_sio_init                    ;[2180] initialize the SIO keyboard channel
    call    comm_sio_init                   ;[2183] initialize the SIO communication channel
    call    timer3_init                     ;[2186] initialize the timer channel 3
    call    timer12_init                    ;[2189] initialize the timer channels 1 and 2
    ret                                     ;[218c]

    ; Configure the SIO channel 2, dedicated to the keyboard
    ; communication
kbd_sio_init:
    ld      hl,kbd_sio_cfg                  ;[218d]
L2190:
    ld      a,(hl)                          ;[2190]
    inc     hl                              ;[2191]
    cp      $ff                             ;[2192]
    jr      z,L219a                         ;[2194] Repeat configuration loop until *hl != 0xff
    out     ($b3),a                         ;[2196]
    jr      L2190                           ;[2198]
L219a:
    in      a,($b2)                         ;[219a] Flush SIO buffer
    in      a,($b2)                         ;[219c]
    in      a,($b2)                         ;[219e]
    ret                                     ;[21a0]

kbd_sio_cfg:                                ;[21a1]
    DB $00                                  ; Register 0
    DB $18                                  ;  Channel reset
    DB $1b                                  ;  Channel reset? but with another register pointer (which is forbidden by the manual)
    DB $00                                  ; Register 0
    DB $10                                  ;  Reset interrupts
    DB $00                                  ; Register 0
    DB $10                                  ;  Reset interrupts
    DB $04                                  ; Register 4
    DB $4c                                  ;  2 stop bits + x16 clock mode
    DB $01                                  ; Register 1
    DB $18                                  ;  interrupts enabled on all received character
    DB $03                                  ; Register 3
    DB $c1                                  ;  8 bit per character (Rx) + Rx enable
    DB $05                                  ; Register 5
    DB $6a                                  ;  RTS + Tx enable + 8 bit per character (Tx)
    DB $02                                  ; Register 2
    DB $88                                  ;  Vector interrupt address (TODO)
    DB $ff

timer3_cfg:                                 ;[21b3]
    DB $e0,$80                              ; timer x: vector address ($80), common for all channels
    DB $e3,$03                              ; timer 3: software reset
    DB $e3,$05                              ; timer 3: time constant follows
    DB $e3,$01                              ; timer 3: time constant = 1
    DB $e3,$c1                              ; timer 3: enable interrupts + counter mode
    DB $ff

timer3_init:
    ld      hl,timer3_cfg                   ;[21be]
L21c1:
    ld      a,(hl)                          ;[21c1] load IO address
    inc     hl                              ;[21c2]
    cp      $ff                             ;[21c3] loop until *hl != 0xff
    ret     z                               ;[21c5]
    ld      c,a                             ;[21c6] put IO address in c
    ld      a,(hl)                          ;[21c7] load register value
    inc     hl                              ;[21c8]
    out     (c),a                           ;[21c9]
    jp      L21c1                           ;[21cb]

    ; Configure the SIO channel 1, dedicated to communication
    ; with other devices
comm_sio_init:
    ld      a,$18                           ;[21ce] Channel reset
    out     ($b1),a                         ;[21d0]
    ld      c,$b1                           ;[21d2] address of SIO channel 1
    ld      hl,comm_sio_cfg                 ;[21d4]
    ld      b,$0e                           ;[21d7] sizeof(comm_sio_cfg)
    otir                                    ;[21d9] repeat io(c) = (*hl++) over all table
    ret                                     ;[21db]

    ; Configure timers 1 and 2
timer12_init:
    ld      b,$03                           ;[21dc] load number of register to program
    ld      c,$e1                           ;[21de] load peripheral IO address
    ld      hl,timer12_cfg                  ;[21e0] load configuration table
L21e3:
    ld      a,(hl)                          ;[21e3] load register value
    out     (c),a                           ;[21e4]  and write it to CTC
    inc     hl                              ;[21e6]
    dec     b                               ;[21e7]
    jr      nz,L21e3                        ;[21e8] repeat for all three register
    ld      a,(hl)                          ;[21ea] check if table end was reached
    inc     c                               ;[21eb] move IO pointer to the other channel
    or      a                               ;[21ec]
    ld      b,$03                           ;[21ed]
    jr      nz,L21e3                        ;[21ef] repeat until table value != 0
    ret                                     ;[21f1]

    ; Enable bank switching (access to whole 64k DRAM)
bank_on:
    in      a,($81)                         ;[21f2]
    set     0,a                             ;[21f4]
    out     ($81),a                         ;[21f6]
    ret                                     ;[21f8]

    ; Disable bank switching
bank_off:
    in      a,($81)                         ;[21f9]
    res     0,a                             ;[21fb]
    out     ($81),a                         ;[21fd]
    ret                                     ;[21ff]

    ;; The system ROM code starts back here, same as before
romjunk2:
    DB $CD,$EE,$C3,$79,$D3,$C1,$C9,$DB,$C0,$CB,$67,$20,$FA,$C9
    DB $06,$01,$79,$E6,$03,$B7,$28,$05,$CB,$00,$3D,$20,$FB,$3A
    DB $C7,$FF,$4F,$A0,$C0,$79,$B0,$32,$C7,$FF,$CD,$7C,$C3,$C9
    DB $C5,$E5,$21,$47,$C4,$CD,$07,$C4,$0E,$03,$CD,$00,$C4,$4E
    DB $23,$CD,$00,$C4,$4E,$CD,$00,$C4,$AF,$32,$C7,$FF,$E1,$C1
    DB $C9,$6F,$1B,$F5,$C5,$D5,$E5,$DD,$E5,$FD,$E5,$CD,$80,$C6
    DB $3A,$D8,$FF,$B7,$C2,$C9,$C9,$3A,$CC,$FF,$FE,$FF,$CA,$89
    DB $C6,$B7,$C2,$A4,$C4,$79,$FE,$1B,$28,$30,$FE,$20,$D2,$A4
    DB $C4,$FE,$0D,$CA,$0A,$C5,$FE,$0A,$CA,$18,$C5,$FE,$0B,$CA
    DB $3E,$C5,$FE,$0C,$CA,$55,$C5,$FE,$08,$CA,$81,$C5,$FE,$1E
    DB $CA,$C1,$C5,$FE,$1A,$CA,$D4,$C5,$FE,$07,$CC,$DA,$C5,$C3
    DB $89,$C6,$3E,$01,$32,$D8,$FF,$C3,$89,$C6,$FD,$E5,$E1,$CD
    DB $FB,$C6,$71,$CD,$7B,$C7,$3A,$D1,$FF,$47,$3A,$D2,$FF,$A6
    DB $B0,$77,$CD,$84,$C7,$CD,$DE,$C5,$38,$06,$CD,$F9,$C5,$C3
    DB $89,$C6,$3A,$CB,$FF,$47,$3A,$CD,$FF,$B8,$28,$17,$04,$78
    DB $32,$CB,$FF,$3A,$C9,$FF,$B7,$20,$06,$CD,$F9,$C5,$C3,$89
    DB $C6,$CD,$06,$C6,$C3,$89,$C6,$3A,$C9,$FF,$B7,$20,$09,$CD
    DB $F9,$C5,$CD,$14,$C6,$C3,$89,$C6,$3A,$CD,$FF,$47,$3A,$D0
    DB $FF,$4F,$CD,$D7,$C6,$CD,$02,$C7,$CD,$14,$C6,$C3,$89,$C6
    DB $3A,$D0,$FF,$32,$CA,$FF,$4F,$3A,$CB,$FF,$47,$C3,$CB,$C5
    DB $3A,$CB,$FF,$47,$3A,$CD,$FF,$B8,$28,$0F,$04,$78,$32,$CB
    DB $FF,$FD,$E5,$E1,$11,$50,$00,$19,$C3,$CE,$C5,$CD,$14,$C6
    DB $3A,$CB,$FF,$47,$3A,$CA,$FF,$4F,$18,$E9,$3A,$CB,$FF,$47
    DB $3A,$CE,$FF,$B8,$CA,$89,$C6,$05,$78,$32,$CB,$FF,$3A,$CA
    DB $FF,$4F,$C3,$CB,$C5,$CD,$DE,$C5,$3A,$CB,$FF,$47,$38,$03
    DB $C3,$CB,$C5,$3A,$D0,$FF,$32,$CA,$FF,$4F,$3A,$CB,$FF,$47
    DB $3A,$CD,$FF,$B8,$28,$08,$04,$78,$32,$CB,$FF,$C3,$CB,$C5
    DB $C5,$CD,$14,$C6,$C1,$18,$4A,$3A,$CA,$FF,$4F,$3A,$D0,$FF
    DB $B9,$28,$13,$0D,$3A,$D1,$FF,$CB,$5F,$28,$01,$0D,$79,$32
    DB $CA,$FF,$3A,$CB,$FF,$47,$18,$2D,$3A,$CF,$FF,$47,$3A,$D1
    DB $FF,$CB,$5F,$28,$01,$05,$78,$32,$CA,$FF,$4F,$3A,$CB,$FF
    DB $47,$3A,$CE,$FF,$B8,$CA,$89,$C6,$05,$78,$32,$CB,$FF,$18
    DB $0A,$AF,$32,$CB,$FF,$32,$CA,$FF,$01,$00,$00,$CD,$D7,$C6
    DB $CD,$02,$C7,$C3,$89,$C6,$CD,$4A,$C7,$C3,$89,$C6,$AF,$D3
    DB $DA,$C9,$3A,$CA,$FF,$4F,$0C,$3A,$D1,$FF,$CB,$5F,$28,$01
    DB $0C,$3A,$CF,$FF,$B9,$79,$30,$03,$3A,$D0,$FF,$32,$CA,$FF
    DB $C9,$23,$3A,$D1,$FF,$CB,$5F,$28,$01,$23,$CD,$02,$C7,$C9
    DB $3A,$C8,$FF,$5F,$16,$00,$FD,$E5,$E1,$19,$CD,$02,$C7,$C9
    DB $3A,$C9,$FF,$B7,$20,$13,$DD,$E5,$E1,$11,$50,$00,$19,$CD
    DB $28,$C7,$06,$17,$CD,$E0,$C7,$CD,$56,$C6,$C9,$3A,$D0,$FF
    DB $4F,$3A,$CE,$FF,$47,$3A,$CE,$FF,$57,$3A,$CD,$FF,$92,$28
    DB $0B,$57,$04,$CD,$D7,$C6,$CD,$8D,$C7,$15,$20,$F6,$3A,$CD
    DB $FF,$57,$3A,$CF,$FF,$5F,$CD,$EB,$C7,$C9,$DD,$E5,$E1,$11
    DB $30,$07,$06,$50,$19,$11,$00,$20,$CD,$7B,$C7,$CD,$FB,$C6
    DB $E5,$C5,$1E,$00,$CD,$76,$C6,$C1,$E1,$CD,$84,$C7,$1E,$20
    DB $73,$23,$CB,$5C,$CC,$FB,$C6,$10,$F7,$C9,$DD,$2A,$D4,$FF
    DB $FD,$2A,$D6,$FF,$C9,$CD,$CE,$C6,$FD,$E1,$DD,$E1,$E1,$D1
    DB $C1,$F1,$C9,$21,$C9,$FF,$AF,$77,$23,$77,$23,$77,$23,$77
    DB $23,$36,$17,$23,$77,$23,$36,$4F,$23,$77,$23,$77,$23,$36
    DB $80,$23,$3A,$55,$C8,$57,$DB,$D6,$CB,$6F,$28,$02,$16,$03
    DB $CB,$77,$28,$04,$CB,$EA,$CB,$F2,$72,$AF,$23,$06,$15,$77
    DB $23,$10,$FC,$C9,$DD,$22,$D4,$FF,$FD,$22,$D6,$FF,$C9,$F5
    DB $C5,$D5,$DD,$E5,$E1,$11,$50,$00,$78,$06,$05,$1F,$30,$01
    DB $19,$B7,$CB,$13,$CB,$12,$05,$20,$F4,$16,$00,$59,$19,$7C
    DB $E6,$0F,$67,$D1,$C1,$F1,$C9,$7C,$E6,$07,$F6,$D0,$67,$C9
    DB $7C,$E6,$07,$67,$DD,$E5,$D1,$EB,$B7,$ED,$52,$38,$07,$28
    DB $05,$21,$00,$08,$19,$EB,$3E,$0E,$D3,$A0,$7A,$D3,$A1,$3E
    DB $0F,$D3,$A0,$7B,$D3,$A1,$D5,$FD,$E1,$C9,$7C,$E6,$07,$67
    DB $CD,$41,$C7,$3E,$0C,$D3,$A0,$7C,$D3,$A1,$3E,$0D,$D3,$A0
    DB $7D,$D3,$A1,$E5,$DD,$E1,$C9,$DB,$A0,$DB,$82,$CB,$4F,$28
    DB $FA,$C9,$01,$80,$07,$DD,$E5,$E1,$11,$00,$20,$CD,$FB,$C6
    DB $72,$DB,$81,$CB,$FF,$D3,$81,$73,$CB,$BF,$D3,$81,$23,$CB
    DB $5C,$CC,$FB,$C6,$0B,$78,$B1,$20,$E9,$DD,$E5,$E1,$CD,$02
    DB $C7,$AF,$32,$CA,$FF,$32,$CB,$FF,$C9,$F5,$DB,$81,$CB,$FF
    DB $D3,$81,$F1,$C9,$F5,$DB,$81,$CB,$BF,$D3,$81,$F1,$C9,$D5
    DB $C5,$3E,$50,$2F,$16,$FF,$5F,$13,$CD,$9C,$C7,$C1,$D1,$C9
    DB $3A,$D0,$FF,$4F,$CD,$D7,$C6,$E5,$19,$EB,$E1,$3A,$D0,$FF
    DB $47,$3A,$CF,$FF,$90,$3C,$47,$CD,$FB,$C6,$EB,$CD,$FB,$C6
    DB $EB,$C5,$D5,$E5,$0E,$02,$7E,$12,$13,$7A,$E6,$07,$F6,$D0
    DB $57,$23,$CB,$5C,$CC,$FB,$C6,$10,$EF,$0D,$28,$0A,$79,$E1
    DB $D1,$C1,$4F,$CD,$7B,$C7,$18,$E2,$CD,$84,$C7,$C9,$D5,$C5
    DB $11,$50,$00,$CD,$9C,$C7,$C1,$D1,$C9,$7B,$91,$3C,$5F,$7A
    DB $90,$3C,$57,$CD,$D7,$C6,$CD,$FB,$C6,$36,$20,$CD,$7B,$C7
    DB $36,$00,$CD,$84,$C7,$23,$1D,$20,$EF,$04,$3A,$D0,$FF,$4F
    DB $3A,$CF,$FF,$91,$3C,$5F,$15,$20,$DE,$C9,$3A,$CD,$FF,$47
    DB $3A,$CE,$FF,$B8,$28,$0B,$57,$78,$92,$57,$05,$CD,$E0,$C7
    DB $15,$20,$F9,$3A,$CE,$FF,$47,$57,$3A,$D0,$FF,$4F,$3A,$CF
    DB $FF,$5F,$CD,$EB,$C7,$C9,$C5,$06,$1E,$0E,$0F,$0D,$C2,$41
    DB $C8,$05,$C2,$3F,$C8,$C1,$C9,$63,$50,$54,$AA,$19,$06,$19
    DB $19,$00,$0D,$0D,$0D,$00,$00,$00,$00,$3A,$D1,$FF,$CB,$DF
    DB $32,$D1,$FF,$3A,$CA,$FF,$4F,$1F,$30,$07,$FD,$23,$0C,$79
    DB $32,$CA,$FF,$AF,$C9,$21,$4B,$C8,$06,$10,$0E,$A1,$AF,$D3
    DB $A0,$3C,$ED,$A3,$20,$F9,$DD,$21,$00,$00,$CD,$4A,$C7,$CD
    DB $9C,$C8,$21,$00,$00,$CD,$02,$C7,$3A,$D1,$FF,$CB,$9F,$32
    DB $D1,$FF,$AF,$C9,$3E,$06,$D3,$A0,$3E,$18,$D3,$A1,$C9,$AF
    DB $32,$CE,$FF,$32,$D0,$FF,$32,$C9,$FF,$3E,$17,$32,$CD,$FF
    DB $C9,$06,$04,$CD,$41,$C7,$AF,$0E,$A1,$D3,$A0,$3C,$ED,$A3
    DB $20,$F9,$C9,$3A,$D9,$FF,$B7,$20,$05,$3C,$32,$D9,$FF,$C9
    DB $79,$E6,$0F,$07,$07,$07,$07,$2F,$47,$3A,$D1,$FF,$A0,$32
    DB $D1,$FF,$AF,$C9,$AF,$32,$D1,$FF,$C9,$3A,$D9,$FF,$47,$16
    DB $00,$5F,$21,$D9,$FF,$19,$79,$D6,$20,$77,$78,$3C,$32,$D9
    DB $FF,$C9,$78,$D3,$A0,$79,$D3,$A1,$C9,$CD,$D7,$C6,$E5,$42
    DB $4B,$CD,$D7,$C6,$D1,$D5,$B7,$ED,$52,$23,$EB,$E1,$47,$CD
    DB $7B,$C7,$CD,$FB,$C6,$7E,$B0,$77,$23,$1B,$7A,$B3,$20,$F4
    DB $CD,$84,$C7,$C9,$79,$FE,$44,$20,$04,$0E,$40,$18,$39,$FE
    DB $45,$20,$04,$0E,$60,$18,$31,$FE,$46,$20,$04,$0E,$20,$18
    DB $29,$3A,$55,$C8,$57,$DB,$D6,$CB,$6F,$28,$02,$16,$03,$CB
    DB $77,$28,$04,$CB,$EA,$CB,$F2,$7A,$32,$D3,$FF,$06,$0A,$4F
    DB $CD,$FC,$C8,$3A,$56,$C8,$4F,$06,$0B,$CD,$FC,$C8,$AF,$C9
    DB $3A,$D3,$FF,$E6,$9F,$B1,$32,$D3,$FF,$4F,$06,$0A,$CD,$FC
    DB $C8,$AF,$C9,$21,$D1,$FF,$CB,$C6,$AF,$C9,$21,$D1,$FF,$CB
    DB $86,$AF,$C9,$21,$D1,$FF,$CB,$D6,$AF,$C9,$21,$D1,$FF,$CB
    DB $96,$AF,$C9,$21,$D1,$FF,$CB,$CE,$AF,$C9,$21,$D1,$FF,$CB
    DB $8E,$AF,$C9,$3A,$D1,$FF,$E6,$8F,$F6,$10,$32,$D1,$FF,$AF
    DB $C9,$3A,$D1,$FF,$E6,$8F,$F6,$00,$32,$D1,$FF,$AF,$C9,$3A
    DB $D1,$FF,$E6,$8F,$F6,$20,$32,$D1,$FF,$AF,$C9,$CD,$E7,$C9
    DB $FE,$01,$20,$01,$79,$32,$D8,$FF,$FE,$60,$D2,$56,$CA,$D6
    DB $31,$DA,$56,$CA,$CD,$EB,$C9,$B7,$28,$72,$C3,$89,$C6,$2A
    DB $FA,$BF,$E9,$87,$21,$F8,$C9,$16,$00,$5F,$19,$5E,$23,$56
    DB $EB,$E9,$1E,$CD,$22,$CD,$60,$CA,$60,$CA,$60,$CA,$62,$CA
    DB $A5,$C9,$5B,$CC,$60,$CA,$BA,$CA,$D8,$CA,$02,$CB,$50,$CB
    DB $7B,$CB,$97,$CB,$62,$CA,$5B,$C8,$92,$C8,$60,$CA,$28,$C9
    DB $28,$C9,$28,$C9,$28,$C9,$7B,$C9,$82,$C9,$89,$C9,$90,$C9
    DB $97,$C9,$9E,$C9,$21,$CC,$60,$CA,$87,$CC,$BB,$CC,$60,$CA
    DB $B6,$CB,$E0,$CB,$F7,$CB,$0F,$CC,$A5,$C9,$B1,$C9,$BD,$C9
    DB $A5,$C9,$5B,$CC,$C5,$C8,$E2,$C8,$71,$CC,$03,$CD,$AF,$32
    DB $D8,$FF,$32,$D9,$FF,$C3,$89,$C6,$AF,$C9,$CD,$B3,$CD,$FE
    DB $01,$20,$09,$79,$FE,$31,$38,$28,$FE,$36,$30,$24,$CD,$9B
    DB $CA,$B7,$C0,$3A,$DA,$FF,$E6,$0F,$3D,$87,$47,$87,$4F,$87
    DB $80,$81,$C6,$04,$2A,$F4,$BF,$16,$00,$5F,$19,$EB,$21,$DB
    DB $FF,$01,$09,$00,$ED,$B0,$CD,$2D,$CD,$AF,$C9,$CD,$E7,$C8
    DB $71,$FE,$0A,$C0,$21,$DB,$FF,$06,$08,$7E,$23,$FE,$7F,$28
    DB $06,$10,$F8,$36,$7F,$18,$05,$21,$E3,$FF,$36,$20,$AF,$C9
    DB $CD,$B3,$CD,$FE,$04,$28,$04,$CD,$E7,$C8,$C9,$79,$D6,$20
    DB $5F,$21,$DA,$FF,$46,$23,$56,$23,$4E,$3E,$01,$CD,$03,$C9
    DB $AF,$C9,$CD,$B3,$CD,$FE,$02,$28,$04,$CD,$E7,$C8,$C9,$79
    DB $D6,$20,$5F,$3A,$DA,$FF,$57,$3A,$D3,$FF,$E6,$60,$B2,$32
    DB $D3,$FF,$4F,$06,$0A,$CD,$FC,$C8,$4B,$06,$0B,$CD,$FC,$C8
    DB $AF,$C9,$CD,$B3,$CD,$FE,$04,$28,$04,$CD,$E7,$C8,$C9,$79
    DB $D6,$20,$5F,$3E,$4F,$BB,$38,$38,$21,$DA,$FF,$46,$23,$7E
    DB $FE,$18,$30,$2E,$4F,$23,$56,$79,$B8,$38,$27,$7B,$BA,$38
    DB $23,$21,$CD,$FF,$71,$23,$70,$23,$73,$23,$72,$3E,$01,$32
    DB $C9,$FF,$3E,$50,$93,$5F,$7A,$83,$21,$D1,$FF,$CB,$5E,$28
    DB $01,$87,$32,$C8,$FF,$CD,$F7,$CB,$AF,$C9,$CD,$B3,$CD,$FE
    DB $02,$28,$04,$CD,$E7,$C8,$C9,$79,$D6,$20,$4F,$3E,$4F,$B9
    DB $38,$15,$3A,$DA,$FF,$FE,$19,$30,$0E,$47,$32,$CB,$FF,$79
    DB $32,$CA,$FF,$CD,$D7,$C6,$CD,$02,$C7,$AF,$C9,$CD,$B3,$CD
    DB $79,$D6,$20,$4F,$3E,$4F,$B9,$38,$0E,$3A,$CB,$FF,$47,$79
    DB $32,$CA,$FF,$CD,$D7,$C6,$CD,$02,$C7,$AF,$C9,$CD,$B3,$CD
    DB $FE,$04,$28,$04,$CD,$E7,$C8,$C9,$79,$D6,$20,$5F,$21,$DA
    DB $FF,$46,$23,$4E,$23,$56,$3A,$D2,$FF,$CD,$03,$C9,$AF,$C9
    DB $01,$80,$07,$DD,$E5,$E1,$CD,$7B,$C7,$3A,$D2,$FF,$57,$1E
    DB $20,$CD,$FB,$C6,$7E,$A2,$20,$09,$36,$00,$CD,$7B,$C7,$73
    DB $CD,$7B,$C7,$23,$0B,$78,$B1,$20,$EA,$CD,$84,$C7,$AF,$C9
    DB $3A,$D0,$FF,$4F,$3A,$CE,$FF,$47,$3A,$CF,$FF,$5F,$3A,$CD
    DB $FF,$57,$CD,$EB,$C7,$CD,$F7,$CB,$C9,$3A,$CE,$FF,$47,$3A
    DB $D0,$FF,$4F,$CD,$D7,$C6,$CD,$02,$C7,$78,$32,$CB,$FF,$79
    DB $32,$CA,$FF,$AF,$C9,$CD,$4A,$C7,$3E,$01,$32,$C8,$FF,$3E
    DB $4F,$32,$CF,$FF,$CD,$A5,$C8,$AF,$C9,$06,$00,$0E,$00,$C5
    DB $CD,$D0,$CD,$4A,$D5,$CD,$A0,$FF,$D1,$C1,$CB,$5B,$28,$0D
    DB $0C,$79,$FE,$50,$28,$0D,$C5,$0E,$20,$CD,$A0,$FF,$C1,$0C
    DB $79,$FE,$50,$20,$DE,$C5,$0E,$0D,$CD,$A0,$FF,$0E,$0A,$CD
    DB $A0,$FF,$C1,$04,$78,$FE,$18,$20,$CA,$AF,$C9,$CD,$B3,$CD
    DB $79,$E6,$0F,$07,$07,$07,$07,$47,$3A,$D1,$FF,$E6,$0F,$B0
    DB $32,$D1,$FF,$AF,$C9,$CD,$B3,$CD,$79,$FE,$30,$28,$0E,$FE
    DB $31,$28,$1C,$FE,$32,$28,$3A,$FE,$33,$28,$4B,$AF,$C9,$3A
    DB $CB,$FF,$47,$57,$3A,$CA,$FF,$4F,$3A,$CF,$FF,$5F,$CD,$EB
    DB $C7,$AF,$C9,$3A,$CE,$FF,$47,$3A,$CB,$FF,$32,$CE,$FF,$3A
    DB $C9,$FF,$4F,$3E,$01,$32,$C9,$FF,$C5,$CD,$14,$C6,$C1,$78
    DB $32,$CE,$FF,$79,$32,$C9,$FF,$AF,$C9,$3A,$CB,$FF,$47,$3A
    DB $CA,$FF,$4F,$3A,$CD,$FF,$57,$3A,$CF,$FF,$5F,$CD,$EB,$C7
    DB $AF,$C9,$3A,$CE,$FF,$47,$3A,$CB,$FF,$4F,$3A,$CD,$FF,$B9
    DB $28,$16,$79,$32,$CE,$FF,$C5,$CD,$16,$C8,$C1,$78,$32,$CE
    DB $FF,$3A,$D0,$FF,$4F,$CD,$7B,$CB,$AF,$C9,$47,$57,$3A,$CF
    DB $FF,$5F,$3A,$D0,$FF,$4F,$CD,$EB,$C7,$18,$E8,$CD,$B3,$CD
    DB $FE,$02,$D2,$66,$CD,$79,$FE,$30,$28,$0E,$FE,$31,$28,$0E
    DB $FE,$34,$28,$15,$FE,$35,$28,$4A,$AF,$C9,$06,$19,$18,$02
    DB $06,$18,$3E,$06,$D3,$A0,$78,$D3,$A1,$AF,$C9,$2A,$F4,$BF
    DB $EB,$06,$18,$0E,$00,$CD,$D7,$C6,$3A,$EA,$BF,$4F,$06,$46
    DB $78,$32,$DA,$FF,$CD,$FB,$C6,$1A,$77,$CD,$7B,$C7,$71,$CD
    DB $84,$C7,$13,$23,$10,$F0,$3A,$DA,$FF,$B7,$28,$0C,$06,$0A
    DB $3A,$EB,$BF,$4F,$AF,$32,$DA,$FF,$18,$DE,$AF,$C9,$79,$FE
    DB $0D,$28,$26,$3A,$D9,$FF,$FE,$01,$28,$04,$CD,$93,$CD,$C9
    DB $06,$18,$0E,$00,$CD,$D7,$C6,$22,$DA,$FF,$3E,$02,$32,$D9
    DB $FF,$06,$46,$0E,$20,$CD,$FB,$C6,$71,$23,$10,$F9,$C9,$AF
    DB $C9,$47,$3C,$32,$D9,$FF,$2A,$DA,$FF,$CD,$FB,$C6,$71,$3A
    DB $EB,$BF,$CD,$7B,$C7,$77,$CD,$84,$C7,$23,$22,$DA,$FF,$78
    DB $FE,$47,$C0,$AF,$C9,$3A,$D9,$FF,$B7,$C0,$3C,$32,$D9,$FF
    DB $E1,$C9,$CD,$80,$C6,$CD,$D7,$C6,$CD,$FB,$C6,$72,$CD,$7B
    DB $C7,$73,$CD,$84,$C7,$C9,$CD,$80,$C6,$CD,$D7,$C6,$CD,$FB
    DB $C6,$56,$CD,$7B,$C7,$5E,$CD,$84,$C7,$C9
    REPT 538
    nop                                     ;[2be2] 00
    ENDR
    ; 1.01 from system ROM
    DB $31,$2e,$30,$31                      ;[2dfc]
                                            ;[2e00]
    REPT 1024
    nop                                     ;[2e02]
    ENDR
    REPT 63
    DB $ff
    DB $00
    ENDR
    DB $ff
    DB $d1
    REPT 63
    DB $ff
    DB $00
    ENDR
    DB $ff
    DB $2f                                  ;[32ff]
