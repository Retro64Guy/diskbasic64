//*******************************************************************************
//* ERASE Command                                                               *
//* This BASIC funtion Erases lines and shapes                                  *
//*******************************************************************************
//* Syntax ERASE or E and shifted R                                             *
//*******************************************************************************
#define ERASECMD
#importonce

#import "incGLOBALVARS.asm"

COM_ERASE:
        lda COMM_ERASE_ENABLED
        eor #$80
        sta COMM_ERASE_ENABLED
        rts
