;*******************************************************************************
;* Library of Disktool commands                                                *
;*******************************************************************************
;* CATALOG, DRIVE, DINIT, DLOAD, DSAVE, DVALIDATE, SCRATCH, FCOPY, BAM         *
;*******************************************************************************

; Jeder Track besteht aus 4 Bytes XX SS SS SS (15 ff ff 1f)
;                00000000  11111100     21111
;                76543210  54321098  xxx09876
; 21 255 255 31 %11111111 %11111111 %00011111
; Bitmaske Track XX=Anzahl Freie Sektoren SS Sektorenmaske
MAXSECS
        byte 21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21
        byte 19,19,19,19,19,19,19
        byte 18,18,18,18,18,18
        byte 17,17,17,17,17

DISKBLOCKBUFFER = $7F00

DISK_CMD_CHANNEL
        byte $0F
DISK_DRIVE
        byte $08

DISK_TEXT
        text "current drive #"
        brk
STATUS_TEXT
        text "reset:"
        brk
LABEL_TEXT
        text "diskname: "
        brk
LABEL_NEWTEXT
        text "new name: "
        brk
READTRSEC
        text "u1:2 0 "
RDTR
        byte $30,$30,$20
RDSE
        byte $30,$30,$0d
        brk
WRITETRSEC
        text "u2:2 0 "
WRTR
        byte $30,$30,$20
WRSE
        byte $30,$30,$0d
        brk
BPSECTORFIRSTBYTE
        text "b-p:2 0"
        byte $0d
        brk
BPDISKNAME
        text "b-p:2 144"
        byte $0d
        brk
DISKBUFCHAR
        text "#"
        brk
DISKERRBUF
        byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        brk
CMDSTRLENGTH
        brk
CMDBUFLEN
        brk
CMDBUFLEN2
        brk
CMDBUF
        byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        byte 0,0,0,0
CMDBUF2
        byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        byte 0,0,0,0
CMDTABLE
        ;XRegister    Initialize=1,Validate=2,Reset=3,Scratch=5,Copy=6,New=7
        text "$ivujscn"
  ;CMD-Length 1112 111
        brk
STRPTRLEN
        brk
STRPTRLOW
        brk
STRPTRHIGH
        brk
DIRMASKSTR
        byte $01
        word CMDTABLE
        brk
STDDIRMASK
        byte $01
        word CMDTABLE
        brk
PROGADR
        text CHR_Return,"load: "
        brk
PROGADR2
        text " to "
        brk
PROGSIZE
        text CHR_Return,"size: "
        brk
LOADSECADR
        brk
BYTES
        text " bytes",$0d
        brk
TIMER
        byte $40
;*******************************************************************************
;* SUBROUTINES used by all disk commands                                       *
;*******************************************************************************

;*******************************************************************************
;* CLEARCMDBUF - Initializes the command string buffer                         *
;*******************************************************************************
CLEARCMDBUF
        txa
        pha
        ldy #$00
        ldx #CMDTABLE-CMDBUF
        tya
@CLRBUFLOOP
        sta CMDBUF,y
        iny
        dex
        bne @CLRBUFLOOP
        pla
        tax
        rts

;*******************************************************************************
;* CPYSTRINGTOBUF - Copy a Memory String to CMDBUF                             *
;*   YReg needs to be initialized with offset into CMDBUF                      *
;*******************************************************************************
CPYSTRINGTOBUF
        ldy #$00
CPYSTRLOOP
        lda (ZP_FLAGFB),y
        sta (ZP_FLAGFD),y
        iny
        dex
        bne CPYSTRLOOP
        lda COMM_TEMP_VAR
        beq @CPYBUFEXIT
@CPYCHECKMAX
        cpy #$10
        beq @CPYBUFEXIT
        lda #$20
        sta (ZP_FLAGFD),y
        iny
        bne @CPYCHECKMAX
@CPYBUFEXIT
        rts

;*******************************************************************************
;* SETCMDCHANNEL - Setup Commandchannel for Drive                             *
;*******************************************************************************
SETCMDCHANNEL
        txa
        pha
        lda DISK_CMD_CHANNEL    ; logical file
        ldx DISK_DRIVE          ; Diskdrive number
        tay                     ; Secondary address
        jsr krljmp_SETLFS$      ; Set 15,DISK_DRIVE,15
        pla
        tax
        rts

;*******************************************************************************
;* DERROR Command - Display of Diskdrive Errormessage                          *
;*******************************************************************************
;* Syntax: derror or de shifted R                                              *
;*******************************************************************************
;* Input: none or u# for drivenumber                                           *
;*******************************************************************************
;* Output: Errorstring from current or selected drive                          *
;*******************************************************************************
COM_DISKERR
        jsr bas_CHRGOT$
        beq READDISKERROR
        cmp #"u"
        beq @NEWDRVNUM
        jmp SYNTAX_ERROR
@NEWDRVNUM
        jsr SETNEWDRIVE
READDISKERROR
        jsr SETCMDCHANNEL
        lda #$00                ; kein Filename
        jsr krljmp_SETNAM$      ; 
        jsr krljmp_OPEN$        ; Open 15,DISK_DRIVE,15

;Entry for calls from other Diskcommands
GETDISKERR
        jsr krljmp_CLRCHN$
        ldx DISK_CMD_CHANNEL    ; Eingabe
        jsr krljmp_CHKIN$       ; vom Fehlerkanal
        ldx #$00
@READLOOP
        jsr krljmp_CHRIN$       ; Zeichen von Floppy
        ldy COMM_DSSTRFLAG
        cpy #$01
        bne @PRINT_ERR
        sta DISKERRBUF,x        ; ind DISKERRBUF,x für DS$
        inx
        bne @SKIPPRINT
@PRINT_ERR
        jsr krljmp_CHROUT$      ; und ausgeben
