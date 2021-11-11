;*******************************************************************************
;* EvalMy Routine                                                              *
;* BASICVECTOR $030A                                                           *
;*******************************************************************************
; align
;VEC_EVALMY
;        lda #0
;        sta $0D
;        jsr bas_CHRGET$
;        cmp #$CC
;        bcc @EVALLV
;        cmp #$FE
;        bcs @EVALLV
;        jmp BYEGO               ; It is one of our Commands so do it
;@EVALLV
;        jsr bas_CHKLETTER$      ; Prüft auf Buchstabe im Code
;        bcc @EVALV2             ; Kein Buchstabe dann nach BASIC
;        jsr $AF28
;        lda $0D                 ; Typflag holen
;        bpl @CHKTI$
;        lda #$00                ; Wert laden und
;        sta $70                 ; in Rundungsbyte fur FAC
;        cpx #$44                ; 'D'? (von DS$)
;        bne @CHKTI$             ; nein -> $AF40 prüft auf TI$
;        cpy #$D3                ; 'S'? (von DS$)
;        bne @CHKTI$             ; nein -> $AF40 prüft auf TI$
;        lda #$01
;        sta COMM_DSSTRFLAG
;        jsr DISKERR_DSVAR       ; DS$ = DiskError
;        lda #$00
;        sta COMM_DSSTRFLAG
;        lda #<DISKERRBUF
;        ldy #>DISKERRBUF
;        jmp $B487               ; bringt String in Str.bereich
;@CHKTI$
;        jmp $AF40               ; Jump into Basic EVAL at $AF40 checking for TI$
;@EVALV2
;        lda $7A
;        bne @EVALRT
;        dec $7B
;@EVALRT
;        dec $7A
;        jmp bas_EVAL$ + 3       ; Continue with BASIC V2 Routine
;-------------------------------------------------------------------------------

VEC_EVALMY
        lda #0
        sta $0D
        jsr bas_CHRGET$
        bcs @EVALMY_IS_FUNCTION_TOKEN       ; Funktionstoken (>BASICTOKEN)?
        jmp bas_ASCIITOFP$      ; BCF3 ASCII nach Fließkommaformat

@EVALMY_IS_FUNCTION_TOKEN
        cmp #LASTCMDTOKEN       ; LCODE
        bcc EVALNOFUNC          ; L48A1
; L48A2
        sec
        sbc #LASTCMDTOKEN       ; LCODE
        asl
        pha
        jsr bas_CHRGET$
        jsr bas_CHKOPEN$        ; Prüfe auf Klammer auf / Wenn nicht "(" Syntax 
        pla
        tax
        lda FUNKTAB,X
        sta $55                 ; Lowbyte der User Funktion
        lda FUNKTAB+1,X
        sta $56                 ; Highbyte der User Funktion
        jmp $0054               ; User Funktion ausführen

EVALNOFUNC
        jsr bas_CHKLETTER$      ; $B113 prüft auf Buchstaben
        bcs @EVALMY_CHECK_DSVAR ; Wenn Buchstabe dann auf DS($) prüfen
;        CMP #CODINSTR          ; INSTR Funktion
;        BNE CHKDUP
;        JMP INSTR
;CHKDUP
;        CMP #CODDUP            ; DUP Funktion
;        BNE EVALMY_HEXBIN
;        JMP DUPSTR
@EVALMY_HEXBIN
        cmp #"$"                ; Hexzahl -> Dezimalausgabe
        beq DECHEX
        cmp #"%"                ; Binärzahl -> Dezimalausgabe
        beq DECBIN1
        jmp bas_CHECKPI$        ; $AE9A
@EVALMY_CHECK_DSVAR
        jsr bas_CHRGOT$
        cmp #"d"
        beq @EVALMY_DS_CHECK_S  ; Wenn D im basicbuffer dann auf S prüfen
@EVALMY_VAR
        jmp bas_GETVAR$         ; Ist nicht D -> Dann normale Variable holen
@EVALMY_DS_CHECK_S
        ldy #0
        jsr @EVALMY_SPACE
        cmp #"s"                
        bne @EVALMY_VAR         ; Nicht S dann mit BASIC holen
        jsr bas_SEARCHVAR$      ; Prüfen ob eine Variable DS($) existiert
        lda $0D
        beq @EVAL_DS_NUM        ; Is es nicht DS$ dann numerisch auswerten
        jmp DSSTR
