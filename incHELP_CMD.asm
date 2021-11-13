//*******************************************************************************
//* Help Routine - Shows Help about a specific command                          *
//*******************************************************************************
//* Syntax: help or he shifted L                                                *
//*******************************************************************************
//* Inputparams: none or basic command for which to show help                   *
//*******************************************************************************
//* Outputvalues: help.text of basic command                                     *
//*******************************************************************************
#define HELPCMD
#importonce

#import "incGLOBALVARS.asm"
#import "libROMRoutines.asm"
#import "libGraphicsRoutines.asm"
#import "libBASICRoutines.asm"
#import "libCharacterPETSCIIConst.asm"
#import "incBASICTokenizer.asm"
#import "incBASICErrorHandler.asm"

COM_HELP:
        ldx #$00
        stx HELPFLAG
// AKKU enthaelt 0 oder das nächste Zeichen nach dem help token
        jsr bas_CHRGOT
        beq !SHOWHELPALL+
        bmi !SHOWCMDHELP+       // negative flag set if token follows
        cmp #$30
        beq !SHOWSTDHELP+
        cmp #$31
        beq !SHOWEXTHELP+
// it was neither one of our new command tokens or a '0' or a '1'
!HELPSYNTAX:
        jmp SYNTAX_ERROR

!SHOWCMDHELP:
        cmp #$cc                // check if it is one of our new commands
        bcc !HELPSYNTAX-
        sec
        sbc #$cc                // First token is Help itself
        asl
        tax
        lda TBLHLPTEXT + 1,x
        tay
        lda TBLHLPTEXT,x
        jsr ABIE
        jmp bas_CHRGET

!SHOWSTDHELP:
        jsr bas_CHRGET
        lda HELPFLAG
        and #%00000000          // set HELPFLAG to 1
        ora #%00000001          
        sta HELPFLAG
        jsr !CLRSCR+
        lda #<HLPHEADERBASICV2
        ldy #>HLPHEADERBASICV2
        jsr bas_PrintString

!SHOWHELPALL:
        lda HELPFLAG
        bne !LISTTBL+           // if not zero do not clear screen
        jsr !CLRSCR+

!LISTTBL:
        ldy #$00
        sty TABPOS
        lda #<COMMAND_LIST
        sta $fb
        lda #>COMMAND_LIST
        sta $fc
        jmp !CHRLOOP+

!SHOWEXTHELP:
        jsr bas_CHRGET
        lda HELPFLAG
        and #%00000000
        ora #%00000010          // set HELPFLAG to 2 for extended commands
        sta HELPFLAG
        jsr !CLRSCR+
        lda #<HLPHEADEREXTBASIC
        ldy #>HLPHEADEREXTBASIC
        jsr bas_PrintString

!EXTHELP:
        ldy #$00
        sty TABPOS
        lda #<EXTCOMMANDS
        sta $fb
        lda #>EXTCOMMANDS
        sta $fc

!CHRLOOP:
        lda ($fb),y
        cmp #$00
        beq !EXITHELP+
        pha
        and #$7f
        jsr $ffd2
        pla
        cmp #$80
        bcc !NOTAB+
        jsr SCRPRINTTAB
!NOTAB:
        iny
        bne !NOPAGE+
!NEXTPAGE:
        inc $fc
!NOPAGE:
        cpy #$ff
        bne !CHRLOOP-            // if YReg is $ff reached the endof basicv2 commands
        lda HELPFLAG
        cmp #$01                 // if HELPFLAG is greater than zero
        bcs !EXITHELP+           // we show not all commands and exit!
        tya                      // otherwise we make a pause
        pha                      // between the two commandtables
        ldx #$02
        jsr TIMED_WAITFORKEY
        pla
        jmp !EXTHELP-            // and clear the screen before showing the extended
!EXITHELP:
        rts
!CLRSCR:
        lda #$93
        jmp krljmp_CHROUT

HELPFLAG:
        brk