@SKIPPRINT
        bit ZP_STATE            ; Status testen
        bvc @READLOOP           ; ok, sonst springe zum loop
        stx COMM_DSSTRLEN
        jsr krljmp_CLRCHN$      ; CMD Modus beenden
        lda DISK_CMD_CHANNEL    ; Kanal
        jsr krljmp_CLOSE$       ; schliessen
        rts
DISKERR_DSVAR
        jsr READDISKERROR
        ldx COMM_DSSTRLEN
        dex
        lda DISKERRBUF,x
        cmp #CHR_Return
        bne @NORETURN
        lda #$00
        sta DISKERRBUF,x
@NORETURN
        inx
        lda #$00
        sta DISKERRBUF,x
        inx
        sta DISKERRBUF,x
        stx COMM_DSSTRLEN       ; Globale Variable für DS$
        rts
;*******************************************************************************
;* DRIVE Command - Set Deviceno. of Default Diskdrive to use                   *
;*******************************************************************************
;* Syntax: drive or dr shifted I                                               *
;*******************************************************************************
;* Input: u#   u+number of diskunit OR                                         *
;*        r    reset current drive                                             *
;*******************************************************************************
;* Output: on success the diskdrive devicenumber or illegal quantity error     *
;*         floppy rom identification string                                    *
;*******************************************************************************
COM_DRIVE
        jsr bas_CHRGOT$
        beq @SHOWDRVNUM
        cmp #"u"
        beq @NEWDRVNUM
        cmp #"r"
        beq @DRIVERESET
        jmp SYNTAX_ERROR
@NEWDRVNUM
        jsr SETNEWDRIVE
@SHOWDRVNUM
        lda #<DISK_TEXT
        ldy #>DISK_TEXT
        jsr bas_PrintString$
        lda DISK_DRIVE
        ora #$30
        jsr krljmp_CHROUT$
        lda #$0d
        jmp krljmp_CHROUT$
@DRIVERESET
        jsr bas_CHRGET$
        jsr CLEARCMDBUF
        lda #$02                ; length of floppy reset command "UJ"
        sta CMDSTRLENGTH
        sta CMDBUFLEN
        ldx #$03                ; index of floppy reset command "UJ"
        jmp DISKCMD
        
ILLEGAL
        jmp bas_IQERR$

SETNEWDRIVE
        jsr bas_CHRGET$        
        jsr bas_GETBYTC$
        cpx #$08
        bcc ILLEGAL
        cpx #$0c
        bcs ILLEGAL 
        stx DISK_DRIVE
        stx ZP_FA
        rts

; Set Track for Readbuffer
;----- Paragraph @Hexzahl im AKKU nach ASCII@ -----
SETREADTR
        jsr HEX2ASC
        stx RDTR
        sta RDTR + 1
        rts

; Set Sector for Readbuffer
;----- Paragraph @Hexzahl im AKKU nach ASCII@ -----
SETREADSEC
        jsr HEX2ASC
        stx RDSE
        sta RDSE + 1
        rts

; Set Track for Writebuffer
; Accu  = Track
SETWRITETR
        jsr HEX2ASC
        stx WRTR
        sta WRTR + 1
        rts

; Set Sector for Readbuffer
;----- Paragraph @Hexzahl im AKKU nach ASCII@ -----
SETWRITESEC
        jsr HEX2ASC
        stx WRSE
        sta WRSE + 1
        rts

;-----------------------------------------------------
; HEX2ASC convert Hexnumber in Accu to Decimalnumber in
; Accu = Ones Place and XReg = Tenth place
;-----------------------------------------------------
; Output in X-Register (Zehnerstelle) und AKKU (Einerstelle)
;-----------------------------------------------------
HEX2ASC
        cld
        ldx #$30
        sec
@HA1    sbc #$0a
        bcc @HA2
        inx
        bcs @HA1
@HA2    adc #$3a
        rts

;*******************************************************************************
;* DINIT Command - Initialize current drive or drive that will be given as para*
;*******************************************************************************
;* Syntax: dinit or di shifted N                                               *
;*******************************************************************************
;* Input: optional u# - deviceaddress of drive to use                          *
;*******************************************************************************
;* Output: errormessage of diskdrive that should be initialized                *
;*******************************************************************************
COM_INITDISK
        jsr bas_CHRGOT$
        beq @EXEC_INIT
        cmp #"u"
        beq @NEWDRVNUM
        jmp SYNTAX_ERROR
@NEWDRVNUM
        jsr SETNEWDRIVE
@EXEC_INIT
        lda #$01
        sta CMDSTRLENGTH
        sta CMDBUFLEN
        ldx #$01                ; Initialize Disk
        jmp DISKCMD

;*******************************************************************************
;* COLLECT Command - Validates Disk in current drive or drive given as U#      *
;*******************************************************************************
;* Syntax: COLLECT or COL shifted L                                            *
;*******************************************************************************
;* Input: optional u# - deviceaddress of drive to use                          *
;*******************************************************************************
;* Output: errormessage of diskdrive that should be initialized                *
;*******************************************************************************
COM_COLLECT
        jsr bas_CHRGOT$
        beq @EXEC_COLLECT
        cmp #"u"
        beq @NEWDRVNUM
        jmp SYNTAX_ERROR
@NEWDRVNUM
        jsr SETNEWDRIVE
@EXEC_COLLECT
        lda #$01
        sta CMDSTRLENGTH
        sta CMDBUFLEN
        ldx #$02                ; Validate Disk

;*******************************************************************************
;* DISKCMD command - Executes floppy commands on commandchannel                *
;*******************************************************************************
;* Call params: XReg = Offset of floppycommand - Accu = length of Commandstr   *
;*******************************************************************************
DISKCMD
        cpx #$04                ; Is Command >=4 then
        bcs @DONTCLRBUF         ; do not clear buffer
        jsr CLEARCMDBUF
@DONTCLRBUF
        ldy #$00                
