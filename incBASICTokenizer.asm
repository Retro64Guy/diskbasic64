//*******************************************************************************
//* Tokenizer Routine                                                           *
//* Original A57C - A612                                                        *
//*******************************************************************************
#define TOKENIZER
#importonce

VEC_TOKEN:
        ldx $7a
        ldy #$04
        sty $0f

TOK_BUFLOOP:
        lda $0200,x
        bpl TOK_PROOFCHRORTOK
        cmp #$ff
        beq TOK_UPDATEBUFFER
        inx
        bne TOK_BUFLOOP

TOK_PROOFCHRORTOK:
        cmp #$20
        beq TOK_UPDATEBUFFER
        sta $08
        cmp #$22
        beq TOK_READBUFFER
        bit $0f
        bvs TOK_UPDATEBUFFER
        cmp #$3f
        bne TOK_PROOFFORNUM
        lda #$99
        bne TOK_UPDATEBUFFER

TOK_PROOFFORNUM:
        cmp #$30
        bcc TOK_INITTOKENIZER
        cmp #$3c
        bcc TOK_UPDATEBUFFER

TOK_INITTOKENIZER:
        sty $71
        ldy #$00
        sty $0b
        stx $7a
        lda #<COMMAND_LIST
        sta $64
        lda #>COMMAND_LIST
        sta $65
        bne TOK_SKIPPTRHIBYTE

TOK_INCCMDLISTPTR:
        inx
        inc $64
        bne TOK_SKIPPTRHIBYTE
        inc $65

TOK_SKIPPTRHIBYTE:
        lda $0200,x
        sec
        sbc ($64),y
        beq TOK_INCCMDLISTPTR
        cmp #$80
        bne TOK_NEXTTOKEN
        ora $0b

TOK_SAVEBUFPTR:
        ldy $71

TOK_UPDATEBUFFER:
        inx
        iny
        sta $01fb,y
        lda $01fb,y
        beq TOK_EXIT
        sec
        sbc #$3a
        beq TOK_SAVELASTBUFPOS
        cmp #$49
        bne TOK_CHKNORMTOK

TOK_SAVELASTBUFPOS:
        sta $0f

TOK_CHKNORMTOK:
        sec
        sbc #$55
        bne TOK_BUFLOOP
        sta $08

TOK_SKIPBUFCHAR:
        lda $0200,x
        beq TOK_UPDATEBUFFER
        cmp $08
        beq TOK_UPDATEBUFFER

TOK_READBUFFER:
        iny
        sta $01fb,y
        inx
        bne TOK_SKIPBUFCHAR

TOK_NEXTTOKEN:
        ldx $7a
        inc $0b

TOK_UPDATECMDPTR:
        lda ($64),y
        php
        inc $64
        bne TOK_SEARCHCMDCHAR
        inc $65

TOK_SEARCHCMDCHAR:
        plp
        bpl TOK_UPDATECMDPTR
        lda ($64),y
        bne TOK_SKIPPTRHIBYTE
        lda $0200,x
        bpl TOK_SAVEBUFPTR

TOK_EXIT:
        sta $01fd,y
        dec $7b
        lda #$ff
        sta $7a
        rts

