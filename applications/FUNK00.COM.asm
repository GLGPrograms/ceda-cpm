; FUNK00, used to remap keyboard layout on a Sanco computer.
; More information will come later, I hope.
; z80asm FUNK00.COM.asm -b -o FUNK00.COM

    org 0x0100

;; Functions
SYSCALL: = $0005

;; Constants
; The displacement of the first keymap entry inside SLF file
SLF_KEYMAP_BASE  : = $1d00
SLF_KEYMAP_OFFSET: = $0080

; The entrypoint checks current sanco model by reading a particular memory
; byte in CP/M BIOS area, right after service routines table.
; This "model byte" decides the keyboard peripheral address, which is stored
; in IO_KBDST,IO_KBDCH variables for later usage.
                    ld      sp,$0ab4                        ;[0100]
                    ld      hl,($0001)                      ;[0103] f203
                    ld      de,$0030                        ;[0106]
                    add     hl,de                           ;[0109] -> f233
                    ld      a,(hl)                          ;[010a] On our Sanco (CEDA) this is "0" ($30)
                    cp      $30                             ;[010b] check if this Sanco is "model 0"
                    jr      nz,model1                       ;[010d]
                    ld      a,$b3                           ;[010f] Save keyboard IO address to
                    ld      (IO_KBDST),a                    ;[0111]  a certain location in ram (TODO)
                    dec     a                               ;[0114]
                    ld      (IO_KBDCH),a                    ;[0115] Store this value in ram
                    jr      label_0135                      ;[0118]
model1:
                    cp      $31                             ;[011a] check if this Sanco is "model 1"
                    jr      nz,incompatible                 ;[011c]
                    ld      a,$d5                           ;[011e] TODO im not interested since not for our sanco
                    ld      (IO_KBDST),a                    ;[0120]
                    ld      a,$d4                           ;[0123]
                    ld      (IO_KBDCH),a                    ;[0125]
                    jr      label_0135                      ;[0128]
incompatible:
                    ld      de,STR_INCOMPATIBLE             ;[012a] Print unsupported sanco model
                    ld      c,$09                           ;[012d] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[012f]
                    jp      $0000                           ;[0132] TODO just reset or go back to CP/M

label_0135:
                    ld      de,STR_WELCOME                  ;[0135]
                    ld      c,$09                           ;[0138] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[013a]
                    ld      de,STR_GETFILE                  ;[013d]
                    ld      c,$09                           ;[0140] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[0142]
                    call    CIN_FILENAME                    ;[0145] Get input filename
                    ld      de,$0080                        ;[0148]
                    ld      c,$1a                           ;[014b] TODO F_DMAOFF
                    call    GUARD_SYSCALL                   ;[014d]
                    ld      de,fd                           ;[0150] file descriptor address
                    ld      c,$0f                           ;[0153] TODO F_OPEN
                    call    GUARD_SYSCALL                   ;[0155] F_OPEN returns $FF for error
                    inc     a                               ;[0158] increment to get $00 on error
                    jp      z,err_nofile                    ;[0159] TODO file not found error?
                    ld      hl,$0ab4                        ;[015c] TODO this is the base ptr to special keys string? no, because is used as read buffer
                    ld      (dmaoff_p),hl                   ;[015f]
                    ld      b,$00                           ;[0162]
fread_all:
                    ld      de,(dmaoff_p)                   ;[0164]
                    ld      c,$1a                           ;[0168] TODO F_DMAOFF
                    call    GUARD_SYSCALL                   ;[016a]
                    ld      de,fd                           ;[016d] file descriptor address
                    ld      c,$14                           ;[0170] TODO F_READ
                    call    GUARD_SYSCALL                   ;[0172]
                    or      a                               ;[0175] F_READ returns $00 if ok
                    jr      nz,fread_eof                    ;[0176] TODO any error is considered as EOF?
                    ld      hl,(dmaoff_p)                   ;[0178] Update DMA pointer for the next record
                    ld      de,$0080                        ;[017b]
                    add     hl,de                           ;[017e]
                    ld      (dmaoff_p),hl                   ;[017f]
                    inc     b                               ;[0182] keep the count of the number of read records
                    jr      fread_all                       ;[0183]
fread_eof:
                    ld      a,b                             ;[0185]
                    ld      ($0a81),a                       ;[0186] preserve the number of read records from the SLF file
                    ld      de,fd                           ;[0189]
                    ld      c,$10                           ;[018c] F_CLOSE(fd)
                    call    GUARD_SYSCALL                   ;[018e]
                    ld      de,STR_WELCOME                  ;[0191]
                    ld      c,$09                           ;[0194] C_WRITESTR(STR_WELCOME)
                    call    GUARD_SYSCALL                   ;[0196]
                    ld      de,STR_NORMAL                   ;[0199]
                    ld      c,$09                           ;[019c] C_WRITESTR(STR_NORMAL)
                    call    GUARD_SYSCALL                   ;[019e]
                    ld      hl,slfbuff                      ;[01a1] TODO this is again the read buffer
                    ld      de,SLF_KEYMAP_BASE              ;[01a4] This is the offset of the first keymap table in the SLF file
                    add     hl,de                           ;[01a7]
                    ld      (layout_p),hl                   ;[01a8]
                    ld      a,$00                           ;[01ab]
                    ld      ($0a80),a                       ;[01ad]
                    call    DISPLAYKBD                      ;[01b0] TODO print keymap on screen
remap_normal_loop:
                    ld      de,STR_PROMPT                   ;[01b3]
                    ld      c,$09                           ;[01b6] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[01b8]
                    ;
                    di                                      ;[01bb] Direct access to keyboard I/O, interrupts are disabled
                    ld      a,(IO_KBDST)                    ;[01bc] Fetch keyboard's status register I/O address
                    ld      c,a                             ;[01bf] Depending on the peripheral address (i.e. the
                    cp      $b3                             ;[01c0]  model), we have a different mask to read keyboard
                    jr      nz,lmodel1                      ;[01c2]  status register
                    ; Direct I/O access to keyboard for Sanco model "0"
                    ; (i.e. the one we have)
                    ; Read the status register until an available flag is raised
                    ; Here is bit 0, active high
lmodel0:
                    in      a,(c)                           ;[01c4] Read keyboard status?
                    bit     0,a                             ;[01c6] TODO
                    jr      z,lmodel0                       ;[01c8]
                    jr      L01d2                           ;[01ca]
                    ; Direct I/O access to keyboard for Sanco model "1"
                    ; Read the status register until an available flag is raised
                    ; Here is bit 1, active high