@CPYDOSCMD
        lda CMDTABLE,x          ; copy floppy command to commandbuffer
        sta CMDBUF,y
        inx
        iny
        cpy CMDSTRLENGTH        ; Cmd String copied ?
        bne @CPYDOSCMD
        jsr SETCMDCHANNEL       ; Set CMDCHANNEL 15,DISK_DRIVE,15
        lda CMDBUFLEN           ; Get length of Commandstring into Accu
        ldx #<CMDBUF
        ldy #>CMDBUF
        jsr krljmp_SETNAM$      ; Set CMDCHANNEL filename params
        jsr krljmp_OPEN$        ; Open 15,DISK_DRIVE,15,"CMD"
        bcc @CMDOK
        jmp @NOWAIT
@CMDOK 
        lda CMDBUF+1
        cmp #"j"
        bne @NOWAIT
        jsr WAITFORDISKRESET
@NOWAIT
        jmp GETDISKERR

;*******************************************************************************
;* This routine is needed for a Disk Reset to wait until Disk Reset finished   *
;*******************************************************************************
WAITFORDISKRESET
        jsr krljmp_CLRCHN$
        ldy #$40
        sty TIMER
@YLOOP
        dec TIMER
        ldx #$FF
@XLOOP
        nop
        nop
        dex
        bne @XLOOP
        tya
        pha
        lda #<STATUS_TEXT
        ldy #>STATUS_TEXT
        jsr bas_PrintString$
        lda #100
@WAIT_RAS
        cmp VICII_RASTER
        bne @WAIT_RAS
        ldx TIMER
        lda #$00
        jsr bas_DecimalPrint$   ; XR = Lowbyte - Accu = HighByte
        lda #CHR_Return
        jsr krljmp_CHROUT$
        lda #CHR_CursorUp
        jsr krljmp_CHROUT$
        pla
        tay
        dey
        bne @YLOOP
        rts

;*******************************************************************************
;* INITCATALOG - Set default catalog loadstring to "$"                         *
;*******************************************************************************
INITCATALOG
        ldx #2
@INITLOOP
        lda STDDIRMASK,x
        sta DIRMASKSTR,x
        dex
        bpl @INITLOOP
        rts

;*******************************************************************************
;* Catalog Command - Display of Disk directory                                 *
;*******************************************************************************
;* Syntax: catalog or c shifted A                                              *
;*******************************************************************************
;* Input: optional u# - deviceaddress of drive to use                          *
;*******************************************************************************
;* Output: directory of default diskdrive or selected diskdrive with ON U#     *
;*******************************************************************************
COM_CATALOG
        jsr INITCATALOG
        jsr bas_CHRGOT$
        beq @GETDIR
        cmp #$22
        bne @NOSTRING
        jsr bas_FRMEVAL$
        lda $0d
        beq @NOSTRING
        jsr bas_FRESTR$
        sta DIRMASKSTR
        stx DIRMASKSTR + 1
        sty DIRMASKSTR + 2
        jsr bas_CHRGOT$
@NOSTRING
        cmp #$91
        bne @GETDIR
        jsr bas_CHRGET$
        cmp #"u"
        beq @GETDRIVE
        jmp SYNTAX_ERROR
@GETDRIVE
        jsr SETNEWDRIVE
@GETDIR
        lda #$01                ;open 1,8,0     
        ldx DISK_DRIVE    
        ldy #$00
        jsr krljmp_SETLFS$      ; logische Filenummer in Akku
        lda DIRMASKSTR          ; LEN OF FILENAME 
        ldx DIRMASKSTR + 1      ; LoByte Filenameaddress
        ldy DIRMASKSTR + 2      ; HiByte Filenameaddress
        jsr krljmp_SETNAM$
        jsr krljmp_OPEN$
        lda #$00
        sta ZP_STATE
        ldx #$01
        jsr krljmp_CHKIN$
        ldy #$03
@DIRLOOP    
        sty ZP_FLAGFB
        jsr krljmp_CHRIN$       ; byte from floppy
        sta ZP_FLAGFC
        ldy ZP_STATE
        bne @EXITDIR
        JSR krljmp_CHRIN$       ; get byte
        ldy ZP_STATE 
        bne @EXITDIR
        ldy ZP_FLAGFB
        dey
        bne @DIRLOOP
        ldx ZP_FLAGFC
        jsr bas_DecimalPrint$   ; 16bit number output
        lda #$20                ; space
        jsr krljmp_CHROUT$      ; type space
@GETBYTE 
        jsr krljmp_CHRIN$       ; get next byte
        ldx ZP_STATE            ; status 
        bne @EXITDIR
        tax                     ; test byte
        beq @PRINTCR            ; zero ? go to cr
        jsr krljmp_CHROUT$      ; else type again
        jmp @GETBYTE            ; get next 
@PRINTCR
        lda #$0D                ; cr
        jsr krljmp_CHROUT$      ; type
        ldy #$02                ; 2 byte for link adr
        bne @DIRLOOP            ; work again
@EXITDIR
        jsr krljmp_CLRCHN$
        lda #$01
        jsr krljmp_CLOSE$       ; close 
        rts                     ; go home

;*******************************************************************************
;* Scratch Command - Deletes a file on disk                                    *
;*******************************************************************************
;* Syntax: scratch or scr shifted A                                            *
;*******************************************************************************
;* Input: filename of file to delete on current drive                          *
;*        optional after filename u# with  deviceaddress of diskdrive          *
;*******************************************************************************
;* Output: errormessage of diskdrive with result of scratch command            *
;*******************************************************************************
COM_SCRATCH
        jsr CLEARCMDBUF
        jsr bas_CHRGOT$
        beq @SCRATCH_ERROR
        jsr bas_FRMEVAL$
        lda $0d
        bmi @GETCMDSTR
@SCRATCH_ERROR
        jmp SYNTAX_ERROR
