;*******************************************************************************
;* Cartridge Basic Template                                                    *
;*                                                                             *
;* written by eepwin                                                           *
;*                                                                             *
;* adapted from John Dale                                                      *
;*                                                                             *
;*                                                                             *
;*******************************************************************************

TARGET TGT_C64

GenerateTo EXTBasic.prg

debug option auto on
debug option highlight on
debug option pass 2
debug "Current"
debug BYTESLEFT
debug MEMLEFT
debug HLP_HELP_SIZE
debug HLP_GRAPHIC_SIZE
debug HLP_SCREEN_SIZE
debug HLP_PLOT_SIZE
debug HLP_RPOINT_SIZE
debug HLP_DRAW_SIZE
debug HLP_CIRCLE_SIZE
debug HLP_COLOUR_SIZE
debug HLP_ERASE_SIZE
debug HLP_GCLEAR_SIZE
debug HLP_DRIVE_SIZE

* = $8000               ; Cartridge Start
CARTSTART = *

;*******************************************************************************
;* Global Variables                                                            *
;*******************************************************************************
Buffer          = 512
RIBUF           = $F7                   ; graphic $F7
STAL            = $C1                   ; used in PLACE routine
MEMUSS          = $C3
ZP_FNLEN        = $B7                   ;FILENAME LENGTH
ZP_LA           = ZP_FNLEN  + 1         ;Current Logical Filenumber
ZP_SA           = ZP_LA + 1             ;Current Secondary Address
ZP_FA           = ZP_SA + 1             ;Current Device Number
ZP_FNADR        = ZP_FA + 1             ;Pointer LoByte to Current Filename
ZP_FNADRHI      = ZP_FA + 2             ;Pointer HiByte to Current Filename
ZP_STATE        = $90                   ;Kernal I/O Status
ZP_BLNSW        = $cc
ZP_BLNCT        = ZP_BLNSW + 1
ZP_FLAGFA       = $fa
ZP_FLAGFB       = ZP_FLAGFA + 1
ZP_FLAGFC       = ZP_FLAGFB + 1
ZP_FLAGFD       = ZP_FLAGFC + 1
ZP_FLAGFE       = ZP_FLAGFD + 1

;*******************************************************************************
;* Storage Locations for Graphic Commands                                      *
;*******************************************************************************
COMM_XLO                = $02A8
COMM_XHI                = COMM_XLO + 1  ;02A9
COMM_Y                  = COMM_XHI + 1  ;02AA
COMM_U                  = COMM_Y + 1    ;02AB
COMM_V                  = COMM_U + 1    ;02AC
COMM_SLO                = COMM_V + 1    ;02AD
COMM_SHI                = COMM_SLO + 1  ;02AE
COMM_R                  = COMM_SHI + 1  ;02AF
COMM_C                  = COMM_R + 1    ;02B0
COMM_X1LO               = COMM_C + 1    ;02B1
COMM_X1HI               = COMM_X1LO + 1 ;02B2
COMM_X2LO               = COMM_X1HI + 1 ;02B3
COMM_X2HI               = COMM_X2LO + 1 ;02B4
COMM_Y1                 = COMM_X2HI + 1 ;02B5
COMM_Y2                 = COMM_Y1 + 1   ;02B6
COMM_XDLO               = COMM_Y2 + 1   ;02B7
COMM_XDHI               = COMM_XDLO + 1 ;02B8
COMM_XXLO               = COMM_XDHI + 1 ;02B9
COMM_XXHI               = COMM_XXLO + 1 ;02BA
COMM_YY                 = COMM_XXHI + 1 ;02BB
COMM_YD                 = COMM_YY + 1   ;02BC
COMM_XLLO               = COMM_YD + 1   ;02BD
COMM_XLHI               = COMM_XLLO + 1 ;02BE
COMM_YL                 = COMM_XLHI + 1 ;02BF
COMM_AXLO               = COMM_YL + 1   ;02C0
COMM_AXHI               = COMM_AXLO + 1 ;02C1
COMM_AY                 = COMM_AXHI + 1 ;02C2
COMM_RXLO               = COMM_AY + 1   ;02C3
COMM_RXHI               = COMM_RXLO + 1 ;02C4
COMM_RY                 = COMM_RXHI + 1 ;02C5
COMM_XRLO               = COMM_RY + 1   ;02C6
COMM_XRHI               = COMM_XRLO + 1 ;02C7
COMM_YR                 = COMM_XRHI + 1 ;02C8
COMM_START              = COMM_YR + 1   ;02C9
COMM_FINISH             = COMM_START + 6        ;02CA - 02D0
COMM_INCR               = COMM_FINISH + 6       ;02D1 - 02D7

