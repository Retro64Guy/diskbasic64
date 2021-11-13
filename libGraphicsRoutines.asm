//*******************************************************************************
//* Library of Graphics Functions that will be used throughout the code.        *
//*******************************************************************************
#define GRAPHICROUTINES
#importonce

#if !GLOBALVARS
#import "incGLOBALVARS.asm"
#endif

//*******************************************************************************
//* PLACE Functions                                                             *
//* This function works out the byte location of the memory address to modify   *
//*******************************************************************************
//* Inputs : X - Pixel Column location, Y - Pixel Row location                  *
//*******************************************************************************

PLACE:
        clc
        lda COMM_Y              // Get Y Pixel Location
        cmp #200                // Maximum Nubers of Rows + 1
        bcs !PLACE_ERROR+       // >199 then Error
        lda COMM_XHI            // Get X Pixel Column Location (HiByte)
        cmp #2
        bcs !PLACE_ERROR+       // 2 or above  = Error
        cmp #1
        bne WORK_PLACEOUT       // This is Zero ... so it's legal
        lda COMM_XLO
        cmp #64
        bcc WORK_PLACEOUT       //
        

!PLACE_ERROR:
        jmp bas_IQERR

WORK_PLACEOUT:
        // Row = (200 - Y) / 8 (inverted Y coordinate)
        lda #199
        sec
        sbc COMM_Y
        clc
        lsr             // Div 2
        lsr             // Div 2 = 4
        lsr             // Div 2 = 8
        sta COMM_U      // Row Value 0- 25

        // Col = X / 8
        lda COMM_XHI    // this is either 1 or 0
        lsr             // populate the carry flag - initialize carry with 0 or 1
        lda COMM_XLO    // 0-255
        
        // C XLO - Byte
        // 1 10101010
        // > 11010101 > 1
        ror             // Div 2
        lsr             // Div 2 = 4
        lsr             // Div 2 = 8
        sta COMM_V      // Column value 0-39

        // pixelRow = Row * 320  ( S = U * 320)

        ldy COMM_U
        lda #0
        sta COMM_SLO
        sta COMM_SHI
        cpy #0
        beq WORK_OUT_COL

!RowMultiplier:
        lda COMM_SLO
        clc
        adc #64
        sta COMM_SLO
        lda COMM_SHI
        adc #1
        sta COMM_SHI
        dey
        bne !RowMultiplier-

WORK_OUT_COL:
        // pixelRow = 7 - (Y - (Column * 8))
        // better solution -> pixelRow = 7 - (Y and 7)
        lda COMM_Y
        and #7
        sta COMM_R      // R = 7 - (Y and 7)
        sec
        lda #7
        sbc COMM_R
        sta COMM_R

        //pixelCol = X and 7
        lda COMM_XLO
        and #7
        sta COMM_C      // this is pixel column

        // Mem Location
        // Base + pixelRow + (column * 8) + pixelRow
        // $A0000 + S + (V*8) + R
        lda #0
        sta STAL
        lda #$A0
        sta STAL + 1
        clc
        lda STAL
        adc COMM_SLO
        sta STAL
        lda STAL + 1
        adc COMM_SHI
        sta STAL + 1

        lda #0
        asl COMM_V      // Mult 2
        asl COMM_V      // Mult 2 = 4
        asl COMM_V      // Mult 2 = 8
        rol
        clc
        adc STAL + 1
        sta STAL + 1

        clc
        lda COMM_V
        adc STAL
        sta STAL

        bcc !ByPassInc+
        inc STAL + 1

!ByPassInc:
        clc
        lda COMM_R
        adc STAL
        sta STAL
        bcc !ByPassIncAgain+
        inc STAL + 1

!ByPassIncAgain:
        rts


//*******************************************************************************
//* DOT Function                                                                *
//* This function sets or clears the pixel in the memory location set by PLACE  *
//*******************************************************************************
//* Inputs : ZP : C1 and C2, COMM_C                                             *
//*******************************************************************************

DOT:
        lda $01
        and #%11111110          // paging out BASIC ROM
        sta $01

        ldx COMM_C
        ldy #0
        lda BYTEMASK,x
        pha
SETDOT:
        lda COMM_ERASE_ENABLED
        bmi ERASEDOT
        pla
        ora (STAL),y
        jmp DoDotset
ERASEDOT:
        pla
        eor (STAL),y
DoDotset:
        sta (STAL),y

        lda $01
        ora #%00000001          // paging in BASIC ROM
        sta $01
        rts
