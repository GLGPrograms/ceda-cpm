;**************************************************************
;*
;*             CP/M BIOS   version   2.2
;*
;*       Reconstructed from Sanco CP/M Floppy Image
;*
;*                by RetrOfficina GLG
;*
;**************************************************************

    org 0xf200

PUBLIC _main
_main:
    jp      $f8ae                           ;[f200] BOOT
    jp      $f2de                           ;[f203] WBOOT
    jp      $f368                           ;[f206] CONST
    jp      $f372                           ;[f209] CONIN
    jp      $f3ab                           ;[f20c] CONOUT
    jp      $f3e6                           ;[f20f] LIST
    jp      $f3c7                           ;[f212] PUNCH
    jp      $f3d1                           ;[f215] READER
    jp      $f474                           ;[f218] HOME
    jp      $f47d                           ;[f21b] SELDSK
    jp      $f4b3                           ;[f21e] SETTRK
    jp      $f4b9                           ;[f221] SETSEC
    jp      $f4be                           ;[f224] SETDMA
    jp      $f4c8                           ;[f227] READ
    jp      $f4df                           ;[f22a] WRITE
    jp      $f3da                           ;[f22d] LISTST
    jp      $f4c4                           ;[f230] SECTRAN

; TODO
    DB      "0037"                          ;[f231]

; CP/M Disc Parameter Header
; https://www.seasip.info/Cpm/dph.html
; In CP/M, the DPH is a BIOS structure containing information about a disk drive.
; The actual format of the DPH is version-dependent.

; TODO DPH for disk 0
    DW 0                                    ;[f237] Address of sector translation table
    DW 0, 0, 0                              ;[f239] Used as workspace by CP/M
    DW $fd7c                                ; Address of a 128-byte sector buffer
                                            ;  this is the same for all DPHs in the system.
    DW $f267                                ; Address of the DPB
                                            ;  giving the format of this drive.
    DW $fe15                                ; Address of the directory checksum vector
                                            ;  for this drive.
    DW $fdfc                                ; Address of the allocation vector
                                            ;  for this drive.
; TODO DPH for disk 1
    DW 0                                    ;[f247] Address of sector translation table
    DW 0, 0, 0                              ;[] Used as workspace by CP/M
    DW $fd7c                                ; Address of a 128-byte sector buffer
                                            ;  this is the same for all DPHs in the system.
    DW $f284                                ; Address of the DPB
                                            ;  giving the format of this drive.
    DW $fe4e                                ; Address of the directory checksum vector
                                            ;  for this drive.
    DW $fe35                                ; Address of the allocation vector
                                            ;  for this drive.

; TODO DPH for disk 2 (what is disk 2??)
    DW 0                                    ;[] Address of sector translation table
    DW 0, 0, 0                              ;[] Used as workspace by CP/M
    DW $fd7c                                ; Address of a 128-byte sector buffer
                                            ;  this is the same for all DPHs in the system.
    DW $f2ac                                ; Address of the DPB
                                            ;  giving the format of this drive.
    DW $fe94                                ; Address of the directory checksum vector
                                            ;  for this drive.
    DW $fe6e                                ; Address of the allocation vector
                                            ;  for this drive.

; TODO DPB for disk 0
    DW      80                              ;[f267] Number of 128-byte records per track
    DB      5                               ;[f269] Block shift. 3 => 1k, 4 => 2k, 5 => 4k
    DB      0x1f                            ;[f26a] Block mask. 7 => 1k, 0Fh => 2k, 1Fh => 4k...
    DB      03                              ;[f26b] Extent mask
    DW      196                             ;[f26c] (no. of blocks on the disk)-1
    DW      0x7f                            ;[f26e] (no. of directory entries)-1
    DB      0x80                            ;[f270] Directory allocation bitmap, first byte
    DB      0                               ;[f271] Directory allocation bitmap, second byte
    DW      0x0020                          ;[f272] Checksum vector size, 0 for a fixed disk
                                            ;       No. directory entries/4, rounded up.
    DB      1                               ;[f274] Offset, number of reserved tracks

    DB      0x00 ; TODO
    DB      0x20
    DB      0x50                            ;[f277]
    DB      0x07                            ;[f278]
    DB      0x03                            ;[f279]
    DB      0x00                            ;[f27a]
    DB      0x03                            ;[f27b]
    DB      0x05                            ;[f27c]
    DB      0x00                            ;[f27d]
    DB      0x00                            ;[f27e]
    DB      0x00                            ;[f27f]
    DB      0x02                            ;[f280]
    DB      0x04                            ;[f281]
    DB      1                               ;[f282]
    DB      3

; TODO DPB for disk 1
    DW      80                              ;[f284] Number of 128-byte records per track
    DB      5                               ;[f286] Block shift. 3 => 1k, 4 => 2k, 5 => 4k
    DB      0x1f                            ;[f287] Block mask. 7 => 1k, 0Fh => 2k, 1Fh => 4k...
    DB      03                              ;[f288] Extent mask
    DW      196                             ;[f289] (no. of blocks on the disk)-1
    DW      0x7f                            ;[f28b] (no. of directory entries)-1
    DB      0x80                            ;[f28d] Directory allocation bitmap, first byte
    DB      0                               ;[f28e] Directory allocation bitmap, second byte
    DW      0x0020                          ;[f28f] Checksum vector size, 0 for a fixed disk
                                            ;       No. directory entries/4, rounded up.
    DB      1                               ;[f291] Offset, number of reserved tracks

    DB      00                              ;[f292] TODO
    DB      0x20                            ;[f293]
    DB      0x50                            ;[f294]
    DB      0x07                            ;[f295]
    DB      0x03                            ;[f296]
    DB      0x01, 0x03, 0x05                ;[f297]
    DB      0x00                            ;[f29a]
    DB      0x00                            ;[f29b]
    DB      0x00                            ;[f29c]
    DB      0x02                            ;[f29d]
    DB      0x04                            ;[f29e]
    DB      0x01, 0x03, 0x00                ;[f29f]
    DB      0x00                            ;[f2a2]
    DB      0x00                            ;[f2a3]
    DB      0x00                            ;[f2a4]
    DB      0x00                            ;[f2a5]
    DB      0x00                            ;[f2a6]
    DB      0x00                            ;[f2a7]
    DB      0x00                            ;[f2a8]
    DB      0x00                            ;[f2a9]
    DB      0x00                            ;[f2aa]
    DB      0x00                            ;[f2ab]

