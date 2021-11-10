;*******************************************************************************
;* CIA Chiplocations                                                           *
;*******************************************************************************

CIA1                    = $DC00

CIA1_PRA                = $DC00
CIA1_PRB                = $DC01
CIA1_DDRA               = $DC02
CIA1_DDRB               = $DC03

CIA1_TIMALO             = $DC04
CIA1_TIMAHI             = $DC05

CIA1_TIMBLO             = $DC06
CIA1_TIMBHI             = $DC07

CIA1_TODTEN             = $DC08
CIA1_TODSEC             = $DC09
CIA1_TODMIN             = $DC0A
CIA1_TODHRS             = $DC0B

CIA1_SDR                = $DC0C
CIA1_ICR                = $DC0D
CIA1_CRA                = $DC0E
CIA1_CRB                = $DC0F

CIA2                    = $DD00

CIA2_PRA                = $DD00
CIA2_PRA_VICBank_Mask   = %00000011
CIA2_PRA_VICBank_0      = %00000011
CIA2_PRA_VICBank_1      = %00000010
CIA2_PRA_VICBank_2      = %00000001
CIA2_PRA_VICBank_3      = %00000000

CIA2_PRB                = $DD01
CIA2_DDRA               = $DD02
CIA2_DDRB               = $DD03

CIA2_TIMALO             = $DD04
CIA2_TIMAHI             = $DD05

CIA2_TIMBLO             = $DD06
CIA2_TIMBHI             = $DD07

CIA2_TODTEN             = $DD08
CIA2_TODSEC             = $DD09
CIA2_TODMIN             = $DD0A
CIA2_TODHRS             = $DD0B

CIA2_SDR                = $DD0C
CIA2_ICR                = $DD0D

CIA2_CRA                = $DD0E
CIA2_CRB                = $DD0F
