; z80dasm 1.1.6
; command line: z80dasm -t -a -l ../from-cpmls/trx62.com
    
FILE_LIST := $0948
    
IO_SIO_ADDR := $b0
    
    org	$0100
    
entrypoint:
    nop                                     ;[0100] they like very much to lose time
    nop                                     ;[0101] 
    nop                                     ;[0102] 
    jp init                                 ;[0103] 
    
SIO_SETUP_WRAPPER:
    jp SIO_SETUP                            ;[0106] 
SIO_WRITE_WRAPPER:
    jp SIO_WRITE                            ;[0109] 
SIO_READ_WRAPPER:
    jp SIO_READ                             ;[010c] 
    
init:
    ld sp,stack_base                        ;[010f] initialize stack pointer
    call SIO_SETUP_WRAPPER                  ;[0112] Setup SIO
    ld hl,($0001)                           ;[0115] Take the BIOS entrypoint, aka base address of BIOS service routines
    ld de,$0006                             ;[0118] +6 displacement...
    add hl,de                               ;[011b] ... aka syscall #2, aka console input (CONIN)
    ld (trampoline_addr+1),hl               ;[011c] 
    call PRINT_NEXT_STR                     ;[011f] cd 20 03 	.   .
    DB "\r\n"
    DB "         "
    DB "File exchange program  vers 6.0 ,4800 Baud (SED)"
    DB "\r\n"
    DB $00
    jp main                                 ;[0160] 
    
; BEGIN stack area
    REPT 64
    DB $00
    ENDR
stack_base:
; END stack area
    
; Counter of files to be transferred (after wildcard expansion)
num_of_files:
    DB 0
    
; buffer area used by the getline routine
GETLINE_BUFSIZE := 76
getline_buffer:
    REPT GETLINE_BUFSIZE
    DB $00
    ENDR
    DB $20
    
drive_index:
    DB $00
    
; BEGIN: getline
; This routine populates the getline_buffer area with character until a newline.
; Backspace is handled to delete inserted chars.
; Only printable characters are allowed, and all alphabetic chars are made uppercase.
; (This leads to funny side effects since some symbols may be altered)
getline:
    call PRINT_NEXT_STR                     ;[01f2] 
    DB "\r\n"
    DB "*>"
    DB 0
    ld b,GETLINE_BUFSIZE                    ;[01fa] 
    ld hl,getline_buffer+GETLINE_BUFSIZE    ;[01fc] 
    getline_init_buf:                       ;       initialize the buffer area filling it with spaces
    dec hl                                  ;[01ff] 
    ld (hl),' '                             ;[0200] 
    djnz getline_init_buf                   ;[0202] 
    xor a                                   ;[0204] 
getline_out_loop:
    push af                                 ;[0205] 
getline_in_loop:
    call guard_bios_conin                   ;[0206] console input
    and $7f                                 ;[0209] Mask to get only chars in ASCII table
    cp $03                                  ;[020b] ETX
    jp z,epilogue                           ;[020d] terminate application
    cp '\r'                                 ;[0210] 
    jp z,handle_newline                     ;[0212] end the getline method and return buffer pointer
    cp $7f                                  ;[0215] DEL
    jp z,handle_delete                      ;[0217] 
    cp $08                                  ;[021a] Backspace
    jp z,handle_delete                      ;[021c] 
    cp ' '                                  ;[021f] first printable (valid) ASCII char
    jp c,handle_non_printable               ;[0221] if non printable...
    cp '~'                                  ;[0224] last printable (valid) ASCII char
    jp nc,handle_non_printable              ;[0226] if non printable... just beep and wait for another char
    cp 'A'                                  ;[0229] 
    jp c,is_symbol                          ;[022b] if less than 'A', skip (i.e. symbols or numbers)
    and $5f                                 ;[022e] else, transform lowercase chars to uppercase (and change some symbols... side effect)
    is_symbol:                              ;       is symbol or number, just store as is
    ld (hl),a                               ;[0230] store char
    call bdos_write                         ;[0231] then print it
    pop af                                  ;[0234] 
    inc a                                   ;[0235] 
    cp 76                                   ;[0236] 
    jp z,getline_ovf                        ;[0238] if buffer space for filenames is ended, terminate
    inc hl                                  ;[023b] 
    jp getline_out_loop                     ;[023c] 
    
; Buffer area overflowed. Print error message and start back with line read
getline_ovf:
    call PRINT_NEXT_STR                     ;[023f] 
    DB " ??"
    DB 0
    jp getline                              ;[0246] start back reading a new line
    
handle_non_printable:
    ld a,$07                                ;[0249] BEL
    call bdos_write                         ;[024b] just beep
    jp getline_in_loop                      ;[024e] and then continue acquiring chars
    