; TODO DPB for disk 2
    DW      128                             ;[f2ac] Number of 128-byte records per track
    DB      5                               ;[f2ae] Block shift. 3 => 1k, 4 => 2k, 5 => 4k
    DB      0x1f                            ;[f2af] Block mask. 7 => 1k, 0Fh => 2k, 1Fh => 4k...
    DB      00                              ;[f2b0] Extent mask
    DW      299                             ;[f2b1] (no. of blocks on the disk)-1
    DW      0x7f                            ;[f2b3] (no. of directory entries)-1
    DB      0x80                            ;[f2b5] Directory allocation bitmap, first byte
    DB      0                               ;[f2b6] Directory allocation bitmap, second byte
    DW      0x0020                          ;[f2b7] Checksum vector size, 0 for a fixed disk
                                            ;       No. directory entries/4, rounded up.
    DB      2                               ;[f2b9] Offset, number of reserved tracks

    DB      0                               ;[f2ba] 00
    DB      0x20
    DB      0x80
    DB      0x07                            ;[f2bd]
    DB      0x03                            ;[f2be]
    DB      0x82                            ;[f2bf]
    DB      0x03                            ;[f2c0]
    DB      0x08                            ;[f2c1]
    DB      0x00                            ;[f2c2]
    DB      0x00                            ;[f2c3]
    DB      0x00                            ;[f2c4]
    DB      0x03                            ;[f2c5]
    DB      0x06, 0x01                      ;[f2c6]
    DB      0x04                            ;[f2c8]
    DB      0x07                            ;[f2c9]
    DB      0x02                            ;[f2ca]
    DB      0x05                            ;[f2cb]
    DB      0x00                            ;[f2cc]
    DB      0x00                            ;[f2cd]
    DB      0x00                            ;[f2ce]
    DB      0x00                            ;[f2cf]
    DB      0x00                            ;[f2d0]
    DB      0x00                            ;[f2d1]
    DB      0x00                            ;[f2d2]
    DB      0x00                            ;[f2d3]
    DB      0x00                            ;[f2d4]
    DB      0x00                            ;[f2d5]
    DB      0x00                            ;[f2d6]
    DB      0x00                            ;[f2d7]
    DB      0x00                            ;[f2d8]
    DB      0x00                            ;[f2d9]
    DB      0x00                            ;[f2da]
    DB      0x00                            ;[f2db]
    DB      0x00                            ;[f2dc]
    DB      0x00                            ;[f2dd]

; Warm boot - reload command processor
; Reloads the command processor and (on some systems) the BDOS as well.
; How it does this is implementation-dependent; it may use the reserved tracks
; of a floppy disc or extra memory.
wboot:
    ld      sp,$0100                        ;[f2de] initialize stack pointer
    ld      hl,$e000                        ;[f2e1] buffer area: $e000
    ld      d,$00                           ;[f2e4] track = 0
    ld      e,$00                           ;[f2e6] sector = 0, no burst
    ld      c,$04                           ;[f2e8] head = 1
    ld      b,$40                           ;[f2ea] read operation
    ld      a,$03                           ;[f2ec] ssf = 3
    call    $f631                           ;[f2ee]
    cp      $ff                             ;[f2f1]
    jp      z,$f34e                         ;[f2f3]
    ld      hl,$e000                        ;[f2f6] Now, move the just loaded block
    ld      de,$dc00                        ;[f2f9] in the proper area ($dc00)
    ld      bc,$0400                        ;[f2fc]
    ldir                                    ;[f2ff]
    ld      hl,$e000                        ;[f301] buffer area: $e000
    ld      d,$00                           ;[f304] track = 0
    ld      e,$01                           ;[f306] sector = 1
    set     7,e                             ;[f308] sector burst enabled
    ld      c,$04                           ;[f30a] head = 1
    ld      b,$43                           ;[f30c] read operation, burst = 3
    ld      a,$03                           ;[f30e] ssf = 3
    call    $f631                           ;[f310] load CCP and part of BDOS
    cp      $ff                             ;[f313]
    jr      z,label_f34e                    ;[f315] if read fails, die
    call    bank_switch_on                  ;[f317]
    jr      label_f31c                      ;[f31a] TODO it's right there, why jump?

label_f31c:
    di                                      ;[f31c]
    xor     a                               ;[f31d] TODO zero some other memories
    ld      ($fd24),a                       ;[f31e]
    ld      ($fd26),a                       ;[f321]
    ld      bc,($0080)                      ;[f324] TODO load 0080 in $fd32
    call    $f4be                           ;[f328]
    ld      a,$c3                           ;[f32b]
    ld      ($0000),a                       ;[f32d] load jp $f203 in $0000 (c3 03 f2)
    ld      hl,$f203                        ;[f330]
    ld      ($0001),hl                      ;[f333]
    ld      ($0005),a                       ;[f336] load jp $e406 in $0005 (c3 06 e4)
    ld      hl,$e406                        ;[f339] this is the BDOS entry point
    ld      ($0006),hl                      ;[f33c]
    xor     a                               ;[f33f]
    ld      hl,$0080                        ;[f340]
    ld      ($fd32),hl                      ;[f343] TODO reload 0080 in $fd32, why?
    ld      a,($0004)                       ;[f346]
    ld      c,a                             ;[f349]
    ei                                      ;[f34a]
    jp      $dc00                           ;[f34b] invoke CCP

label_f34e:
    call    bank_switch_off                 ;[f34e] must access to ROM
    call    $c01b                           ;[f351] call putstr
    BYTE $0d
    BYTE $0a
    BYTE "BOOT ERROR"
    BYTE $0d
    BYTE $0a
    BYTE $00
    call    bank_switch_on                  ;[f363]
    jr      label_f34e                      ;[f366] infinite loop

; Console status
; Returns its status in A; 0 if no character is ready, FF if one is.
const:
    ld      a,($fcf4)                       ;[f368] TODO fcf4 may be populated by the SIO ISR
    or      a                               ;[f36b]
    ld      a,$00                           ;[f36c]
    ret     z                               ;[f36e]
    ld      a,$ff                           ;[f36f]
    ret                                     ;[f371]

; Console input
; Wait until the keyboard is ready to provide a character, and return it in A.
conin:
    in      a,($b1)                         ;[f372] TODO read from serial???
    and     $01                             ;[f374]
    jr      z,label_f37d                    ;[f376] TODO if no data, read from keyboard buffer?
    in      a,($b0)                         ;[f378]
    and     $7f                             ;[f37a]
    ret                                     ;[f37c]
