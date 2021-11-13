//******************************************************************************
// Cartridge Basic Template                                                    *
//                                                                             *
// written by eepwin                                                           *
//                                                                             *
// adapted from John Dale                                                      *
//                                                                             *
//                                                                             *
//******************************************************************************
.cpu _6502NoIllegals

#import "incGLOBALVARS.asm"

* = $8000               // Cartridge Start
.label CARTSTART = *

//******************************************************************************
//* Includes Cartridge Code                                                    *
//******************************************************************************
#import "incCartInitiate.asm"
#import "incBASICTokenizer.asm"
#import "incBASICByeBye.asm"
#import "incBASICErrorHandler.asm"

*=$8400 "SCREEN"
.fill 1024, $20
*=$8800 "CODE"

#import "incBASICEvalMy.asm"
#import "incBASICListener.asm"
#import "libROMRoutines.asm"
//******************************************************************************
//* CODE New BASIC Commands                                                    *
//******************************************************************************
#import "libBASICRoutines.asm"
#import "libGraphicsRoutines.asm"
#import "incGRAPHIC_CMD.asm"
#import "incSCREEN_CMD.asm"
#import "incERASE_CMD.asm"
#import "incCOLOR_CMD.asm"
#import "incPLOT_CMD.asm"
#import "incRPOINT_CMD.asm"
#import "incDRAW_CMD.asm"
#import "incUTILITIES_CMD.asm"
// #import "incNEWDRAW_CMD.asm"
#import "incCIRCLE_CMD.asm"
#import "incDISKTOOL_CMD.asm"
#import "incHELP_CMD.asm"
