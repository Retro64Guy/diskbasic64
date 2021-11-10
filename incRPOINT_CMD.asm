;*******************************************************************************
;* RPLOT Command                                                               *
;* This BASIC function reads a dot in the hires screen                         *
;*******************************************************************************
;* Syntax : RPLOT or rp shifted L                                              *
;* Inputs : X (0->319) and Y (2)0->199)                                        *
;*******************************************************************************
;* Output : eithe a 1 = pixel set or 0 = pixel clear                           *
;*******************************************************************************

; rplot syntax: var = rplo(x,y)

COM_RPOINT
        ;jsr bas_CHRGET$
        jsr GETNo2              ; Get X Coords - 2 bytes into ACCU(lo) and YReg(Hi)
        sta COMM_XLO
        sty COMM_XHI

        jsr bas_CHKCOM$         ; Prüfe auf Komma
        jsr bas_GETBYTC$        ; Get Y coords - 1 byte into XReg
        stx COMM_Y

        jsr bas_CHKCLOSE$       ; Checks for bracket close

        jsr PLACE               ; Works out the memory location to change

        lda $01
        and #%11111110          ; paging out BASIC ROM
        sta $01

        ldx COMM_C
        ldy #0
        lda BYTEMASK,x

        and (STAL),y
        pha

        lda $01
        ora #%00000001          ; paging in BASIC ROM
        sta $01

        pla
        cmp BYTEMASK,x
        beq RPOINT_RETURN1
        lda #0
        ldy #0
        jmp bas_GIVEAYF$        ; Return 0 in the floating Point Accu (FAC)

RPOINT_RETURN1
        lda #$00
        ldy #$01
        jmp bas_GIVEAYF$        ; Return 0 in the floating Point Accu (FAC)