lmodel1:
                    in      a,(c)                           ;[01cc]
                    and     $02                             ;[01ce]
                    jr      z,lmodel1                       ;[01d0]
L01d2:
                    ld      a,(IO_KBDCH)                    ;[01d2] Fetch keyboard's data register I/O address
                    ld      c,a                             ;[01d5]
                    in      a,(c)                           ;[01d6]
                    ld      e,a                             ;[01d8] put the first data byte in e register

                    ; The "read status - read data" code is repeated as before.
                    ; this second read is discarded. Why? don't know
                    ld      a,(IO_KBDST)                    ;[01d9]
                    ld      c,a                             ;[01dc]
                    cp      $b3                             ;[01dd]
                    jr      nz,label_01e9                   ;[01df]
label_01e1:
                    in      a,(c)                           ;[01e1]
                    bit     0,a                             ;[01e3]
                    jr      z,label_01e1                    ;[01e5]
                    jr      label_01ef                      ;[01e7]
label_01e9:
                    in      a,(c)                           ;[01e9]
                    and     $02                             ;[01eb]
                    jr      z,label_01e9                    ;[01ed]
label_01ef:
                    ld      a,(IO_KBDCH)                    ;[01ef]
                    ld      c,a                             ;[01f2]
                    in      a,(c)                           ;[01f3]
                    ei                                      ;[01f5] End of direct I/O access

                    ld      a,e                             ;[01f6] Discard last keypress, take first one
                    cp      $39                             ;[01f7] This is the spacebar scancode
                    jr      z,label_0200                    ;[01f9]  when spacebar is pressed, break cycle
                    call    $0583                           ;[01fb] TODO: remap scancode
                    jr      remap_normal_loop               ;[01fe] Repeat keboard reading
label_0200:
                    ld      hl,(layout_p)                   ;[0200] Update keymap pointer to the next block
                    ld      de,SLF_KEYMAP_OFFSET            ;[0203]  TODO: SHIFT layer
                    add     hl,de                           ;[0206]
                    ld      (layout_p),hl                   ;[0207]
                    ld      de,STR_WELCOME                  ;[020a]
                    ld      c,$09                           ;[020d] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[020f]
                    ld      de,STR_SHIFT                    ;[0212]
                    ld      c,$09                           ;[0215] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[0217]
                    ld      a,$01                           ;[021a]
                    ld      ($0a80),a                       ;[021c]
                    call    DISPLAYKBD                      ;[021f]
remap_shift_loop:
                    ld      de,STR_PROMPT                   ;[0222]
                    ld      c,$09                           ;[0225]
                    call    GUARD_SYSCALL                   ;[0227]
                    ; The following code is same as before: catch keypress,
                    ; with direct I/O access, to remap scancode
                    di                                      ;[022a]
                    ld      a,(IO_KBDST)                    ;[022b]
                    ld      c,a                             ;[022e]
                    cp      $b3                             ;[022f]
                    jr      nz,label_023b                   ;[0231]
label_0233:
                    in      a,(c)                           ;[0233]
                    bit     0,a                             ;[0235]
                    jr      z,label_0233                    ;[0237]
                    jr      label_0241                      ;[0239]
label_023b:
                    in      a,(c)                           ;[023b]
                    and     $02                             ;[023d]
                    jr      z,label_023b                    ;[023f]
label_0241:
                    ld      a,(IO_KBDCH)                    ;[0241]
                    ld      c,a                             ;[0244]
                    in      a,(c)                           ;[0245]
                    ld      e,a                             ;[0247]
                    ld      a,(IO_KBDST)                    ;[0248]
                    ld      c,a                             ;[024b]
                    cp      $b3                             ;[024c]
                    jr      nz,label_0258                   ;[024e]
label_0250:
                    in      a,(c)                           ;[0250]
                    bit     0,a                             ;[0252]
                    jr      z,label_0250                    ;[0254]
                    jr      label_025e                      ;[0256]
label_0258:
                    in      a,(c)                           ;[0258]
                    and     $02                             ;[025a]
                    jr      z,label_0258                    ;[025c]
label_025e:
                    ld      a,(IO_KBDCH)                    ;[025e]
                    ld      c,a                             ;[0261]
                    in      a,(c)                           ;[0262]
                    ei                                      ;[0264]
                    ld      a,e                             ;[0265] Discard last keypress, take first one
                    cp      $39                             ;[0266] This is the spacebar scancode
                    jr      z,label_026f                    ;[0268]  when spacebar is pressed, break cycle
                    call    $0583                           ;[026a] TODO: remap scancode
                    jr      remap_shift_loop                ;[026d] Repeat keboard reading
label_026f:
                    ld      hl,(layout_p)                   ;[026f]
                    ld      de,SLF_KEYMAP_OFFSET            ;[0272]
                    add     hl,de                           ;[0275]
                    ld      (layout_p),hl                   ;[0276]
                    ld      de,STR_WELCOME                  ;[0279]
                    ld      c,$09                           ;[027c]
                    call    GUARD_SYSCALL                   ;[027e]
                    ld      de,STR_CTRL                     ;[0281]
                    ld      c,$09                           ;[0284]
                    call    GUARD_SYSCALL                   ;[0286]
                    ld      a,$01                           ;[0289]
                    ld      ($0a80),a                       ;[028b]
                    call    DISPLAYKBD                      ;[028e]
remap_ctrl_loop:
                    ld      de,STR_PROMPT                   ;[0291]
                    ld      c,$09                           ;[0294]
                    call    GUARD_SYSCALL                   ;[0296]
                    ; The following code is same as before: catch keypress,
                    ; with direct I/O access, to remap scancode
                    di                                      ;[0299]
                    ld      a,(IO_KBDST)                    ;[029a]
                    ld      c,a                             ;[029d]
                    cp      $b3                             ;[029e]
                    jr      nz,label_02aa                   ;[02a0]
label_02a2:
                    in      a,(c)                           ;[02a2]
                    bit     0,a                             ;[02a4]
                    jr      z,label_02a2                    ;[02a6]
                    jr      label_02b0                      ;[02a8]
label_02aa:
                    in      a,(c)                           ;[02aa]
                    and     $02                             ;[02ac]
                    jr      z,label_02aa                    ;[02ae]
label_02b0:
                    ld      a,(IO_KBDCH)                    ;[02b0]
                    ld      c,a                             ;[02b3]
                    in      a,(c)                           ;[02b4]
                    ld      e,a                             ;[02b6]
                    ld      a,(IO_KBDST)                    ;[02b7]
                    ld      c,a                             ;[02ba]
                    cp      $b3                             ;[02bb]
                    jr      nz,label_02c7                   ;[02bd]