label_f37d:
    call    const                           ;[f37d] fetch console status
    or      a                               ;[f380]
    jr      z,conin                         ;[f381] if no data, busy wait
    di                                      ;[f383] begin interrupt guard
    ld      hl,$fcb2                        ;[f384] TODO fetch from keyboard buffer?
    ld      a,($fcf3)                       ;[f387]
    ld      e,a                             ;[f38a]
    ld      d,$00                           ;[f38b]
    add     hl,de                           ;[f38d]
    ld      a,(hl)                          ;[f38e]
    push    af                              ;[f38f]
    ld      a,$00                           ;[f390]
    ld      ($fcf5),a                       ;[f392]
    ld      ($fcf6),a                       ;[f395]
    ld      a,($fcf3)                       ;[f398]
    inc     a                               ;[f39b]
    and     $3f                             ;[f39c]
    ld      ($fcf3),a                       ;[f39e]
label_f3a1:
    ld      a,($fcf4)                       ;[f3a1]
    dec     a                               ;[f3a4]
    ld      ($fcf4),a                       ;[f3a5]
    ei                                      ;[f3a8] end interrupt guard
    pop     af                              ;[f3a9]
    ret                                     ;[f3aa]

; Console output
; Write the character in C to the screen.
conout:
    ld      a,c                             ;[f3ab]
    or      a                               ;[f3ac]
    ret     z                               ;[f3ad] Null is not printable
    ld      a,($0003)                       ;[f3ae]
    cp      $83                             ;[f3b1]
    jp      z,$f3e6                         ;[f3b3] TODO
    call    $f6b0                           ;[f3b6] TODO
    call    bank_switch_off                 ;[f3b9]
    call    $c009                           ;[f3bc] BIOS ROM putchar
    call    bank_switch_on                  ;[f3bf]
    ret                                     ;[f3c2]

    ld      hl,($bff8)                      ;[f3c3] 2a f8 bf
    jp      (hl)                            ;[f3c6] e9

; Paper tape punch output
; Write the character in C to the "paper tape punch" - or whatever the current
; auxiliary device is. If the device isn't ready, wait until it is.
punch:
    in      a,($b1)                         ;[f3c7] Just write C on main serial
    and     $04                             ;[f3c9] polling status register
    jr      z,punch                         ;[f3cb] to avoid overrun
    ld      a,c                             ;[f3cd]
    out     ($b0),a                         ;[f3ce]
    ret                                     ;[f3d0]

; Paper tape reader input
; Read a character from the "paper tape reader" - or whatever the current
; auxiliary device is. If the device isn't ready, wait until it is. The
; character will be returned in A. If this device isn't implemented,
; return character 26 (^Z).
reader:
    in      a,($b1)                         ;[f3d1] Just read from main serial
    and     $01                             ;[f3d3] polling status register
    jr      z,reader                        ;[f3d5] (busy wait)
    in      a,($b0)                         ;[f3d7]
    ret                                     ;[f3d9]


; Status of list device
; Return status of current printer device.
; Returns A=0 (not ready) or A=FF (ready).
listst:
    in      a,($82)                         ;[f3da] TODO
    bit     7,a                             ;[f3dc]
    jr      z,label_f3e2                    ;[f3de]
    xor     a                               ;[f3e0]
    ret                                     ;[f3e1]
label_f3e2:
    ld      a,($00ff)                       ;[f3e2]
    ret                                     ;[f3e5]

; Printer output
; Write the character in C to the printer. If the printer isn't ready, wait
; until it is.
list:
    ld      hl,$0000                        ;[f3e6] big TODO, which printer??
    ld      ($f471),hl                      ;[f3e9]
    ld      a,($0003)                       ;[f3ec]
    cp      $81                             ;[f3ef]
    call    z,$f3ab                         ;[f3f1]
label_f3f4:
    ld      a,($0003)                       ;[f3f4]
    rlc     a                               ;[f3f7]
    rlc     a                               ;[f3f9]
    and     $03                             ;[f3fb]
    or      a                               ;[f3fd]
    jr      z,label_f408                    ;[f3fe]
    dec     a                               ;[f400]
    jr      z,label_f40b                    ;[f401]
    dec     a                               ;[f403]
    jr      z,label_f40c                    ;[f404]
    jr      label_f432                      ;[f406]
label_f408:
    jp      $f3ab                           ;[f408]
label_f40b:
    ret                                     ;[f40b]

label_f40c:
    in      a,($82)                         ;[f40c]
    bit     7,a                             ;[f40e]
    jr      z,label_f432                    ;[f410]
    ld      hl,($f471)                      ;[f412]
    dec     hl                              ;[f415]
    ld      ($f471),hl                      ;[f416]
    ld      a,h                             ;[f419]
    or      l                               ;[f41a]
    jr      nz,label_f3f4                   ;[f41b]
    xor     a                               ;[f41d]
    out     ($da),a                         ;[f41e]
    call    $f368                           ;[f420]
    or      a                               ;[f423]
    jr      z,label_f3f4                    ;[f424]
    call    $f372                           ;[f426]
    cp      $1a                             ;[f429]
    jr      nz,label_f3f4                   ;[f42b]
    xor     a                               ;[f42d]
    ld      ($0003),a                       ;[f42e]
    ret                                     ;[f431]

label_f432:
    ld      a,($f473)                       ;[f432]
    or      a                               ;[f435]
    jr      nz,label_f44e                   ;[f436]
    call    $f6b0                           ;[f438]
label_f43b:
    call    bank_switch_off                 ;[f43b]
    call    $f3c3                           ;[f43e]
    call    bank_switch_on                  ;[f441]
    jr      z,label_f44e                    ;[f444]
    push    bc                              ;[f446]
    ld      c,a                             ;[f447]
    call    $f44e                           ;[f448]
    pop     bc                              ;[f44b]
    jr      label_f43b                      ;[f44c]
label_f44e:
    ld      a,($0003)                       ;[f44e]
    and     $c0                             ;[f451]
    cp      $c0                             ;[f453]
    jp      z,$f3c7                         ;[f455]
    ld      a,c                             ;[f458]
    out     ($80),a                         ;[f459]
    out     ($d0),a                         ;[f45b]
    out     ($d2),a                         ;[f45d]
    ret                                     ;[f45f]

    ld      a,$01                           ;[f460]
    ld      ($f473),a                       ;[f462]
    push    hl                              ;[f465]
    push    de                              ;[f466]
    call    $f3e6                           ;[f467]
    pop     de                              ;[f46a]
    pop     hl                              ;[f46b]
    xor     a                               ;[f46c]
    ld      ($f473),a                       ;[f46d]
    ret                                     ;[f470]

    nop                                     ;[f471]
    nop                                     ;[f472]
    nop                                     ;[f473]

