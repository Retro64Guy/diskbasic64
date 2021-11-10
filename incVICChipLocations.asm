;*******************************************************************************
;* VIC Chip Locations                                                          *
;*******************************************************************************
VICII_SP0XP     = $D000
VICII_SP0YP     = $D001

VICII_SP1XP     = $D002
VICII_SP1YP     = $D003

VICII_SP2XP     = $D004
VICII_SP2YP     = $D005

VICII_SP3XP     = $D006
VICII_SP3YP     = $D007

VICII_SP4XP     = $D008
VICII_SP4YP     = $D009

VICII_SP5XP     = $D00A
VICII_SP5YP     = $D00B

VICII_SP6XP     = $D00C
VICII_SP6YP     = $D00D

VICII_SP7XP     = $D00E
VICII_SP7YP     = $D00F

VICII_SPXMSB    = $D010

VICII_SCROLY    = $D011
VICII_SCROLY_FineScroll_Mask    = %00000011
VICII_SCROLY_25Rw               = %00000100
VICII_SCROLY_24Rw               = 255 - VICII_SCROLY_25Rw           ;=%11111011
VICII_SCROLY_Restore_Screen     = %00001000
VICII_SCROLY_BlankScreen        = 255 - VICII_SCROLY_Restore_Screen ;=%11110111
VICII_SCROLY_GraphicsMode       = %00010000
VICII_SCROLY_NormalMode         = 255 - VICII_SCROLY_GraphicsMode   ;=%11101111
VICII_SCROLY_ExtColorMode       = %00100000
VICII_SCROLY_NormalColorMode    = 255 - VICII_SCROLY_ExtColorMode   ;=%00000011
VICII_SCROLY_RasterCompareMask  = %11000000

VICII_RASTER    = $D012

VICII_LPENX     = $D013
VICII_LPENY     = $D014

VICII_SPRENA    = $D015

VICII_SCROLX    = $D016

VICII_YXPAND    = $D017

VICII_VMCSB     = $D018

VICII_VICIRQ    = $D019

VICII_IRQMASK   = $D01A

VICII_SPBGPR    = $D01B

VICII_SPMC      = $D01C

VICII_XXPAND    = $D01D

VICII_SPSPCL    = $D01E
VICII_SPBGCL    = $D01F

VICII_EXTCOL    = $D020
VICII_BGCOL0    = $D021
VICII_BGCOL1    = $D022
VICII_BGCOL2    = $D023
VICII_BGCOL3    = $D024

VICII_SPMC0     = $D025
VICII_SPMC1     = $D026

VICII_SP0COL    = $D027
VICII_SP1COL    = $D028
VICII_SP2COL    = $D029
VICII_SP3COL    = $D02A
VICII_SP4COL    = $D02B
VICII_SP5COL    = $D02C
VICII_SP6COL    = $D02D
VICII_SP7COL    = $D02E

; VICIIe (C128)

VICII_KEYP      = $D02F

VICII_MODE      = $D030
VICII_SLOW_Mask = %00000000
VICII_FAST_Mask = %00000001