label_02bf:
                    in      a,(c)                           ;[02bf]
                    bit     0,a                             ;[02c1]
                    jr      z,label_02bf                    ;[02c3]
                    jr      label_02cd                      ;[02c5]
label_02c7:
                    in      a,(c)                           ;[02c7]
                    and     $02                             ;[02c9]
                    jr      z,label_02c7                    ;[02cb]
label_02cd:
                    ld      a,(IO_KBDCH)                    ;[02cd]
                    ld      c,a                             ;[02d0]
                    in      a,(c)                           ;[02d1]
                    ei                                      ;[02d3]
                    ld      a,e                             ;[02d4] Discard last keypress, take first one
                    cp      $39                             ;[02d5] This is the spacebar scancode
                    jr      z,label_02de                    ;[02d7]  when spacebar is pressed, break cycle
                    call    $0583                           ;[02d9] TODO: remap scancode
                    jr      remap_ctrl_loop                 ;[02dc] Repeat keboard reading
                    ; Now the changed SLF file is saved, first in a temporary
                    ; location with SLF*.$$$ extension. Then, old SLF*.COM file
                    ; is removed and SLF*.$$$ is renamed.
label_02de:
                    ld      de,STR_REBOOT                   ;[02de] Print the "now reboot" message
                    ld      c,$09                           ;[02e1] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[02e3]
                    ld      hl,fd+1                         ;[02e6] SLF filename
                    ld      de,tmpfd+1                      ;[02e9] temporary SLF filename
                    ld      bc,$0008                        ;[02ec] filename max length
                    ldir                                    ;[02ef] memcpy($0721, slf filename, 8)
                    ld      de,tmpfd                        ;[02f1] fp for saving, with same name. TODO: F_MAKE will overwrite?
                    ld      c,$16                           ;[02f4] F_MAKE
                    call    GUARD_SYSCALL                   ;[02f6]
                    ld      de,STR_DIR_PLEINE               ;[02f9] Prepare error message
                    inc     a                               ;[02fc] F_MAKE returns $ff on error, make it $00 on error
                    jp      z,error_epilogue                ;[02fd]
                    ld      hl,slfbuff                      ;[0300] Update the "dma offset" pointer to the buffer area
                    ld      (dmaoff_p),hl                   ;[0303]   where the file content is located
                    ld      a,($0a81)                       ;[0306] TODO - number of chunks to be written?
                    ld      b,a                             ;[0309]
L030a:
                    ld      de,(dmaoff_p)                   ;[030a]
                    ld      c,$1a                           ;[030e] F_DMAOFF
                    call    GUARD_SYSCALL                   ;[0310]
                    ld      de,tmpfd                        ;[0313]
                    ld      c,$15                           ;[0316] F_WRITE - writes a chunk of 128 bytes
                    call    GUARD_SYSCALL                   ;[0318]
                    ld      de,STR_DISC_PLEINE              ;[031b] Prepare error message
                    or      a                               ;[031e] F_WRITE returns 0 on success
                    jp      nz,error_epilogue               ;[031f]
                    ld      hl,(dmaoff_p)                   ;[0322] Move dma offset to the next chunk of data
                    ld      de,$0080                        ;[0325]  to be written
                    add     hl,de                           ;[0328]
                    ld      (dmaoff_p),hl                   ;[0329]
                    djnz    L030a                           ;[032c] Repeat until b > 0
                    ld      de,tmpfd                        ;[032e]
                    ld      c,$10                           ;[0331] F_CLOSE(tmpfd)
                    call    GUARD_SYSCALL                   ;[0333]
                    ld      de,fd                           ;[0336]
                    ld      c,$13                           ;[0339] F_DELETE(fd)
                    call    GUARD_SYSCALL                   ;[033b]
                    ld      de,srcfd                        ;[033e] Copy SLF filename in source descriptor
                    ld      hl,tmpfd                        ;[0341]
                    ld      bc,$0009                        ;[0344]
                    ldir                                    ;[0347]
                    ld      de,dstfd                        ;[0349] Copy SLF filename in dest descriptor
                    ld      hl,tmpfd                        ;[034c]
                    ld      bc,$0009                        ;[034f]
                    ldir                                    ;[0352]
                    ld      de,srcfd                        ;[0354]
                    ld      c,$17                           ;[0357] F_RENAME(srcfd,srcfd+16)
                    call    GUARD_SYSCALL                   ;[0359]
                    jp      $0000                           ;[035c] Return to CP/M

CIN_FILENAME:
                    ld      hl,fd+1                         ;[035f] filename: buffer ptr
                    ld      b,$08                           ;[0362] filename: max 8 characters (without extension)
label_0364:
                    ld      c,$01                           ;[0364] C_READ
                    call    GUARD_SYSCALL                   ;[0366]
                    cp      $0d                             ;[0369]
                    jr      z,label_037f                    ;[036b] \n, terminate loop
                    cp      $08                             ;[036d]
                    jr      nz,label_0375                   ;[036f] backspace...
                    dec     hl                              ;[0371] delete stored char
                    inc     b                               ;[0372]
                    jr      label_0364                      ;[0373] continue loop
label_0375:
                    cp      $61                             ;[0375] TODO char cleanup?
                    jr      c,label_037b                    ;[0377]
                    sub     $20                             ;[0379]
label_037b:
                    ld      (hl),a                          ;[037b] store char
                    inc     hl                              ;[037c]  increment buffer ptr
                    djnz    label_0364                      ;[037d]  decrement buffer ctr and loop until > 0
label_037f:
                    ld      hl,STR_FILENAME                 ;[037f] The provided filename must start with "SLF"
                    ld      de,$06fe                        ;[0382]  Sanco Layout File? TODO
                    ld      b,$03                           ;[0385]
L0387:
                    ld      a,(de)                          ;[0387] Compare the SLF string with the
                    cp      (hl)                            ;[0388]  filename string in buffer
                    jp      nz,COUT_BADFNAME                ;[0389] If mismatch, print error and terminate
                    inc     hl                              ;[038c]
                    inc     de                              ;[038d]
                    djnz    L0387                           ;[038e] Repeat until strlen("SLF")
                    ret                                     ;[0390]