@GETCMDSTR
        jsr bas_FRESTR$
        stx ZP_FLAGFB
        sty ZP_FLAGFC
        tax
        lda #<CMDBUF + 2
        sta ZP_FLAGFD
        lda #>CMDBUF
        sta ZP_FLAGFE
        jsr CPYSTRINGTOBUF
        tya
        clc
        adc #$02
        sta CMDBUFLEN
        lda #":"
        sta CMDBUF + 1
        jsr ARE_YOU_SURE_REQUEST
        bpl @ACTION
        rts
@ACTION
        lda #$01
        sta CMDSTRLENGTH
        ldx #$05                ; Scratch Command
        jmp DISKCMD

TEXT_AREYOUSURE
        text "are you sure? n  ",CHR_CursorLeft,CHR_CursorLeft,CHR_CursorLeft
        brk

ARE_YOU_SURE_REQUEST
        lda #<TEXT_AREYOUSURE
        ldy #>TEXT_AREYOUSURE
        jsr bas_PrintString$
        lda #$00
        sta ZP_BLNSW
@WAIT_YN
        jsr krljmp_GETIN$
        beq @WAIT_YN
        cmp #"y"
        beq @TRUE
        cmp #"n"
        bne @WAIT_YN
@TRUE
        tax
        lda ZP_BLNCT
@WAITCRSROFF
        beq @WAITCRSROFF
        lda #$01
        sta ZP_BLNSW
        txa
        jsr krljmp_CHROUT$
        lda #$0d
        jsr krljmp_CHROUT$
        cpx #"y"
        beq @YES
        lda #$FF
        rts
@YES
        lda #$00
        rts

;*******************************************************************************
;*   DLOAD Command - Loads a file from default drive to BASICSTART             *
;* DVERIFY Command - Verifies a file from default drive to BASICMEMORY         *
;*******************************************************************************
;* Syntax: dload or dl shifted O                                               *
;*******************************************************************************
;* Input: filename of file to load                                             *
;*        optional after filename ,u# with deviceaddress of drive to load from *
;*******************************************************************************
;* Output: in directmode the memory endaddress of loaded file                  *
;*         in program mode only errormessage if load error occured             *
;*******************************************************************************
COM_DVERIFY
        lda #$01
        byte $2C
COM_DLOAD
        lda #$00                ; Flag for Load
        sta $0A                 ; setzen
        lda #$00                ; Flag for Load
        sta LOADSECADR
        jsr bas_CHRGOT$         ; Prüfe auf weitere Zeichen
        bne @GETFILENAME
        jmp SYNTAX_ERROR      ; No more chars -> Error!
@GETFILENAME
        jsr bas_FRMEVAL$
        lda $0d
        beq @LSYNTAX_ERROR
        jsr bas_FRESTR$
        jsr krljmp_SETNAM$
        jsr bas_CHRGOT$
        cmp #","
        bne @DOLOADVERIFY
        jsr bas_CHRGET$
        cmp #"u"                ; Parameter U = Change Diskdrive to U#
        bne @CHKFORLOAD
        jsr SETNEWDRIVE         ;Get new drivenumber after U
@CHKFORLOAD
        ldx $0A
        cpx #$00
        bne @DOLOADVERIFY
        cmp #"b"                ; Parameter B = Binary load
        bne @LSYNTAX_ERROR
        inc LOADSECADR
        bne @DOLOADVERIFY
@LSYNTAX_ERROR
        jmp SYNTAX_ERROR
@DOLOADVERIFY
        lda #$01                ;open 1,8,0     
        ldx DISK_DRIVE    
        ldy LOADSECADR
        jsr krljmp_SETLFS$      ; logische Filenummer in Akku
        lda $0A
        ldx $2b
        ldy $2c
        jsr krljmp_LOAD$
        bcc @LOAD_VERIFY_OK
        jmp $E1D1
@LOAD_VERIFY_OK
        lda $0A
        beq @CMD_LOAD           ; Accu = 0 then it was load command
        ldx #$1C                ; Verify Error errornumber
        jsr krljmp_READST$
        and #$10                ; Errorbit ?
        bne @ERROR
        lda $7b
        cmp #$02
        bne @VERIFY_DONE
        lda #$64                ; pointer to 'OK'
        ldy #$A3                ; string
        jsr bas_PrintString$    ; and print it
@VERIFY_DONE
;        dec $7A
        rts
;load command execution continues here
@CMD_LOAD
        jsr krljmp_READST$      ; Status lesen
        and #$BF                ; EOF-Bit loeschen
        beq @NOERROR            ; Kein Status Fehler
        ldx #$1D                ; Load Error errornumber
@ERROR
        jmp bas_ROMError$       ; jump to ROM Error routine
@NOERROR
        lda $7b                 ; check for directmode
        cmp #$02                ; $08 = program mode, $02 = directmode
        bne @INPROGRAMMODE      ; if not $02 then its program mode
; if load in directmode print the endaddress of the loaded file
        stx $2d                 ; X = LoByte of Load Endaddress
        sty $2e                 ; Y = HiByte of Load Endaddress
        lda #$76                ; Auf READY
        ldy #$a3                ; zeigen
        jsr bas_PrintString$    ; und ausgeben
        lda #<PROGADR
        ldy #>PROGADR
        jsr bas_PrintString$    ; und ausgeben
        lda LOADSECADR
        beq @BASICLOAD
TODO APROVE DLOAD STARTADRESS - NOT CORRECT AFTER LOADING A BINARY
        ldx $b2
        lda $b3
        jmp @ADROUT
@BASICLOAD
        ldx $2b
        lda $2c
@ADROUT        
        jsr bas_DecimalPrint$
        lda #<PROGADR2
        ldy #>PROGADR2
        jsr bas_PrintString$    ; und ausgeben
        ldx $2d
        lda $2e
        jsr bas_DecimalPrint$
        lda #<PROGSIZE
        ldy #>PROGSIZE
        jsr bas_PrintString$
        jsr @CALCBYTES
        jsr bas_DecimalPrint$
        lda #<BYTES
        ldy #>BYTES
        jsr bas_PrintString$
        jmp $A52A               ; Programmzeilen neu binden und CLR
