//************************
//* ErrorHandler Routine *
//************************

.label ErrorHandlerLo  = $22
.label ErrorHandlerHi  = $23

VEC_ERRORHANDLER:
        txa
        pha                     // Store Away Error Code
        bmi !ROMError+           // + 1
        cmp #31
        bcc !ROMError+          // less than 30
        sec
        sbc #31                 // Subtract Our Error Code start
        asl                     // Multiply By Two
        tax
        lda !ErrorCodeAddr,x
        sta ErrorHandlerLo
        lda !ErrorCodeAddr + 1,x
        sta ErrorHandlerHi
        jsr COM_SCREEN
        pla                     // Retrieve Back Error Code
        jmp bas_CustomError$

!ROMError:
        jsr COM_SCREEN
        pla                     // Retrieve Back Error Code
        tax
        bmi !GOReady
        jmp bas_ROMError$ + 3   //$E38B
!GOReady:
        jmp bas_ReadyPrompt$

ErrorCodeAddr:
        .word MISSING_DISKNAME
        .word ILLEGAL_DISKID
        .word ERRORCODE_33

MISSING_DISKNAME:
        .text "missing disknamE"

ILLEGAL_DISKID:
        .text "illegal or missing diskiD"

ERRORCODE_33:
        .text "Code 33 ErroR"

//*******************************************************************************
//* Show Syntax Error                                                           *
//*******************************************************************************
SYNTAX_ERROR:
//    lda #$20                // 32
//    sta $81                 // 129
    ldx #$0b                // Code for Syntax Error
    jmp (jmpvec_Error)      // Display Error Message