//#region Original from OldSkoolCoder (John Dale)
//********************************************************************************
//        jsr bas_CRUNCH$ + 3
//
//        ldy #5
//LOOPOT
//        lda Buffer-5,y
//        beq CNCHRT
//        cmp #CHR_Quote
//        beq LOOPQT
//        cmp #"a"
//        bcc LOOPBK
//        cmp #"["
//        bcs LOOPBK
//        sty $B1
//        ldx #$00
//        stx $0B
//        cmp #128
//        bcc LOOPIN
//        eor #128
//
//LOOPIN
//        sec
//        sbc Command_List,x
//        beq NEXT
//        cmp #128
//        beq DONE
//
//LOOPNO
//        lda Command_List,x      // Check next Char in Command_List
//        beq LOOPBK              // If ZERO this is end of all Commands in List
//        bmi CONTLP
//        inx
//        bne LOOPNO
//
//CONTLP
//        inc $0B
//        ldy $B1
//        byte $A9
//
//NEXT
//        iny
//        lda Buffer-5,y
//        inx
//        bne LOOPIN
//
//DONE
//        ldx $B1
//        lda $0B
//        clc
//        adc #$CC                // First Token we use - Tokens up to $CB are Used
//        sta Buffer-5,x
//
//LOOPC
//        iny
//        inx
//        lda Buffer-5,y          // Here we shuffle down the BYtes in commandline
//        sta Buffer-5,x          // Because we put our 1-byte Token in the Buffer
//        bne LOOPC
//
//        ldy $B1
//
//LOOPBK
//        iny
//        bne LOOPOT              // Check next Bytes in Buffer
//
//LOOPQT
//        iny
//        lda Buffer-5,y
//        beq CNCHRT
//        cmp #CHR_Quote
//        bne LOOPQT
//        beq LOOPBK
//
//CNCHRT
//        lda #0                  // End of Buffer reached
//        sta Buffer-5,y          // so put a zero at buffer end
//        rts
//
//********************************************************************************
//#endregion

//*******************************************************************************
//* Command_List                                                                *
//*******************************************************************************

COMMAND_LIST:
        //BASIC V2 Commands      //TOKEN NO.
        .text "enD"              // $80
        .text "foR"              // $81
        .text "nexT"             // $82
        .text "datA"             // $83
        .text "input"            // $84   INPUT#
        .byte $A3                // $84   INPUT#
        .text "inpuT"            // $85
        .text "diM"              // $86
        .text "reaD"             // $87
        .text "leT"              // $88
        .text "gotO"             // $89
        .text "ruN"              // $8A
        .text "iF"               // $8B
        .text "restorE"          // $8C
        .text "gosuB"            // $8D
        .text "returN"           // $8E
        .text "reM"              // $8F
        .text "stoP"             // $90
        .text "oN"               // $91
        .text "waiT"             // $92
        .text "loaD"             // $93
        .text "savE"             // $94
        .text "verifY"           // $95
        .text "deF"              // $96
        .text "pokE"             // $97
        .text "print"            // $98   PRINT#
        .byte $A3                // $98   PRINT#
        .text "prinT"            // $99
        .text "conT"             // $9A
        .text "lisT"             // $9B
        .text "clR"              // $9C
        .text "cmD"              // $9D
        .text "syS"              // $9E
        .text "opeN"             // $9F
        .text "closE"            // $A0
        .text "geT"              // $A1
        .text "neW"              // $A2
        .text "tab"              // $A3   TAB(
        .byte $A8                // $A3   TAB(
        .text "tO"               // $A4
        .text "fN"               // $A5
        .text "spc"              // $A6   SPC(
        .byte $A8                // $A6   SPC(
        .text "theN"             // $A7
        .text "noT"              // $A8
        .text "steP"             // $A9
        .byte $AB                // $AA   Operator +
        .byte $AD                // $AB   Operator -
        .byte $AA                // $AC   Operator *
        .byte $AF                // $AD   Operator /
        .byte $DE                // $AE   Operator ArrowUp (Potenzieren)
        .text "anD"              // $AF
        .text "oR"               // $B0
        .byte $BE                // $B1   Operator >
        .byte $BD                // $B2   Operator =
        .byte $BC                // $B3   Operator <
        .text "sgN"              // $B4
        .text "inT"              // $B5
        .text "abS"              // $B6
        .text "usR"              // $B7
        .text "frE"              // $B8
        .text "poS"              // $B9
        .text "sqR"              // $BA
        .text "rnD"              // $BB
        .text "loG"              // $BC
        .text "exP"              // $BD
        .text "coS"              // $BE
        .text "siN"              // $BF
        .text "taN"              // $C0
        .text "atN"              // $C1
        .text "peeK"             // $C2
        .text "leN"              // $C3
        .text "str"              // $C4   STR$
        .byte $A4                // $C4   STR$
        .text "vaL"              // $C5
        .text "asC"              // $C6
        .text "chr"              // $C7   CHR$
        .byte $A4                // $C7   CHR$
        .text "left"             // $C8   LEFT$
        .byte $A4                // $C8   LEFT$
        .text "right"            // $C9   RIGHT$
        .byte $A4                // $C9   RIGHT$
        .text "mid"              // $CA   MID$
        .byte $A4                // $CA   MID$
        .text "gO"               // $CB