HLPHEADERBASICV2:
        .byte $93
        .text "basic v2 commands"
        .byte $0d
        .byte $A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3
        .byte $A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3,$0d
        brk

HLPHEADEREXTBASIC:
        .byte $93
        .text "extended commands"
        .byte $0d
        .byte $A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3
        .byte $A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3,$0d
        brk

TBLHLPTEXT:
        .word HLP_HELP,HLP_GRAPHIC,HLP_SCREEN,HLP_PLOT,HLP_RPOINT
        .word HLP_DRAW,HLP_CIRCLE,HLP_COLOUR,HLP_ERASE,HLP_GCLEAR
        .word HLP_DRIVE,HLP_CATALOG,HLP_COLLECT,HLP_DISKERR,HLP_DISKINIT
        .word HLP_SCRATCH,HLP_DVERIFY,HLP_DLOAD,HLP_DSAVE,HLP_FCOPY
        .word HLP_SHOWBAM,HLP_HEADER,HLP_LABEL
        brk

.label HIRESSCREEN = $A000
.label ASMADDRESS = *
.label MEMLEFT = HIRESSCREEN - ASMADDRESS

* = $C000

HLP_HELP:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn
        .text "hilfe zur hilfe"
        .byte CHR_ReverseOff,$0d,$0d
        .text "befehl: help oder h + shift-e"
        .byte $0d,$0d
        .text "optionale parameter:"
        .byte $0d
        .text " 0 -> nur anzeige der basic v2 befehle"
        .byte $0d
        .text " 1 -> nur anzeige der extended befehle"
        .byte $0d
        .text " oder help <extended basic befehl>"
        .byte $0d,$0d
        .text "verwendung:"
        .byte $0d
        .text "anzeige aller verfuegbaren basicbefehle"
        .byte $0d
        .text "oder hilfe zu einem der erweiterten"
        .byte $0d
        .text "basicbefehle."
        .byte $0d
        brk
HLP_HELP_END:
.label HLP_HELP_SIZE = HLP_HELP_END - HLP_HELP

HLP_GRAPHIC:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"graphic-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .text "befehl: graphic oder g + shift-r"
        .byte $0d,$0d
        .text "syntax: graphic clr(,pc(,bgc,(brc)))"
        .byte $0d
        .text "parameter:"
        .byte $0d
        .text " clr - 1 = loeschen hiresgraphic"
        .byte $0d
        .text "       0 = nicht loeschen"
        .byte $0d
        .text " pc  - pixel/linienfarbe"
        .byte $0d
        .text " bgc - hintergrundfarbe"
        .byte $0d
        .text " brc - rahmenfarbe"
        .byte $0d,$0d
        .text "verwendung:"
        .byte $0d
        .text "einschalten und loeschen (clr=1) oder"
        .byte $0d
        .text "nicht loeschen (clr=0) der hiresgrafik."
        .byte $0d
        .text "optional setzen der pixel-, hintergund-"
        .byte $0d
        .text "und rahmenfarbe. beispiele:"
        .byte $0d
        .text "    graphic 1,0,1,2 oder gR 1,0,1,2"
        .byte $0d
        .text "schaltet die hires grafik ein, loescht"
        .byte $0d
        .text "die grafik und setzt die pixelfarbe"
        .byte $0d
        .text "auf schwarz, die hintergrundfarbe auf"
        .byte $0d
        .text "weiss und die rahmenfarbe auf rot."
        .byte $0d
        .text "weitere beispiele mit "
        .byte CHR_ReverseOn
        .text "<return>"
        .byte CHR_ReverseOff
        .byte 255,CHR_ClearScreen
        .text "beispiel 2:"
        .byte $0d
        .text "    graphic 0,2,,1 oder gR 0,2,,1"
        .byte $0d,$0d
        .text "schaltet die hires grafik ein, loescht"
        .byte $0d
        .text "die grafik nicht, setzt die pixelfarbe"
        .byte $0d
        .text "auf rot, die hintergrundfarbe bleibt"
        .byte $0d
        .text "weiss und die rahmenfarbe wird weiss."
        .byte $0d
        brk
