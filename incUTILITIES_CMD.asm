;*******************************************************************************
;* Library of Functions that will be used thrpughout the code.                 *
;*******************************************************************************

;*******************************************************************************
;* 16-Bit Divide Function                                                      *
;* This function works out the binary fraction of two 16-Bit Numbers           *
;*******************************************************************************
;* Inputs : Number (Number to be divided by)                                   *;*          Divisor (The Number to divide by)                                  *
;*******************************************************************************

Divide16Bit
; Reset all Variables
        lda #0
        sta ResultHi
        sta Result
        sta ResultFrac

        sta Working
        sta WorkingHi
        sta Estimate
        sta EstimateHi

; Load the numbers to Divide
        lda Number
        sta Working
        lda NumberHi
        sta WorkingHi

; Start Divide process
        ldy #0

@BitLevelLoop
        asl Working             ; Roll 0 into left Hand side
        rol WorkingHi           ; Roll into High Byte too

        rol Estimate            ; Roll Result of Working Bit into Estimate
        rol EstimateHi

        lda EstimateHi
        cmp DivisorHi
        bcc @DivisorNotFit      ; EstimateHi < DivisorHi, So not fitting
        bne @DivisorFits        ; If Estimate <> Divisor then it's greater than

        ; EstimateHi >= DivisorHi, so now Test Low bytes
        lda Estimate
        cmp Divisor
        bcs @DivisorFits        ; The Estimate is greater than Divisior

@DivisorNotFit
        asl ResultFrac          ; Estimate is still too small, roll in a zero
        jmp @RotateRoundResult

@DivisorFits
        lda Estimate            ; Estimate is greater than Divisor
        sec
        sbc Divisor             ; Subtract Divisor
        sta Estimate

        lda EstimateHi
        sbc DivisorHi
        sta EstimateHi

        sec                     ; Set the Carry
        rol ResultFrac          ; Roll in a One from Carry

@RotateRoundResult
        rol Result              ; Continue Roll for all Result Bytes
        rol ResultHi

@CheckRightNumDigits
        iny
        cpy #24                 ; have we run through all 24 Bits (Frac/lo/Hi)
        bne @BitLevelLoop       ; Nope, loop back around
        
        rts                     ; Yes then Stop

;-----------------------------------------------------------------------------
;----- Paragraph @PRIMM - Routine die INLINE TEXTE am Bildschirm anzeigt@-----
;-----------------------------------------------------------------------------
PRIMM
        sta $fa
        stx $fb
        sty $fc
        pla 
        sta $fd
        pla 
        sta $fe
        inc $fd
        ldy #$00
@PRLOOP
        lda ($fd),y
        beq @PREND
        jsr krljmp_chrout$
        iny 
        bne @PRLOOP
@PREND
        tya 
        clc 
        adc $fd
        bcc @PR2
        inc $fe
@PR2
        tax 
        lda $fe
        pha 
        txa 
        pha 
        ldy $fc
        ldx $fb
        lda $fa
        rts

;**************************************************************
;*** FUNKTIONEN IM TOKENIZER FUNKTAB LABEL UND WORD HEX,BIN ***
;**************************************************************
;----- Paragraph @HEX$ Funktion@ -----
HEX     LDA INTADR+1            ; $15
        PHA
        LDA INTADR              ; $14
        PHA
        JSR bas_CHKNUM$         ; $AD8D
        JSR bas_GETADR$         ; $B7F7
        LDA #4
        JSR bas_GETPLACE$       ; $B47D
        LDY #3
        LDA INTADR
        JSR HEXNIBBLE
        LDA INTADR
        LSR
        LSR
        LSR
        LSR
        DEY
        JSR HEXNIBBLE
        DEY
        LDA INTADR+1
        JSR HEXNIBBLE
        LDA INTADR+1
        LSR
        LSR
        LSR
        LSR
        DEY
        JSR HEXNIBBLE
        PLA
        STA INTADR
        PLA
        STA INTADR+1
        JMP bas_STRSTACK$       ; $B4CA
HEXNIBBLE
        AND #$0F                ; 15
        CMP #$0A                ; < 10 dann Ziffer
        BCC HEXNIBBLE1
        CLC
        ADC #$07
HEXNIBBLE1
        CLC
        ADC #"0"
        STA ($62),Y
        RTS
;*********************************
;*** Paragraph @BIN$ Funktion@ ***
;*********************************
BIN     JSR $B7A1
        TXA
        PHA
        LDA #8
        JSR $B47D
        PLA
        LDY #7
@BIN1
        JSR @BINBIT
        DEY
        BPL @BIN1
        JMP $B4CA
@BINBIT
        PHA
        AND #1
        CLC
        ADC #"0"
        STA ($62),Y
        PLA
        LSR
        RTS

