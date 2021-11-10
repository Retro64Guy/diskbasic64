;*******************************************************************************
;* DRAW Command                                                                *
;* This BASIC function put a line on the hires screen                          *
;*******************************************************************************
;* Syntax : DRAW or d shifted R                                                *
;* Inputs : X1 (0->319) and Y1 (2)0->199)                                      *
;*          X2 (0->319) and Y2 (2)0->199)                                      *
;*******************************************************************************

; draw : draw x1,y1 to x2,y2
COM_DRAW
        jsr GetNo2              ; Get X1
        sta COMM_X1LO
        sty COMM_X1HI

        jsr bas_CHKCOM$
        jsr bas_GETBYTC$        ; Get Y1
        stx COMM_Y1

        lda #$A4                ; Token for 'TO'
        jsr bas_SYNCHR$         ; Check for the BASIC command 'TO'
        
        jsr GetNo2              ; Get X2
        sta COMM_X2LO
        sty COMM_X2HI

        jsr bas_CHKCOM$
        jsr bas_GETBYTC$        ; Get Y2
        stx COMM_Y2

Draw_Eval_X
        lda COMM_X1HI
        cmp COMM_X2HI           ; Compare HiByte of X1 and X2
        beq @InXHi              ; X1HI = X2HI
        bcs @X1GTX2             ; X1HI > X2HI
        bcc @X1LTX2             ; X1HI < X2Hi

@InXHi
        lda COMM_X1LO           ; Compare Lo Byte of X1 and X2
        cmp COMM_X2LO
        bcc @X1LTX2             ; X1LO < X2LO

@X1GTX2                         ; X1 > X2
        sec
        lda COMM_X1LO
        sbc COMM_X2LO
        sta COMM_XDLO           ; Difference of X LoByte

        lda COMM_X1HI
        sbc COMM_X2HI
        sta COMM_XDHI           ; Difference of X HiByte

;        lda #$38                ; SEC Instruction
;        ldx #$E5                ; SBC (xx),y  Zeropage Instruction
;        jsr PREPAREXCALC        ; Alter the X Draw Routine to "SUBTRACT"

        lda DrawingExecutionDriver
        and #%00001100
        ora #%00000011
        sta DrawingExecutionDriver

        jmp DRAW_EVAL_Y

@X1LTX2                         ; X1 < X2
        sec
        lda COMM_X2LO
        sbc COMM_X1LO
        sta COMM_XDLO           ; Difference of X LoByte

        lda COMM_X2HI
        sbc COMM_X1HI
        sta COMM_XDHI           ; Difference of X HiByte

;        lda #$18                ; CLC Instruction
;        ldx #$65                ; ADC (xx),y  Zeropage Instruction
;        jsr PREPAREXCALC        ; Alter the X Draw Routine to "ADD"

        lda DrawingExecutionDriver
        and #%00001100
        sta DrawingExecutionDriver

DRAW_EVAL_Y
        lda COMM_Y1
        cmp COMM_Y2             ; Compare Y1 and Y2
        bcc @Y1LTY2             ; Y1 < Y2

        sec                     ; Y2 >= Y2
        lda COMM_Y1
        sbc COMM_Y2
        sta COMM_YD             ; Difference of Y

;        lda #$38                ; SEC Instruction
;        ldx #$E5                ; SBC (xx),y  Zeropage Instruction
;        jsr PREPAREYCALC        ; Alter the Y Draw Routine to "SUBTRACT"

        lda DrawingExecutionDriver
        and #%00000011
        ora #%00001100
        sta DrawingExecutionDriver

        jmp DRAW_DELTA_CALC

@Y1LTY2                         ; Y1 < Y2
        sec
        lda COMM_Y2
        sbc COMM_Y1
        sta COMM_YD             ; Difference of Y

;        lda #$18                ; CLC Instruction
;        ldx #$65                ; ADC (xx),y  Zeropage Instruction
;        jsr PREPAREYCALC        ; Alter the Y Draw Routine to "ADD"

        lda DrawingExecutionDriver
        and #%00000011
        sta DrawingExecutionDriver

