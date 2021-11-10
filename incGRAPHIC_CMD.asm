;*******************************************************************************
;* Graphics Routine - Setup of Hires Graphic of the VIC Chip                   *
;*******************************************************************************
;* Syntax: graphic or g shifted R                                              *
;*******************************************************************************
;* Inputparams: Clearscreen,Pencolor,Backgroundcolor,Bordercolor               *
;*******************************************************************************
;* Syntax graphic clr[,pencol,bgcol,brdrcol]                                   *
;*        clr parameter must be given anyway                                   *
;*        pencol can be skipped by using clr,,bgcol,brdrcol                    *
;*        pencol and bgcol can be skipped by using clr,,,brdrcol               *
;*        bgcol and brdrcol can skipped by using clr,pencolor                  *
;*        pencol and brdrcol can be skipped by using clr,,bgcolor              *
;*******************************************************************************
COM_GRAPHIC
        jsr bas_GETBYTC$        ; Get Clear Flag
        stx $02                 ; 1 = Clear Screen - 0 = Don't clear Screen
        cmp #","                ; Do we have more parameters ? 
        bne @GRAPHIC_CLR

        jsr bas_CHKCOM$         ; get next char and check for comma
        cmp #","                ; If "," then skip Pencolor
        beq @NO_PENCOLOR
        jsr bas_GETBYTC$        ; Get Pencolor
        stx COMM_PEN_COLOR

@NO_PENCOLOR
        jsr bas_CHKCOM$
        cmp #","                ; If next char is also "," then skip BGColor
        beq @NO_BGCOLOR
        jsr bas_GETBYTC$        ; Get Backgroundcolor
        stx VICII_BGCOL0
        stx COMM_GRAPHIC_COLOR  ; Store Pencolor

@NO_BGCOLOR
        jsr bas_CHKCOM$         ; After the last comma must follow the bg color
        cmp #","                ; If next char is also "," then skip BGColor
        beq @GRAPHIC_CLR        
        jsr bas_GETBYTC$        ; if not a number form 0 to 15 -> syntax error
        stx VICII_EXTCOL        ; Set Bordercolor

@GRAPHIC_CLR
        lda $02
        beq @SKIP_CLR
        jsr COM_GCLEAR

; Switch on Hires Mode
@SKIP_CLR
        lda CIA2_DDRA
        ora #%00000011                          ;$8000 - $BFFF
        sta CIA2_DDRA

        lda CIA2_PRA
        and #255 - CIA2_PRA_VICBank_Mask
        ora #CIA2_PRA_VICBank_2                 ;Change VIC Chip to Bank 2 !!
        sta CIA2_PRA

        lda VICII_VMCSB
        ora #8
        sta VICII_VMCSB

        lda VICII_SCROLY
        ora #VICII_SCROLY_ExtColorMode
        sta VICII_SCROLY

        lda #$01
        sta COMM_GRAPHIC_MODE

GRAPHIC_SetColors
; Set Background and Pen Color
        lda COMM_PEN_COLOR         ; Load pencolor
        asl                        ; and shift
        asl                        ; to
        asl                        ; high
        asl                        ; nibble
        ora COMM_GRAPHIC_COLOR     ; then or BGColor into lower nibble

; Then set whole screenmemory to colors for Hires Screen
        ldy #0
@GRAPHIC_Color
        sta SCREENSTART,y
        sta SCREENSTART + $100,y
        sta SCREENSTART + $200,y        
        sta SCREENSTART + $300,y
        iny
        bne @GRAPHIC_Color
        rts

;*******************************************************************************
;* GCLEAR Routine - Clears Hires Graphic                                       *
;*******************************************************************************
;* Syntax: gclear or g shifted C                                               *
;*******************************************************************************
;* Inputs:                                                                     *
;*******************************************************************************
COM_GCLEAR
        lda #0                  ; HIRESSCREEN STARTS AT $A000
        sta RIBUF
        lda #$A0
        sta RIBUF + 1

        ldy #0
@CLR_LOOP
        lda #0
        sta (RIBUF),y
        inc RIBUF
        bne @CLR_LOOP
        inc RIBUF + 1

        lda RIBUF + 1
        cmp #$C0
        bne @CLR_LOOP
        rts