handle_delete:
    pop af                                  ;[0251] retrieve number of elements in buffer
    cp $00                                  ;[0252] if start of buffer, ...
    jp z,getline_out_loop                   ;[0254] ... just ignore delete and go on
    dec hl                                  ;[0257] else, move buffer pointer back
    dec a                                   ;[0258] and number of elements
    push af                                 ;[0259] 
    ld (hl),' '                             ;[025a] Clear the inserted char
    ld a,$08                                ;[025c] print backspace (move cursor back)
    call bdos_write                         ;[025e] 
    ld a,$20                                ;[0261] print space to overwrite char on the screen
    call bdos_write                         ;[0263] 
    ld a,$08                                ;[0266] move cursor back again
    call bdos_write                         ;[0268] 
    jp getline_in_loop                      ;[026b] 
    
;; Terminate the filename fetch loop
handle_newline:
    ld hl,getline_buffer                    ;[026e] 
    pop af                                  ;[0271] 
    ret                                     ;[0272] 
    
;; END of getline routine
    
; argument parser
; parse any filename passed as arguments to the program.
; Note 1: wildcard are supported
;  FILE*     -> all files starting by FILE, regardless of the extension
;  FILE*.EXT -> all files starting by FILE, with EXT extension
;  FILE.E*   -> all files named FILE with extension starting by E
; Note 2: if drive is specified, the drive letter MUST be uppercase!
arg_parser:
    push de                                 ;[0273] 
    call fcb_clear                          ;[0274] clear the FCB1 data structure
    inc hl                                  ;[0277] skip first char to check if drive is specified or just filename
    ld a,(hl)                               ;[0278] the second char may be ':', indicating that a drive letter was specified
    dec hl                                  ;[0279] restore pointer to beginning of argument string
    cp ':'                                  ;[027a] check if drive letter is specified
    ld a,$00                                ;[027c] preload default drive index
    jp nz,arg_no_drive                      ;[027e] if no drive letter specified, jump to filename parsing
    ld a,(hl)                               ;[0281] load the drive letter (1st char of the argument)
    cp 'A'                                  ;[0282] 
    jp c,invalid_file_name                  ;[0284] less than A is invalid
    cp 'E'                                  ;[0287] 
    jp nc,invalid_file_name                 ;[0289] bigger than E is invalid
    and $0f                                 ;[028c] get the drive index from the letter
    inc hl                                  ;[028e] skip drive letter
    inc hl                                  ;[028f] 
arg_no_drive:
    ld (drive_index),a                      ;[0290] store drive number (default one or specified with D: syntax)
    ld (de),a                               ;[0293] load drive index in DR byte of FCB
    inc de                                  ;[0294] move pointer to FCB to filename
    ld b,$08                                ;[0295] 
    fcb_fname_loop:                         ;       copy all the filename chars from the argument to FCB
    ld a,(hl)                               ;[0297] 
    cp '*'                                  ;[0298] check if wildcard char
    jp z,fcb_fname_is_wildcard              ;[029a] 
    cp '.'                                  ;[029d] if a dot is encountered, switch to filetype parsing
    jp z,fcb_fname_is_filetype              ;[029f] 
    ld (de),a                               ;[02a2] copy char in FCB and move pointers
    inc hl                                  ;[02a3] 
    inc de                                  ;[02a4] 
    djnz fcb_fname_loop                     ;[02a5] go on with file name reading
    ld a,(hl)                               ;[02a7] ...filename has ended,
    cp '.'                                  ;[02a8] check if filetype is specified
    jp nz,fcb_fname_no_filetype             ;[02aa] 
    fcb_fname_is_filetype:                  ;       filetype parsing section
    ex de,hl                                ;[02ad] save in de the current pointer in args string
    pop hl                                  ;[02ae] restore the initial FCB pointer in hl
    push hl                                 ;[02af] 
    ld bc,9                                 ;[02b0] 
    add hl,bc                               ;[02b3] shift FCB pointer to first filetype char
    ex de,hl                                ;[02b4] hl = pointer to '.' char of arguments
; 	  de = pointer to T1 byte in FCB
    fcb_parse_ftype:                        ;       copy all the filetype chars from the argument to FCB
    ld b,3                                  ;[02b5] number of bytes composing filetype
    inc hl                                  ;[02b7] skip '.'
fcb_ftype_loop:
    ld a,(hl)                               ;[02b8] 
    cp '*'                                  ;[02b9] 
    jp z,fcb_ftype_is_wildcard              ;[02bb] wildcard on filetype
    ld (de),a                               ;[02be] copy char in FCB
    inc hl                                  ;[02bf] update pointers
    inc de                                  ;[02c0] 
    djnz fcb_ftype_loop                     ;[02c1] continue copying filetype in FCB
    pop de                                  ;[02c3] 
    xor a                                   ;[02c4] 
    ret                                     ;[02c5] 
    
fcb_ftype_is_wildcard:
    ld a,'?'                                ;[02c6] fill the remaining chars of filetype with '?'
    ld (de),a                               ;[02c8] 
    inc de                                  ;[02c9] 
    djnz fcb_ftype_is_wildcard              ;[02ca] 
    pop de                                  ;[02cc] 
    xor a                                   ;[02cd] 
    ret                                     ;[02ce] 
    
