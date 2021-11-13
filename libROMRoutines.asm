//*******************************************************************************
//* Assembler Library Basic and Kernal ROM Routines                             *
//*                                                                             *
//* written by eepwin                                                           *
//*                                                                             *
//* adapted from John Dale                                                      *
//*                                                                             *
//*******************************************************************************
#define ROMROUTINES
#importonce

// BASIC Rom starts at A000
.const bas_CHRGET             = $0073
.const bas_CHRGOT             = $0079
.const bas_MOVEMEMBLOCK       = $A3BF // 58-59 L/H New Block Start
                                // 5A-5B L/H Startadr. Old BlockEnd
                                // 5F-60 L/H Startadr. Old Blockstart       
.const bas_ROMError           = $A437
.const bas_CustomError        = $A447
.const bas_ReadyPrompt        = $A474
.const bas_CRUNCH             = $A579
.const bas_NEWCommand         = $A642
.const bas_FindLine           = $A613
.const bas_CLRCommand         = $A67A
.const bas_UNCRUNCH           = $A717
.const bas_NewStatement       = $A7AE
.const bas_GONE               = $A7E4
.const bas_LineGet            = $A96B
.const bas_PrintString        = $AB1E
.const bas_FRMNUM             = $AD8A
.const bas_CHKNUM             = $AD8D
.const bas_TYPEERR            = $AD99
.const bas_FRMEVAL            = $AD9E
.const bas_EVAL               = $AE83
.const bas_CHECKPI            = $AE9A // Basic Systemvariablen prüfen/Ausdruck holen
.const bas_CHKOPEN            = $AEF1 // prüft auf Klammer auf
.const bas_CHKCLOSE           = $AEF7 // prüft auf Klammer zu
.const bas_CHKCOM             = $AEFD
.const bas_SYNCHR             = $AEFF
.const bas_GETVAR             = $AF28
.const bas_SEARCHVAR          = $B08B
.const bas_CHKLETTER          = $B113 // Carry Set = $Letter - Carry Clear no Letter
.const bas_FACINX             = $B1AA
.const bas_IQERR              = $B248
.const bas_GIVEAYF            = $B391
.const bas_GETPLACE           = $B47D
.const bas_STRSTACK           = $B4CA
.const bas_FRESTR             = $B6A3
.const bas_GETBYTC            = $B79E
.const bas_GETADR             = $B7F7
.const bas_FADDT              = $B86A
.const bas_FMULTT             = $BA30
.const bas_CONUPK             = $BA8C
.const bas_MOVEFP1M           = $BBD7
.const bas_FPDIV              = $BB12
.const bas_MOVEMFP1           = $BBA2
.const bas_MOVEFP1FP2         = $BC0F
.const bas_FCOMP              = $BC5B
.const bas_ASCIITOFP          = $BCF3
.const bas_DecimalPrint       = $BDCD
.const os_COS                 = $E264
.const os_SIN                 = $E26B
         
/* TGT_VIC20_8K
 BASIC Rom Starts at C000
.const bas_ROMError       = $A437
.const bas_CustomError    = $C447
.const bas_DecimalPrint   = $DDCD
.const bas_PrintString    = $CB1E
.const bas_ReadyPrompt    = $C474
.const bas_LineGet        = $C96B
.const bas_NEWCommand     = $C642
.const bas_FindLine       = $C613
}
*/

// Kernel Jump Vectors
.const krljmp_PCINT       = $FF81
.const krljmp_IOINIT      = $FF84
.const krljmp_RAMTAS      = $FF87
.const krljmp_RESTOR      = $FF8A
.const krljmp_VECTOR      = $FF8D
.const krljmp_SETMSG      = $FF90
.const krljmp_SECOND      = $FF93
.const krljmp_TKSA        = $FF96
.const krljmp_MEMTOP      = $FF99
.const krljmp_MEMBOT      = $FF9C
.const krljmp_SCNKEY      = $FF9F
.const krljmp_SETTMO      = $FFA2
.const krljmp_ACPTR       = $FFA5
.const krljmp_CIOUT       = $FFA8
.const krljmp_UNTALK      = $FFAB
.const krljmp_UNLSN       = $FFAE
.const krljmp_LISTEN      = $FFB1
.const krljmp_TALK        = $FFB4
.const krljmp_READST      = $FFB7
.const krljmp_SETLFS      = $FFBA
.const krljmp_SETNAM      = $FFBD
.const krljmp_OPEN        = $FFC0
.const krljmp_CLOSE       = $FFC3
.const krljmp_CHKIN       = $FFC6
.const krljmp_CHKOUT      = $FFC9
.const krljmp_CLRCHN      = $FFCC
.const krljmp_CHRIN       = $FFCF
.const krljmp_CHROUT      = $FFD2
.const krljmp_LOAD        = $FFD5
.const krljmp_SAVE        = $FFD8
.const krljmp_SETTIM      = $FFDB
.const krljmp_RDTIM       = $FFDE
.const krljmp_STOP        = $FFE1
.const krljmp_GETIN       = $FFE4
.const krljmp_CLALL       = $FFE7
.const krljmp_UDTIM       = $FFEA
.const krljmp_SCREEN      = $FFED
.const krljmp_PLOT        = $FFF0
.const krljmp_BASE        = $FFF3

// Jump Vectors
.const freespace           = $02A7 // - 02ff
.const jmpvec_Error        = $0300
.const jmpvec_Main         = $0302
.const jmpvec_Crunch       = $0304
.const jmpvec_List         = $0306
.const jmpvec_Run          = $0308
.const jmpvec_IEval        = $030A // -030B Vector: BASIC Token evaluation (AE86).
// 030C  SAREG Storage for 6510 Accumulator during SYS.
// 030D  SXREG Storage for 6510 X-Register during SYS.
// 030E  SYREG Storage for 6510 Y-Register during SYS.
// 030F  SPREG Storage for 6510 Status Register during SYS.
// 0310  USR Function JMP Instruction (4C).
.const jmpvec_USR          = $0311 // -312
.const unused313           = $0313 // unused byte
.const jmpvec_irq          = $0314
.const jmpvec_brk          = $0316
.const jmpvec_nmi          = $0318

//-------------------------------------------------------------------------------
// End of Library ROM Routines                                                  //
//-------------------------------------------------------------------------------
