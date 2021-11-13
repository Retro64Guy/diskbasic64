//*******************************************************************************
//* DE-Tokenizer (Lister) Routine                                               *
//*******************************************************************************
#define BASICLISTENER
#importonce


VEC_LISTER:
        bmi LIST_SEARCHTOKEN

LIST_BASICPRINTCHAR:
        jmp $a6f3

LIST_SEARCHTOKEN:
        cmp #$ff
        beq LIST_BASICPRINTCHAR
        bit $0f
        bmi LIST_BASICPRINTCHAR
        tax
        sty $49
        ldy #<COMMAND_LIST
        sty $64
        ldy #>COMMAND_LIST
        sty $65
        ldy #$00
        asl
        beq LIST_FNDTOKEN

LIST_UPDATEBUFPTR:
        dex
        bpl LIST_UPDCMDLISTIDX

LIST_UPDATECMDPTR:
        inc $64
        bne LIST_SKIPPTRHIBYTE
        inc $65

LIST_SKIPPTRHIBYTE:
        lda ($64),y
        bpl LIST_UPDATECMDPTR
        bmi LIST_UPDATEBUFPTR

LIST_UPDCMDLISTIDX:
        iny

LIST_FNDTOKEN:
        lda ($64),y
        bmi LIST_RESTORELISTPTR
        jsr $ab47
        bne LIST_UPDCMDLISTIDX

LIST_RESTORELISTPTR:
        jmp $a6ef

/* #region Original Lister Routine from Dale
        php
        cmp #255
        beq LEXIT
        bit $0F
        bmi LEXIT
        cmp #$CC
        bcc LEXIT
        plp
        sec
        sbc #$CB
        tax
        sty $49
        ldy #$FF

RESLP1
        dex
        beq RESPRT

RESLP2
        iny
        lda Command_LIST,y
        bpl RESLP2
        bmi RESLP1

RESPRT
        iny
        lda Command_LIST,y
        bmi RESEXT
        jsr krljmp_CHROUT$
        bne RESPRT

RESEXT
        jmp $A6EF

LEXIT
        plp
        jmp bas_UNCRUNCH$ + 3

#endregion
 */