; Move disk head to track 0
; Move the current drive to track 0.
home:
    ld      a,($fd25)                       ;[f474] TODO
    or      a                               ;[f477]
    ret     nz                              ;[f478]
    ld      ($fd24),a                       ;[f479]
    ret                                     ;[f47c]

; Select the disk drive in register C (0=A:, 1=B: ...). Called with E=0 or 0FFFFh.
; If bit 0 of E is 0, then the disc is logged in as if new; if the format has
; to be determined from the boot sector, for example, this will be done.
; If bit 0 if E is 1, then the disc has been logged in before. The disc is not
; accessed; the DPH address (or zero) is returned immediately.
; SELDSK returns the address of a Disc Parameter Header in HL. The exact format
; of a DPH varies between CP/M versions; note that under CP/M 3, the DPH is in
; memory bank 0 and probably not visible to programs. If the disc could not be
; selected it returns HL=0.
seldsk:
    ld      hl,$fd25                        ;[f47d] TODO
    xor     a                               ;[f480]
    cp      (hl)                            ;[f481]
    ld      (hl),a                          ;[f482]
    call    nz,$f4ac                        ;[f483]
    ld      hl,$0000                        ;[f486]
    ld      a,c                             ;[f489]
    ld      ($fd1b),a                       ;[f48a]
    cp      $04                             ;[f48d]
    ret     nc                              ;[f48f]
    ld      l,a                             ;[f490]
    ld      h,$00                           ;[f491]
    add     hl,hl                           ;[f493]
    add     hl,hl                           ;[f494]
    add     hl,hl                           ;[f495]
    add     hl,hl                           ;[f496]
    ld      de,$f237                        ;[f497]
    add     hl,de                           ;[f49a]
    push    hl                              ;[f49b]
    ld      de,$000a                        ;[f49c]
    add     hl,de                           ;[f49f]
    ld      e,(hl)                          ;[f4a0]
    inc     hl                              ;[f4a1]
    ld      d,(hl)                          ;[f4a2]
    ld      hl,$000f                        ;[f4a3]
    add     hl,de                           ;[f4a6]
    ld      ($fd34),hl                      ;[f4a7]
    pop     hl                              ;[f4aa]
    ret                                     ;[f4ab]

    call    $f6b0                           ;[f4ac]
    call    $f625                           ;[f4af]
    ret                                     ;[f4b2]

; Set track number
; Set the track in BC - 0 based.
settrk:
    ld      h,b                             ;[f4b3]
    ld      l,c                             ;[f4b4]
    ld      ($fd1c),hl                      ;[f4b5]
    ret                                     ;[f4b8]

; Set sector number
; Set the sector in BC. Under CP/M 1 and 2 a sector is 128 bytes.
setsec:
    ld      a,c                             ;[f4b9]
    ld      ($fd1e),a                       ;[f4ba]
    ret                                     ;[f4bd]

; Set DMA address
; The next disc operation will read its data from (or write its data to) the
; address given in BC.
setdma:
    ld      h,b                             ;[f4be]
    ld      l,c                             ;[f4bf]
    ld      ($fd32),hl                      ;[f4c0]
    ret                                     ;[f4c3]

; Sector translation for skewing
; Translate sector numbers to take account of skewing.
; On entry, BC=logical sector number (zero based) and DE=address of translation
; table. On exit, HL contains physical sector number. On a system with hardware
; skewing, this would normally ignore DE and return either BC or BC+1.
sectran:
    ld      l,c                             ;[f4c4]
    ld      h,$00                           ;[f4c5] Just return bc, with MSB zeroed
    ret                                     ;[f4c7]

; Read a sector
; Read the currently set track and sector at the current DMA address.
; Returns A=0 for OK, 1 for unrecoverable error, FF if media changed.
read:
    call    $f6b0                           ;[f4c8]
    xor     a                               ;[f4cb]
    ld      ($fd26),a                       ;[f4cc]
    ld      a,$01                           ;[f4cf]
    ld      ($fd30),a                       ;[f4d1]
    ld      ($fd2c),a                       ;[f4d4]
    ld      a,$02                           ;[f4d7]
    ld      ($fd31),a                       ;[f4d9]
    jp      $f557                           ;[f4dc]