HLP_GRAPHIC_END:
.label HLP_GRAPHIC_SIZE = HLP_GRAPHIC_END - HLP_GRAPHIC

HLP_SCREEN:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn
        .text "screen-hilfe"
        .byte CHR_ReverseOff
        .byte $0d,$0d
        .text "befehl: screen or s + shift-c"
        .byte $0d,$0d
        .text "verwendung:"
        .byte $0d
        .text "einschalten des standard .textmodus"
        .byte $0d
        brk
HLP_SCREEN_END:
.label HLP_SCREEN_SIZE = HLP_SCREEN_END - HLP_SCREEN

HLP_PLOT:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn
        .text "plot-hilfe"
        .byte CHR_ReverseOff
        .byte $0d,$0d
        .text "befehl: plot oder p + shift-l"
        .byte $0d,$0d
        .text "parameter:"
        .byte $0d
        .text "  xpos - x-koordinate 0 - 319"
        .byte $0d
        .text "  ypos - y-koordinate 0 - 199"
        .byte $0d,$0d
        .text "verwendung:"
        .byte $0d
        .text "plotted einen punkt in die hiresgrafik"
        .byte $0d
        .text "an der x und y koordinate."
        .byte $0d,$0d
        .text "beispiel:"
        .byte $0d
        .text " plot 100,100 oder plO 50,50"
        .byte $0d
        brk
HLP_PLOT_END:
.label HLP_PLOT_SIZE = HLP_PLOT_END - HLP_PLOT

HLP_RPOINT:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn
        .text "rpoint-hilfe"
        .byte CHR_ReverseOff
        .byte $0d,$0d
        .text "funktion: rpoint( oder r + shift-p"
        .byte $0d
        .text "parameter:"
        .byte $0d
        .text "  xpos - x-koordinate 0 - 319"
        .byte $0d
        .text "  ypos - y-koordinate 0 - 199"
        .byte $0d,$0d
        .text "verwendung:"
        .byte $0d
        .text "testet ob an der angegeben x/y position"
        .byte $0d
        .text "ein pixel gesetzt ist oder nicht."
        .byte $0d
        .text "ist an der angegeben x/y koordinate ein"
        .byte $0d
        .text "pixel gesetzt ist das ergebnis 1"
        .byte $0d
        .text "anderenfalls ist das ergebnis 0."
        .byte $0d,$0d
        .text "beispiele:"
        .byte $0d
        .text " print rpoint(50,50), p=rpO50,50)"
        .byte $0d
        .text " p=rpO10,150):print p"
        .byte $0d
        brk
HLP_RPOINT_END:
.label HLP_RPOINT_SIZE = HLP_RPOINT_END - HLP_RPOINT

HLP_DRAW:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"draw-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .text "befehl: draw oder d + shift-r"
        .byte $0d
        .text "parameter:"
        .byte $0d
        .text "  x1 - x-koordinate 0 - 319"
        .byte $0d
        .text "  y1 - y-koordinate 0 - 199"
        .byte $0d
        .text "  x2 - x-koordinate 0 - 319"
        .byte $0d
        .text "  y2 - y-koordinate 0 - 199"
        .byte $0d,$0d
        .text "verwendung:"
        .byte $0d
        .text "zeichnet eine linie in die hiresgrafik"
        .byte $0d
        .text "von x1,y1 nach x2,y2"
        .byte $0d,$0d
        .text "beispiel:"
        .byte $0d
        .text " draw 10,10 to 50,50"
        .byte $0d
        brk
HLP_DRAW_END:
.label HLP_DRAW_SIZE = HLP_DRAW_END - HLP_DRAW