GUARD_SYSCALL:
                    push    bc                              ;[0391]
                    push    de                              ;[0392]
                    push    hl                              ;[0393]
                    call    SYSCALL                         ;[0394]
                    pop     hl                              ;[0397]
                    pop     de                              ;[0398]
                    pop     bc                              ;[0399]
                    ret                                     ;[039a]

;; TODO i think display the keyboard layout
DISPLAYKBD:
                    ld      de,$097d                        ;[039b]
                    ld      c,$09                           ;[039e] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[03a0]
                    ld      b,$10                           ;[03a3]
                    inc     hl                              ;[03a5]
                    push    hl                              ;[03a6]
                    call    HEXANDSPACE                     ;[03a7]
                    ld      de,$0982                        ;[03aa]
                    ld      c,$09                           ;[03ad]
                    call    GUARD_SYSCALL                   ;[03af]
                    ld      b,$10                           ;[03b2]
                    pop     hl                              ;[03b4]
                    call    $04d2                           ;[03b5]
                    ld      de,$0987                        ;[03b8]
                    ld      c,$09                           ;[03bb]
                    call    GUARD_SYSCALL                   ;[03bd]
                    ld      b,$0f                           ;[03c0]
                    push    hl                              ;[03c2]
                    call    HEXANDSPACE                     ;[03c3]
                    ld      de,$098c                        ;[03c6]
                    ld      c,$09                           ;[03c9]
                    call    GUARD_SYSCALL                   ;[03cb]
                    ld      b,$0f                           ;[03ce]
                    pop     hl                              ;[03d0]
                    call    $04d2                           ;[03d1]
                    ld      de,$0991                        ;[03d4]
                    ld      c,$09                           ;[03d7]
                    call    GUARD_SYSCALL                   ;[03d9]
                    ld      b,$0d                           ;[03dc]
                    push    hl                              ;[03de]
                    call    HEXANDSPACE                     ;[03df]
                    ld      de,$0996                        ;[03e2]
                    ld      c,$09                           ;[03e5]
                    call    GUARD_SYSCALL                   ;[03e7]
                    ld      b,$0d                           ;[03ea]
                    pop     hl                              ;[03ec]
                    call    $04d2                           ;[03ed]
                    ld      de,$099b                        ;[03f0]
                    ld      c,$09                           ;[03f3]
                    call    GUARD_SYSCALL                   ;[03f5]
                    ld      b,$0c                           ;[03f8]
                    push    hl                              ;[03fa]
                    call    HEXANDSPACE                     ;[03fb]
                    ld      de,$09a0                        ;[03fe]
                    ld      c,$09                           ;[0401]
                    call    GUARD_SYSCALL                   ;[0403]
                    ld      b,$0c                           ;[0406]
                    pop     hl                              ;[0408]
                    call    $04d2                           ;[0409]
                    ld      de,$09a5                        ;[040c]
                    ld      c,$09                           ;[040f]
                    call    GUARD_SYSCALL                   ;[0411]
                    ld      b,$01                           ;[0414]
                    call    HEXANDSPACE                     ;[0416]
                    ld      de,$09aa                        ;[0419]
                    ld      c,$09                           ;[041c]
                    call    GUARD_SYSCALL                   ;[041e]
                    ld      de,$09c4                        ;[0421]
                    ld      c,$09                           ;[0424]
                    call    GUARD_SYSCALL                   ;[0426]
                    ld      b,$04                           ;[0429]
                    push    hl                              ;[042b]
                    call    HEXANDSPACE                     ;[042c]
                    ld      de,$09c9                        ;[042f]
                    ld      c,$09                           ;[0432]
                    call    GUARD_SYSCALL                   ;[0434]
                    ld      b,$04                           ;[0437]
                    pop     hl                              ;[0439]
                    call    $04d2                           ;[043a]
                    ld      de,$09ce                        ;[043d]
                    ld      c,$09                           ;[0440]
                    call    GUARD_SYSCALL                   ;[0442]
                    ld      b,$04                           ;[0445]
                    push    hl                              ;[0447]
                    call    HEXANDSPACE                     ;[0448]
                    ld      b,$04                           ;[044b]
                    pop     hl                              ;[044d]
                    ld      de,$09d3                        ;[044e]
                    ld      c,$09                           ;[0451]
                    call    GUARD_SYSCALL                   ;[0453]
                    call    $04d2                           ;[0456]
                    ld      de,$09d8                        ;[0459]
                    ld      c,$09                           ;[045c]
                    call    GUARD_SYSCALL                   ;[045e]
                    ld      b,$04                           ;[0461]
                    push    hl                              ;[0463]
                    call    HEXANDSPACE                     ;[0464]
                    ld      b,$04                           ;[0467]
                    pop     hl                              ;[0469]
                    ld      de,$09dd                        ;[046a]
                    ld      c,$09                           ;[046d]
                    call    GUARD_SYSCALL                   ;[046f]
                    call    $04d2                           ;[0472]
                    ld      de,$09e2                        ;[0475]
                    ld      c,$09                           ;[0478]
                    call    GUARD_SYSCALL                   ;[047a]
                    ld      b,$03                           ;[047d]
                    push    hl                              ;[047f]
                    call    HEXANDSPACE                     ;[0480]
                    ld      b,$03                           ;[0483]
                    pop     hl                              ;[0485]
                    ld      de,$09e7                        ;[0486]
                    ld      c,$09                           ;[0489]
                    call    GUARD_SYSCALL                   ;[048b]
                    call    $04d2                           ;[048e]
                    ld      de,$09ec                        ;[0491]
                    ld      c,$09                           ;[0494]
                    call    GUARD_SYSCALL                   ;[0496]
                    ld      b,$04                           ;[0499]
                    push    hl                              ;[049b]
                    call    HEXANDSPACE                     ;[049c]
                    ld      b,$04                           ;[049f]
                    pop     hl                              ;[04a1]
                    ld      de,$09f1                        ;[04a2]
                    ld      c,$09                           ;[04a5]
                    call    GUARD_SYSCALL                   ;[04a7]
                    call    $04d2                           ;[04aa]
                    inc     hl                              ;[04ad]
                    ld      de,$09f6                        ;[04ae]
                    ld      c,$09                           ;[04b1]
                    call    GUARD_SYSCALL                   ;[04b3]
                    ld      b,$0f                           ;[04b6]
                    call    HEXANDSPACE                     ;[04b8]
                    ret                                     ;[04bb]

