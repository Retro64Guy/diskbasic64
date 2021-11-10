;*******************************************************************************
;* CIRCLE Command                                                              *
;* This BASIC Command draws a circle on the Hires Screen                       *
;*******************************************************************************
;* Syntax: CIRCLE or C shifted I                                               *
;* Inputs: X (0-319)                                                           *
;          Y (0-199)                                                           *
;          XRadius ()                                                          *
;          YRadius ()                                                          *
;          Start Angle in Degrees (0 -360)                                     *
;*******************************************************************************

; circle : circle x, y, xr, yr, angle

COM_CIRCLE
        lda #<NOCIRCLE
        ldy #>NOCIRCLE
        jmp ABIE

NOCIRCLE
        text "circle-cmd not yet implemented!"
        brk