fcb_fname_is_wildcard:
    ld a,'?'                                ;[02cf] fill the remaining chars of filename with '?'
    ld (de),a                               ;[02d1] 
    inc de                                  ;[02d2] 
    djnz fcb_fname_is_wildcard              ;[02d3] 
    inc hl                                  ;[02d5] check if, after wildcard char, a filetype is specified
    ld a,(hl)                               ;[02d6] 
    cp '.'                                  ;[02d7] 
    jp z,fcb_parse_ftype                    ;[02d9] 
    fcb_fname_no_filetype:                  ;       no filetype specified
    ld b,$03                                ;[02dc] 
    ld a,' '                                ;[02de] clear filetype bytes
fcb_clear_filetype:
    ld (de),a                               ;[02e0] 
    inc de                                  ;[02e1] 
    djnz fcb_clear_filetype                 ;[02e2] 
    pop de                                  ;[02e4] restore FCB pointer
    xor a                                   ;[02e5] 
    ret                                     ;[02e6] 
    
invalid_file_name:
    call PRINT_NEXT_STR                     ;[02e7] 
    DB "\r\n"
    DB "Invalid filename"
    DB $00
    ld a,$ff                                ;[02fd] 
    pop de                                  ;[02ff] 
    ret                                     ;[0300] 
    
; Clear file name in fcb
; Arguments:
;  de: pointer to FCB1 (File Control Block 1)
fcb_clear:
    push de                                 ;[0301] 
    xor a                                   ;[0302] 
    ld (de),a                               ;[0303] Set drive number to 0 (default)
    inc de                                  ;[0304] Move pointer to filename in FCB
    ld b,11                                 ;[0305] Number of characters in filename (8+3)
    ld a,' '                                ;[0307] 
fcb_clear_filename:
    ld (de),a                               ;[0309] clear the filename (write spaces)
    inc de                                  ;[030a] 
    djnz fcb_clear_filename                 ;[030b] 
    xor a                                   ;[030d] 
    ld b,21                                 ;[030e] Number of bytes of the rest of the FCB structure
fcb_clear_flags:
    ld (de),a                               ;[0310] 
    inc de                                  ;[0311] 
    djnz fcb_clear_flags                    ;[0312] 
    pop de                                  ;[0314] 
    ret                                     ;[0315] 
    
; Self-changing code (yaaay!)
; The call address is changed in init, then it calls the
; CONIN BIOS routine
guard_bios_conin:
    push bc                                 ;[0316] 
    push de                                 ;[0317] 
    push hl                                 ;[0318] 
trampoline_addr:
    call $0000                              ;[0319] 
    pop hl                                  ;[031c] 
    pop de                                  ;[031d] 
    pop bc                                  ;[031e] 
    ret                                     ;[031f] 
    
PRINT_NEXT_STR:
    ex (sp),hl                              ;[0320] 
    ld a,(hl)                               ;[0321] 
    inc hl                                  ;[0322] 
    ex (sp),hl                              ;[0323] 
    or a                                    ;[0324] 
    ret z                                   ;[0325] 
    call bdos_write                         ;[0326] 
    jp PRINT_NEXT_STR                       ;[0329] 
    
; Send the character in A to the screen
bdos_write:
    push af                                 ;[032c] 
    push hl                                 ;[032d] 
    push bc                                 ;[032e] 
    ld c,$02                                ;[032f] 
    ld e,a                                  ;[0331] 
    call $0005                              ;[0332] 
    pop bc                                  ;[0335] 
    pop hl                                  ;[0336] 
    pop af                                  ;[0337] 
    ret                                     ;[0338] 
    
; Open the file specified in FCB (pointer passed in DE)
bdos_fopen:
    ld a,$00                                ;[0339] 
    ld hl,$0020                             ;[033b] CR byte offset
    add hl,de                               ;[033e] 
    ld (hl),a                               ;[033f] zero the value of CR in FCB
    ld c,$0f                                ;[0340] 
    call $0005                              ;[0342] 
    cp $ff                                  ;[0345] 
    ret nz                                  ;[0347] return on success
    push af                                 ;[0348] else print error message
    call PRINT_NEXT_STR                     ;[0349] 
    DB "\r\n"
    DB "File open error"
    Db 0
    pop af                                  ;[035e] 
    ret                                     ;[035f] 
    
bdos_fread:
    push hl                                 ;[0360] 
    push de                                 ;[0361] 
    push bc                                 ;[0362] 
    ld c,$14                                ;[0363] 
    call $0005                              ;[0365] 
    pop bc                                  ;[0368] 
    pop de                                  ;[0369] 
    pop hl                                  ;[036a] 
    ret                                     ;[036b] 
    
send_record:
    push bc                                 ;[036c] 
    ld hl,$0080                             ;[036d] record buffer address
    ld b,$80                                ;[0370] record size
    send_record_loop:                       ;       just load bytes from buffer and send them
    ld a,(hl)                               ;[0372] 
    call SIO_WRITE_WRAPPER                  ;[0373] 
    inc hl                                  ;[0376] 
    djnz send_record_loop                   ;[0377] 
    pop bc                                  ;[0379] 
    ret                                     ;[037a] 
    
