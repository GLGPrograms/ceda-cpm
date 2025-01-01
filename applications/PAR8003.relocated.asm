; Relocated code from PAR8003.COM.
; This code reimplements the rwfs routines.
; Actually, I copied the rwfs routines from the ROM and adapted them adding the
; missing lines.
; z80asm FUNK00.COM.asm -b -o FUNK00.COM

    org 0xbc00

    ; FDC Read Write Format Seek routine.
    ; Arguments:
    ; - a: bytes per sector "shift factor", bps = 0x80 << a
    ; - b: operation command, see switch in this routine
    ; - c: drive number (0-3) + HD flag
    ; - d: track number
    ; - e: sector number
    ; - hl: read/write buffer address
fdc_rwfs:
    push    bc
    push    de
    push    hl
    ld      hl,todo_wip
    ld      (hl),$00
    bit     7,a
    jr      z,label_03a6
    ld      (hl),$01
label_03a6:
    res     7,a
    ld      ($ffb8),a                       ; bytes per sector
    pop     hl
    push    hl
    ld      a,$0a
    ld      ($ffbf),a                       ; value used in error checking routines
    ld      ($ffb9),bc                      ; *$ffb9 = drive no. + HD flag, *$ffba = operation command
    ld      ($ffbb),de                      ; *$ffbb = sector number, *$ffbc = track number
    ld      ($ffbd),hl                      ; base address for read/write buffer
    call    fdc_initialize_drive            ; move head to track 0 if never done before on current drive
    ld      a,($ffba)                       ; load command byte
    and     $f0                             ; take only the most significant nibble
    jp      z,fdc_sw_track0                 ; case $00: move to track 0 (home)
    cp      $40
    jp      z,fdc_sw_read_data              ; case $40: read sector in hl buffer
    cp      $80
    jp      z,fdc_sw_write_data             ; case $80: write sector in hl buffer
    cp      $20
    jp      z,fdc_sw_seek                   ; case $20: move head to desired track
    cp      $f0
    jp      z,fdc_sw_format                 ; case $f0: format desired track
    ld      a,$ff
    jp      fdc_sw_default                  ; default: return -1
fdc_sw_write_data:
    call    fdc_write_data
    jr      fdc_sw_default
fdc_sw_read_data:
    call    fdc_read_data
    jr      fdc_sw_default
fdc_sw_seek:
    call    fdc_seek
    jr      fdc_sw_default
fdc_sw_track0:
    call    fdc_track0
    jr      fdc_sw_default
fdc_sw_format:
    call    fdc_format
    jr      fdc_sw_default
fdc_sw_default:
    pop     hl
    pop     de
    pop     bc
    ret

    ; FDC write data routine
    ; Writes data from *$ffbd to desired track/sector
    ; Arguments are stored in $ffb8-$ffbf, as explained in caller fdc_rwfs
fdc_write_data:
    call    fdc_seek                        ; move to desired track
fdc_write_retry_c1f7:
    call    fdc_compute_bps                 ; compute bytes to be processed, result in de
    push    de
    call    fdc_wait_busy
    ld      c,$c5                           ; load "write data" command with MT and MF flags set
    ld      a,($ffb8)
    or      a
    jr      nz,label_c208                   ; if ssf = 0 (128 bytes per sector)...
    res     6,c                             ; ...clear MF flag (FM mode)
label_c208:
    call    fdc_send_cmd                    ; send the "write data" command with desired MF flag
    di                                      ; disable interrupts
    call    fdc_send_rw_args                ; send "write data" arguments (common with "read data" arguments)
    pop     de
    ld      c,$c1                           ; prepare IO address in c
    ld      b,e                             ; load number of bytes to write (LSB)
    ld      hl,($ffbd)                      ; load base address of writing buffer
    ; Buffer writing loop
label_c216:
    in      a,($82)                         ; wait until FDC is ready (INT = 1)
    bit     2,a
    jr      z,label_c216
    in      a,($c0)                         ; read FDC main status register
    bit     5,a                             ; check if still in execution phase...
    jr      z,label_c229                    ; ...if not, end writing
    outi                                    ; write data from buffer to FDC:  IO(c) = *(hl++); b--;
    jr      nz,label_c216
    dec     d
    jr      nz,label_c216                   ; write ends when d = 0 and b = 0

