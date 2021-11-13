//*******************************************************************************
//* COLOUR Command                                                              *
//* This BASIC Command set the background colors                                *
//*******************************************************************************
//* Syntax: COLOUR or CO shifted L                                              *
//* Inputs: Border Color (0->15)             can be skipped by ,                *
//          Background Color (0->15)         can be skipped by ,                *
//          Text Color (0->15)               Mandantory!                        *
//          Background Color1 (0->15)        can be skipped by ,                *
//          Background Color2 (0->15)                                           *
//          Background Color3 (0->15)                                           *
//*******************************************************************************
// colour : colour border, background (,pen, bg1, bg2, bg3)
#define COLORCMD
#importonce

#import "incGRAPHIC_CMD.asm"
#import "incBASICErrorHandler.asm"

COM_COLOUR:
        cmp #$2C
        beq !SKIP_BORDER+
        jsr bas_GETBYTC
        stx VICII_EXTCOL        // Border Color

!SKIP_BORDER:
        jsr bas_CHRGET
        cmp #$2C
        beq !COLOUR_SKIPBACKGROUND+
        jsr bas_GETBYTC
        stx VICII_BGCOL0        // Screen Background Color
        stx COMM_GRAPHIC_COLOR  // Screen Background Color for Hires Screen

!COLOUR_SKIPBACKGROUND:
        jsr bas_CHRGET
        cmp #$30
        bcs !GET_PENCOLOUR+
        jmp SYNTAX_ERROR
!GET_PENCOLOUR:
        jsr bas_GETBYTC
        stx $0286               // Textcolor of Chars on Textscreen
        stx COMM_PEN_COLOR      // Pen Graphicscolor / Textcolor

        cmp #","
        bne !COLOUR_END+
        jsr bas_CHKCOM
        jsr bas_GETBYTC
        stx VICII_BGCOL1        // Background ExtendedColor1

        cmp #","
        bne !COLOUR_END+
        jsr bas_CHKCOM
        jsr bas_GETBYTC
        stx VICII_BGCOL2        // Background ExtendedColor2

        cmp #","
        bne !COLOUR_END+
        jsr bas_CHKCOM
        jsr bas_GETBYTC
        stx VICII_BGCOL3        // Background ExtendedColor3

!COLOUR_END:
        lda COMM_GRAPHIC_MODE
        beq !NOT_IN_GRAPHICMODE+
        jmp GRAPHIC_SetColors
!NOT_IN_GRAPHICMODE:
        rts
