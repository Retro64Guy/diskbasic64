//*******************************************************************************
//* Library of Functions that will be used thrpughout the code.                 *
//*******************************************************************************
#define LIBUTILITIES
#importonce

#import "incGLOBALVARS.asm"
#import "libROMRoutines.asm"

//*******************************************************************************
//* 16-Bit Divide Function                                                      *
//* This function works out the binary fraction of two 16-Bit Numbers           *
//*******************************************************************************
//* Inputs : Number (Number to be divided by)                                   *//*          Divisor (The Number to divide by)                                  *
//*******************************************************************************
Divide16Bit:
// Reset all Variables
        lda #0
        sta ResultHi
        sta Result
        sta ResultFrac

        sta Working
        sta WorkingHi
        sta Estimate
        sta EstimateHi

// Load the numbers to Divide
        lda Number
        sta Working
        lda NumberHi
        sta WorkingHi

// start Divide process
        ldy #0

!BitLevelLoop:
        asl Working             // Roll 0 into left Hand side
        rol WorkingHi           // Roll into High Byte too

        rol Estimate            // Roll Result of Working Bit into Estimate
        rol EstimateHi

        lda EstimateHi
        cmp DivisorHi
        bcc !DivisorNotFit+     // EstimateHi < DivisorHi, So not fitting
        bne !DivisorFits+       // If Estimate <> Divisor then it's greater than

        // EstimateHi >= DivisorHi, so now Test Low bytes
        lda Estimate
        cmp Divisor
        bcs !DivisorFits+       // The Estimate is greater than Divisior

!DivisorNotFit:
        asl ResultFrac          // Estimate is still too small, roll in a zero
        jmp !RotateRoundResult+

!DivisorFits:
        lda Estimate            // Estimate is greater than Divisor
        sec
        sbc Divisor             // Subtract Divisor
        sta Estimate

        lda EstimateHi
        sbc DivisorHi
        sta EstimateHi

        sec                     // Set the Carry
        rol ResultFrac          // Roll in a One from Carry

!RotateRoundResult:
        rol Result              // Continue Roll for all Result Bytes
        rol ResultHi

!CheckRightNumDigits:
        iny
        cpy #24                 // have we run through all 24 Bits (Frac/lo/Hi)
        bne !BitLevelLoop-      // Nope, loop back around
        
        rts                     // Yes then Stop

//-----------------------------------------------------------------------------
//----- Paragraph @PRIMM - Routine die INLINE TEXTE am Bildschirm anzeigt@-----
//-----------------------------------------------------------------------------
PRIMM:
        sta $fa
        stx $fb
        sty $fc
        pla 
        sta $fd
        pla 
        sta $fe
        inc $fd
        ldy #$00
!PRLOOP:
        lda ($fd),y
        beq !PREND+
        jsr krljmp_CHROUT
        iny 
        bne !PRLOOP-
!PREND:
        tya 
        clc 
        adc $fd
        bcc !PR2+
        inc $fe
!PR2:
        tax 
        lda $fe
        pha 
        txa 
        pha 
        ldy $fc
        ldx $fb
        lda $fa
        rts

//**************************************************************
//*** FUNKTIONEN IM TOKENIZER FUNKTAB LABEL UND WORD HEX,BIN ***
//**************************************************************
//----- Paragraph @HEX$ Funktion@ -----
HEX:    lda INTADR+1            // $15
        pha
        lda INTADR              // $14
        pha
        jsr bas_CHKNUM          // $AD8D
        jsr bas_GETADR          // $B7F7
        lda #4
        jsr bas_GETPLACE        // $B47D
        ldy #3
        lda INTADR
        jsr !HEXNIBBLE+
        lda INTADR
        lsr
        lsr
        lsr
        lsr
        dey
        jsr !HEXNIBBLE+
        dey
        lda INTADR+1
        jsr !HEXNIBBLE+
        lda INTADR+1
        lsr
        lsr
        lsr
        lsr
        dey
        jsr !HEXNIBBLE+
        pla
        sta INTADR
        pla
        sta INTADR+1
        jmp bas_STRSTACK        // $B4CA
!HEXNIBBLE:
        and #$0F                // 15
        cmp #$0A                // < 10 dann Ziffer
        bcc !HEXNIBBLE1+
        clc
        adc #$07
!HEXNIBBLE1:
        clc
        adc #$30
        sta ($62),Y
        rts
//*********************************
//*** Paragraph @BIN$ Funktion@ ***
//*********************************
BIN:    jsr $B7A1
        txa
        pha
        lda #8
        jsr $B47D
        pla
        ldy #7
!BIN1:
        jsr !BINBIT+
        dey
        bpl !BIN1-
        jmp $B4CA
!BINBIT:
        pha
        and #1
        clc
        adc #"0"
        sta ($62),Y
        pla
        lsr
        rts