label_c229:
    out     ($dc),a                         ; request Terminal Count to FDC
    ei                                      ; enable interrupts again
    call    fdc_rw_status                   ; read command response, put it in $ffc0-$ffc6
    ld      a,($ffc0)                       ; fetch status (ST0)
    and     $c0                             ; mask Interrupt Code bits (as in fdc_sis routine)...
    cp      $40
    jr      nz,label_c248                   ; ... and return if IC != 01 (!= "readfail")
    call    fdc_err_check                   ; after-write error checking (common with "read data")
    ld      a,($ffbf)                       ; keep a retry counter to avoid infinite loops
    dec     a                               ; decrement number of remaining retry
    ld      ($ffbf),a
    jp      nz,fdc_write_retry_c1f7         ; after 10 tries give up and...
    ld      a,$ff
    ret                                     ; ... return -1
label_c248:
    xor     a
    ret                                     ; return 0

    ; FDC read data routine
    ; Read data from desired track/sector to *$ffbd
    ; Arguments are stored in $ffb8-$ffbf, as explained in caller fdc_rwfs
fdc_read_data:
    call    fdc_seek                        ; move to desired track
fdc_read_retry:
    call    fdc_compute_bps                 ; compute bytes to be processed, result in de
    push    de
    call    fdc_wait_busy
    ld      c,$c6                           ; load "read data" command with MT and MF flags set
    ld      a,($ffb8)
    or      a
    jr      nz,label_c25e                   ; if ssf = 0 (128 bytes per sector)...
    res     6,c                             ; ...clear MF flag (FM mode)
label_c25e:
    call    fdc_send_cmd                    ; send the "read data" command
    di                                      ; disable interrupts
    call    fdc_send_rw_args                ; send "read data" arguments (common with "write data" arguments)
    pop     de
    ld      c,$c1                           ; prepare IO address in c
    ld      b,e                             ; load number of bytes to write (LSB)
    ld      hl,($ffbd)                      ; load base address of reading buffer
label_c26c:
    in      a,($82)                         ; wait until FDC is ready (INT = 1)
    bit     2,a
    jr      z,label_c26c
    in      a,($c0)                         ; read FDC main status register
    bit     5,a                             ; check if still in execution phase...
    jr      z,label_c27f                    ; ...if not, end reading
    ini                                     ; read data from FDC to *hl, hl++, b--
    jr      nz,label_c26c
    dec     d
    jr      nz,label_c26c                   ; read ends when d = 0 and b = 0

label_c27f:
    out     ($dc),a                         ; request Terminal Count to FDC
    ei                                      ; enable interrupts again
    call    fdc_rw_status                   ; read command response, put it in $ffc0-$ffc6
    ld      a,($ffc0)                       ; fetch status (ST0)
    and     $c0                             ; mask Interrupt Code bits (as in fdc_sis routine)...
    cp      $40
    jr      nz,label_c29e                   ;... and return if IC != 01 (!= "readfail")
    call    fdc_err_check                   ; after-write error checking (common with "write data")
    ld      a,($ffbf)                       ; keep a retry counter to avoid infinite loops
    dec     a                               ; decrement number of remaining retry
    ld      ($ffbf),a
    jp      nz,fdc_read_retry               ; after 10 tries give up and...
    ld      a,$ff
    ret                                     ; ... return -1
label_c29e:
    xor     a
    ret                                     ; return 0

    ; FDC utility function: called only if read or write operation fails.
    ; A head position reset (recalibrate) is issued if overrun or missing
    ; address mark in data field event occur.
fdc_err_check:
    ld      a,($ffc2)                       ; read 2nd status register (ST1)
    bit     4,a                             ; check OverRun bit (OR)
    jr      z,label_c2ab                    ; if not set, return, else...
    call    fdc_track0                      ; ...reset head position...
    ret                                     ; ...and return for retry
label_c2ab:
    ld      a,($ffc1)                       ; read 3rd status register (ST2)
    bit     0,a                             ; check Missing Address Mark in Data Field (MD) bit
    jr      z,label_c2b6                    ; if not set, return, else...
    call    fdc_track0                      ; ...reset head position...
    ret                                     ; ...and return for retry
label_c2b6:
    ret                                     ; return and just retry

    ; FDC utility function: compute number of bytes to be moved
    ; Arguments:
    ; - $ffb8: sector size factor (bps = 0x80 << ssf)
    ;          Note: if = 0, FM encoding is used. If != 0, MFM encoding is used
    ; - $ffba: sector burst (bits 3:0)
    ; - $ffbb: sector burst enabled (bit 7), valid only for ssf = 3
    ; Return:
    ; - de: bytes to be processed

    ; | ssf  | sbe = 0 |     sbe = 1      |
    ; | ---- | ------- | ---------------- |
    ; |  0   |       128 + 256 * sb       |
    ; |  1   |       256 + 256 * sb       |
    ; |  2   |       256 + 256 * sb       |
    ; |  3   |   1024  | 1024 + 1024 * sb |