HEXANDSPACE:
                    ld      a,(hl)                          ;[04bc]
                    call    PRHEX                           ;[04bd]
                    inc     hl                              ;[04c0]
                    ld      e,$20                           ;[04c1] Prints space twice
                    ld      c,$02                           ;[04c3] C_WRITE
                    call    GUARD_SYSCALL                   ;[04c5]
                    ld      e,$20                           ;[04c8]
                    ld      c,$02                           ;[04ca] C_WRITE
                    call    GUARD_SYSCALL                   ;[04cc]
                    djnz    HEXANDSPACE                     ;[04cf] while b > 0
                    ret                                     ;[04d1]

L04d2:
                    ld      a,(hl)                          ;[04d2]
                    cp      $20                             ;[04d3]
                    call    c,PRSPECIALSWITCH               ;[04d5]
                    cp      $7f                             ;[04d8]
                    call    nc,PRSPECIALSWITCH              ;[04da]
                    or      a                               ;[04dd]
                    jr      z,label_04fb                    ;[04de]
                    ld      e,a                             ;[04e0]
                    ld      c,$02                           ;[04e1]
                    call    GUARD_SYSCALL                   ;[04e3]
                    ld      e,$20                           ;[04e6]
                    ld      c,$02                           ;[04e8]
                    call    GUARD_SYSCALL                   ;[04ea]
                    ld      e,$20                           ;[04ed]
                    ld      c,$02                           ;[04ef]
                    call    GUARD_SYSCALL                   ;[04f1]
                    ld      e,$20                           ;[04f4]
                    ld      c,$02                           ;[04f6]
                    call    GUARD_SYSCALL                   ;[04f8]
label_04fb:
                    inc     hl                              ;[04fb]
                    djnz    L04d2                           ;[04fc]
                    ret                                     ;[04fe]

                    ; TODO this routine seems to print the special character
                    ; strings, passed in a
PRSPECIALSWITCH:
                    cp      $1b                             ;[04ff]
                    ld      de,$0a51                        ;[0501]
                    jp      z,PRSPECIALSTR                  ;[0504]
                    cp      $7f                             ;[0507]
                    ld      de,$0a4d                        ;[0509]
                    jp      z,PRSPECIALSTR                  ;[050c]
                    cp      $09                             ;[050f]
                    ld      de,$0a55                        ;[0511]
                    jp      z,PRSPECIALSTR                  ;[0514]
                    cp      $03                             ;[0517]
                    ld      de,$0a59                        ;[0519]
                    jp      z,PRSPECIALSTR                  ;[051c]
                    cp      $0d                             ;[051f]
                    ld      de,$0a5d                        ;[0521]
                    jp      z,PRSPECIALSTR                  ;[0524]
                    cp      $18                             ;[0527]
                    ld      de,$0a69                        ;[0529]
                    jp      z,PRSPECIALSTR                  ;[052c]
                    cp      $0a                             ;[052f]
                    ld      de,$0a61                        ;[0531]
                    jp      z,PRSPECIALSTR                  ;[0534]
                    cp      $15                             ;[0537]
                    ld      de,$0a65                        ;[0539]
                    jp      z,PRSPECIALSTR                  ;[053c]
                    cp      $00                             ;[053f]
                    ld      de,$0a41                        ;[0541]
                    jp      z,PRSPECIALSTR                  ;[0544]
                    cp      $07                             ;[0547]
                    ld      de,$0a45                        ;[0549]
                    jp      z,PRSPECIALSTR                  ;[054c]
                    cp      $1a                             ;[054f]
                    ld      de,$0a49                        ;[0551]
                    jp      z,PRSPECIALSTR                  ;[0554]
                    cp      $0b                             ;[0557]
                    jr      nz,label_055d                   ;[0559]
                    ld      a,$f1                           ;[055b]
label_055d:
                    cp      $0c                             ;[055d]
                    jr      nz,label_0563                   ;[055f]
                    ld      a,$f3                           ;[0561]
label_0563:
                    cp      $08                             ;[0563]
                    jr      nz,label_0569                   ;[0565]
                    ld      a,$f4                           ;[0567]
label_0569:
                    cp      $1d                             ;[0569]
                    jr      nz,label_056f                   ;[056b]
                    ld      a,$20                           ;[056d]
label_056f:
                    cp      $1e                             ;[056f]
                    ret     nz                              ;[0571]
                    ld      a,$20                           ;[0572]
                    ret                                     ;[0574]

PRSPECIALSTR:
                    ld      c,$09                           ;[0575] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[0577]
                    ld      e,$20                           ;[057a]
                    ld      c,$02                           ;[057c] C_WRITE
                    call    GUARD_SYSCALL                   ;[057e]
                    xor     a                               ;[0581]
                    ret                                     ;[0582]

                    ld      hl,(layout_p)                   ;[0583]
                    ld      c,a                             ;[0586]
                    ld      b,$00                           ;[0587]
                    add     hl,bc                           ;[0589]
                    ld      a,(hl)                          ;[058a]
                    ld      c,a                             ;[058b]
                    ld      a,($0a80)                       ;[058c]
                    cp      $01                             ;[058f]
                    ld      a,c                             ;[0591]
                    jp      z,L0628                         ;[0592]
                    cp      $80                             ;[0595]
                    jp      c,L0628                         ;[0597]
                    cp      $85                             ;[059a]
                    jp      nc,L0628                        ;[059c]
                    ld      hl,slfbuff                      ;[059f]
                    ld      de,$1f80                        ;[05a2]
                    add     hl,de                           ;[05a5]
                    sub     $7f                             ;[05a6]
                    ld      de,$000e                        ;[05a8]
label_05ab:
                    dec     a                               ;[05ab]
                    jr      z,label_05b1                    ;[05ac]
                    add     hl,de                           ;[05ae]
                    jr      label_05ab                      ;[05af]

label_05b1:
                    ld      ($0a7b),hl                      ;[05b1]
label_05b4:
                    ld      a,(hl)                          ;[05b4] TODO loop that prints *hl++
                    cp      $0d                             ;[05b5]
                    jr      nz,label_05bb                   ;[05b7]
                    ld      a,$f2                           ;[05b9]
label_05bb:
                    cp      $7f                             ;[05bb]
                    jr      z,label_05c8                    ;[05bd]
                    ld      e,a                             ;[05bf]
                    ld      c,$02                           ;[05c0] C_WRITE
                    call    GUARD_SYSCALL                   ;[05c2]
                    inc     hl                              ;[05c5]
                    jr      label_05b4                      ;[05c6]

label_05c8:
                    ld      hl,($0a7b)                      ;[05c8]
                    ld      b,$04                           ;[05cb]
