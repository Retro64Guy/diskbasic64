//*******************************************************************************
//* Cartridge Initialisation Routine                                            *
//*                                                                             *
//* written by eepwin                                                           *
//*                                                                             *
//* adapted from John Dale (OldSkoolCoder)                                      *
//*                                                                             *
//*                                                                             *
//*******************************************************************************
#define CARTINITILIZER
#importonce

#import "incGLOBALVARS.asm"
        .word CART_RESET
        .word CART_NMI
        .text "CBM80"

CART_RESET:
        stx VICII_SCROLX
        jsr krljmp_IOINIT       // CIA IO Initialisation
        jsr krljmp_RAMTAS       // Reform RAM Test
        jsr krljmp_RESTOR       // Restore RAM Vectors
        jsr krljmp_PCINT        // Initialise Screen Editor and VIC Chip
        cli

        jsr $E453               // Copy BASIC Vectors to RAM
        jsr $E3BF               // Initialise BASIC
        jsr START               // Gosub of our Start Routine
        jsr $E422               // Print BASIC Startup Screen

        ldx #$FB                // Load Stack Pointer Start Value (?Why $FB)
        txs                     // Transfer To Stack Pointer
        lda #<NMI_TEXT+1        // Load LoByte of Our Banner (+1 Skip CLR_Screen)
        ldy #>NMI_TEXT          // Load HiByte of Our Banner
        jsr bas_PrintString     // Prints out our Banner
        jmp NMI_EXIT            // NMI Exit Routine

NMI_TEXT:
        .byte CHR_ClearScreen
        .byte CHR_CursorDown
        //COLS"1234567890123456789012345678901234567890"
        .text "oldskoolcoder basic for the commodore 64"
        .byte CHR_CursorDown
        .text "oskbasic v2.020a  (c) 2020 oldskoolcoder"
        brk

CART_NMI:
        jsr $F6BC               // 
        jsr krljmp_STOP         // Check Stop Key
        beq !NMI+
        jmp $FE72               // NMI RS232 Handler

!NMI:
        jsr krljmp_RESTOR       // Restore RAM Vectors
        jsr krljmp_IOINIT       // CIA IO Initialisation
        jsr krljmp_PCINT        // Initialise Screen Editor and VIC Chip
        jsr krljmp_CLRCHN       // Restore Input and Output Channels

        lda #$00
        sta $13
        jsr bas_CLRCommand      // Performing a BASIC CLR
        cli

        lda #<NMI_TEXT          // Load LoByte of Our Banner
        ldy #>NMI_TEXT          // Load HiByte of Our Banner
        jsr bas_PrintString     // Prints out our Banner
        jsr START               // Gosub of our Start Routine

NMI_EXIT:
        ldx #128
        jmp (jmpvec_Error)


//*******************************************************************************
//* Start Routine                                                               *
//*******************************************************************************
START:
        ldy #0
VEC:
        lda MAP_VECTOR,y
        sta jmpvec_Error,y
        iny
        cpy #12
        bne VEC
        
        lda #>CARTSTART-2 // $7E Protects Our BASIC Extension from Corruption
        sta 56
        sta 54
        sta 52

        lda #<CARTSTART-1 // $FF Protects Our BASIC Extension from Corruption
        sta 55
        sta 53
        sta 51
        
        lda #0
        sta COMM_PEN_COLOR
        sta COMM_ERASE_ENABLED
        lda #1
        sta COMM_GRAPHIC_COLOR

        ldx #0
        jmp $A663               // Perform NEW Command


MAP_VECTOR:
        .word VEC_ERRORHANDLER   // ErrorHandler          $300-C64 = word $E38B
        .word $A483              // Default C64 Vector    $302
        .word VEC_TOKEN          // Tokenizer             $304-C64 = word $A57C
        .word VEC_LISTER         // De-Tokenizer / Lister $306-C64 = word $A71A
        .word VEC_BYEBYE         // Cmd Execute           $308-C64 = word $A7E4
        .word VEC_EVALMY         // Evaluator/Interpreter $30A-C64 = word $AE86
//-------------------------------------------------------------------------------
// End of Cartridge Initialisation Routine                                      //
//-------------------------------------------------------------------------------
//