send_file:
    ld b,$80                                ;[037b] for each 128 blocks, ask ACK
    call bdos_fread                         ;[037d] read first record from opened file
    call send_record                        ;[0380] send the record content over serial
    dec b                                   ;[0383] 
send_file_loop:
    push bc                                 ;[0384] 
    call bdos_fread                         ;[0385] read next record
    or a                                    ;[0388] on error, file is finished: terminate
    jp nz,send_file_end                     ;[0389] 
    ld a,$17                                ;[038c] ETB (end of transfer block)
    call SIO_WRITE_WRAPPER                  ;[038e] between each record, send ETB
    call send_record                        ;[0391] 
    pop bc                                  ;[0394] 
    djnz send_file_loop                     ;[0395] repeat until end of file or max num of record
    ld a,$17                                ;[0397] send ETB for last record
    call SIO_WRITE_WRAPPER                  ;[0399] 
    call SIO_READ_WRAPPER                   ;[039c] read ACK
    cp $06                                  ;[039f] 
    jp nz,send_file_fail                    ;[03a1] if other than ACK, terminate with error
    jp send_file                            ;[03a4] else start back sending other records
; note: after 128 record, sequence is  -> ETB; <- ACK -> ETB -> new record
    
send_file_end:
    ld a,$04                                ;[03a7] EOT (end of transmission)
    call SIO_WRITE_WRAPPER                  ;[03a9] 
    pop bc                                  ;[03ac] 
    xor a                                   ;[03ad] 
    ret                                     ;[03ae] 
    
send_file_fail:
    ld a,$ff                                ;[03af] 
    ret                                     ;[03b1] return failure
    
; Given the filename pattern specified in FCB, process the files to be copied.
; If wildcards were specified, they must be expanded, i.e. replaced with the
; matching filenames.
; The list of expanded filename is stored in a separate buffer, using a particular
; format. For each filename 16 bytes are reserved, as specified in push_file_in_list
; routine description.
expand_wildcard:
    xor a                                   ;[03b2] 
    ld (num_of_files),a                     ;[03b3] reset the number of files to be sent
    ld hl,FILE_LIST                         ;[03b6] 
    ld (p_file_list),hl                     ;[03b9] store the pointer to the file list area
    call bdos_sfirst                        ;[03bc] start finding files matching the one(s) in FCB
; an offset to the directory entry is returned in a
    cp $ff                                  ;[03bf] check if error returned
    jp z,perror_no_file                     ;[03c1] 
    call push_file_in_list                  ;[03c4] copy the filename from the directory entry (a) into the list to be sent
    ld a,(num_of_files)                     ;[03c7] 
    inc a                                   ;[03ca] 
    ld (num_of_files),a                     ;[03cb] 
fetch_files_loop:
    call bdos_snext                         ;[03ce] try finding next file
    cp $ff                                  ;[03d1] 
    jp z,no_more_files                      ;[03d3] no more files to be retrieved
    call push_file_in_list                  ;[03d6] copy the filename from the directory entry (a) into the list to be sent
    ld a,(num_of_files)                     ;[03d9] 
    inc a                                   ;[03dc] 
    ld (num_of_files),a                     ;[03dd] 
    jp fetch_files_loop                     ;[03e0] 
    
; Pointer to the files to be sent list
p_file_list:
    DW $0000
    
; Push an entry in the mysterious file_list array.
; Each entry is 16 byte long, containing the following info
; _ A B : F F F F F F F F T T T _
; Where:
; _ is a space character
; AB is the file index (starting from "00")
; : is literally ':'
; F is file name, according to CP/M specs
; T is file type, according to CP/M specs
; This curious format is used both for retrieving the filenames and to display
; the file list on the screen.
push_file_in_list:
    call find_dir_entry                     ;[03e5] use the directory entry offset passed in a to fetch filename (returned in hl)
    ld de,(p_file_list)                     ;[03e8] 
    ld a,$20                                ;[03ec] 
    ld (de),a                               ;[03ee] 
    inc de                                  ;[03ef] 
    ld a,(num_of_files)                     ;[03f0] 
    call to_integer                         ;[03f3] compute and store file index (increasing value from 00)
    ld a,':'                                ;[03f6] add the separator character
    ld (de),a                               ;[03f8] 
    inc de                                  ;[03f9] 
    ld bc,11                                ;[03fa] copy file name and type (hl) into file list entry
    ldir                                    ;[03fd] repeat (de++) = (hl++) until --bc == 0
    ld a,$20                                ;[03ff] add last space
    ld (de),a                               ;[0401] 
    inc de                                  ;[0402] 
    ld (p_file_list),de                     ;[0403] point to a new entry
    ret                                     ;[0407] 
    
