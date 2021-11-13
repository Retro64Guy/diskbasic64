//*******************************************************************************
//* .const CIA Chiplocations                                                           *
//*******************************************************************************
#define incCIAChipLocations
#importonce

.const CIA1                    = $DC00

.const CIA1_PRA                = $DC00
.const CIA1_PRB                = $DC01
.const CIA1_DDRA               = $DC02
.const CIA1_DDRB               = $DC03

.const CIA1_TIMALO             = $DC04
.const CIA1_TIMAHI             = $DC05

.const CIA1_TIMBLO             = $DC06
.const CIA1_TIMBHI             = $DC07

.const CIA1_TODTEN             = $DC08
.const CIA1_TODSEC             = $DC09
.const CIA1_TODMIN             = $DC0A
.const CIA1_TODHRS             = $DC0B

.const CIA1_SDR                = $DC0C
.const CIA1_ICR                = $DC0D
.const CIA1_CRA                = $DC0E
.const CIA1_CRB                = $DC0F

.const CIA2                    = $DD00

.const CIA2_PRA                = $DD00
.const CIA2_PRA_VICBank_Mask   = %00000011
.const CIA2_PRA_VICBank_0      = %00000011
.const CIA2_PRA_VICBank_1      = %00000010
.const CIA2_PRA_VICBank_2      = %00000001
.const CIA2_PRA_VICBank_3      = %00000000

.const CIA2_PRB                = $DD01
.const CIA2_DDRA               = $DD02
.const CIA2_DDRB               = $DD03

.const CIA2_TIMALO             = $DD04
.const CIA2_TIMAHI             = $DD05

.const CIA2_TIMBLO             = $DD06
.const CIA2_TIMBHI             = $DD07

.const CIA2_TODTEN             = $DD08
.const CIA2_TODSEC             = $DD09
.const CIA2_TODMIN             = $DD0A
.const CIA2_TODHRS             = $DD0B

.const CIA2_SDR                = $DD0C
.const CIA2_ICR                = $DD0D

.const CIA2_CRA                = $DD0E
.const CIA2_CRB                = $DD0F