@INPROGRAMMODE
        jsr $A68E               ; CHRGET Zeiger auf Programmstart
        jsr $A533               ; Programmzeilen neu binden
        jmp $A677

@CALCBYTES
        php
        lda $2d                 ; reload current
        ldy $2e                 ; basic end address
        sec
        ldx LOADSECADR
        beq @BASLOW
        sbc $b2
        byte $2c
@BASLOW
        sbc $2b
        bcs @SkipHigh
        dey
@SkipHigh
        tax                     ; LowByte in X-Reg
        tya                     ; HighByte in Accu
        sec
        ldy LOADSECADR
        beq @BASHIGH
        sbc $b3
        byte $2c
@BASHIGH
        sbc $2c
        plp
        rts

;*******************************************************************************
;* DSAVE Command - Saves a BASIC file to the default drive                     *
;*******************************************************************************
;* Syntax: dsave or ds shifted A                                               *
;*******************************************************************************
;* Input: filename of file to save                                             *
;*        optional after filename ,u# with deviceaddress of drive to save to   *
;*******************************************************************************
;* Output: errormessage if save error occured                                  *
;*******************************************************************************
COM_DSAVE
        jsr bas_CHRGOT$         ; Prüfe auf weitere Zeichen
        beq @SSYNTAX           ; No more chars -> Error!
        jsr bas_FRMEVAL$
        lda $0d
        bpl @SSYNTAX
        jsr bas_FRESTR$
        jsr krljmp_SETNAM$
        jsr bas_CHRGOT$
        cmp #","
        bne @SETSTDADDRESS
@CHKADDRESS
        jsr bas_CHRGET$
        cmp #"u"
        beq @GETDRIVENO
        cmp #$3A
        bcc @GETADDRESS
@SSYNTAX
        jmp SYNTAX_ERROR
@STYPEMISMATCH
        jmp bas_TYPEERR$
@GETDRIVENO
        jsr SETNEWDRIVE
        cmp #","
        bne @SETSTDADDRESS
        jsr bas_CHRGET$
@GETADDRESS
        cmp #$30
        bcc @STYPEMISMATCH
        cmp #$3A
        bcs @STYPEMISMATCH
        lda #$01
        sta LOADSECADR
        jmp @GETMEMADRESSES
@SETSTDADDRESS
        lda #$00
        sta LOADSECADR
        lda $2b
        sta ZP_FLAGFB
        lda $2c
        sta ZP_FLAGFC
        lda $2d
        sta ZP_FLAGFD
        lda $2e
        sta ZP_FLAGFE
        jmp @DOSAVE
@GETMEMADRESSES
        jsr bas_FRMNUM$
        jsr bas_GETADR$         ; Get Startaddress of memory to save
        lda $14
        sta ZP_FLAGFB           ; Store LoByte of memory startaddress
        lda $15
        sta ZP_FLAGFC           ; Store HiByte of memory startaddress
        jsr bas_CHKCOM$
        jsr bas_FRMNUM$
        jsr bas_GETADR$         ; Get Endaddress of memory to save
        lda $14
        sta ZP_FLAGFD           ; Store LoByte of memory endaddress
        lda $15
        sta ZP_FLAGFE           ; Store LoByte of memory endaddress
@DOSAVE
        lda #$01                ;open 1,8,0/1     
        ldx DISK_DRIVE    
        ldy LOADSECADR
        jsr krljmp_SETLFS$      ; logische Filenummer in Akku
        lda ZP_FLAGFC
        cmp #$A0
        bcc @SAVERAM
        lda $01
        and #%11111110          ; paging out BASIC ROM
        sta $01
@SAVERAM
        ldx ZP_FLAGFD           ; Memory Endaddress LoByte
        ldy ZP_FLAGFE           ; Memory Endaddress HiByte
        lda #$fb                ; Pointer to Memory Startaddress
        jsr krljmp_SAVE$
        lda $01
        ora #%00000001          ; paging in BASIC ROM
        sta $01
        bcc @EXIT_SAVE
        tax             ;Fehlernummer nach XReg
        bne @ERROUT
        ldx #$1E        ;BREAK Error
@ERROUT
        jmp bas_ROMError$
@EXIT_SAVE
        rts

;*******************************************************************************
;* FCOPY Command - Copies a file on the Disk to another file on the same Disk  *
;*******************************************************************************
;* Syntax: FCOPY or F shifted C                                                *
;*******************************************************************************
;* Input: filename of destinationfile                                          *
;*        filename of sourcefile                                               *
;*******************************************************************************
;* Output: errormessage if copy error occured                                  *
;*******************************************************************************
COM_FCOPY
        jsr CLEARCMDBUF
        jsr bas_CHRGOT$         ; Prüfe auf weitere Zeichen
        beq @FCERR
        jsr bas_FRMEVAL$
        lda $0d
        beq @FCERR
        jsr bas_FRESTR$ ; A = StrLen, X = LowByte StrPtr, Y = HighByte StrPtr^
        stx ZP_FLAGFB
        sty ZP_FLAGFC
        tax
        lda #<CMDBUF2
        sta ZP_FLAGFD
        lda #>CMDBUF2
        sta ZP_FLAGFE
        jsr CPYSTRINGTOBUF
        sty CMDBUFLEN2
        jsr bas_CHRGOT$
        cmp #$A4                ; Token for TO
        beq @FCPY2
@FCERR
        ldx #$08
        jmp bas_ROMError$