; Given return value of BDOS disk functions, find the directory entry and
; return the filename
find_dir_entry:
    and $03                                 ;[0408] a can be 0-3
    add a,a                                 ;[040a] 
    add a,a                                 ;[040b] 
    add a,a                                 ;[040c] 
    add a,a                                 ;[040d] 
    add a,a                                 ;[040e] a = a * 32
    ld hl,$0080                             ;[040f] dma offset
    ld b,$00                                ;[0412] 
    ld c,a                                  ;[0414] 
    add hl,bc                               ;[0415] directory entry = dma_offset + a * 32
    inc hl                                  ;[0416] skip User number (UU) and go to filename
    ret                                     ;[0417] 
    
; Convert value in a to a two digit integer string.
; Store ascii digits in memory pointed by de
to_integer:
    ld b,$ff                                ;[0418] 
divide_loop:
    inc b                                   ;[041a] 
    sub $0a                                 ;[041b] 
    jp nc,divide_loop                       ;[041d] b = a/10, a = a%10 - 10
    add a,$3a                               ;[0420] get a printable reminder in range '0'-'9' (units)
    push af                                 ;[0422] 
    ld a,b                                  ;[0423] 
    add a,$30                               ;[0424] get a printable quotient in range '0'-'9' (tens)
    ld (de),a                               ;[0426] store tens digit
    inc de                                  ;[0427] 
    pop af                                  ;[0428] 
    ld (de),a                               ;[0429] store units digit
    inc de                                  ;[042a] 
    ret                                     ;[042b] 
    
perror_no_file:
    call PRINT_NEXT_STR                     ;[042c] cd 20 03 	.   .
    DB "\r\n"
    DB "File does not exist"
    DB 0
    ld a,$ff                                ;[0445] 3e ff 	> .
    ret                                     ;[0447] c9 	.
    
no_more_files:
    ld de,(p_file_list)                     ;[0448] 
    xor a                                   ;[044c] 
    ld (de),a                               ;[044d] terminate the list by adding a "null" element with first byte set to zero
    ld de,$0948                             ;[044e] restore pointer to the first element of the list
    ld (p_file_list),de                     ;[0451] 
    ret                                     ;[0455] 
    
; Search for the first occurrence of the specified file (specified in FCB).
; The filename can include ? marks, which match anything on disc.
; Returns A=0FFh if error, or A=0-3 if successful. The value returned can be
; used to calculate the address of a memory image of the directory entry; it is
; to be found at DMA+A*32.
bdos_sfirst:
    ld c,$11                                ;[0456] 
    jp $0005                                ;[0458] 
    
; Finds the next occurrence of the specified file after the one returned last
; time. Same considerations as bdos_sfirst.
bdos_snext:
    ld c,$12                                ;[045b] 
    jp $0005                                ;[045d] 
    
list_files_to_send:
    ld b,$00                                ;[0460] 
    ld hl,$0948                             ;[0462] point to first element in file list
print_file_to_send_loop:
    push bc                                 ;[0465] 
    ld a,(hl)                               ;[0466] 
    cp $01                                  ;[0467] 
    jp nz,print_no_skip                     ;[0469] 
    ld bc,$0010                             ;[046c] 
print_skip_loop:
    add hl,bc                               ;[046f] 09 	.
    ld a,(hl)                               ;[0470] 7e 	~
    cp $01                                  ;[0471] skip entries marked with 1
    jp z,print_skip_loop                    ;[0473] 
print_no_skip:
    cp $00                                  ;[0476] null element, terminate
    jp z,print_file_to_send_end             ;[0478] 
    ld b,12                                 ;[047b] 
    print_file_loop:                        ;       print first 12 characters of the file entry, aka _AB:FFFFFFFF
    ld a,(hl)                               ;[047d] 
    call bdos_write                         ;[047e] 
    inc hl                                  ;[0481] 
    djnz print_file_loop                    ;[0482] 
    ld a,'.'                                ;[0484] print separator
    call bdos_write                         ;[0486] 
    ld b,4                                  ;[0489] 
    print_file_type_loop:                   ;       print the last 4 bytes of the entry, aka TTT_
    ld a,(hl)                               ;[048b] 
    call bdos_write                         ;[048c] 
    inc hl                                  ;[048f] 
    djnz print_file_type_loop               ;[0490] 
    pop bc                                  ;[0492] 
    inc b                                   ;[0493] 
    ld a,b                                  ;[0494] 
    and $03                                 ;[0495] 
    jp nz,print_file_to_send_loop           ;[0497] print up to four file names per row
    call PRINT_NEXT_STR                     ;[049a] 
    DB "\r\n"
    DB 0
    jp print_file_to_send_loop              ;[04a0] 
    
print_file_to_send_end:
    pop bc                                  ;[04a3] c1 	.
    ret                                     ;[04a4] c9 	.
    