HLP_CIRCLE:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn
        .text "circle-hilfe"
        .byte CHR_ReverseOff
        .byte $0d,$0d
        .text "befehl: circle oder c + shift-i"
        .byte $0d
        .text "verwendung:"
        .byte $0d
        .text "beispiel:"
        .byte $0d
        brk
HLP_CIRCLE_END:
.label HLP_CIRCLE_SIZE = HLP_CIRCLE_END - HLP_CIRCLE

HLP_COLOUR:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn
        .text "colour-hilfe"
        .byte CHR_ReverseOff
        .byte $0d,$0d
        .text "befehl: colour oder co + shift-l"
        .byte $0d
        .text "verwendung:"
        .byte $0d
        .text "beispiel:"
        .byte $0d
        brk
HLP_COLOUR_END:
.label HLP_COLOUR_SIZE = HLP_COLOUR_END - HLP_COLOUR

HLP_ERASE:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"erase-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: erase oder e + shift-r",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk
HLP_ERASE_END:
.label HLP_ERASE_SIZE = HLP_ERASE_END - HLP_ERASE

HLP_GCLEAR:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"gclear-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: gclear oder g + shift-C",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk
HLP_GCLEAR_END:
.label HLP_GCLEAR_SIZE = HLP_GCLEAR_END - HLP_GCLEAR

HLP_DRIVE:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"drive-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: drive oder dr + shift-i",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk
HLP_DRIVE_END:
.label HLP_DRIVE_SIZE = HLP_DRIVE_END - HLP_DRIVE

HLP_CATALOG:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"catalog-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: catalog oder c + shift-a",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk

HLP_COLLECT:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"collect-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: collect oder col + shift-l",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk

HLP_DISKERR:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"derror-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: derror oder de + shift-r",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk

HLP_DISKINIT:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"dinit-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: dinit oder di + shift-n",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk

HLP_SCRATCH:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"scratch-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: scratch oder scr + shift-a",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk

HLP_DVERIFY:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"dverify-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: dverify oder d + shift-v",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk

HLP_DLOAD:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"dload-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: dload oder d + shift-l",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk

HLP_DSAVE:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"dsave-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: dsave oder d + shift-s",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk

HLP_FCOPY:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"fcopy-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: fcopy oder f + shift-c",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk

HLP_SHOWBAM:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"showbam-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: showbam oder s + shift-h",$0d
        .byte "verwendung:",$0d
        .byte "beispiel:",$0d
        brk

HLP_HEADER:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"header-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: header oder he + shift-a",$0d,$0d
        .byte "verwendung:",$0d
        .byte "diskette hart oder soft formatieren.",$0d
        .byte "hart formatieren loescht alle bloecke",$0d
        .byte "einer diskette unwiederbringlich.",$0d
        .byte "soft formatieren loescht nur die bam",$0d
        .byte "und aendert den namen einer diskette.",$0d
        .byte "(dateiwiederherstellung moeglich)",$0d,$0d
        .byte "beispiele:",$0d
        .byte " hart formatieren",$0d
        .byte " header",CHR_Quote,"disklabel",CHR_Quote,",ixx",$0d
        .byte " xx = diskid",$0d,$0d
        .byte " soft formatieren",$0d
        .byte " header",CHR_Quote,"disklabel",CHR_Quote,$0d
        .byte " loescht alle dateieintraege und aendert"
        .byte " den namen der diskette in disklabel.",$0d
        brk

HLP_LABEL:
        //     0123456789012345678901234567890123456789
        .byte CHR_ClearScreen,CHR_ReverseOn,"label-hilfe",CHR_ReverseOff
        .byte $0d,$0d
        .byte "befehl: label oder l + shift-a",$0d
        .byte "verwendung:",$0d
        .byte "diskettenname aendern ohne die diskette",$0d
        .byte "zu formatieren. alle dateien bleiben",$0d
        .byte "erhalten.",$0d
        .byte "beispiel:",$0d
        .byte "  label",CHR_Quote,"new diskname",CHR_Quote,$0d
        brk