@FCPY2
        jsr bas_CHRGET$         ; Prüfe auf weitere Zeichen
        beq @FCERR              ; No more chars -> Error!
        jsr bas_FRMEVAL$
        lda $0d
        beq @FCERR
        jsr bas_FRESTR$ ; A = StrLen, X = LowByte StrPtr, Y = HighByte StrPtr^
        stx ZP_FLAGFB
        sty ZP_FLAGFC
        tax
        lda #<CMDBUF + 2
        sta ZP_FLAGFD
        lda #>CMDBUF
        sta ZP_FLAGFE
        jsr CPYSTRINGTOBUF
        sty CMDBUFLEN
        lda #":"
        sta CMDBUF + 1
        lda #<CMDBUF2 - 1
        sta ZP_FLAGFB
        lda #>CMDBUF2
        sta ZP_FLAGFC
        lda #<CMDBUF + 2
        sta ZP_FLAGFD
        lda #>CMDBUF
        sta ZP_FLAGFE
        lda ZP_FLAGFD
        clc
        adc CMDBUFLEN
        sta ZP_FLAGFD
        bne @SkipHighBuf
        inc ZP_FLAGFE
@SkipHighBuf
        ldy #$00
        lda #"="
        sta (ZP_FLAGFD),y
        iny
        ldx CMDBUFLEN2
        jsr CPYSTRLOOP
        tya
        clc
        adc CMDBUFLEN
        adc #$02
        sta CMDBUFLEN
        jsr ARE_YOU_SURE_REQUEST
        bpl @CPYACTION
        rts
@CPYACTION
        lda #$01
        sta CMDSTRLENGTH
        ldx #$06                ; Copy Command
        jmp DISKCMD

;*******************************************************************************
;* BAM Command - Display of Disk BAM on Screen                                 *
;*******************************************************************************
;* Syntax: SHOWBAM or s shifted H                                              *
;*******************************************************************************
;* Input:                                                                      *
;*******************************************************************************
;* Output: Errormessage of Diskdrive if occured                                *
;*******************************************************************************
COM_SHOWBAM
; SET PARAMS FOR READING TRACK 18,0
        lda #18
        jsr SETREADTR
        lda #0
        sta ZP_FLAGFE           ; SECTOR COUNTER
        jsr SETREADSEC
        jsr SETCMDCHANNEL
        lda #$00                ; kein Filename
        jsr krljmp_SETNAM$      ; 
        jsr krljmp_OPEN$        ; Open 15,DISK_DRIVE,15
        
; SET PARAMS FOR DISKBUFFER CHANNEL #2
        lda #$02                ;open 2,8,2,"#"
        tay
        ldx DISK_DRIVE    
        jsr krljmp_SETLFS$      ; logische Filenummer in Akku
        lda #$01                ; LEN OF FILENAME 
        ldx #<DISKBUFCHAR       ; LoByte Filenameaddress
        ldy #>DISKBUFCHAR       ; HiByte Filenameaddress
        jsr krljmp_SETNAM$
        jsr krljmp_OPEN$
        jsr SENDREADTRACKCMD
        jsr SENDBUFSECCMD
        ldy #$00
        lda #<DISKBLOCKBUFFER
        sta ZP_FLAGFB
        lda #>DISKBLOCKBUFFER
        sta ZP_FLAGFC
        ldx #$02
        jsr krljmp_CHKIN$
        bcc @RDSECTORTOMEM
        jmp CLOSEALL_ON_DISK_ERR
@RDSECTORTOMEM
        jsr krljmp_CHRIN$
        sta (ZP_FLAGFB),y
        iny
        lda $90
        beq @RDSECTORTOMEM 
        jsr krljmp_CLRCHN$
        lda #$02
        jsr krljmp_CLOSE$
        lda DISK_CMD_CHANNEL
        jsr krljmp_CLOSE$
;-------------------------------
; START OUTPUT OF BAM TO SCREEN
;-------------------------------
        jsr PRIMM
        byte CHR_ClearScreen
;       text CHR_ReverseOn,"sec                                    ",CHR_Return
        text CHR_ReverseOn,"   trk      1         2         3      ",CHR_Return
        text CHR_ReverseOn,"sec12345678901234567890123456789012345 ",CHR_Return
        text CHR_Home,CHR_CursorDown,CHR_CursorDown,0 ;CHR_CursorDown,0
        lda #$00
        sta ZP_FLAGFE
        lda #$01                ; BIT-Maske
        sta ZP_FLAGFB           ; mit 1 Initialisieren "bitmask"
        sta ZP_FLAGFC           ; POSITION
@NXSECT
        ldx #<DISKBLOCKBUFFER+4
        ldy #>DISKBLOCKBUFFER
        stx STAL                ; len1
        sty STAL + 1            ; len2 
        lda #$00                ; Erster Track
        sta ZP_FLAGFD           ; BAMTRACK COUNTER (bamtrack)
        lda #CHR_ReverseOn
        jsr krljmp_CHROUT$
        lda #CHR_Space
        jsr krljmp_CHROUT$
        lda ZP_FLAGFE           ; SECTOR COUNTER   (sector)
        jsr HEX2ASC
; @NOINCR
        pha
        cpx #$30
        bne @NOTZERO
        ldx #$20
@NOTZERO
        txa
        jsr krljmp_CHROUT$
        pla
        jsr krljmp_CHROUT$      ; jsr PRIMM
; STRSECT
; text 18,32,0,0,146,0
        lda #CHR_ReverseOff
        jsr krljmp_CHROUT$
        ldx ZP_FLAGFD           ; bamtrack
@NXTRACK
        lda ZP_FLAGFE           ; sector
        cmp MAXSECS,x
        bcs @UNUSEDSEC
        ldy ZP_FLAGFC           ; position
        lda (STAL),y            ; len1
        and ZP_FLAGFB           ; bitmask
        bne @FREE
        lda #CHR_Asterisk       ; Sternchen = Belegter Sektor
        byte $2c
@FREE
        lda #CHR_Dot            ; Punkt = freier Block
        byte $2c