L05cd:
                    ld      a,(hl)                          ;[05cd]
                    ld      e,a                             ;[05ce]
                    ld      c,$02                           ;[05cf]
                    call    GUARD_SYSCALL                   ;[05d1]
                    inc     hl                              ;[05d4]
                    djnz    L05cd                           ;[05d5]
                    ld      b,$08                           ;[05d7]
                    xor     a                               ;[05d9]
                    ld      ($0a7f),a                       ;[05da]
label_05dd:
                    ld      c,$06                           ;[05dd] TODO C_RAWIO
                    ld      e,$ff                           ;[05df] TODO Return a character without echoing if one is waiting; zero if none is available. In MP/M 1, this works like E=0FDh below and waits for a character.
                    call    GUARD_SYSCALL                   ;[05e1]
                    or      a                               ;[05e4] zero = no char available
                    jr      z,label_05dd                    ;[05e5]
                    cp      $5c                             ;[05e7] TODO \
                    jr      z,label_0622                    ;[05e9]
                    cp      $0d                             ;[05eb] TODO \n
                    jr      nz,label_05fd                   ;[05ed]
                    ld      c,a                             ;[05ef]
                    ld      a,($0a7f)                       ;[05f0]
                    or      a                               ;[05f3]
                    jp      z,L0636                         ;[05f4]
                    ld      (hl),c                          ;[05f7]
                    inc     hl                              ;[05f8]
                    ld      e,$f2                           ;[05f9]
                    jr      label_061b                      ;[05fb]

label_05fd:
                    cp      $08                             ;[05fd]
                    jr      nz,label_060b                   ;[05ff]
                    dec     hl                              ;[0601]
                    inc     b                               ;[0602]
                    ld      e,a                             ;[0603]
                    ld      c,$02                           ;[0604]
                    call    GUARD_SYSCALL                   ;[0606]
                    jr      label_05dd                      ;[0609]

label_060b:
                    cp      $61                             ;[060b]
                    jr      c,label_0615                    ;[060d]
                    cp      $7b                             ;[060f]
                    jr      nc,label_0615                   ;[0611]
                    sub     $20                             ;[0613]
label_0615:
                    ld      ($0a7f),a                       ;[0615]
                    ld      (hl),a                          ;[0618]
                    inc     hl                              ;[0619]
                    ld      e,a                             ;[061a]
label_061b:
                    ld      c,$02                           ;[061b] C_WRITE
                    call    GUARD_SYSCALL                   ;[061d]
                    djnz    label_05dd                      ;[0620]
label_0622:
                    ld      a,$7f                           ;[0622]
                    ld      (hl),a                          ;[0624]
                    jp      L0636                           ;[0625]

L0628:
                    call    PRHEX                           ;[0628]
                    ld      de,STR_NOUVELLE                 ;[062b]
                    ld      c,$09                           ;[062e] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[0630]
                    call    L0644                           ;[0633]
L0636:
                    ld      de,STR_SPACES                   ;[0636]
                    ld      c,$09                           ;[0639] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[063b]
                    ld      hl,(layout_p)                   ;[063e]
                    jp      DISPLAYKBD                      ;[0641]

L0644:
                    ld      de,$0a79                        ;[0644]
                    ld      b,$02                           ;[0647]
label_0649:
                    ld      c,$01                           ;[0649]
                    call    GUARD_SYSCALL                   ;[064b]
                    cp      $0d                             ;[064e]
                    ret     z                               ;[0650]
                    cp      $08                             ;[0651]
                    jr      nz,label_0659                   ;[0653]
                    dec     de                              ;[0655]
                    inc     b                               ;[0656]
                    jr      label_0649                      ;[0657]
label_0659:
                    cp      $30                             ;[0659]
                    jr      c,label_0694                    ;[065b]
                    cp      $67                             ;[065d]
                    jr      nc,label_0694                   ;[065f]
                    cp      $61                             ;[0661]
                    jr      nc,label_066b                   ;[0663]
                    cp      $47                             ;[0665]
                    jr      nc,label_0694                   ;[0667]
                    jr      label_066d                      ;[0669]
label_066b:
                    add     $20                             ;[066b]
label_066d:
                    ld      (de),a                          ;[066d]
                    inc     de                              ;[066e]
                    djnz    label_0649                      ;[066f]
                    ld      de,$0a79                        ;[0671]
                    ld      a,(de)                          ;[0674]
                    cp      $41                             ;[0675]
                    jr      c,label_067b                    ;[0677]
                    sub     $07                             ;[0679]
label_067b:
                    sub     $30                             ;[067b]
                    and     $0f                             ;[067d]
                    rra                                     ;[067f]
                    rra                                     ;[0680]
                    rra                                     ;[0681]
                    rra                                     ;[0682]
                    rra                                     ;[0683]
                    ld      c,a                             ;[0684]
                    inc     de                              ;[0685]
                    ld      a,(de)                          ;[0686]
                    cp      $41                             ;[0687]
                    jr      c,label_068d                    ;[0689]
                    sub     $07                             ;[068b]
label_068d:
                    sub     $30                             ;[068d]
                    and     $0f                             ;[068f]
                    add     c                               ;[0691]
                    ld      (hl),a                          ;[0692]
                    ret                                     ;[0693]

label_0694:
                    ld      c,$02                           ;[0694]
                    ld      e,$08                           ;[0696]
                    call    GUARD_SYSCALL                   ;[0698]
                    jp      label_0649                      ;[069b]

                    ; PRHEX(a)
PRHEX:
                    push    af                              ;[069e]
                    rra                                     ;[069f]
                    rra                                     ;[06a0]
                    rra                                     ;[06a1]
                    rra                                     ;[06a2] a >>= 4
                    call    PRHEXNIBBLE                     ;[06a3]
                    pop     af                              ;[06a6]
                    call    PRHEXNIBBLE                     ;[06a7]
                    ret                                     ;[06aa]

                    ; PRHEXNIBBLE(a)
PRHEXNIBBLE:
                    and     $0f                             ;[06ab]
                    cp      $0a                             ;[06ad]
                    jr      c,label_06b3                    ;[06af]
                    add     $07                             ;[06b1]
label_06b3:
                    add     $30                             ;[06b3]
                    ld      e,a                             ;[06b5]
                    ld      c,$02                           ;[06b6] C_WRITE
                    call    GUARD_SYSCALL                   ;[06b8]
                    ret                                     ;[06bb]

err_nofile:
                    ld      de,STR_MODULE                   ;[06bc]
                    ld      c,$09                           ;[06bf] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[06c1]
                    ld      hl,$06fe                        ;[06c4]
                    ld      b,$08                           ;[06c7]