ask_files_to_skip:
    call PRINT_NEXT_STR                     ;[04a5] 
    DB "\r\n\n"
    DB "Are there any files not to be transfered? (type file number)"
    DB "\r\n"
    DB "more than one separated by ,"
    DB "\r\n"
    DB "or RETURN to continue"
    DB "\r\n"
    DB 0
    call getline                            ;[051f] prompt and fetch the indexes of files to be skipped
    cp $00                                  ;[0522] 
    ret z                                   ;[0524] no files to be skipped, return
    call mark_sk_files                      ;[0525] else, add a mark to each file to be skipped in the file list
    call PRINT_NEXT_STR                     ;[0528] print the updated files list
    DB "\r\n"
    DB "                     "
    Db "FILES TO SEND"
    DB "\r\n\n"
    DB 0
    call list_files_to_send                 ;[0553] 
    jp ask_files_to_skip                    ;[0556] 
    
    ret                                     ;[0559] 
    
; mark files to skip in file list
; note: numbers have to be written two digits with leading zeros!
; i.e. 00 01 10 ...
mark_sk_files:
    ld a,(hl)                               ;[055a] first digit (msb)
    call isnum                              ;[055b] 
    cp $ff                                  ;[055e] 
    jp z,mark_sk_invalid                    ;[0560] invalid character, ignore this and next one and search separator (,)
    and $0f                                 ;[0563] get 0-9 value
    rrc a                                   ;[0565] 
    rrc a                                   ;[0567] 
    rrc a                                   ;[0569] 
    rrc a                                   ;[056b] a <<= 4
    ld b,a                                  ;[056d] 
    inc hl                                  ;[056e] 
    ld a,(hl)                               ;[056f] second digit (lsb)
    call isnum                              ;[0570] 
    cp $ff                                  ;[0573] 
    jp z,ch_invalid                         ;[0575] invalid character, skip and search separator (,)
    and $0f                                 ;[0578] 
    or b                                    ;[057a] get BCD value from the two inserted digit
    call bcd_to_hex                         ;[057b] convert BCD value in an hex number
    push hl                                 ;[057e] 
    ld hl,$0948                             ;[057f] file list pointer
    ld b,a                                  ;[0582] 
    ld a,(num_of_files)                     ;[0583] 
    dec a                                   ;[0586] 
    cp b                                    ;[0587] 
    jp c,index_invalid                      ;[0588] if requested number is greater than num of files, ignore this file number
    ld de,$0000                             ;[058b] 
    inc b                                   ;[058e] 
    find_index_loop:                        ;       find the requested entry
    add hl,de                               ;[058f] 
    ld de,$0010                             ;[0590] 
    djnz find_index_loop                    ;[0593] 
    ld (hl),$01                             ;[0595] mark that entry as to be skipped
index_invalid:
    pop hl                                  ;[0597] restore pointer to digits inserted from keyboard
    ch_invalid:                             ;       skip separating char between file numbers
    inc hl                                  ;[0598] 
    ld a,(hl)                               ;[0599] 
    cp ' '                                  ;[059a] space terminates parsing
    ret z                                   ;[059c] 
    cp ','                                  ;[059d] comma is a separator, just skip it
    jp nz,l05c8h                            ;[059f] why is this code duplicated ?!?
    inc hl                                  ;[05a2] 
    jp mark_sk_files                        ;[05a3] 
    
; given a char in a, returns the char itself if is a number, else 0xFF
isnum:
    cp '0'                                  ;[05a6] 
    jp c,l05aeh                             ;[05a8] 
    cp '9'+1                                ;[05ab] 
    ret c                                   ;[05ad] 
l05aeh:
    ld a,$ff                                ;[05ae] 
    ret                                     ;[05b0] 
    
bcd_to_hex:
    push bc                                 ;[05b1] 
    push af                                 ;[05b2] 
    and $0f                                 ;[05b3] 
    ld c,a                                  ;[05b5] 
    pop af                                  ;[05b6] 
    and $f0                                 ;[05b7] 
    rrc a                                   ;[05b9] 
    ld b,a                                  ;[05bb] 
    rrc a                                   ;[05bc] 
    rrc a                                   ;[05be] 
    add a,b                                 ;[05c0] 
    add a,c                                 ;[05c1] result = msb * 16 / 2  + msb * 16 / 8 + lsb
    pop bc                                  ;[05c2] result = msb * 10 + lsb
    ret                                     ;[05c3] 
    
mark_sk_invalid:
    inc hl                                  ;[05c4] 
    jp ch_invalid                           ;[05c5] 
    
    l05c8h:                                 ;       this seems the same code as in l0598h, this doesn't have much sense
    inc hl                                  ;[05c8] 
    ld a,(hl)                               ;[05c9] 
    cp ' '                                  ;[05ca] 
    ret z                                   ;[05cc] 
    cp ','                                  ;[05cd] 
    dec hl                                  ;[05cf] 
    jp z,ch_invalid                         ;[05d0] 
    inc hl                                  ;[05d3] 
    jp l05c8h                               ;[05d4] 
    