@UNUSEDSEC
        lda #CHR_Space          ; Unbenutzter Block Leerzeichen
        jsr krljmp_CHROUT$
        lda STAL
        clc
        adc #$04
        bcc @NOHIBY
        inc STAL + 1
@NOHIBY
        sta STAL
        inc ZP_FLAGFD           ; bamtrack
        lda ZP_FLAGFD           ; bamtrack
        tax
        cmp #35
        bne @NXTRACK
        jsr @DOPRINTCHARS
        inc ZP_FLAGFE           ; sector
        lda ZP_FLAGFE           ; sector
        cmp #21
        beq @BAMEXIT
        asl ZP_FLAGFB           ; bitmask
        bne @NXSECT
        inc ZP_FLAGFB           ; bitmask
        inc ZP_FLAGFC           ; position
        lda ZP_FLAGFC           ; position
        cmp #$04
        bne @NXSECT
@BAMEXIT
        lda #CHR_ReverseOn
        jsr krljmp_CHROUT$
        ldy #$00
@PRNLABEL
        lda DISKBLOCKBUFFER+144,y
        jsr krljmp_CHROUT$
        iny
        cpy #25
        bne @PRNLABEL
        lda #CHR_ReverseOff
        jsr krljmp_CHROUT$
        jsr @WAIT_FOR_RETKEY
        rts

@DOPRINTCHARS
        php
        pha
        tya
        pha
        txa
        pha
        lda #<LINEEND           ; jsr PRIMM
        ldy #>LINEEND           ; !tx 18,32,146,13,0
        jsr bas_PrintString$
        pla
        tax
        pla
        tay
        pla
        plp
        rts

@WAIT_FOR_RETKEY
        jsr $ffe4
        bne @GOTKEY
        cmp #CHR_Return
        bne @WAIT_FOR_RETKEY
@GOTKEY
        rts

LINEEND
        byte 18,32,146,13
        brk

;*******************************************************************************
;* HEADER Command - Format a Disk soft or hard                                 *
;*******************************************************************************
;* Syntax: HEADER or HE shifted A                                              *
;*******************************************************************************
;* Input: name for the disk (,Ixx)                                             *
;*******************************************************************************
;* Output: errormessage if format error occured                                *
;*******************************************************************************
COM_FORMATDISK
        jsr CLEARCMDBUF
        jsr bas_CHRGOT$         ; Prüfe auf weitere Zeichen
        beq @NDERR
        jsr bas_FRMEVAL$
        lda $0d
        bmi @GETLABEL
@NDERR
        ldx #31
        byte $2c
@NDIDERR
        ldx #32
        jmp bas_ROMError$
@GETLABEL
        jsr bas_FRESTR$ ; A = StrLen, X = LowByte StrPtr, Y = HighByte StrPtr^
        stx ZP_FLAGFB
        sty ZP_FLAGFC
        tax
        lda #<CMDBUF + 2
        sta ZP_FLAGFD
        lda #>CMDBUF
        sta ZP_FLAGFE
        jsr CPYSTRINGTOBUF
        tya
        clc
        adc #$02
        sta CMDBUFLEN
        jsr bas_CHRGOT$
        cmp #","
        bne @RENEWDISK
        pha
        jsr bas_CHKCOM$
        cmp #"i"
        bne @NDIDERR
        pla
        sta CMDBUF2
        jsr bas_CHRGET$
        and #$7f
        sta CMDBUF2 + 1
        jsr bas_CHRGET$
        and #$7f
        sta CMDBUF2 + 2
        jsr bas_CHRGET$
        bne @NDIDERR
        ldy CMDBUFLEN
        ldx #$00
        lda CMDBUF2,x
        sta CMDBUF,y
        iny
        inx
@PROOFID
        lda CMDBUF2,x
        cmp #$30
        bcc @NDIDERR
        cmp #$3A
        bcs @CHKALPHA
        sta CMDBUF,y
        iny
        inx
        cpx #$03
        beq @ADJUSTBUFLEN
@CHKALPHA        
        cmp #$41
        bcs @CHKAGAIN
        bcc @NDERR
@CHKAGAIN        
        cmp #$5B
        bcs @NDERR
        sta CMDBUF,y
        iny
        inx
        cpx #$03
        bne @PROOFID
@ADJUSTBUFLEN
        txa
        clc
        adc CMDBUFLEN
        sta CMDBUFLEN
@RENEWDISK
        jsr ARE_YOU_SURE_REQUEST
        bpl @FORMATACTION
        rts
@FORMATACTION
        lda #":"
        sta CMDBUF + 1
        lda #$01
        sta CMDSTRLENGTH
        ldx #$07                ; New Command
        jmp DISKCMD

;*******************************************************************************
;* LABEL Command - Rename a Disk                                               *
;*******************************************************************************
;* Syntax: LABEL or L shifted A                                                *
;*******************************************************************************
;* Input: new name for the disk                                                *
;*******************************************************************************
;* Output: errormessage if label error occured                                 *
;*******************************************************************************
COM_LABEL
        jsr CLEARCMDBUF
        lda #$80
        sta COMM_TEMP_VAR
        jsr bas_CHRGOT$         ; Prüfe auf weitere Zeichen
        beq @LABELERR
        jsr bas_FRMEVAL$
        lda $0d
        bmi @GETLABEL
@LABELERR
        ldx #31
        jmp bas_ROMError$

@GETLABEL
        jsr bas_FRESTR$ ; A = StrLen, X = LowByte StrPtr, Y = HighByte StrPtr^
        stx ZP_FLAGFB
        sty ZP_FLAGFC
        tax
        cmp #$11
        bcc @LENGTHOK
        ldx #$17                ;"STRING TOO LONG" Error
        jmp bas_ROMError$