; Write a sector
; Write the currently set track and sector. C contains a deblocking code:
; C=0 - Write can be deferred
; C=1 - Write must be immediate
; C=2 - Write can be deferred, no pre-read is necessary.
; Returns A=0 for OK, 1 for unrecoverable error, 2 if disc is readonly, FF if
; media changed.
write:
    call    $f6b0                           ;[f4df]
    xor     a                               ;[f4e2]
    ld      ($fd30),a                       ;[f4e3]
    ld      a,c                             ;[f4e6]
    ld      ($fd31),a                       ;[f4e7]
    cp      $02                             ;[f4ea]
    jp      nz,$f50b                        ;[f4ec]
    ld      ix,($fd34)                      ;[f4ef]
    ld      a,(ix+$00)                      ;[f4f3]
    ld      ($fd26),a                       ;[f4f6]
    ld      a,($fd1b)                       ;[f4f9]
    ld      ($fd27),a                       ;[f4fc]
    ld      hl,($fd1c)                      ;[f4ff]
    ld      ($fd28),hl                      ;[f502]
    ld      a,($fd1e)                       ;[f505]
    ld      ($fd2a),a                       ;[f508]
    ld      a,($fd26)                       ;[f50b]
    or      a                               ;[f50e]
    jp      z,$f54f                         ;[f50f]
    dec     a                               ;[f512]
    ld      ($fd26),a                       ;[f513]
    ld      a,($fd1b)                       ;[f516]
    ld      hl,$fd27                        ;[f519]
    cp      (hl)                            ;[f51c]
    jp      nz,$f54f                        ;[f51d]
    ld      hl,$fd28                        ;[f520]
    call    $f60d                           ;[f523]
    jp      nz,$f54f                        ;[f526]
    ld      a,($fd1e)                       ;[f529]
    ld      hl,$fd2a                        ;[f52c]
    cp      (hl)                            ;[f52f]
    jp      nz,$f54f                        ;[f530]
    inc     (hl)                            ;[f533]
    ld      a,(hl)                          ;[f534]
    ld      ix,($fd34)                      ;[f535]
    cp      (ix+$01)                        ;[f539]
    jp      c,$f548                         ;[f53c]
    ld      (hl),$00                        ;[f53f]
    ld      hl,($fd28)                      ;[f541]
    inc     hl                              ;[f544]
    ld      ($fd28),hl                      ;[f545]
    xor     a                               ;[f548]
    ld      ($fd2c),a                       ;[f549]
    jp      $f557                           ;[f54c]
    xor     a                               ;[f54f]
    ld      ($fd26),a                       ;[f550]
    inc     a                               ;[f553]
    ld      ($fd2c),a                       ;[f554]
    xor     a                               ;[f557]
    ld      ($fd2b),a                       ;[f558]
    push    bc                              ;[f55b]
    ld      ix,($fd34)                      ;[f55c]
    ld      a,(ix+$03)                      ;[f560]
    and     $03                             ;[f563]
    ld      c,a                             ;[f565]
    inc     c                               ;[f566]
    ld      a,($fd1e)                       ;[f567]
    dec     c                               ;[f56a]
    jp      z,$f573                         ;[f56b]
    or      a                               ;[f56e]
    rra                                     ;[f56f]
    jp      $f56a                           ;[f570]
    pop     bc                              ;[f573]
    ld      ($fd23),a                       ;[f574]
    ld      hl,$fd24                        ;[f577]
    ld      a,(hl)                          ;[f57a]
    ld      (hl),$01                        ;[f57b]
    or      a                               ;[f57d]
    jp      z,$f5a5                         ;[f57e]
    ld      a,($fd1b)                       ;[f581]
    ld      hl,$fd1f                        ;[f584]
    cp      (hl)                            ;[f587]
    jp      nz,$f59e                        ;[f588]
    ld      hl,$fd20                        ;[f58b]
    call    $f60d                           ;[f58e]
    jp      nz,$f59e                        ;[f591]
    ld      a,($fd23)                       ;[f594]
    ld      hl,$fd22                        ;[f597]
    cp      (hl)                            ;[f59a]
    jp      z,$f5c2                         ;[f59b]
    ld      a,($fd25)                       ;[f59e]
    or      a                               ;[f5a1]
    call    nz,$f625                        ;[f5a2]
    ld      a,($fd1b)                       ;[f5a5]
    ld      ($fd1f),a                       ;[f5a8]
    ld      hl,($fd1c)                      ;[f5ab]
    ld      ($fd20),hl                      ;[f5ae]
    ld      a,($fd23)                       ;[f5b1]
    ld      ($fd22),a                       ;[f5b4]
    ld      a,($fd2c)                       ;[f5b7]
    or      a                               ;[f5ba]
    call    nz,$f619                        ;[f5bb]
    xor     a                               ;[f5be]
    ld      ($fd25),a                       ;[f5bf]
    ld      a,($fd1e)                       ;[f5c2]
    ld      ix,($fd34)                      ;[f5c5]
    and     (ix+$02)                        ;[f5c9]
    ld      l,a                             ;[f5cc]
    ld      h,$00                           ;[f5cd]
    add     hl,hl                           ;[f5cf]
    add     hl,hl                           ;[f5d0]
    add     hl,hl                           ;[f5d1]
    add     hl,hl                           ;[f5d2]
    add     hl,hl                           ;[f5d3]
    add     hl,hl                           ;[f5d4]
    add     hl,hl                           ;[f5d5]
    ld      de,$f8ae                        ;[f5d6]
    add     hl,de                           ;[f5d9]
    ex      de,hl                           ;[f5da]
    ld      hl,($fd32)                      ;[f5db]
    ld      a,h                             ;[f5de]
    jp      $f5ee                           ;[f5df]
    ld      a,($fd30)                       ;[f5e2]
    or      a                               ;[f5e5]
    ret     nz                              ;[f5e6]
    ld      a,$01                           ;[f5e7]
    ld      ($fd25),a                       ;[f5e9]
    ex      de,hl                           ;[f5ec]
    ret                                     ;[f5ed]

    ld      bc,$0080                        ;[f5ee]
    call    $f5e2                           ;[f5f1]
    ex      de,hl                           ;[f5f4]
    ldir                                    ;[f5f5]
    ld      a,($fd31)                       ;[f5f7]
    cp      $01                             ;[f5fa]
    ld      a,($fd2b)                       ;[f5fc]
    ret     nz                              ;[f5ff]
    or      a                               ;[f600]
    ret     nz                              ;[f601]
    xor     a                               ;[f602]
    ld      ($fd25),a                       ;[f603]
    call    $f625                           ;[f606]
    ld      a,($fd2b)                       ;[f609]
    ret                                     ;[f60c]

    ex      de,hl                           ;[f60d]
    ld      hl,$fd1c                        ;[f60e]
    ld      a,(de)                          ;[f611]
    cp      (hl)                            ;[f612]
    ret     nz                              ;[f613]
    inc     de                              ;[f614]
    inc     hl                              ;[f615]
    ld      a,(de)                          ;[f616]
    cp      (hl)                            ;[f617]
    ret                                     ;[f618]

    call    $f64a                           ;[f619]
    set     6,b                             ;[f61c]
    call    $f631                           ;[f61e]
    ld      ($fd2b),a                       ;[f621]
    ret                                     ;[f624]

    call    $f64a                           ;[f625]
    set     7,b                             ;[f628]
    call    $f631                           ;[f62a]
    ld      ($fd2b),a                       ;[f62d]
    ret                                     ;[f630]

    call    bank_switch_off                 ;[f631]
    ld      ($fd2e),a                       ;[f634]
    call    $f692                           ;[f637]
    call    $b818                           ;[f63a]
    or      a                               ;[f63d]
    jr      z,label_f646                    ;[f63e]
    ld      a,($fd2e)                       ;[f640]
    call    $b818                           ;[f643]
label_f646:
    call    bank_switch_on                  ;[f646]
    ret                                     ;[f649]

    ld      ix,($fd34)                      ;[f64a]
    push    ix                              ;[f64e]
    ld      hl,$fd1f                        ;[f650]
    ld      a,(ix+$04)                      ;[f653]
    and     $80                             ;[f656]
    or      (hl)                            ;[f658]
    ld      c,a                             ;[f659]
    inc     hl                              ;[f65a]
    ld      d,(hl)                          ;[f65b]
    ld      a,d                             ;[f65c]
    cp      $00                             ;[f65d]
    jr      z,label_f66b                    ;[f65f]
    cp      (ix+$07)                        ;[f661]
    jr      nc,label_f66b                   ;[f664]
    ld      a,(ix+$08)                      ;[f666]
    sub     d                               ;[f669]
    ld      d,a                             ;[f66a]
label_f66b:
    inc     hl                              ;[f66b]
    inc     hl                              ;[f66c]
    ld      a,(hl)                          ;[f66d]
    cp      (ix+$06)                        ;[f66e]
    jr      c,label_f67c                    ;[f671]
    sub     (ix+$06)                        ;[f673]
    push    af                              ;[f676]
    ld      a,c                             ;[f677]
    or      $04                             ;[f678]
    ld      c,a                             ;[f67a]
    pop     af                              ;[f67b]