fdc_compute_bps:
    ld      e,$00                           ; e = 0
    ld      a,($ffb8)                       ; load ssf, valid values are 0 to 3
    cp      $03
    jr      nz,label_c2d4                   ; handle separately ssf != 3
    ld      d,$04                           ; if ssf = 3 (bps = 1024) d = 4
    ld      a,($ffbb)                       ; load sector burst enabled bit
    bit     7,a
    jr      z,label_c2e2                    ; if sbe = 0, just return (e = 0 (256), d = 4 --> 1024)
    ld      a,($ffba)                       ; load (lower nibble of) operation command
    and     $0f
    rlca
    rlca
    add     d
    ld      d,a                             ; return: d = (sb + 1) * 4
    jr      label_c2e2                      ; e = 0 --> 1024 + 1024 * sb

label_c2d4:                                 ;       if bytes per sector != 1024...
    or      a
    jr      nz,label_c2d9
    ld      e,$80                           ; if ssf = 0, e = 128
label_c2d9:
    ld      a,($ffba)                       ; load sector burst
    and     $0f
    ld      d,$01
    add     d
    ld      d,a                             ; d = sb + 1
label_c2e2:
    ret

    ; Format floppy disk
    ; Arguments are stored in $ffb8-$ffbf, as explained in caller fdc_rwfs
    ; During format, ID fields are supplied to FDC, one for each sector in track.
    ; Each ID field is 4 bytes long.
fdc_format:
    call    fdc_seek                        ; move to desired track
    cp      $ff                             ; if not able to locate track...
    ret     z                               ; ...return -1
    ld      b,$14                           ; if ssf=3, 5 sectors per track (5*4=20)
    ld      a,($ffb8)                       ; load sector size factor
    cp      $03
    jr      z,label_c2f4                    ; if less than 1024 bytes per sector...
    ld      b,$40                           ; if ssf<3, 16 sectors per track (16*4=64)
label_c2f4:
    push    bc
    call    fdc_wait_busy
    ld      c,$4d
    call    fdc_send_cmd                    ; send "write id" command
    ld      bc,($ffb9)                      ; 1st argument: drive number (c <= *$ffb9)
    call    fdc_send_cmd
    ld      a,($ffb8)                       ; 2nd argument: sector size factor
    ld      c,a
    call    fdc_send_cmd
    ld      c,$05                           ; if ssf = 3, sectors per track = 5
    ld      a,($ffb8)                       ; laod ssf
    cp      $03
    jr      z,label_c316
    ld      c,$10                           ; if *ssf != 3, sectors per track = 16
label_c316:
    call    fdc_send_cmd                    ; 3rd argument: sectors per track
    ld      c,$28                           ; gap length is 40
    call    fdc_send_cmd                    ; 4rd argument: gap3 length
    di                                      ; disable interrupts
    ld      c,$e5
    call    fdc_send_cmd                    ; 5th argument: filler byte value = 0xe5
    pop     bc
    ld      c,$c1                           ; prepare IO address in c
    ld      hl,($ffbd)                      ; prepare buffer address in hl
label_c32a:
    in      a,($82)                         ; wait until FDC is ready (INT = 1)
    bit     2,a
    jr      z,label_c32a
    in      a,($c0)                         ; read main status register
    bit     5,a                             ; check if still in execution phase...
    jr      z,label_c33a                    ; ...if not, end formatting
    outi                                    ; write sector IDs
    jr      nz,label_c32a
label_c33a:
    out     ($dc),a                         ; request Terminal Count to FDC
    ei                                      ; enable interrupts again
    call    fdc_rw_status                   ; command response, put it in $ffc0-$ffc6
    ld      a,($ffc0)                       ; fetch status (ST0)
    and     $c0                             ; mask Interrupt Code bits (as in fdc_sis routine)...
    cp      $40
    jr      nz,label_c34c                   ; ... and return if IC != 01 (!= "readfail")
    ld      a,$ff
    ret                                     ; return -1
label_c34c:
    xor     a
    ret                                     ; return 0

    ; FDC utility function: send arguments for read or write data commands