L06c9:
                    ld      a,(hl)                          ;[06c9]
                    cp      $20                             ;[06ca]
                    jr      z,label_06d7                    ;[06cc]
                    ld      e,a                             ;[06ce]
                    ld      c,$02                           ;[06cf] C_WRITE
                    call    GUARD_SYSCALL                   ;[06d1]
                    inc     hl                              ;[06d4]
                    djnz    L06c9                           ;[06d5]
label_06d7:
                    ld      de,STR_INEXISTANT               ;[06d7]
                    ld      c,$09                           ;[06da] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[06dc]
                    jp      $0000                           ;[06df] Reset

error_epilogue:
                    ld      c,$09                           ;[06e2] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[06e4]
                    ld      de,$0720                        ;[06e7]
                    ld      c,$13                           ;[06ea] F_DELETE
                    call    GUARD_SYSCALL                   ;[06ec]
                    jp      $0000                           ;[06ef] Reset

COUT_BADFNAME:
                    ld      de,STR_BADFNAME                 ;[06f2]
                    ld      c,$09                           ;[06f5] C_WRITESTR
                    call    GUARD_SYSCALL                   ;[06f7]
                    jp      $0000                           ;[06fa] Reset

                    ; File descriptors area: they are used with F_OPEN, F_READ,
                    ; F_WRITE, ...

                    ; The file descriptor used to read the SLF file
                    ; (*.COM)
fd:                                                         ;[06fd]
                    DB 0x01
                    ;[06fe]
                    DB "        COM"

                    nop                                     ;[0709] 00
                    nop                                     ;[070a] 00
                    nop                                     ;[070b] 00
                    nop                                     ;[070c] 00
                    nop                                     ;[070d] 00
                    nop                                     ;[070e] 00
                    nop                                     ;[070f] 00
                    nop                                     ;[0710] 00
                    nop                                     ;[0711] 00
                    nop                                     ;[0712] 00
                    nop                                     ;[0713] 00
                    nop                                     ;[0714] 00
                    nop                                     ;[0715] 00
                    nop                                     ;[0716] 00
                    nop                                     ;[0717] 00
                    nop                                     ;[0718] 00
                    nop                                     ;[0719] 00
                    nop                                     ;[071a] 00
                    nop                                     ;[071b] 00
                    nop                                     ;[071c] 00
                    nop                                     ;[071d] 00
                    nop                                     ;[071e] 00
                    nop                                     ;[071f] 00

                    ; The file descriptor used to store temporary SLF file
                    ; (*.$$$)
tmpfd:                                                      ;[0720]
                    DB 0x01
                    ;[0721]
                    DB "        $$$"
                    nop                                     ;[072c] 00
                    nop                                     ;[072d] 00
                    nop                                     ;[072e] 00
                    nop                                     ;[072f] 00
                    nop                                     ;[0730] 00
                    nop                                     ;[0731] 00
                    nop                                     ;[0732] 00
                    nop                                     ;[0733] 00
                    nop                                     ;[0734] 00
                    nop                                     ;[0735] 00
                    nop                                     ;[0736] 00
                    nop                                     ;[0737] 00
                    nop                                     ;[0738] 00
                    nop                                     ;[0739] 00
                    nop                                     ;[073a] 00
                    nop                                     ;[073b] 00
                    nop                                     ;[073c] 00
                    nop                                     ;[073d] 00
                    nop                                     ;[073e] 00
                    nop                                     ;[073f] 00
                    nop                                     ;[0740] 00
                    nop                                     ;[0741] 00
                    nop                                     ;[0742] 00

                    ; Special file descriptors used with F_RENAME to move
                    ; temporary *.$$$ file as *.COM
srcfd:                                                      ;[0743]
                    DB 0
                    DB "        $$$"
                    DB 0,0,0,0
dstfd:                                                      ;[0753]
                    DB 0
                    DB "        COM"
                    DB 0,0,0,0

                    ; [0763]
STR_WELCOME:
                    DB      "\x1A\x0D\x0A\x09\x09\x09\x1B\x37\x1B\x41"
                    DB      "** FUNK00 **"
                    DB      "\x1B\x42\x1B\x58"
                    DB      "$"

                    ; [077e]
STR_GETFILE:
                    DB      "\x0D\x0A\x0A\x0A\x0A"
                    DB      "Entrez le nom du module <SLF.....> a modifier :"
                    DB      "$"

                    ;[07b3]
STR_NORMAL:
                    DB      "\x0D\x0A\x0A"
                    DB      "Valeur des touches en mode "
                    DB      "\x1B\x48"
                    DB      "NORMAL"
                    DB      "\x1B\x49"
                    DB      "$"

STR_SHIFT:                                                  ;[07dc]
                    DB      "\x0D\x0A\x0A"
                    DB      "Valeur des touches en mode "
                    DB      "\x1B\x48"
                    DB      "SHIFT"
                    DB      "\x1B\x49$"

STR_CTRL:                                                   ;[0804]
                    DB      "\x0D\x0A\x0A"
                    DB      "Valeur des touches en mode "
                    DB      "\x1B\x48"
                    DB      "CONTROL"
                    DB      "\x1B\x49$"

STR_REBOOT:                                                 ;[082e]
                    DB      "\x0D\x0A\x1B\x48"
                    DB      "Rebooter pour installer le nouveau clavier"
                    DB      "\x1B\x49$"

STR_MODULE:                                                 ;[0863]
                    DB      "\x0d\x0a\x0a\x07Module $"

STR_INEXISTANT:                                             ;[086b]
                    DB      ".COM inexistant sur cette disquette$"

STR_DIR_PLEINE:                                             ;[088f]
                    DB      "\x0d\x0a\x0a\x07Creation impossible\x2e\x2e\x2eDirectorie pleine$"

STR_DISC_PLEINE:                                            ;[08bb]
                    DB      "\x0d\x0a\x0a\x07Erreur ecriture\x2e\x2e\x2eDisquette pleine$"

STR_BADFNAME:                                               ;[08e2]
                    DB      "\x0D\x0A\x0A\x07"
                    DB      "Le fichier n est pas un <SLF.....>$"

STR_PROMPT:                                                 ;[0909]
                    DB      "\x1B\x3D\x37"
                    DB      " Appuyez sur le caractere a modifier : "
                    DB      "$"

