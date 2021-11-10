;*******************************************************************************
;* PLOT Command                                                                *
;* This BASIC function put a dot ins the hires screen                          *
;*******************************************************************************
;* Syntax : PLOT or p shifted L                                                *
;* Inputs : X (0->319) and Y (2)0->199)                                        *
;*******************************************************************************

; plot : plot x,y

COM_PLOT
        jsr GETNo2              ; Get X Coords - 2 bytes into ACCU(lo) and YReg(Hi)
        sta COMM_XLO
        sty COMM_XHI

        jsr bas_CHKCOM$         ; Prüfe auf Komma
        jsr bas_GETBYTC$        ; Get Y coords - 1 byte into XReg
        stx COMM_Y

        jsr PLACE               ; Works out the memory location to change
        jmp DOT                 ; Sets the bit location of the memory location