fdc_send_rw_args:
    ld      bc,($ffb9)                      ; 1st argument: load drive number
    call    fdc_send_cmd
    ld      de,($ffbb)                      ; 2nd argument: track number
    ld      c,d                             ; track is in d <= *$ffbc
    call    fdc_send_cmd
    ld      bc,($ffb9)                      ; ffb9 contains HD flag too (physical head number)
    ld      a,c
    and     $04                             ; extract bit 2 (HD)
    rrca
    rrca                                    ; Move in bit 0 position
    ld      c,a
    call    fdc_send_cmd                    ; 3rd argument: head number (0/1)
    res     7,e                             ; reset bit 7 in e (sector number register loaded before)
    ld      c,e
    inc     c                               ; hypothesys: sector number - 1 is stored in $ffbb
    call    fdc_send_cmd                    ; 4th argument: sector number to write
    ld      a,($ffb8)
    ld      c,a
    call    fdc_send_cmd                    ; 5th argument: bytes per sector "factor"
    ld      c,$05                           ; default value for EOT = 5
    ld      a,($ffb8)                       ; load bytes per sector "factor"
    cp      $03
    jr      z,label_c383                    ; if less than 1024 bytes per sector...
    ld      c,$10                           ; override EOT with c = 16
label_c383:
    call    fdc_send_cmd                    ; 6th argument: EOT - final sector of a track
    ld      c,$28
    call    fdc_send_cmd                    ; 7th argument: GPL - gap length fixed to 0x28
    ld      c,$ff
    call    fdc_send_cmd                    ; 8th argument: DTL - data length, should be invalid if 5th argument is != 0
    ret

    ; This routine seems to move the floppy head to track 0, then waits for the operation execution
fdc_track0:
    call    fdc_wait_busy
    ld      c,$07                           ; Recalibrate command
    call    fdc_send_cmd                    ; Send command to FDC
    ld      bc,($ffb9)                      ; Load drive number?
    res     2,c                             ; For some reason, clear bit 2. Recalibrate argument must be 0b000000xx, where xx = drive number in [0,3]
    call    fdc_send_cmd                    ; Send command to FDC
    call    fdc_sis                         ; send SIS to check if head movement was correctly completed
    jr      z,fdc_track0                    ; check if return is "readfail" (Z = 0) then retry, else...
    xor     a                               ; ... return 0
    ret

    ; FDC: sends the seek command and move head upon desired track
    ; Arguments:
    ; - $ffbb: new track number
    ; - $ffb9: drive number
fdc_seek:
    ld      de,($ffbb)                      ; load track number
    ld      a,d                             ; track number is in d <= *$ffbc
    or      a                               ; check if requested track is 0...
    jp      z,fdc_track0                    ; if track = 0, skip this and call appropriate routine
    call    fdc_wait_busy
    ld      c,$0f                           ; send "seek" command
    call    fdc_send_cmd
    ld      bc,($ffb9)                      ; 1st arg: load and send *$ffb9 = drive number + HD flag
    call    fdc_send_cmd
    ld      hl,todo_wip
    bit     0,(hl)
    jr      z,label_05d4
    sla     d
label_05d4:
    ld      c,d                             ; 2nd arg: send NCN (new cylinder number) = desired track
    call    fdc_send_cmd
    call    fdc_sis                         ; sends SIS to check if head movement was correctly completed
    jr      nz,label_c3d0                   ; if fdc_sis returns "OK" (Z != 0), return, else...
    call    fdc_track0                      ; ...move head to track 0...
    jp      fdc_seek                        ; ...and try again
label_c3d0:
    xor     a                               ; On success, a=0 and return
    ret

    ; FDC utility function: send "Sense Interrupt Status" command and read the two bytes (ST0, PCN)
    ; Return:
    ; - Z flag from the comparison (ST0 & 0xC0) == 0x40.
    ;   ST0[7:6] is Interrupt Code, and is:
    ;     - 00 if previous operation was successful (OK);
    ;     - 01 if previous operation was not successful (readfail);
    ;     - other cases are treated as successful.
fdc_sis:
    in      a,($82)                         ; wait until FDC is ready (INT = 1)
    bit     2,a
    jp      z,fdc_sis
    call    fdc_wait_busy
    call    fdc_wait_rqm_wr                 ; wait until FDC is ready for write request
    ld      a,$08                           ; send "Sense Interrupt Status" command
    out     ($c1),a
    call    fdc_wait_rqm_rd                 ; wait for data ready from FDC
    in      a,($c1)                         ; read status byte (ST0)
    ld      b,a
    call    fdc_wait_rqm_rd
    in      a,($c1)                         ; read present cylinder number (PCN), aka current track
    ld      a,b                             ; discard PCN
    and     $c0
    cp      $40                             ; perform (ST0 & 0xC0) == 0x40
    ret                                     ; return is in Z flag

    ; FDC utility function: read response after read/write/format execution.
    ; A 7 byte response is given, read it all in $ffc0-$ffc6
