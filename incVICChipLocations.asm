//*******************************************************************************
//* VIC Chip Locations                                                          *
//*******************************************************************************
#define VICIICONSTANTS
#importonce

.const VICII_SP0XP     = $D000
.const VICII_SP0YP     = $D001

.const VICII_SP1XP     = $D002
.const VICII_SP1YP     = $D003

.const VICII_SP2XP     = $D004
.const VICII_SP2YP     = $D005

.const VICII_SP3XP     = $D006
.const VICII_SP3YP     = $D007

.const VICII_SP4XP     = $D008
.const VICII_SP4YP     = $D009

.const VICII_SP5XP     = $D00A
.const VICII_SP5YP     = $D00B

.const VICII_SP6XP     = $D00C
.const VICII_SP6YP     = $D00D

.const VICII_SP7XP     = $D00E
.const VICII_SP7YP     = $D00F

.const VICII_SPXMSB    = $D010

.const VICII_SCROLY    = $D011
.const VICII_SCROLY_FineScroll_Mask    = %00000011
.const VICII_SCROLY_25Rw               = %00000100
.const VICII_SCROLY_24Rw               = 255 - VICII_SCROLY_25Rw           //=%11111011
.const VICII_SCROLY_Restore_Screen     = %00001000
.const VICII_SCROLY_BlankScreen        = 255 - VICII_SCROLY_Restore_Screen //=%11110111
.const VICII_SCROLY_GraphicsMode       = %00010000
.const VICII_SCROLY_NormalMode         = 255 - VICII_SCROLY_GraphicsMode   //=%11101111
.const VICII_SCROLY_ExtColorMode       = %00100000
.const VICII_SCROLY_NormalColorMode    = 255 - VICII_SCROLY_ExtColorMode   //=%00000011
.const VICII_SCROLY_RasterCompareMask  = %11000000

.const VICII_RASTER    = $D012

.const VICII_LPENX     = $D013
.const VICII_LPENY     = $D014

.const VICII_SPRENA    = $D015

.const VICII_SCROLX    = $D016

.const VICII_YXPAND    = $D017

.const VICII_VMCSB     = $D018

.const VICII_VICIRQ    = $D019

.const VICII_IRQMASK   = $D01A

.const VICII_SPBGPR    = $D01B

.const VICII_SPMC      = $D01C

.const VICII_XXPAND    = $D01D

.const VICII_SPSPCL    = $D01E
.const VICII_SPBGCL    = $D01F

.const VICII_EXTCOL    = $D020
.const VICII_BGCOL0    = $D021
.const VICII_BGCOL1    = $D022
.const VICII_BGCOL2    = $D023
.const VICII_BGCOL3    = $D024

.const VICII_SPMC0     = $D025
.const VICII_SPMC1     = $D026

.const VICII_SP0COL    = $D027
.const VICII_SP1COL    = $D028
.const VICII_SP2COL    = $D029
.const VICII_SP3COL    = $D02A
.const VICII_SP4COL    = $D02B
.const VICII_SP5COL    = $D02C
.const VICII_SP6COL    = $D02D
.const VICII_SP7COL    = $D02E

// VICIIe (C128)

.const VICII_KEYP      = $D02F

.const VICII_MODE      = $D030
.const VICII_SLOW_Mask = %00000000
.const VICII_FAST_Mask = %00000001
