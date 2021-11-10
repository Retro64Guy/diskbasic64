;*******************************************************************************
;* EvalMy Routine                                                              *
;*******************************************************************************
; align

VEC_EVALMY
        lda #0
        sta $0D
        jsr bas_CHRGET$
        cmp #$CC
        bcc @EVALLV
        cmp #$FE
        bcs @EVALLV
        jmp BYEGO               ; It is one of our Commands so do it
@EVALLV
        jsr bas_CHKLETTER$      ; Prüft auf Buchstabe im Code
        bcc @EVALV2             ; Kein Buchstabe dann nach BASIC
        jsr $AF28
        lda $0D                 ; Typflag holen
        bpl @CHKTI$
        lda #$00                ; Wert laden und
        sta $70                 ; in Rundungsbyte fur FAC
        cpx #$44                ; 'D'? (von DS$)
        bne @CHKTI$             ; nein -> $AF40 prüft auf TI$
        cpy #$D3                ; 'S'? (von DS$)
        bne @CHKTI$             ; nein -> $AF40 prüft auf TI$
        lda #$01
        sta COMM_DSSTRFLAG
        jsr DISKERR_DSVAR       ; DS$ = DiskError
        lda #$00
        sta COMM_DSSTRFLAG
        lda #<DISKERRBUF
        ldy #>DISKERRBUF
        jmp $B487               ; bringt String in Str.bereich
@CHKTI$
        jmp $AF40               ; Jump into Basic EVAL at $AF40 checking for TI$
@EVALV2
        lda $7A
        bne @EVALRT
        dec $7B
@EVALRT
        dec $7A
        jmp bas_EVAL$ + 3       ; Continue with BASIC V2 Routine