fdc_rw_status:
    ld      hl,$ffc0                        ; buffer pointer
    ld      b,$07                           ; data length, answer is 7 byte long
    ld      c,$c1                           ; IO address
label_c3fb:
    call    fdc_wait_rqm_rd                 ; wait until FDC is ready to send data
    ini                                     ; read from IO in *hl, hl++, b--
    jr      nz,label_c3fb                   ; end if b = 0
    ret

    ; SUBROUTINE C403 ; wait for ioaddr(0xc0) to become "0b10xxxxxx"
    ; FDC utility function: read main status register and wait for RQM = 1 and DIO = 0.
    ; RQM = request from master, RQM = 1 means FDC is ready for communication with the CPU
    ; DIO = data input/output, DIO = 0 means transfer from CPU to FDC
fdc_wait_rqm_wr:
    in      a,($c0)
    rlca
    jr      nc,fdc_wait_rqm_wr              ; while (bit7 == 0), try again
    rlca
    jr      c,fdc_wait_rqm_wr               ; while (bit7 == 1) && (bit6 == 1), try again
    ret

    ; SUBROUTINE C40C ; wait for ioaddr(0xc0) to become "0b11xxxxxx"
    ; FDC utility function: read main status register and wait for RQM = 1 and DIO = 1
    ; RQM = request from master, RQM = 1 means FDC is ready for communication with the CPU
    ; DIO = data input/output, DIO = 1 means transfer from FDC to CPU
fdc_wait_rqm_rd:
    in      a,($c0)
    rlca
    jr      nc,fdc_wait_rqm_rd              ; while (bit7 == 0), try again
    rlca
    jr      nc,fdc_wait_rqm_rd              ; while (bit7 == 1) && (bit6 == 0), try again
    ret

    ; SUBROUTINE C415
    ; FDC utility function: send a command byte to the FDC
    ; Arguments:
    ; - c: the command byte
fdc_send_cmd:
    call    fdc_wait_rqm_wr                 ; wait until FDC is ready to receive data
    ld      a,c
    out     ($c1),a                         ; actually send the comamnd
    ret

    ; SUBROUTINE C41C ; while( ioaddr(0xc0).4 == 1 ), wait
    ; FDC utility function: wait until the FDC is no more busy.
    ; $C0 may be the main status register, where bit 4 is the CB (active high busy) flag.
fdc_wait_busy:
    in      a,($c0)
    bit     4,a
    jr      nz,fdc_wait_busy
    ret

    ; FDC drive initialization
    ; Reset head position at least one time per drive since the computer was
    ; turned on.
    ; Arguments:
    ; - c: drive number
fdc_initialize_drive:
    ld      b,$01
    ld      a,c
    and     $03                             ; mask drive number only
    or      a
    jr      z,label_c430
label_c42b:
    rlc     b                               ; at the end of the cycle...
    dec     a                               ; ... b = 1 << (drive number)
    jr      nz,label_c42b
label_c430:
    ld      a,($ffc7)
    ld      c,a
    and     b                               ; if this drive was already initialized...
    ret     nz                              ; ...return doing nothing
    ld      a,c
    or      b                               ; else, mark this drive as initialized...
    ld      ($ffc7),a                       ; ...store this information in ram...
    call    fdc_track0                      ; ...and perform initialization (aka move head to track 0)
    ret

    ; SUBROUTINE C43F
    ; FDC initialization.
    ; Configure the FDC IC with:
    ; - SRT = 6 (Step Rate Time = 6ms)
    ; - HUT = F (Head Unload Time = 240ms)
    ; - HLT = D (Head Load Time = 26ms)
    ; - ND = 1 (DMA mode disabled)
fdc_init:
    push    bc
    push    hl
    ld      hl,fdc_cfg_base                 ; prepare HL to address FDC configuration table
    call    fdc_wait_busy
    ld      c,$03                           ; send "specify" command
    call    fdc_send_cmd
    ld      c,(hl)                          ; load first "specify" argument from table
    inc     hl
    call    fdc_send_cmd                    ; send SRT | HUT
    ld      c,(hl)                          ; load second "specify" argument from table
    call    fdc_send_cmd                    ; send HLT | ND
    xor     a
    ld      ($ffc7),a                       ; *$ffc7 = 0
    pop     hl
    pop     bc
    ret

todo_wip:
    BYTE $00

    ; STATIC DATA for C43F
fdc_cfg_base:
    BYTE $6f                                ; SRT << 4 | HUT
    BYTE $1b                                ; HLT << 1 | ND