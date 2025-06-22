    org $b821

    ; Empty, it's populated directly by the SLF80037 main code
scancode_table:
    REPT 640                                ;[b821]
    nop
    ENDR

    ; Local variables for the "accented letter print" routine
alp_table:                                  ;[baa1]
    DB  $D0,$5C,$00
    DB  $D1,$7E,$00
    DB  $D2,$7B,$00
    DB  $D3,$7D,$00
    DB  $D4,$40,$00
    DB  $D5,$7C,$00
    DB  $D6,$7E,$61
    DB  $D7,$7E,$65
    DB  $D8,$7E,$69
    DB  $D9,$7E,$6F
    DB  $DA,$7E,$75
    DB  $DB,$5E,$61
    DB  $DC,$5E,$65
    DB  $DD,$5E,$69
    DB  $DE,$5E,$6F
    DB  $DF,$5E,$75
    DB  $E0,$5B,$00
    DB  $E1,$5C,$00
    DB  $E2,$5D,$00
    DB  $00

dkh_table:                                  ;[badb]
    ; vowel,circumflex,umlaut
    DB  $61,       $DB, $D6 ; a
    DB  $65,       $DC, $D7 ; e
    DB  $69,       $DD, $D8 ; i
    DB  $6F,       $DE, $D9 ; o
    DB  $75,       $DF, $DA ; u
    DB  $00

dkh_scratch:                                ;[baeb]
    DB  $00

; Dead key handling
; The routine takes c as parameter, which is the input char, and leaves the eventually
; modified char in c as output. Carry is set if the output char should not be printed
; (i.e. when a modifier key is pressed).
; dkh_scratch is used as dead key status, deafult is 0 (no modifier key pressed and c itself
; is returned).
; There are two possible modifier keys that can change the output status: c=$f1 (up arrow) and
; c=$f2 (down arrow).
; If a modifier key is pressed, dkh_scratch is set to a value other than zero and carry is set:
; this changes the behavior of the routine at the next call:
; if the next pressed char is in dkh_table, then
; - left value of the table is returned in c if dkh_scratch is 1 (circumflex modifier).
; - right value of the table is returned in c if dkh_scratch is 2 (umlaut modifier).
; - the unchanged character is returned if it's not in dkh_table.
; At the end, dkh_scratch is clear.
deadKeyHandler:                             ;[baec]
    ld a,c
    cp $f1
    jr z,dkh_isf1
    cp $f2
    jr nz,dkh_nof1f2
    ld a,$02                                ; if $f2, write 2 in dkh_scratch and return
    jr dkh_f1f2_epilogue
dkh_isf1:
    ld a,$01                                ; if $f1, write 1 in dkh_scratch and return
dkh_f1f2_epilogue:
    ld (dkh_scratch),a
    scf                                     ; carry set
    ret
    ; Anything but f1 and f2
dkh_nof1f2:
    ld a,(dkh_scratch)
    or a
    jr z,dkh_return
    ld hl,dkh_table
    ld b,$05
dkh_loop:
    ld a,(hl)
    cp c
    jr z,dkh_found
    inc hl
    inc hl
    inc hl
    djnz dkh_loop
epilogue:
    xor a
    ld (dkh_scratch),a     ; clear dkh_scratch
dkh_return:
    ret
dkh_found:
    ld a,(dkh_scratch)
    ld b,$00
    ld c,a
    add hl,bc
    ld c,(hl)                               ; c = hl + dkh_scratch
    jr epilogue                             ; where hl is the pointer to found


; Briefly, this routine takes c as parameter.
; It has some kind of memory, since it uses:
;   - alp_scratch as internal status
;   - the jp at the entrypoint as trampoline, since its jp address is altered at runtime!
; By default, alp_entrypoint1 is used as trampoline jp address.
; Following this branch, c value is used to find an entry in the alp_table table.
; If found, left value of the entry is returned in c, right value in a.
; A pointer to the the right value is stored in the alp_scratch.
; If the right value is zero, the routine returns.
; If the right value is not zero, trampoline is altered enabling the secondary entrypoint.
; If the entrypoint has been altered, the next calls follow a fixed pattern:
;   - alp_entrypoint2: c cargument is returned as is, $08 is returned in a and
;     trampoline is changed to alp_entrypoint3.
;   - alp_entrypoint3: the right value that triggered the alternate path is loaded in c (via alp_scratch).
;     a is zeroed and path is restored to the default entrypoint.
accentedLetterPrintHandler:                 ;[bb23]
    jp alp_entrypoint1                      ; this jp is altered at runtime!
alp_entrypoint1:
    ld a,c
    bit 7,a
    ret z                                   ; return if bit 7 is cleared
    ld hl,alp_table
alp_loop:
    ld a,(hl)
    or a
    ret z
    cp c
    inc hl
    jr z,alp_found
    inc hl
    inc hl
    jr alp_loop
alp_found:
    ld c,(hl)
    inc hl
    ld (alp_scratch),hl
    ld a,(hl)
    or a
    ret z
    ld a,c
    ld de,alp_entrypoint2                   ; change the entrypoint to the first stage alternate one
    jr alp_epilogue

alp_entrypoint2:                            ; first stage alternate entrypoint
    ld a,$08
    ld de,alp_entrypoint3                   ; change the entrypoint to the second stage alternate one
    jr alp_epilogue

alp_entrypoint3:                            ; second stage alternate entrypoint
    ld hl,(alp_scratch)
    ld c,(hl)                               ; take back the "right value" that triggered the alternate path
    xor a
    ld de,alp_entrypoint1                   ; restore the default entrypoint
alp_epilogue:
    ld (accentedLetterPrintHandler+1),de
    or a                                    ; set flags according to a content
    ret                                     ; result is in a

alp_scratch:
    DW  $0000

; This function is indirectly called by ROM's putchar during second stage escaping
custom_escape:
    ret                                     ;[bb5d]

    REPT 1164
    nop
    ENDR

    DB "TT"                                 ;[bfea]
    DB 00
    DB 00
    DB 00
    DB 00
    DB 00
    DB 00

    ; pointer to the scancode table, used by CP/M bios routine to map
    ; keystrokes against ASCII characters
pScancode_table:                            ;[bff2]
    DW scancode_table

    ; Pointer to a sequence of fixed length strings, defined in SLF80037.COM.
    ; They are used for function key shortcuts.
    ; This pointer is initialized by SLF80037.COM.
pShortcuts_base:
    DB 0, 0                                 ;[bff4]

    ; Dead key handler pointer
    ; referenced in CP/M BIOS when reading from kbd
pDeadKeyHandler:                            ;[bff6]
    DW deadKeyHandler
    ; (TODO) Custom character print handler
    ; referenced in CP/M BIOS when writing to printer
pAccentedLetterPrintHandler:                ;[bff8]
    DW accentedLetterPrintHandler

    ; Pointer to a custom routine used to handle escape during putchar.
    ; The routine is implemented here, and at the moment is just a ret.
    ; At the moment we don't know much about it, except that it is used by
    ; the ROM, so using putchar when CP/M is not initialized may lead to
    ; unexpected behavior!
pCustom_escape:                             ;[bffa]
    DW custom_escape
                                            ;[bffc]