label_f67c:
    push    bc                              ;[f67c]
    ld      c,a                             ;[f67d]
    ld      b,$00                           ;[f67e]
    add     ix,bc                           ;[f680]
    ld      e,(ix+$09)                      ;[f682]
    pop     bc                              ;[f685]
    ld      hl,$f8ae                        ;[f686]
    pop     ix                              ;[f689]
    ld      b,(ix+$05)                      ;[f68b]
    ld      a,(ix+$03)                      ;[f68e]
    ret                                     ;[f691]

    push    af                              ;[f692]
    push    bc                              ;[f693]
    ld      a,c                             ;[f694]
    bit     7,a                             ;[f695]
    jr      nz,label_f6a4                   ;[f697]
    call    $f6f9                           ;[f699]
    in      a,($82)                         ;[f69c]
    set     5,a                             ;[f69e]
    out     ($82),a                         ;[f6a0]
    jr      label_f6ad                      ;[f6a2]
label_f6a4:
    call    $f6f2                           ;[f6a4]
    in      a,($82)                         ;[f6a7]
    res     5,a                             ;[f6a9]
    out     ($82),a                         ;[f6ab]
label_f6ad:
    pop     bc                              ;[f6ad]
    pop     af                              ;[f6ae]
    ret                                     ;[f6af]

    ld      ($fd36),hl                      ;[f6b0]
    ex      (sp),hl                         ;[f6b3]
    ld      ($fd38),hl                      ;[f6b4]
    ld      ($fd3a),sp                      ;[f6b7]
    ld      sp,$fd7c                        ;[f6bb]
    push    de                              ;[f6be]
    push    bc                              ;[f6bf]
    push    ix                              ;[f6c0]
    push    iy                              ;[f6c2]
    ld      hl,$f6d0                        ;[f6c4]
    push    hl                              ;[f6c7]
    ld      hl,($fd38)                      ;[f6c8]
    push    hl                              ;[f6cb]
    ld      hl,($fd36)                      ;[f6cc]
    ret                                     ;[f6cf]

    pop     iy                              ;[f6d0]
    pop     ix                              ;[f6d2]
    pop     bc                              ;[f6d4]
    pop     de                              ;[f6d5]
    ld      sp,($fd3a)                      ;[f6d6]
    pop     hl                              ;[f6da]
    ret                                     ;[f6db]

bank_switch_off:
    di                                      ;[f6dc]
    push    af                              ;[f6dd]
    in      a,($81)                         ;[f6de]
    res     0,a                             ;[f6e0]
    out     ($81),a                         ;[f6e2]
    pop     af                              ;[f6e4]
    ei                                      ;[f6e5]
    ret                                     ;[f6e6]

bank_switch_on:
    push    af                              ;[f6e7]
    di                                      ;[f6e8]
    in      a,($81)                         ;[f6e9]
    set     0,a                             ;[f6eb]
    out     ($81),a                         ;[f6ed]
    ei                                      ;[f6ef]
    pop     af                              ;[f6f0]
    ret                                     ;[f6f1]

    push    af                              ;[f6f2]
    push    hl                              ;[f6f3]
    ld      hl,$f717                        ;[f6f4]
    jr      label_f6ff                      ;[f6f7]
    ret                                     ;[f6f9]

    push    af                              ;[f6fa]
    push    hl                              ;[f6fb]
    ld      hl,$f71b                        ;[f6fc]
label_f6ff:
    ld      a,(hl)                          ;[f6ff]
    or      a                               ;[f700]
    jr      z,label_f709                    ;[f701]
    call    $f70c                           ;[f703]
    inc     hl                              ;[f706]
    jr      label_f6ff                      ;[f707]
label_f709:
    pop     hl                              ;[f709]
    pop     af                              ;[f70a]
    ret                                     ;[f70b]

    out     ($c1),a                         ;[f70c]
label_f70e:
    in      a,($c0)                         ;[f70e]
    rla                                     ;[f710]
    jr      nc,label_f70e                   ;[f711]
    rla                                     ;[f713]
    jr      c,label_f70e                    ;[f714]
    ret                                     ;[f716]

    inc     bc                              ;[f717] 03
    rst     $18                             ;[f718] df
    ld      ($0300),a                       ;[f719] 32 00 03
    rst     $28                             ;[f71c] ef
    jr      nz,label_f71f                   ;[f71d] 20 00

label_f71f:
    ld      ($fcf9),sp                      ;[f71f] ed 73 f9 fc
    ld      sp,$fd1b                        ;[f723] 31 1b fd
    push    af                              ;[f726] f5
    push    bc                              ;[f727] c5
    push    de                              ;[f728] d5
    push    hl                              ;[f729] e5
    in      a,($81)                         ;[f72a] db 81
    push    af                              ;[f72c] f5
    res     0,a                             ;[f72d] cb 87
    out     ($81),a                         ;[f72f] d3 81
    in      a,($82)                         ;[f731] db 82
    bit     0,a                             ;[f733] cb 47
    jr      z,label_f750                    ;[f735] 28 19
    call    $c01b                           ;[f737] cd 1b c0
    BYTE $0d
    BYTE $0a
    BYTE "* PARITY ERROR *"
    BYTE $07
    BYTE $00
label_f74e:
    jr      label_f74e                      ;[f74e]

label_f750:                                 ;       ISR epilogue
    out     ($d8),a                         ;[f750] TODO
    pop     af                              ;[f752]
    out     ($81),a                         ;[f753]
    pop     hl                              ;[f755]
    pop     de                              ;[f756]
    pop     bc                              ;[f757]
    pop     af                              ;[f758]
    ld      sp,($fcf9)                      ;[f759]
    ei                                      ;[f75d] classic return from interrupt
    reti                                    ;[f75e]

                                            ;       keyboard interrupt routine
    ld      ($fcf9),sp                      ;[f760] prologue
    ld      sp,$fd1b                        ;[f764] dedicated stack for ISR
    push    af                              ;[f767]
    push    bc                              ;[f768]
    push    de                              ;[f769]
    push    hl                              ;[f76a]
    in      a,($81)                         ;[f76b] save bank switching status
    push    af                              ;[f76d]
    res     0,a                             ;[f76e] reset memory bank switching
    out     ($81),a                         ;[f770]
    in      a,($b3)                         ;[f772] read from SIO port 2 status TODO
    bit     0,a                             ;[f774]