EXTCOMMANDS:
        //AB HIER EIGENE BEFEHLE //TOKEN NO.
        .text "helP"             // $CC
        .text "graphiC"          // $CD
        .text "screeN"           // $CE
        .text "ploT"             // $CF
        .text "rpoint"           // $D0
        .byte $A8                // $D0
        .text "draW"             // $D1
        .text "circlE"           // $D2
        .text "colouR"           // $D3
        .text "erasE"            // $D4
        .text "gcleaR"           // $D5
// DISK COMMANDS
        .text "drivE"            // $D6
        .text "cataloG"          // $D7
        .text "collecT"          // $D8
        .text "derroR"           // $D9
        .text "diniT"            // $DA
        .text "scratcH"          // $DB
        .text "dverifY"          // $DC
        .text "dloaD"            // $DD
        .text "dsavE"            // $DE
        .text "fcopY"            // $DF
        .text "showbaM"          // $E0
        .text "headeR"           // $E1
        .text "labeL"            // $E2
//AB HIER FUNKTIONSTOKENS DIE IN EVALMY AUSGEWERTET WERDEN - ANPASSEN FÜR EVALMY!
        .text "hex"              // $E3
        .byte $A4                // $E3
        .text "bin"              // $E4
        .byte $A4                // $E4
        //.text "instr",$A4       // $E5
        //.text "string",$A4      // $E6
        brk                     // DIESES NULL BYTE MUSS BLEIBEN DAMIT
                                // DER TOKENIZER NICHT INS NIRWANA VERSCHWINDET!

.const FIRSTCMDTOKEN = $CC             // Erstes Token immer gleich
.const LASTCMDTOKEN  = $E2 + 1         // Letzer Basic BEFEHL! + 1 = AB $E3 =   
                                // FUNKTIONSTOKENS
.const CODEINSTR     = $E5
.const CODEDUP       = $E6

Command_Addr:
        .word COM_HELP - 1
        .word COM_GRAPHIC - 1
        .word COM_SCREEN - 1
        .word COM_PLOT - 1
        .word COM_RPOINT - 1
        .word COM_DRAW - 1
        .word COM_CIRCLE - 1
        .word COM_COLOUR - 1
        .word COM_ERASE - 1
        .word COM_GCLEAR - 1
// DISK COMMANDS
        .word COM_DRIVE - 1
        .word COM_CATALOG - 1
        .word COM_COLLECT - 1
        .word COM_DISKERR - 1
        .word COM_INITDISK - 1
        .word COM_SCRATCH - 1
        .word COM_DVERIFY - 1
        .word COM_DLOAD - 1
        .word COM_DSAVE - 1
        .word COM_FCOPY - 1
        .word COM_SHOWBAM - 1
        .word COM_FORMATDISK - 1
        .word COM_LABEL - 1      // $E2 Letztes BASIC Kommando

// Tabelle auf Funktionen die in EVALMY ausgewertet werden
FUNKTAB:                         // AB HIER FUNKTIONEN KEINE BASICBEFEHLE!!  
        .word HEX                // $E3
        .word BIN                // $E4
        //.word INSTR             // $E5
        //.word DUP               // $E6
