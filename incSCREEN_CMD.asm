//*******************************************************************************
//* Screen Routine - Setup Textmode of the VIC Chip                             *
//*******************************************************************************
//* Syntax: screen or s shifted C                                               *
//*******************************************************************************
//* Inputparams:                                                                *
//*                                                                             *
//*******************************************************************************
//* Outputparam:                                                                *
//*                                                                             *
//*******************************************************************************
#define COMSCREEN
#importonce

#import "incGLOBALVARS.asm"
#import "incCIAChipLocations.asm"
#import "incVICCHIPLocations.asm"

COM_SCREEN:
        lda CIA2_DDRA
        ora #$00000011
        sta CIA2_DDRA

        lda CIA2_PRA
        and #255 - CIA2_PRA_VICBank_Mask
        ora #CIA2_PRA_VICBank_0
        sta CIA2_PRA

        lda VICII_SCROLY
        and #VICII_SCROLY_NormalColorMode
        sta VICII_SCROLY

        lda #21
        sta VICII_VMCSB
        
        lda #$00
        sta COMM_GRAPHIC_MODE
        rts