@EVAL_DS_NUM
        jmp DSFAC
@EVALMY_SPACE
        iny
        lda (ZEIBAS),Y          ; Prüfe Bufferzeiger auf SPACE und überlesen
        cmp #" "
        beq @EVALMY_SPACE
        rts

;*******************************************************************************
;* EvalMy Routine                                                              *
;* Ausgabe einer Binärzahl als Dezimalzahl                                     *
;*******************************************************************************
DECBIN1
        JMP DECBIN
;*******************************************************************************
;* EvalMy Routine                                                              *
;* Ausgabe einer Hexzahl als Dezimalzahl                                       *
;*******************************************************************************
DECHEX
        LDA INTADR
        PHA
        LDA INTADR+1
        PHA
        LDY #1
        LDA #0
        STA INTADR
        STA INTADR+1
HEX1
        LDA (ZEIBAS),Y
        JSR DECNIB
        BCS HEXEND
        PHA
        LDA #16
        JSR MULT8
        PLA
        CLC
        ADC INTADR
        STA INTADR
        INY
        CPY #5
        BCC HEX1
HEXEND
        LDA INTADR
        STA $63
        LDA INTADR+1
        STA $62
        PLA
        STA INTADR+1
        PLA
        STA INTADR
        TYA
        CLC
        ADC ZEIBAS
        STA ZEIBAS
        BCC DEC2
        INC ZEIBAS+1
DEC2
        LDX #$90
        SEC
        JMP $BC49
DECNIB
        SEC
        SBC #"0"
        CMP #10
        BCC @DEC1
        SEC
        SBC #7
@DEC1
        CMP #16
        RTS

;*******************************************************************************
;* EvalMy Routine                                                              *
;* Binären Ausdruck einlesen                                                   *
;*******************************************************************************
DECBIN
        LDA #0
        STA $63
        STA $62
        LDY #1
@DECB1
        LDA (ZEIBAS),Y
        JSR DECBIT
        BCS @BINEND
        INY
        CPY #17
        BCC @DECB1
@BINEND
        TYA
        CLC
        ADC ZEIBAS
        STA ZEIBAS
        BCC @DEB2
        INC ZEIBAS+1
@DEB2   
        JMP DEC2
DECBIT
        SEC
        SBC #"0"
        CMP #$02
        BCC @DEB3       ; Ist es "0" oder "1"
        RTS             ; Dann wandeln - sonst Fehler!
@DEB3
        LSR
        ROL $63
        ROL $62
        CLC
        RTS

;*******************************************************************************
;* EvalMy Routine                                                              *
;* Binären Ausdruck einlesen                                                   *
;*******************************************************************************
MULT8   PHA
        LDA INTADR
        STA ZP_FLAGFE
        LDA INTADR+1
        STA ZP_FLAGFF
        LDA #0
        STA INTADR
        STA INTADR+1
        PLA
MULT01  LSR
        BCS MULT03
        BEQ MULTEND
        BCC MULT02
MULT03  PHA
        LDA INTADR
        CLC
        ADC ZP_FLAGFE
        STA INTADR
        LDA INTADR+1
        ADC ZP_FLAGFF
        STA INTADR+1
        PLA
MULT02  ASL ZP_FLAGFE
        ROL ZP_FLAGFF
        JMP MULT01
MULTEND RTS

