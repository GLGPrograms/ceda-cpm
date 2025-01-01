    org $b821

scancode_table:
    REPT 640                                ;[b821]
    nop
    ENDR

mr2_table:                                  ;[baa1]
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

mr1_table:                                  ;[badb]
    DB  $61,$DB,$D6
    DB  $65,$DC,$D7
    DB  $69,$DD,$D8
    DB  $6F,$DE,$D9
    DB  $75,$DF,$DA
    DB  $00

mr1_scratch:                                ;[baeb]
    DB  $00

; Briefly, this routine takes c as parameter.
; It has some kind of memory, since it uses mr1_scratch as internal status.
; If c is $f1, mr1_scratch is set to 1 else is set to 2 and carry flag is set.
; For all other values of c, the c value is used to find an entry in mr1_table table.
; If mr1_scratch is zero, c itself is returned
; If mr1_scratch is one, left value of the table is returned in c.
; If mr1_scratch is two, right value of the table is returned in c.
; At the end, mr1_scratch is clear.
mysterious_routine_1:                       ;[baec]
    ld a,c
    cp $f1
    jr z,mr1_isf1
    cp $f2
    jr nz,mr1_nof1f2
    ld a,$02                                ; if $f2, write 2 in mr1_scratch and return
    jr mr1_f1f2_epilogue
mr1_isf1:
    ld a,$01                                ; if $f1, write 1 in mr1_scratch and return
mr1_f1f2_epilogue:
    ld (mr1_scratch),a
    scf                                     ; carry set
    ret
    ; Anything but f1 and f2
mr1_nof1f2:
    ld a,(mr1_scratch)
    or a
    jr z,mr1_return
    ld hl,mr1_table
    ld b,$05
mr1_loop:
    ld a,(hl)
    cp c
    jr z,mr1_found
    inc hl
    inc hl
    inc hl
    djnz mr1_loop
epilogue:
    xor a
    ld (mr1_scratch),a     ; clear mr1_scratch
mr1_return:
    ret
mr1_found:
    ld a,(mr1_scratch)
    ld b,$00
    ld c,a
    add hl,bc
    ld c,(hl)                               ; c = hl + mr1_scratch
    jr epilogue                             ; where hl is the pointer to found


; Briefly, this routine takes c as parameter.
; It has some kind of memory, since it uses:
;   - mr2_scratch as internal status
;   - the jp at the entrypoint as trampoline, since its jp address is altered at runtime!
; By default, mr2_entrypoint1 is used as trampoline jp address.
; Following this branch, c value is used to find an entry in the mr2_table table.
; If found, left value of the entry is returned in c, right value in a.
; A pointer to the the right value is stored in the mr2_scratch.
; If the right value is zero, the routine returns.
; If the right value is not zero, trampoline is altered enabling the secondary entrypoint.
; If the entrypoint has been altered, the next calls follow a fixed pattern:
;   - mr2_entrypoint2: c cargument is returned as is, $08 is returned in a and
;     trampoline is changed to mr2_entrypoint3.
;   - mr2_entrypoint3: the right value that triggered the alternate path is loaded in c (via mr2_scratch).
;     a is zeroed and path is restored to the default entrypoint.
mysterious_routine_2:                       ;[bb23]
    jp mr2_entrypoint1                      ; this jp is altered at runtime!
mr2_entrypoint1:
    ld a,c
    bit 7,a
    ret z                                   ; return if bit 7 is cleared
    ld hl,mr2_table
mr2_loop:
    ld a,(hl)
    or a
    ret z
    cp c
    inc hl
    jr z,mr2_mr1_found
    inc hl
    inc hl
    jr mr2_loop
mr2_mr1_found:
    ld c,(hl)
    inc hl
    ld (mr2_scratch),hl
    ld a,(hl)
    or a
    ret z
    ld a,c
    ld de,mr2_entrypoint2                   ; change the entrypoint to the first stage alternate one
    jr mr2_epilogue

mr2_entrypoint2:                            ; first stage alternate entrypoint
    ld a,$08
    ld de,mr2_entrypoint3                   ; change the entrypoint to the second stage alternate one
    jr mr2_epilogue

mr2_entrypoint3:                            ; second stage alternate entrypoint
    ld hl,(mr2_scratch)
    ld c,(hl)                               ; take back the "right value" that triggered the alternate path
    xor a
    ld de,mr2_entrypoint1                   ; restore the default entrypoint
mr2_epilogue:
    ld (mysterious_routine_2+1),de
    or a                                    ; set flags according to a content
    ret                                     ; result is in a

mr2_scratch:
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

    ; TODO referenced in CP/M BIOS when reading from kbd
pMysterious_routine_1:                      ;[bff6]
    DW mysterious_routine_1
    ; TODO referenced in CP/M BIOS when writing to printer
pMysterious_routine_2:                      ;[bff8]
    DW mysterious_routine_2

    ; Pointer to a custom routine used to handle escape during putchar.
    ; The routine is implemented here, and at the moment is just a ret.
    ; At the moment we don't know much about it, except that it is used by
    ; the ROM, so using putchar when CP/M is not initialized may lead to
    ; unexpected behavior!
pCustom_escape:                             ;[bffa]
    DW custom_escape

    ; This version string is populated by the cpm_bios with "8003", but
    ; SLF80037 overwrites it.
version:                                    ;[bffc]
    DB "8.10"
    DB 0
