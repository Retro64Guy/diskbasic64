;*******************************************************************************
;* Assembler Library Basic and Kernal ROM Routines                             *
;*                                                                             *
;* written by eepwin                                                           *
;*                                                                             *
;* adapted from John Dale                                                      *
;*                                                                             *
;*******************************************************************************

ifdef TGT_C64
; BASIC Rom starts at $A000
bas_CHRGET$             = $0073
bas_CHRGOT$             = $0079
bas_MOVEMEMBLOCK$       = $A3BF ; $58-$59 L/H New Block Start
                                ; $5A-$5B L/H Startadr. Old BlockEnd
                                ; $5F-$60 L/H Startadr. Old Blockstart       
bas_ROMError$           = $A437
bas_CustomError$        = $A447
bas_ReadyPrompt$        = $A474
bas_CRUNCH$             = $A579
bas_NEWCommand$         = $A642
bas_FindLine$           = $A613
bas_CLRCommand$         = $A67A
bas_UNCRUNCH$           = $A717
bas_NewStatement$       = $A7AE
bas_GONE$               = $A7E4
bas_LineGet$            = $A96B
bas_PrintString$        = $AB1E
bas_FRMNUM$             = $AD8A
bas_TYPEERR$            = $AD99
bas_FRMEVAL$            = $AD9E
bas_EVAL$               = $AE83
bas_CHKCLOSE$           = $AEF7
bas_CHKCOM$             = $AEFD
bas_SYNCHR$             = $AEFF
bas_SEARCHVAR$          = $B08B
bas_CHKLETTER$          = $B113 ; Carry Set = Letter - Carry Clear no Letter
bas_FACINX$             = $B1AA
bas_IQERR$              = $B248
bas_GIVEAYF$            = $B391
bas_FRESTR$             = $B6A3
bas_GETBYTC$            = $B79E
bas_GETADR$             = $B7F7
bas_FADDT$              = $B86A
bas_FMULTT$             = $BA30
bas_CONUPK$             = $BA8C
bas_MOVEFP1M$           = $BBD7
bas_FPDIV$              = $BB12
bas_MOVEMFP1$           = $BBA2
bas_MOVEFP1FP2$         = $BC0F
bas_FCOMP$              = $BC5B
bas_DecimalPrint$       = $BDCD
os_COS$                 = $E264
os_SIN$                 = $E26B
endif
         
ifdef TGT_VIC20_8K
; BASIC Rom Starts at $C000
bas_ROMError$       = $A437
bas_CustomError$    = $C447
bas_DecimalPrint$   = $DDCD
bas_PrintString$    = $CB1E
bas_ReadyPrompt$    = $C474
bas_LineGet$        = $C96B
bas_NEWCommand$     = $C642
bas_FindLine$       = $C613
endif

; Kernel Jump Vectors
krljmp_PCINT$       = $FF81
krljmp_IOINIT$      = $FF84
krljmp_RAMTAS$      = $FF87
krljmp_RESTOR$      = $FF8A
krljmp_VECTOR$      = $FF8D
krljmp_SETMSG$      = $FF90
krljmp_SECOND$      = $FF93
krljmp_TKSA$        = $FF96
krljmp_MEMTOP$      = $FF99
krljmp_MEMBOT$      = $FF9C
krljmp_SCNKEY$      = $FF9F
krljmp_SETTMO$      = $FFA2
krljmp_ACPTR$       = $FFA5
krljmp_CIOUT$       = $FFA8
krljmp_UNTALK$      = $FFAB
krljmp_UNLSN$       = $FFAE
krljmp_LISTEN$      = $FFB1
krljmp_TALK$        = $FFB4
krljmp_READST$      = $FFB7
krljmp_SETLFS$      = $FFBA
krljmp_SETNAM$      = $FFBD
krljmp_OPEN$        = $FFC0
krljmp_CLOSE$       = $FFC3
krljmp_CHKIN$       = $FFC6
krljmp_CHKOUT$      = $FFC9
krljmp_CLRCHN$      = $FFCC
krljmp_CHRIN$       = $FFCF
krljmp_CHROUT$      = $FFD2
krljmp_LOAD$        = $FFD5
krljmp_SAVE$        = $FFD8
krljmp_SETTIM$      = $FFDB
krljmp_RDTIM$       = $FFDE
krljmp_STOP$        = $FFE1
krljmp_GETIN$       = $FFE4
krljmp_CLALL$       = $FFE7
krljmp_UDTIM$       = $FFEA
krljmp_SCREEN$      = $FFED
krljmp_PLOT$        = $FFF0
krljmp_BASE$        = $FFF3

freespace           = $02A7 ; - $02ff
jmpvec_Error        = $0300
jmpvec_Main         = $0302
jmpvec_Crunch       = $0304
jmpvec_List         = $0306
jmpvec_Run          = $0308
jmpvec_IEval        = $030A ; -$030B Vector: BASIC Token evaluation ($AE86).
; $030C  SAREG Storage for 6510 Accumulator during SYS.
; $030D  SXREG Storage for 6510 X-Register during SYS.
; $030E  SYREG Storage for 6510 Y-Register during SYS.
; $030F  SPREG Storage for 6510 Status Register during SYS.
; $0310  USR Function JMP Instruction ($4C).
jmpvec_USR          = $0311 ; -$312
unused313           = $0313 ; unused byte
jmpvec_irq          = $0314
jmpvec_brk          = $0316
jmpvec_nmi          = $0318

;-------------------------------------------------------------------------------
; End of Library ROM Routines                                                  ;
;-------------------------------------------------------------------------------
;
