#define GLOBAL_VARS
#importonce

//******************************************************************************
// Global Variables                                                            *
//******************************************************************************
.label SCREENSTART      = $8400

.const Buffer           = 512
.const INTADR           = $14
.const STRLEN           = $61
.const STRADR           = $62
.const ZEIBAS           = $7A
.const RIBUF            = $F7                   // graphic $F7
.const STAL             = $C1                   // used in PLACE routine
.const MEMUSS           = $C3
.const ZP_FNLEN         = $B7                   //FILENAME LENGTH
.const ZP_LA            = ZP_FNLEN  + 1         //Current Logical Filenumber
.const ZP_SA            = ZP_LA + 1             //Current Secondary Address
.const ZP_FA            = ZP_SA + 1             //Current Device Number
.const ZP_FNADR         = ZP_FA + 1             //Pointer LoByte to Current Filename
.const ZP_FNADRHI       = ZP_FA + 2             //Pointer HiByte to Current Filename
.const ZP_STATE         = $90                   //Kernal I/O Status
.const ZP_BLNSW         = $cc
.const ZP_BLNCT         = ZP_BLNSW + 1
.const ZP_FLAGFA        = $fa
.const ZP_FLAGFB        = ZP_FLAGFA + 1
.const ZP_FLAGFC        = ZP_FLAGFB + 1
.const ZP_FLAGFD        = ZP_FLAGFC + 1
.const ZP_FLAGFE        = ZP_FLAGFD + 1
.const ZP_FLAGFF        = ZP_FLAGFE + 1

//******************************************************************************
// Storage Locations for Graphic Commands                                      *
//******************************************************************************
.const COMM_XLO         = $02A8
.const COMM_XHI         = COMM_XLO + 1          //02A9
.const COMM_Y           = COMM_XHI + 1          //02AA
.const COMM_U           = COMM_Y + 1            //02AB
.const COMM_V           = COMM_U + 1            //02AC
.const COMM_SLO         = COMM_V + 1            //02AD
.const COMM_SHI         = COMM_SLO + 1          //02AE
.const COMM_R           = COMM_SHI + 1          //02AF
.const COMM_C           = COMM_R + 1            //02B0
.const COMM_X1LO        = COMM_C + 1            //02B1
.const COMM_X1HI        = COMM_X1LO + 1         //02B2
.const COMM_X2LO        = COMM_X1HI + 1         //02B3
.const COMM_X2HI        = COMM_X2LO + 1         //02B4
.const COMM_Y1          = COMM_X2HI + 1         //02B5
.const COMM_Y2          = COMM_Y1 + 1           //02B6
.const COMM_XDLO        = COMM_Y2 + 1           //02B7
.const COMM_XDHI        = COMM_XDLO + 1         //02B8
.const COMM_XXLO        = COMM_XDHI + 1         //02B9
.const COMM_XXHI        = COMM_XXLO + 1         //02BA
.const COMM_YY          = COMM_XXHI + 1         //02BB
.const COMM_YD          = COMM_YY + 1           //02BC
.const COMM_XLLO        = COMM_YD + 1           //02BD
.const COMM_XLHI        = COMM_XLLO + 1         //02BE
.const COMM_YL          = COMM_XLHI + 1         //02BF
.const COMM_AXLO        = COMM_YL + 1           //02C0
.const COMM_AXHI        = COMM_AXLO + 1         //02C1
.const COMM_AY          = COMM_AXHI + 1         //02C2
.const COMM_RXLO        = COMM_AY + 1           //02C3
.const COMM_RXHI        = COMM_RXLO + 1         //02C4
.const COMM_RY          = COMM_RXHI + 1         //02C5
.const COMM_XRLO        = COMM_RY + 1           //02C6
.const COMM_XRHI        = COMM_XRLO + 1         //02C7
.const COMM_YR          = COMM_XRHI + 1         //02C8
.const COMM_START       = COMM_YR + 1           //02C9
.const COMM_FINISH      = COMM_START + 6        //02CA - 02D0
.const COMM_INCR        = COMM_FINISH + 6       //02D1 - 02D7

// Vars for Divider Routine
.const ResultFrac      = COMM_INCR + 6         //02D8 - 02DE
.const Result          = ResultFrac + 1        //02DF
.const ResultHi        = Result + 1            //02E0
.const Working         = ResultHi + 1          //02E1
.const WorkingHi       = Working + 1           //02E2
.const Estimate        = WorkingHi + 1         //02E3
.const EstimateHi      = Estimate + 1          //02E4
.const Number          = EstimateHi + 1        //02E5
.const NumberHi        = Number + 1            //02E6
.const Divisor         = NumberHi + 1          //02E7
.const DivisorHi       = Divisor + 1           //02E8

// Used by the NEWDRAW Routine                                   xxxx 3210
.const DrawingExecutionDriver  = DivisorHi + 1          //02E9   xxxx YYXX
                                                        //       xxxx XYXY
                                                        //0 = Add, 1 = Subtract
.const COMM_XLFRAC             = DrawingExecutionDriver + 1    //02EA
.const COMM_YLFRAC             = COMM_XLFRAC + 1               //02EB
.const COMM_GRAPHIC_COLOR      = COMM_YLFRAC + 1               //02EC
.const COMM_PEN_COLOR          = COMM_GRAPHIC_COLOR + 1        //02ED
.const COMM_ERASE_ENABLED      = COMM_GRAPHIC_COLOR + 1        //02EE
.const COMM_GRAPHIC_MODE       = COMM_ERASE_ENABLED + 1        //02EF
.const COMM_DSSTRLEN           = COMM_GRAPHIC_MODE + 1         //02F0
.const COMM_DSSTRFLAG          = COMM_DSSTRLEN + 1             //02F1
.const COMM_FLAG               = COMM_DSSTRFLAG + 1            //02F2
.const COMM_FLAGA              = COMM_FLAG + 1                 //02F3

.const COMM_TEMP_VAR           = $0313

//******************************************************************************
//* Global Libraries                                                           *
//******************************************************************************
#import "libCharacterPETSCIIConst.asm"
#import "incCIAChipLocations.asm"
#import "incVICChipLocations.asm"
#import "libROMRoutines.asm"

BYTEMASK:
        .byte $80, $40, $20, $10, $08, $04, $02, $01
MAXSECS:
        .byte 21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21
        .byte 19,19,19,19,19,19,19
        .byte 18,18,18,18,18,18
        .byte 17,17,17,17,17