;**************************************************************
;*** Paragraph @EINBINDUNG IN OS VECTOR $0326-$0327  IBSOUT ***
;**************************************************************
;KG01    JSR SCREENOUT
;KEYGET  LDA ANZKEY
;        STA $CC
;        STA $0292
;        BEQ KEYGET
;        SEI
;        LDA $CF
;        BEQ KG02
;        LDA $CE
;        LDX $0287
;        LDY #$00
;        STY $CF
;        JSR $EA13
;KG02    JSR $E5B4
;        CMP #$83               ;SHIFT RUN/STOP
;        BNE KG03
;        LDX #6
;        SEI
;        STX ANZKEY
;KG04    LDA RUNSTOP-1,X
;        STA $0276,X
;        DEX
;        BNE KG04
;KEYGET1 BEQ KEYGET
;KG03    CMP #141                ;SHIFT-RETURN-CODE
;        BCS KG01
;        CMP #13                 ;RETURN-CODE
;        BEQ KGCR
;        CMP #133                ;F1-CODE
;        BCC KG01
;        TAY
;        LDA #32                 ;SPACE-CODE
;        BIT FLAG
;        BNE KG11
;        TYA
;        JMP KG01
;KG11    TYA
;        SEC
;        SBC #137                ;F8-CODE
;        ASL
;        BPL KG05
;        CLC
;        ADC #7
;KG05    CLC
;        ADC #1
;        ASL                     ; * LENKEY
;        STA FLAGFF
;        ASL
;        ASL
;        ADC FLAGFF
;        TAX
;        LDY #1
;        SEI
;KG08    LDA KEYTEXT,X
;        BEQ KGKEYEND
;        CMP #"'"
;        BNE KGO1
;        LDA #34                 ;' ersetzen durch "
;KGO1    CMP #"_"
;        BNE KGOK
;        LDA #13                 ;<- ersetzen durch RETURN-Code
;KGOK    STA $0276,Y
;        INX
;        INY
;        CPY #11                 ;LENKEY+1
;        BNE KG08
;KGKEYEND        
;        DEY
;        STY ANZKEY
;        CLI
;        JMP KEYGET
;KGCR    LDY $D5
;        STY CRFLAG
;KG0A    LDA (CZEI),Y
;        CMP #32
;        BNE KG09
;        DEY
;        BNE KG0A
;KG09    INY
;        STY $C8
;        LDY #0
;        STY $0292
;        STY SPALTE
;        STY $D4
;        LDA $C9
;        BMI KG0C
;KG0B    LDX ZEILE
;        JSR $E6ED
;        CPX $C9
;        BNE KG0C
;        LDA $CA
;        STA SPALTE
;        CMP $C8
;        BCC KG0C
;        BCS NBAS101
;
;******************************************
;*** Paragraph @EINGABE VOM BILDSCHIRM@ ***
;******************************************
;SCREENGET
;        TYA
;        PHA
;        TXA
;        PHA
;        LDA CRFLAG
;        BNE KG0C
;        JMP KEYGET
;KG0C    LDY SPALTE
;        LDA (CZEI),Y
;        STA DIV
;        AND #$3F
;        ASL DIV
;        BIT DIV
;        BPL NBAS002
;        ORA #$80
;NBAS002 BCC NBAS003
;        LDX HKFL
;        BNE NBAS004
;NBAS003 BVS NBAS004
;        ORA #$40
;NBAS004 INC SPALTE
;        JSR $E684
;        CPY FLAGC8
;        BNE NBAS005
;NBAS101 LDA #0
;        STA CRFLAG
;        LDA #13
;        LDX $99
;        CPX #3
;        BEQ NBAS006
;        LDX $9A
;        CPX #3
;        BEQ NBAS007
;NBAS006 JSR SCRENOUT
;NBAS007 LDA #13
;NBAS005 STA DIV
;        PLA
;        TAX
;        PLA
;        TAY
;        LDA DIV
;        CMP #$DE
;        BNE NBAS008
;        LDA #$FF
;NBAS008 CLC
;        RTS
;
;****************************************************************
;*** Vector: Indirect entry to Kernal CHROUT Routine ($F1CA). ***
;*** Für neue Steuerzeichen CTRL-L / CTRL-                    ***
;****************************************************************
;NBSOUT  PHA
;        LDA $9A
;        CMP #3
;        BNE NBS1
;        PLA
;        JMP SCREENOUT
;NBS1    JMP $F1D5
;NBSIN   LDA $99
;        BNE NBS2
;        LDA $D3
;        STA $CA
;        LDA $D6
;        STA $C9
;        JMP SCREENGET
;NBS2    CMP #3
;        BEQ NBS4
;        JMP $F173
;NBS4    STA $D0
;        LDA $D5
;        STA $C8
;        JMP SCREENGET
;----- Paragraph @NEUE ROUTINE SCREENOUT@ -----
;****************************************************************
;*** NEUE ROUTINE SCREENOUT                                   ***
;****************************************************************
;SCREENOUT        
;        PHA
;        STA DIV
;        TXA
;        PHA
;        TYA
;        PHA
;        LDA #16
;        BIT FLAG
;        BEQ SCRFX
;SCRFA   LDA #8
;        BIT FLAGA
;        BNE SCR103
;        LDA #32
;        BIT FLAGA
;        BEQ SCRF2
;        LDA DIV
;        AND #$7F
;        CMP #" "
;        BCS SCRF1
;INS1    LDA #255-32
;        JSR CLRFLA
;        JMP SCRF2
;SCRF1   LDY $D5
;        CPY #39
;        BEQ INS2
;        LDA (CZEI),Y
;        CMP #" "
;        BNE INS1
;INS2    LDA $D4
;        PHA
;        LDA #0
;        STA $D4
;        LDA DIV
;        PHA
;        LDA #$94
;        JSR $E716
;        PLA
;        STA DIV
;        PLA
;        STA $D4
;SCRF2   BIT $9D
;        BPL SCR002
;        LDA $D4
;        ORA $D8
;        BNE SCR002
;        TSX
;        TXA
;        CLC
;        ADC #12
;        TAX
;        LDA $0100,X
;        CMP #<NN032A+2
;        BNE SCR002
;        LDA $0101,X
;        CMP #>NN032A+2
;        BEQ SCR001
;SCR002  LDA #4
;        BIT FLAGA
;        BEQ SCR002A
;        JMP SCOLIST
;SCR103  JMP SCR003
;SCRFX   JMP $E71D
;SCR002A LDA DIV
;        CMP #26        ; CTRL-Z ->Insert Mode ON 
;        BNE SCR002B
;        LDA #32
;        JSR SETFLA     ; BIT-Flagge Insert Mode setzen
;        BNE ESCEND
;SCR002B LDA DIV
;        CMP #3         ; CTRL-C (RUN/STOP) -> ESCAPE (Insert Mode Off etc.)
;        BEQ ESCAPE              
;        CMP #12        ; CTRL-L ->Loesche Zeile bis Ende
;        BNE ESC1
;        LDY $D3        ; Aktueller Cursoroffset auf Bildschirm
;        LDA #" "       ; LEERZEICHEN
;ESC2    STA (CZEI),Y   ; in Bildschirmspeicherzeile Offset Y schreiben
;        CPY $D5        ; Zeilenende aktuelle Bildschirmzeile erreicht?
;        BEQ ESCAPE     ; dann Raus aus der Schleife
;        INY            ; Position im Bildschiemspeicher erhühen
;        BNE ESC2       ; solange Y<255 schleife weiter
;ESC1    CMP #21        ; CTRL-U ->Cursor in linke untere Ecke
;        BEQ ESC5
;;----------------------------------------------------
;        CMP #1         ; CTRL-A ->Cursor hinter das letzte
;        BNE ESC7       ; Hochkomma in der aktuellen Zeile
;        LDX ZEILE
;        JSR $E6ED
;        LDY $D5
;        LDA #34                 ;" "
;ESC3    CMP (CZEI),Y
;        BEQ ESC6
;        DEY
;        BPL ESC3
;!by $2C
;ESC5    LDX #24         ; CTRL-U -> Setze Cursor Zeile 24
;        LDY #0          ; Spalte 0
;ESC6    JSR $E50C       ; und Position setzen
;;----------------------------------------------------
;ESCAPE  LDA #0                  ; Alle Modi
;        STA $D4                 ; -Hochkomma
;        STA $C7                 ; -Insert
;        STA $D8                 ; -Revers
;ESCEND  JMP $E6A8               ; zurücksetzen
;SCRXY2  BNE SCR002
;;----------------------------------------------------
;ESC7    CMP #4                  ; CTRL-D
;        BNE SCRFX
;        LDA #0
;        STA $D4
;        STA $D8
;        LDA #29                 ; Cursor Rechts
;        JSR BSOUT
;        LDA #20                 ; Delete
;        JSR BSOUT
;        JMP ESCAPE