; Vars for Divider Routine
ResultFrac      = COMM_INCR + 6         ;02D8 - 02DE
Result          = ResultFrac + 1        ;02DF
ResultHi        = Result + 1            ;02E0
Working         = ResultHi + 1          ;02E1
WorkingHi       = Working + 1           ;02E2
Estimate        = WorkingHi + 1         ;02E3
EstimateHi      = Estimate + 1          ;02E4
Number          = EstimateHi + 1        ;02E5
NumberHi        = Number + 1            ;02E6
Divisor         = NumberHi + 1          ;02E7
DivisorHi       = Divisor + 1           ;02E8

; Used by the NEWDRAW Routine                                   xxxx 3210
DrawingExecutionDriver  = DivisorHi + 1                 ;02E9   xxxx YYXX
                                                        ;       xxxx XYXY
                                                        ;0 = Add, 1 = Subtract
COMM_XLFRAC             = DrawingExecutionDriver + 1    ;02EA
COMM_YLFRAC             = COMM_XLFRAC + 1               ;02EB
COMM_GRAPHIC_COLOR      = COMM_YLFRAC + 1               ;02EC
COMM_PEN_COLOR          = COMM_GRAPHIC_COLOR + 1        ;02ED
COMM_ERASE_ENABLED      = COMM_GRAPHIC_COLOR + 1        ;02EE
COMM_GRAPHIC_MODE       = COMM_ERASE_ENABLED + 1        ;02EF
COMM_DSSTRLEN           = COMM_GRAPHIC_MODE + 1         ;02F0
COMM_DSSTRFLAG          = COMM_DSSTRLEN + 1             ;02F1

COMM_TEMP_VAR           = $0313

;*******************************************************************************
;* Global Libraries                                                            *
;*******************************************************************************
incasm "libCharacterPETSCIIConst.asm"
incasm "libROMRoutines.asm"
incasm "incCIAChipLocations.asm"
incasm "incVICChipLocations.asm"

;*******************************************************************************
;* Includes Cartridge Code                                                     *
;*******************************************************************************
incasm "incCartInitiate.asm"
incasm "incBASICTokenizer.asm"
incasm "incBASICListener.asm"

BYTEMASK
        byte $80, $40, $20, $10, $08, $04, $02, $01

SCREENSTART = $8400
CURRADDRESS = *
BYTESLEFT = SCREENSTART - CURRADDRESS

*=$8800
;*******************************************************************************
;* CODE New BASIC Commands                                                     *
;*******************************************************************************
incasm "incBASICEvalMy.asm"

incasm "incBASICByeBye.asm"
incasm "incBASICErrorHandler.asm"
incasm "libBASICRoutines.asm"
incasm "libGraphicsRoutines.asm"
incasm "incGRAPHIC_CMD.asm"
incasm "incSCREEN_CMD.asm"
incasm "incERASE_CMD.asm"
incasm "incCOLOR_CMD.asm"
incasm "incPLOT_CMD.asm"
incasm "incRPOINT_CMD.asm"
incasm "incDRAW_CMD.asm"
incasm "incUtilities.asm"
; incasm "incNEWDRAW_CMD.asm"
incasm "incCIRCLE_CMD.asm"
incasm "incDISKTOOL_CMD.asm"
incasm "incHELP_CMD.asm"
