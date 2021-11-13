//*******************************************************************************
//* Assembler Library BasicRoutines                                             *
//*                                                                             *
//* written by eepwin                                                           *
//*                                                                             *
//* adapted from John Dale                                                      *
//*                                                                             *
//*******************************************************************************
#define LIBBASICROUTINES
#importonce

#import "libROMROUTINES.asm"

//*******************************************************************************
//* Get 16-Bit Number from Command line Routine                                 *
//*******************************************************************************
//* Input:                                                                      *
//*                                                                             *
//*******************************************************************************
//* Output:  Accu HiByte                                                        *
//*          XReg LoByte                                                        *
//*******************************************************************************
.label LineNumberLo    = $14
.label LineNumberHi    = $15

GetNumberFromCommandLine:
        jsr bas_CHRGOT
        bcs GNFCL_Return        // No Number on Commandline
        jsr bas_LineGet        // Get 16-Bit Integer Value from Command Line
        lda LineNumberHi        // Stores Hi Integer value
        ldx LineNumberLo        // Stores Lo Integer value
        clc

GNFCL_Return:
        rts

//*******************************************************************************
//* Replacing the Basic ROM Routine $AB1E (faster and more than $FF chars)      *
//*******************************************************************************
//* Input:  Accu LoByte of Textstringpointer                                    *
//*         YReg HiByte of Textstringpointer                                    *
//*******************************************************************************
//* Output: N/A                                                                 *
//*******************************************************************************

ABIE:
        sty 248
        sta 247
!ABIELooper:
        ldy #0
        lda (247),y
        cmp #$FF
        bne !ABIECont+
        jsr GETRETKEY
        jmp !ABIESkip+
!ABIECont:
        cmp #$00
        beq !ABIE_EXIT+
        jsr krljmp_CHROUT
!ABIESkip:
        inc 247
        bne !ABIE+
        inc 248
!ABIE:
        jmp !ABIELooper-
!ABIE_EXIT:
        rts     // jmp bas_ReadyPrompt$

GETRETKEY:
        jsr krljmp_CHRIN
        beq GETRETKEY
        cmp #$0d
        bne GETRETKEY
        rts

//*******************************************************************************
//* GETNo2 Function                                                             *
//* This function gets a number from BASIC and returns the value in two bytes   *
//*******************************************************************************
//* Inputs :                                                                    *
//*******************************************************************************
//* Output :                                                              *
//*******************************************************************************

GETNo2:
        jsr bas_FRMNUM
        jsr bas_GETADR
        lda LineNumberLo
        ldy LineNumberHi
        rts

//*******************************************************************************
//* Basic Tool Routine to wait for a char press                                 *
//*******************************************************************************
//* Input:  Accu LoByte of Textstringpointer                                    *
//*         YReg HiByte of Textstringpointer                                    *
//*******************************************************************************
//* Output: N/A                                                                 *
//*******************************************************************************
TIMED_WAITFORKEY:
        stx WAITTIME + 1
        jsr SETWAITTIMER
!GETKEY:
        jsr $ffe4
        bne !GOTKEY+
        ldx $a1
        cpx PAUSE
        bne !GETKEY-
!GOTKEY:
        rts

SETWAITTIMER:
        lda $a1
        clc
WAITTIME:
        adc #$01
        sta PAUSE
        rts
PAUSE:   
.byte 0

//*******************************************************************************
//* Basic Tool Routine positioning cursor to next TAB position on screen        *
//*******************************************************************************
//* Input:  N/A                                                                 *
//*******************************************************************************
//* Output: N/A                                                                 *
//*******************************************************************************
SCRPRINTTAB:
        pha
        tya
        pha
        sec
        jsr $fff0
        sty $09
        ldx TABPOS
        cpx #$03
        bne !DOTAB+
        ldx #$00
        stx TABPOS
        lda #$0d
        jsr $ffd2
        bne !CHRENDTAB+
!DOTAB:
        lda TABTBL,x
        sbc $09
        bcc !CHRENDTAB+
        tax
!TABLOOP:
        lda #$1d
        jsr $ffd2
        dex
        bne !TABLOOP-
        inc TABPOS
!CHRENDTAB:
        pla
        tay
        pla     
        rts
TABPOS:
        brk
TABTBL:
.byte 10,20,30

//-------------------------------------------------------------------------------
// End of Library BASIC Routines                                                //
//-------------------------------------------------------------------------------
//