label_f776:
    jp      z,$f750                         ;[f776]
    call    $f77f                           ;[f779]
    jp      $f750                           ;[f77c]

    ld      hl,$fcf7                        ;[f77f]
    call    $f88a                           ;[f782] read bytes from SIO
    ret     z                               ;[f785]
    ld      b,a                             ;[f786] put the flags in b
    dec     hl                              ;[f787]
    ld      a,(hl)                          ;[f788]
    ld      c,a                             ;[f789] put the data in c
    bit     2,b                             ;[f78a]
    jr      z,label_f797                    ;[f78c] handle ALT
    bit     3,b                             ;[f78e]
    jr      z,label_f797                    ;[f790] handle CTRL
    cp      $4d                             ;[f792]
    jp      z,$f8a5                         ;[f794] handle BOOT key TODO
label_f797:
    cp      $5c                             ;[f797]
    jr      nz,label_f7af                   ;[f799] handle F15 key TODO
    bit     3,b                             ;[f79b]
    jr      z,label_f7af                    ;[f79d] handle CTRL TODO ???
    ld      a,b                             ;[f79f]
    rrca                                    ;[f7a0]
    rrca                                    ;[f7a1] put C and S flags in MSb
    and     $c0                             ;[f7a2] and mask them
    ld      e,a                             ;[f7a4]
    ld      a,($0003)                       ;[f7a5] TODO in 0003 are kept keyboard status bits
    and     $3f                             ;[f7a8] clear C and S old flags
    or      e                               ;[f7aa] update C and S flags
    ld      ($0003),a                       ;[f7ab]
    ret                                     ;[f7ae]

label_f7af:
    call    $f7b3                           ;[f7af] cd b3 f7
    ret                                     ;[f7b2] c9

    ld      a,($fcf4)                       ;[f7b3] 3a f4 fc
    cp      $36                             ;[f7b6] fe 36
    jr      c,label_f7bf                    ;[f7b8] 38 05
    ld      a,$01                           ;[f7ba] 3e 01
    out     ($da),a                         ;[f7bc] d3 da
    ret                                     ;[f7be] c9

label_f7bf:
    ld      hl,$f826                        ;[f7bf] 21 26 f8
    ld      a,c                             ;[f7c2] 79
    cp      (hl)                            ;[f7c3] be
    jr      z,label_f7cd                    ;[f7c4] 28 07
    call    $f80c                           ;[f7c6] cd 0c f8
    jr      nc,label_f7fa                   ;[f7c9] 30 2f
    jr      label_f7da                      ;[f7cb] 18 0d
label_f7cd:
    ld      a,($fcb1)                       ;[f7cd] 3a b1 fc
    ld      e,a                             ;[f7d0] 5f
label_f7d1:
    ld      c,$30                           ;[f7d1] 0e 30
    call    $f85c                           ;[f7d3] cd 5c f8
    dec     e                               ;[f7d6] 1d
    jr      nz,label_f7d1                   ;[f7d7] 20 f8
    ret                                     ;[f7d9] c9

label_f7da:
    ld      hl,$0004                        ;[f7da] 21 04 00
    ld      de,$000e                        ;[f7dd] 11 0e 00
label_f7e0:
    dec     a                               ;[f7e0] 3d
    jr      z,label_f7e6                    ;[f7e1] 28 03
    add     hl,de                           ;[f7e3] 19
    jr      label_f7e0                      ;[f7e4] 18 fa
label_f7e6:
    ex      de,hl                           ;[f7e6] eb
    ld      hl,($bff4)                      ;[f7e7] 2a f4 bf
    add     hl,de                           ;[f7ea] 19
    ld      e,$09                           ;[f7eb] 1e 09
label_f7ed:
    dec     e                               ;[f7ed] 1d
    ret     z                               ;[f7ee] c8
    ld      a,(hl)                          ;[f7ef] 7e
    cp      $7f                             ;[f7f0] fe 7f
    ret     z                               ;[f7f2] c8
    ld      c,a                             ;[f7f3] 4f
    call    $f85c                           ;[f7f4] cd 5c f8
    inc     hl                              ;[f7f7] 23
    jr      label_f7ed                      ;[f7f8] 18 f3
label_f7fa:
    call    $f82c                           ;[f7fa] cd 2c f8
    ld      a,c                             ;[f7fd] 79
    or      a                               ;[f7fe] b7
    ret     z                               ;[f7ff] c8
    call    $f808                           ;[f800] cd 08 f8
    ret     c                               ;[f803] d8
    call    $f85c                           ;[f804] cd 5c f8
    ret                                     ;[f807] c9

    ld      hl,($bff6)                      ;[f808] 2a f6 bf
    jp      (hl)                            ;[f80b] e9
    ld      a,b                             ;[f80c] 78
    and     $05                             ;[f80d] e6 05
    jr      nz,label_f821                   ;[f80f] 20 10
    ld      a,c                             ;[f811] 79
    ld      hl,$f826                        ;[f812] 21 26 f8
    ld      e,$00                           ;[f815] 1e 00
    ld      d,$06                           ;[f817] 16 06
label_f819:
    cp      (hl)                            ;[f819] be
    jr      z,label_f823                    ;[f81a] 28 07
    inc     hl                              ;[f81c] 23
    inc     e                               ;[f81d] 1c
    dec     d                               ;[f81e] 15
    jr      nz,label_f819                   ;[f81f] 20 f8
label_f821:
    or      a                               ;[f821] b7
    ret                                     ;[f822] c9

label_f823:
    ld      a,e                             ;[f823] 7b
    scf                                     ;[f824] 37
    ret                                     ;[f825] c9

    ld      c,e                             ;[f826] 4b
    ld      c,(hl)                          ;[f827] 4e
    ld      c,a                             ;[f828] 4f
    ld      d,b                             ;[f829] 50
    ld      d,c                             ;[f82a] 51
    ld      d,d                             ;[f82b] 52
    ld      hl,$0000                        ;[f82c] 21 00 00
    ld      de,$0080                        ;[f82f] 11 80 00
    ld      a,b                             ;[f832] 78
    and     $04                             ;[f833] e6 04
    jr      nz,label_f83e                   ;[f835] 20 07
    bit     0,b                             ;[f837] cb 40
    jr      z,label_f845                    ;[f839] 28 0a
    add     hl,de                           ;[f83b] 19
    jr      label_f845                      ;[f83c] 18 07
label_f83e:
    add     hl,de                           ;[f83e] 19
    add     hl,de                           ;[f83f] 19
    bit     2,b                             ;[f840] cb 50
    jr      nz,label_f845                   ;[f842] 20 01
    add     hl,de                           ;[f844] 19