pop_filelist_in_fcb:
    call fcb_clear                          ;[05d7] clear the FCB structure
    ld hl,(p_file_list)                     ;[05da] load pointer to the file list structure
    ld a,(hl)                               ;[05dd] 
    cp $01                                  ;[05de] 
    jp nz,pop_filelist_no_skip              ;[05e0] 
    ld bc,16                                ;[05e3] skip files not to be sent
    pop_filelist_skip_loop:                 ;       continue skipping all files not to be sent
    add hl,bc                               ;[05e6] 
    ld a,(hl)                               ;[05e7] 
    cp $01                                  ;[05e8] 
    jp z,pop_filelist_skip_loop             ;[05ea] 
pop_filelist_no_skip:
    cp $00                                  ;[05ed] terminator of the file list, return
    ld a,$ff                                ;[05ef] 
    ret z                                   ;[05f1] 
    inc hl                                  ;[05f2] 
    ld a,(hl)                               ;[05f3] copy both digits of file index in message to be printed
    ld (file_index_str+2),a                 ;[05f4] 
    inc hl                                  ;[05f7] 
    ld a,(hl)                               ;[05f8] 
    ld (file_index_str+3),a                 ;[05f9] 
    inc hl                                  ;[05fc] skip separators
    inc hl                                  ;[05fd] 
    ld bc,11                                ;[05fe] 
    ld a,(drive_index)                      ;[0601] copy drive index in FCB
    ld (de),a                               ;[0604] 
    inc de                                  ;[0605] 
    ldir                                    ;[0606] Copy the filename in FCB
    inc hl                                  ;[0608] update pointer to the next entry
    ld (p_file_list),hl                     ;[0609] save the pointer value
    xor a                                   ;[060c] return success
    ret                                     ;[060d] 
    
send_name:
    ld a,$02                                ;[060e] STX (start of text)
    call SIO_WRITE_WRAPPER                  ;[0610] 
    ex de,hl                                ;[0613] 
    inc hl                                  ;[0614] 
    ld b,11                                 ;[0615] filename+filetype length
    send_name_loop:                         ;       send the filename over serial (fixed length)
    ld a,(hl)                               ;[0617] 
    call SIO_WRITE_WRAPPER                  ;[0618] 
    inc hl                                  ;[061b] 
    djnz send_name_loop                     ;[061c] 
    ld a,$03                                ;[061e] EXT (end of text)
    call SIO_WRITE_WRAPPER                  ;[0620] 
    call SIO_READ_WRAPPER                   ;[0623] wait for char from serial
    cp $06                                  ;[0626] ACK
    jp nz,send_name_failed                  ;[0628] if others than ACK received, terminate
    xor a                                   ;[062b] else return ok
    ret                                     ;[062c] 
send_name_failed:
    ld a,$ff                                ;[062d] 
    ret                                     ;[062f] 
    
main:
    ld hl,$0080                             ;[0630] Get number of characters in command tail
    ld a,(hl)                               ;[0633] i.e. arguments
    cp $00                                  ;[0634] if no arguments
    jp z,cmd_no_args                        ;[0636] skip
    inc hl                                  ;[0639] TODO: why jump two char and not one? maybe one is a space?
    inc hl                                  ;[063a] 
    jp preface                              ;[063b] 
cmd_no_args:
    call getline                            ;[063e] prompt request and ask filename to user
preface:
    ld de,$005c                             ;[0641] load pointer to default FCB1
    call arg_parser                         ;[0644] parse filename in argument and load it in FCB
    or a                                    ;[0647] check return value
    jp nz,cmd_no_args                       ;[0648] if error (!=0), get filename from keyboard
    call expand_wildcard                    ;[064b] gather the file names matching the requested ones in a separate list
    or a                                    ;[064e] 
    jp nz,cmd_no_args                       ;[064f] error in file gathering = ask (again) which files to send
    call PRINT_NEXT_STR                     ;[0652] 
    DB "\r\n"
    DB "                    "
    DB "FILES FOUND ON DISK"
    DB "\r\n\n"
    DB 0
    call list_files_to_send                 ;[0682] 
    call ask_files_to_skip                  ;[0685] 
    call PRINT_NEXT_STR                     ;[0688] 
    DB "\r\n\n"
    DB "Sending file"
    DB "\r\n\n"
    DB 0
begin_file_send:
    ld de,$005c                             ;[069e] load pointer to FCB1
    call pop_filelist_in_fcb                ;[06a1] 
    or a                                    ;[06a4] 
    jp nz,print_ok_transfer                 ;[06a5] on failure, just print success (?!?)
    ld de,$005c                             ;[06a8] load pointer to FCB1
    call bdos_fopen                         ;[06ab] open file specified in FCB1
    jp z,perror_file_open                   ;[06ae] print error on failer
    ld de,$005c                             ;[06b1] 
    call send_name                          ;[06b4] send the preamble and the filename over serial
    or a                                    ;[06b7] 
    jp nz,perror_send_name                  ;[06b8] 
    call PRINT_NEXT_STR                     ;[06bb] 