STR_SPACES:                                                 ;[0934]
                    DB      "\x1B\x3D\x37"
                    DB      "                                                                     $"

                    ; TODO                                  ;[097d]
                    DB      "\x1b=(!$"
                    DB      "\x1b=)!$"
                    DB      "\x1b=+#$"
                    DB      "\x1b=,#$"
                    DB      "\x1b=\x2e,$"
                    DB      "\x1b=/,$"
                    DB      "\x1b=10$"
                    DB      "\x1b=20$"
                    DB      "\x1b=46$"
                    DB      "\x1b=53SPACE (Ecran suivant)$"
                    DB      "\x1b=%a$"
                    DB      "\x1b=&a$"
                    DB      "\x1b=(a$"
                    DB      "\x1b=)a$"
                    DB      "\x1b=+a$"
                    DB      "\x1b=,a$"
                    DB      "\x1b=\x2ea$"
                    DB      "\x1b=/a$"
                    DB      "\x1b=1a$"
                    DB      "\x1b=2a$"
                    DB      "\x1b=% $"

STR_NOUVELLE:                                               ;[09fb]
                    DB      " Nouvelle valeur (HEXA) :$"

STR_INCOMPATIBLE:                                           ;[0a15]
                    DB      "\x0D\x0A"
                    DB      "Machine incompatible avec ce programme"
                    DB      "$"

                    ;[0a3e]
STR_FILENAME:
                    DB      "SLF00"
                    ;[0a43]
                    DB      $20,$24
STR_SPECIAL:                                                ;[0a45]
                    DB      "BEL$"
                    DB      "CLS$"
                    DB      "DEL$"
                    DB      "ESC$"
                    DB      "TAB$"
                    DB      "BRK$"
                    DB      "RET$"
                    DB      "LF $"
                    DB      "CE $"
                    DB      "CAN$"

                    nop                                     ;[0a6d] 00
                    nop                                     ;[0a6e] 00
                    nop                                     ;[0a6f] 00
                    nop                                     ;[0a70] 00
                    nop                                     ;[0a71] 00
                    nop                                     ;[0a72] 00
                    nop                                     ;[0a73] 00
                    nop                                     ;[0a74] 00
                    ; Points to the current keyboard layout (NORMAL, SHIFT,
                    ; CONTROL). The pointed data is inside slfbuff.
layout_p:
                    DW 0x0000                               ;[0a75]
                    ; Points to the slfbuff area used to load the chunks
                    ; of the SLF file (i.e. the buffer where the file is placed)
dmaoff_p:
                    DW 0x0000                               ;[0a77] 00
                    nop                                     ;[0a79] 00
                    nop                                     ;[0a7a] 00
                    nop                                     ;[0a7b] 00
                    nop                                     ;[0a7c] 00

IO_KBDST:                                                   ;[0a7d]
                    DB 0

IO_KBDCH:                                                   ;[0a7e]
                    DB 0

                    ; Stack (i think) from here, up to 0ab4 excluded
                    nop                                     ;[0a7f] 00

                    ; TODO. it is 0 when handling NORMAL, 1 when SHIFT or CONTROL
                    DB 0                                    ;[0a80]
                    nop                                     ;[0a81]
                    or      a                               ;[0a82] b7
                    nop                                     ;[0a83] 00
                    nop                                     ;[0a84] 00
                    nop                                     ;[0a85] 00
                    nop                                     ;[0a86] 00
                    nop                                     ;[0a87] 00
                    nop                                     ;[0a88] 00
                    nop                                     ;[0a89] 00
                    nop                                     ;[0a8a] 00
                    nop                                     ;[0a8b] 00
                    nop                                     ;[0a8c] 00
                    nop                                     ;[0a8d] 00
                    nop                                     ;[0a8e] 00
                    nop                                     ;[0a8f] 00
                    nop                                     ;[0a90] 00
                    nop                                     ;[0a91] 00
                    nop                                     ;[0a92] 00
                    nop                                     ;[0a93] 00
                    nop                                     ;[0a94] 00
                    nop                                     ;[0a95] 00
                    nop                                     ;[0a96] 00
                    nop                                     ;[0a97] 00
                    nop                                     ;[0a98] 00
                    nop                                     ;[0a99] 00
                    nop                                     ;[0a9a] 00
                    nop                                     ;[0a9b] 00
                    nop                                     ;[0a9c] 00
                    nop                                     ;[0a9d] 00
                    nop                                     ;[0a9e] 00
                    nop                                     ;[0a9f] 00
                    nop                                     ;[0aa0] 00
                    nop                                     ;[0aa1] 00
                    nop                                     ;[0aa2] 00
                    nop                                     ;[0aa3] 00
                    nop                                     ;[0aa4] 00
                    nop                                     ;[0aa5] 00
                    nop                                     ;[0aa6] 00
                    nop                                     ;[0aa7] 00
                    nop                                     ;[0aa8] 00
                    nop                                     ;[0aa9] 00
                    nop                                     ;[0aaa] 00
                    nop                                     ;[0aab] 00
                    nop                                     ;[0aac] 00
                    nop                                     ;[0aad] 00
                    nop                                     ;[0aae] 00
                    nop                                     ;[0aaf] 00
                    nop                                     ;[0ab0] 00
                    nop                                     ;[0ab1] 00
                    nop                                     ;[0ab2] 00
                    nop                                     ;[0ab3] 00

                    ; the buffer area where the SLF file is loaded.
                    ; Note: the stack starts from here and grows to lower
                    ; addresses
slfbuff:                                                    ;[0ab4]
                    DB      "programme$"
                    DB      "SLF00 $"
                    DB      "BEL$"
                    DB      "CLS$"
                    DB      "DEL$"
                    DB      "ESC$"
                    DB      "TAB$"
                    DB      "BRK$"
                    DB      "RET$"
                    DB      "LF $"
                    DB      "CE $"
                    DB      "CAN$"

                    nop                                     ;[0aed] 00
                    nop                                     ;[0aee] 00
                    nop                                     ;[0aef] 00
                    nop                                     ;[0af0] 00
                    nop                                     ;[0af1] 00
                    nop                                     ;[0af2] 00
                    nop                                     ;[0af3] 00
                    nop                                     ;[0af4] 00
                    nop                                     ;[0af5] 00
                    nop                                     ;[0af6] 00
                    nop                                     ;[0af7] 00
                    nop                                     ;[0af8] 00
                    nop                                     ;[0af9] 00
                    nop                                     ;[0afa] 00
                    nop                                     ;[0afb] 00
                    nop                                     ;[0afc] 00
                    nop                                     ;[0afd] 00
                    nop                                     ;[0afe] 00
                    nop                                     ;[0aff] 00