DRAW_DELTA_CALC
        lda COMM_XDHI
        cmp #$01
        beq DRAW_ALONG_XAXIS    ; If XDelta High = 1 as Y will never be :(
        lda COMM_XDLO
        cmp COMM_YD
        bcs DRAW_ALONG_XAXIS    ; X Delta >= Y Delta
        jmp DRAW_ALONG_YAXIS    ; X Delta <  Y Delta

DRAW_ALONG_XAXIS
        lda COMM_YD
        cmp #$00
        bne DRAW_WORK_OUT_XRATIO
        jsr DRAW_SETFAC1_TO_ZERO
        jmp DRAW_XAXIS_START

DRAW_WORK_OUT_XRATIO
        ldx COMM_YD
        ldy COMM_XDLO
        stx COMM_XXLO           ; Contains YD
        lda #$00
        sta COMM_XXHI
        sty COMM_YY             ; Contains XDLO
        lda COMM_XDHI
        sta 246                 ; Differencal High
        jsr DIVIDE_XX_BY_YY
        jsr DRAW_MOVE_FAC1_TO_MEMORY
        jmp DRAW_XAXIS_START

DIVIDE_XX_BY_YY
        lda COMM_XXHI           ; 0     
        ldy COMM_XXLO           ; YD    70 / 50
        jsr bas_GIVEAYF$        ; Converts XX into a floating point value (FAC1)
        jsr bas_MOVEFP1FP2$     ; Moves FAC1 -> FAC2

        lda 246                 ; Value of COMM_XDHI
        ldy COMM_YY             ; Contains COMM_XDLO
        jsr bas_GIVEAYF$        ; Converts YY into a floating point value (FAC1)
        lda $66                 ; Manipulate Signs of FAC1
        eor $6E
        sta $6F
        lda $61
        jmp bas_FPDIV$          ; FAC1 = FAC2 / FAC1 ( XX / YY)

DRAW_SETFAC1_TO_ZERO
        lda #$00
        tay
        jsr bas_GIVEAYF$        ; Set FAC1 to Zero 

DRAW_MOVE_FAC1_TO_MEMORY
        ldy #$02                ; Address Hi byte       $02
        ldx #$f0                ; Address Lo Byte       $f0
        jmp bas_MOVEFP1M$       ; Moves FAC1 to Memory at $02f0

DRAW_XAXIS_START
        lda #$00
        sta COMM_XLLO           ; XLine Lo byte
        sta COMM_XLHI           ; Xline Hi byte
        sta $65
        sta $64
TODO Ep 06 of OldSkoolCoder GraphicsExtension
DRAW_XAXIS_LOOP
        ldy COMM_XLLO
        ldx COMM_XLHI
        lda COMM_YD
        cmp #$00
        beq DRAW_X_AS_YD_IS_ZERO
        jsr DRAW_WORKOUT_NEW_POINT

DRAW_X_AS_YD_IS_ZERO
        lda COMM_Y1
        
DRAW_WORKOUT_Y_FROM_AXISX
        clc
        adc $65
        sta COMM_Y              ; Y Position for Place
        lda COMM_X1LO

DRAW_WORKOUT_X_FROM_AXISX
        clc
        adc COMM_XLLO
        sta COMM_XLO            ; X Position Lo byte for Place
        lda COMM_X1HI
        adc COMM_XLHI
        sta COMM_XHI            ; X Position Hi byte for Place

        jsr PLACE
        jsr DOT

        inc COMM_XLLO
        bne @ByPassInc
        inc COMM_XLHI

@ByPassInc
        lda COMM_XLHI
        cmp COMM_XDHI
        bne DRAW_XAXIS_LOOP
        lda COMM_XLLO
        cmp COMM_XDLO
        bcc DRAW_XAXIS_LOOP
        rts

DRAW_WORKOUT_NEW_POINT          ; YR = Low , XR = High
        txa                     ; so transfer XR to Accu
        jsr bas_GIVEAYF$        ; Convert to FAC1 (y = Lo, Acc = Hi)
        jsr bas_MOVEFP1FP2$     ; Move FAC1 to FAC2
        ldy #$02
        lda #$F0                ; Get the XX/YY Ratio from Memory $02F0 back
        jsr bas_MOVEMFP1$       ; Move Memory float Ratio to FAC1
        lda $66                 ; Set sign of FAC1
        eor $6e
        sta $6f
        lda $61
        jsr bas_FMULTT$    ; FAC1 = FAC1 * FAC2 = New YPosition
        jmp bas_FACINX$    ; Converts FAC1 into Integer (Acc=Hi,Y=lo ($64,$65))

PREPAREXCALC
        sta DRAW_WORKOUT_X_FROM_AXISY
        sta DRAW_WORKOUT_X_FROM_AXISX
        txa
        sta DRAW_WORKOUT_X_FROM_AXISY + 1
        sta DRAW_WORKOUT_X_FROM_AXISY + 9
        eor #$08
        sta DRAW_WORKOUT_X_FROM_AXISX + 1
        sta DRAW_WORKOUT_X_FROM_AXISX + 10
        rts

PREPAREYCALC
        sta DRAW_WORKOUT_Y_FROM_AXISX
        sta DRAW_WORKOUT_Y_FROM_AXISY
        txa
        sta DRAW_WORKOUT_Y_FROM_AXISX + 1
        eor #$08
        sta DRAW_WORKOUT_Y_FROM_AXISY + 1
        rts

DRAW_ALONG_YAXIS
        lda COMM_XDHI
        cmp #$00
        bne DRAW_WORK_OUT_YRATIO
        lda COMM_XDLO
        cmp #$00
        bne DRAW_WORK_OUT_YRATIO
        jsr DRAW_SETFAC1_TO_ZERO
        lda #$FF
        sta COMM_XDHI
        jmp DRAW_YAXIS_START

DRAW_WORK_OUT_YRATIO
        ldy COMM_YD
        ldx COMM_XDLO
        sty COMM_YY
        lda #$00
        sta 246
        stx COMM_XXLO
        lda COMM_XDHI
        sta COMM_XXHI
        jsr DIVIDE_XX_BY_YY
        jsr DRAW_MOVE_FAC1_TO_MEMORY

DRAW_YAXIS_START
        lda #$00
        sta COMM_YL
        sta $64
        sta $65

DRAW_YAXIS_LOOP
        ldy COMM_YL
        ldx #$00
        lda COMM_XDHI
        cmp #$FF
        beq DRAW_Y_AS_XD_IS_ZERO
        jsr DRAW_WORKOUT_NEW_POINT

DRAW_Y_AS_XD_IS_ZERO
        lda COMM_X1LO

DRAW_WORKOUT_X_FROM_AXISY
        clc
        adc $65
        sta COMM_XLO
        lda COMM_X1HI
        adc $64
        sta COMM_XHI
        lda COMM_Y1
        
DRAW_WORKOUT_Y_FROM_AXISY
        clc
        adc COMM_YL
        sta COMM_Y
        jsr PLACE
        jsr DOT

        inc COMM_YL
        lda COMM_YL
        cmp COMM_YD
        bcc DRAW_YAXIS_LOOP
        rts