file_index_str:
    DB "* "
    DB "00"
    DB 0
    ld de,$005c                             ;[06c3] load pointer to FCB1
    call send_file                          ;[06c6] send the actual file over serial
    or a                                    ;[06c9] 
    jp nz,perror_transmit                   ;[06ca] 
    call SIO_READ_WRAPPER                   ;[06cd] 
    cp $06                                  ;[06d0] check for ACK at the end of transmission
    jp z,begin_file_send                    ;[06d2] jump sending next file on success
    call PRINT_NEXT_STR                     ;[06d5] else, print error string
    DB "\r\n"
    DB "Error on receiver (send next file or reboot Y/N)"
    Db 0
    call guard_bios_conin                   ;[070b] 
    cp 'Y'                                  ;[070e] 
    jp z,begin_file_send                    ;[0710] go to next file on 'Y'
    jp epilogue                             ;[0713] terminate on other
    
print_ok_transfer:
    call PRINT_NEXT_STR                     ;[0716] 
    DB "\r\n\n"
    DB "All files transfered  (more files to send? Y/N)"
    DB 0
    call guard_bios_conin                   ;[074c] 
    cp $59                                  ;[074f] fe 59
    jp z,cmd_no_args                        ;[0751] 
    jp epilogue                             ;[0754] 
    
perror_file_open:
    call PRINT_NEXT_STR                     ;[0757] 
    DB "\r\n"
    DB "File open error"
    DB 0
    jp epilogue                             ;[076c] 
    
perror_send_name:
    call PRINT_NEXT_STR                     ;[076f] 
    DB "\r\n"
    DB "Name transfer error"
    DB 0
    jp epilogue                             ;[0788] 
    
perror_transmit:
    call PRINT_NEXT_STR                     ;[078b] 
    DB "\r\n"
    DB "Transmission error"
    DB 0
    jp epilogue                             ;[07a3] 
    
epilogue:
    ld a,$18                                ;[07a6] 
    call SIO_WRITE_WRAPPER                  ;[07a8] 
    call PRINT_NEXT_STR                     ;[07ab] 
    DB "\r\n\n"
    DB "End of transmission"
    DB 0
    jp $0000                                ;[07c5] reset, terminate application
    
; Sends to port $b1 data from $0458 to $0460 (SIO SETUP)
SIO_SETUP:
    ld c,IO_SIO_ADDR+1                      ;[07c8] Output port
    ld b,$09                                ;[07ca] Number of repetitions
    ld hl,SIO_SETUP_COMMANDS                ;[07cc] Starting address
    otir                                    ;[07cf] 
    ret                                     ;[07d1] 
    
SIO_SETUP_COMMANDS:
    DB $18                                  ;       Reset channel 0
    DB $04                                  ;       Access WR4
    DB $4c                                  ;       Parity Disabled, 2 stop bits (?), 8 bit sync,Data Rate x16 = Clock rate
    DB $01                                  ;       Access WR1
    DB $00                                  ;       Disable all interrupts
    DB $05                                  ;       Access WR5
    DB $ea                                  ;       TX CRC disabled, RTS enabled, CRC-16 disabled, Transmit enabled, Send break disabled, 8 bits/character, dtr enabled
    DB $03                                  ;       Access WR3
    DB $c1                                  ;       Receive enabled, the rest disabled, 8 bits/character
    
; Write the character stored in the A register to port B of the SIO (Blocks until can transmit)
SIO_WRITE:
    push af                                 ;[07db] 
SIO_WRITE_LOOP:
    in a,(IO_SIO_ADDR+1)                    ;[07dc] 
    and $04                                 ;[07de] 
    jp z,SIO_WRITE_LOOP                     ;[07e0] 
    pop af                                  ;[07e3] 
    out (IO_SIO_ADDR),a                     ;[07e4] 
    ret                                     ;[07e6] 
    
; Receive a character from the SIO and stores it in A (it blocks until there is something available to read)
SIO_READ:
    in a,(IO_SIO_ADDR+1)                    ;[07e7] 
    and $01                                 ;[07e9] 
    jp z,SIO_READ                           ;[07eb] 
    in a,(IO_SIO_ADDR)                      ;[07ee] 
    ret                                     ;[07f0] 
    
; Junk
    inc bc                                  ;[07f1] 03 	.
    dec c                                   ;[07f2] 0d 	.
    ld a,(bc)                               ;[07f3] 0a 	.
    ld c,(hl)                               ;[07f4] 4e 	N
    ld h,c                                  ;[07f5] 61 	a
    ld l,l                                  ;[07f6] 6d 	m
    ld h,l                                  ;[07f7] 65 	e
    jr nz,$+118                             ;[07f8] 20 74 	  t
    ld (hl),d                               ;[07fa] 72 	r
    ld h,c                                  ;[07fb] 61 	a
    ld l,(hl)                               ;[07fc] 6e 	n
    ld (hl),e                               ;[07fd] 73 	s
    ld h,(hl)                               ;[07fe] 66 	f
    ld h,l                                  ;[07ff] 65 	e