@LENGTHOK
        lda #<CMDBUF
        sta ZP_FLAGFD
        lda #>CMDBUF
        sta ZP_FLAGFE
        jsr CPYSTRINGTOBUF
        sty CMDBUFLEN
        lda #$00
        sta COMM_TEMP_VAR
        lda #$02                ;open 2,8,2,"#"
        tay
        ldx DISK_DRIVE    
        jsr krljmp_SETLFS$      ; logische Filenummer in Akku
        lda #$01                ; LEN OF FILENAME 
        ldx #<DISKBUFCHAR       ; LoByte Filenameaddress
        ldy #>DISKBUFCHAR       ; HiByte Filenameaddress
        jsr krljmp_SETNAM$
        jsr krljmp_OPEN$
        bcc @LABEL_PREP_READWRITE
        jmp LABEL_DISKERR

@LABEL_PREP_READWRITE
        lda #18
        jsr SETREADTR
        lda #0
        jsr SETREADSEC
        jsr SETCMDCHANNEL
        lda #$00                ; kein Filename
        jsr krljmp_SETNAM$      ; 
        jsr krljmp_OPEN$        ; Open 15,DISK_DRIVE,15
        jsr SENDREADTRACKCMD
        jsr krljmp_READST$
        beq @LABEL_RDTRACKOK
        jmp @LABEL_CLOSEBUF
@LABEL_RDTRACKOK
        jsr SENDBUFPOSCMD
        jsr krljmp_READST$
        bne @LABEL_CLOSEBUF
        ldx #$02
        jsr krljmp_CHKIN$
        bcc @LABEL_READLABEL
        jmp LABEL_DISKERR

@LABEL_READLABEL
        ldy #$10
        ldx #$00
@LABEL_READLOOP
        jsr krljmp_CHRIN$
        sta CMDBUF2,x
        inx
        dey
        bne @LABEL_READLOOP
        jsr krljmp_CLRCHN$
; Output old and new label and ask for sure
        lda #<LABEL_TEXT
        ldy #>LABEL_TEXT
        jsr bas_PrintString$
        lda #<CMDBUF2
        ldy #>CMDBUF2
        jsr bas_PrintString$
        lda #$0d
        jsr krljmp_CHROUT$
        lda #<LABEL_NEWTEXT
        ldy #>LABEL_NEWTEXT
        jsr bas_PrintString$
        lda #<CMDBUF
        ldy #>CMDBUF
        jsr bas_PrintString$
        lda #$0d
        jsr krljmp_CHROUT$
        jsr ARE_YOU_SURE_REQUEST
        bpl @LABEL_WRITENEWNAME
        jmp @LABEL_CLOSEBUF
@LABEL_WRITENEWNAME
        jsr SENDBUFPOSCMD
        jsr krljmp_READST$
        bne @LABEL_CLOSEBUF
        ldx #$02
        jsr krljmp_CHKOUT$
        ldy CMDBUFLEN
        ldx #$00
@LABEL_WRITENAME
        lda CMDBUF,x
        jsr krljmp_CHROUT$
        inx
        dey
        bne @LABEL_WRITENAME
        lda #18
        jsr SETWRITETR
        lda #0
        jsr SETWRITESEC
        jsr SENDWRITETRACKCMD
@LABEL_CLOSEBUF
        lda #$02
        jsr krljmp_CLOSE$
LABEL_DISKERR
        jmp GETDISKERR

;----- DISK BLOCK COMMANDS -----
CLOSEALL_ON_DISK_ERR
        jsr krljmp_CLRCHN$
        lda #$02
        jsr krljmp_CLOSE$
        lda DISK_CMD_CHANNEL
        jsr krljmp_CLOSE$
        pla
        pla
        jmp bas_ROMError$

;----- SEND CMD U1:2 0 xx xx -----
SENDREADTRACKCMD
        jsr krljmp_CLRCHN$
        ldx DISK_CMD_CHANNEL
        jsr krljmp_CHKOUT$
        bcc @CHN_OK
        jmp CLOSEALL_ON_DISK_ERR
@CHN_OK
        ldx #$00
        ldy #WRITETRSEC-READTRSEC
@SENDSTR
        lda READTRSEC,x
        jsr krljmp_CHROUT$
        inx
        dey
        bne @SENDSTR
        jsr krljmp_CLRCHN$
        rts

;----- SEND CMD U2:2 0 xx xx -----
SENDWRITETRACKCMD
        jsr krljmp_CLRCHN$
        ldx DISK_CMD_CHANNEL
        jsr krljmp_CHKOUT$
        bcc @CHN_OK
        jmp CLOSEALL_ON_DISK_ERR
@CHN_OK
        ldx #$00
        ldy #BPDISKNAME-WRITETRSEC
@SENDSTR
        lda WRITETRSEC,x
        jsr krljmp_CHROUT$
        inx
        dey
        bne @SENDSTR
        jsr krljmp_CLRCHN$
        rts

;----- SEND CMD B-P:2 144 -----
SENDBUFPOSCMD
        jsr krljmp_CLRCHN$
        ldx DISK_CMD_CHANNEL
        jsr krljmp_CHKOUT$
        bcc @CHN_OK
        jmp CLOSEALL_ON_DISK_ERR
@CHN_OK
        ldx #$00
        ldy #DISKBUFCHAR-BPDISKNAME
@SENDSTR
        lda BPDISKNAME,x
        jsr krljmp_CHROUT$
        inx
        dey
        bne @SENDSTR
        jsr krljmp_CLRCHN$
        rts

;----- SEND CMD B-P:2 0 -----
SENDBUFSECCMD
        jsr krljmp_CLRCHN$
        ldx DISK_CMD_CHANNEL
        jsr krljmp_CHKOUT$
        bcc @CHN_OK
        jmp CLOSEALL_ON_DISK_ERR
@CHN_OK
        ldx #$00
        ldy #BPDISKNAME-BPSECTORFIRSTBYTE
@SENDSTR
        lda BPSECTORFIRSTBYTE,x
        jsr krljmp_CHROUT$
        inx
        dey
        bne @SENDSTR
        jsr krljmp_CLRCHN$
        rts