label_f845:
    ex      de,hl                           ;[f845] eb
    ld      hl,($bff2)                      ;[f846] 2a f2 bf
    add     hl,de                           ;[f849] 19
    ld      e,c                             ;[f84a] 59
    ld      d,$00                           ;[f84b] 16 00
    add     hl,de                           ;[f84d] 19
    ld      c,(hl)                          ;[f84e] 4e
    bit     1,b                             ;[f84f] cb 48
    ret     z                               ;[f851] c8
    ld      a,c                             ;[f852] 79
    cp      $61                             ;[f853] fe 61
    ret     c                               ;[f855] d8
    cp      $7b                             ;[f856] fe 7b
    ret     nc                              ;[f858] d0
    res     5,c                             ;[f859] cb a9
    ret                                     ;[f85b] c9

    push    hl                              ;[f85c] e5
    push    de                              ;[f85d] d5
    ld      a,($fcf2)                       ;[f85e] 3a f2 fc
    ld      e,a                             ;[f861] 5f
    ld      d,$00                           ;[f862] 16 00
    ld      hl,$fcb2                        ;[f864] 21 b2 fc
    add     hl,de                           ;[f867] 19
    ld      (hl),c                          ;[f868] 71
    inc     a                               ;[f869] 3c
    and     $3f                             ;[f86a] e6 3f
    ld      ($fcf2),a                       ;[f86c] 32 f2 fc
    ld      a,($fcf4)                       ;[f86f] 3a f4 fc
    inc     a                               ;[f872] 3c
    and     $3f                             ;[f873] e6 3f
    ld      ($fcf4),a                       ;[f875] 32 f4 fc
    ld      a,c                             ;[f878] 79
    cp      $03                             ;[f879] fe 03
    jr      nz,label_f880                   ;[f87b] 20 03
    ld      ($fcf5),a                       ;[f87d] 32 f5 fc
label_f880:
    cp      $13                             ;[f880] fe 13
    jr      nz,label_f887                   ;[f882] 20 03
    ld      ($fcf6),a                       ;[f884] 32 f6 fc
label_f887:
    pop     de                              ;[f887] d1
    pop     hl                              ;[f888] e1
    ret                                     ;[f889] c9

    in      a,($b2)                         ;[f88a] read data from keyboard
    bit     7,a                             ;[f88c]
    jr      nz,label_f897                   ;[f88e]
    ld      (hl),a                          ;[f890] save the data from keyboard
    ld      a,$ff                           ;[f891]
    ld      ($f8ad),a                       ;[f893]
    ret                                     ;[f896]

; Handle flag byte from keyboard
label_f897:
    inc     hl                              ;[f897] save flags from keyboard
    ld      (hl),a                          ;[f898]
    ld      a,($f8ad)                       ;[f899]
    or      a                               ;[f89c]
    ret     z                               ;[f89d]
    ld      a,$00                           ;[f89e]
    ld      ($f8ad),a                       ;[f8a0]
    ld      a,(hl)                          ;[f8a3]
    ret                                     ;[f8a4]

    ld      hl,$c015                        ;[f8a5] 21 15 c0
    push    hl                              ;[f8a8] e5
    out     ($d8),a                         ;[f8a9] d3 d8
    reti                                    ;[f8ab] ed 4d

    nop                                     ;[f8ad] 00

; Cold start routine
; This function is completely implementation-dependent and should never be
; called from user code.
boot:
    ld      sp,$0100                        ;[f8ae] setup stack pointer
    ld      hl,$fcae                        ;[f8b1]
    ld      bc,$0100                        ;[f8b4]
label_f8b7:
    ld      (hl),$00                        ;[f8b7] clear 256 bytes from $fcae
    dec     bc                              ;[f8b9]
    ld      a,b                             ;[f8ba]
    or      c                               ;[f8bb]
    jr      nz,label_f8b7                   ;[f8bc]
    in      a,($81)                         ;[f8be]
    res     0,a                             ;[f8c0]
    out     ($81),a                         ;[f8c2] disable bank switch
    set     0,a                             ;[f8c4]
    out     ($81),a                         ;[f8c6] enable bank switch
    ld      de,$dc07                        ;[f8c8] copy string in $f93a to $dc07
    ld      hl,$f93a                        ;[f8cb] overwriting a string in BDOS
    ld      bc,$0011                        ;[f8ce] area
    ldir                                    ;[f8d1]
    xor     a                               ;[f8d3]
    ld      ($0004),a                       ;[f8d4] zero some memory locations
    ld      ($0003),a                       ;[f8d7]
    ld      a,$02                           ;[f8da] begin TODO
    ld      ($fcb1),a                       ;[f8dc]
    ld      hl,$feb4                        ;[f8df]
    ld      ($ffad),hl                      ;[f8e2]
    ld      a,$c3                           ;[f8e5]
    ld      hl,$f460                        ;[f8e7]
    ld      ($ffa0),a                       ;[f8ea]
    ld      ($ffa1),hl                      ;[f8ed]
    ld      hl,bank_switch_off              ;[f8f0]
    ld      ($ffa3),a                       ;[f8f3]
    ld      ($ffa4),hl                      ;[f8f6]
    ld      hl,bank_switch_on               ;[f8f9]
    ld      ($ffa6),a                       ;[f8fc]
    ld      ($ffa7),hl                      ;[f8ff] end TODO
    call    bank_switch_off                 ;[f902]
    ld      de,$b800                        ;[f905] take the BIOS ROM jump table
    ld      hl,$c000                        ;[f908] except for the last two entries
    ld      bc,$0021                        ;[f90b] TODO
    ldir                                    ;[f90e]
    ld      de,$bffc                        ;[f910] place "8003" string ... somewhere
    ld      hl,$f936                        ;[f913] TODO
    ld      bc,$0004                        ;[f916]
    ldir                                    ;[f919]
    call    bank_switch_on                  ;[f91b]
    ld      hl,$f71f                        ;[f91e] setup the interrupt vectors
    ld      ($ff80),hl                      ;[f921] CTC channel 0 (TODO)
    ld      ($ff82),hl                      ;[f924] CTC channel 1 (TODO)
    ld      ($ff84),hl                      ;[f927] CTC channel 2 (TODO)
    ld      ($ff86),hl                      ;[f92a] CTC channel 3 (TODO)
    ld      hl,$f760                        ;[f92d]
    ld      ($ff88),hl                      ;[f930] SIO (keyboard channel)
    jp      $f31c                           ;[f933]

    BYTE "8003"                             ;[f936]

    BYTE $08                                ;[f93a]
    BYTE "SLF80037\x00            "

    ; [f950]
    REPT 1456
    nop
    ENDR
