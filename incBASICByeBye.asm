//****************************************
//* ByeBye (Execute Commands) Routine    *
//****************************************
#define BYEBYE
#importonce

#import "incGLOBALVARS.asm"
#if !TOKENIZER
#import "incBASICTOKENIZER.asm"
#endif

VEC_BYEBYE:
        jsr bas_CHRGET
        jsr BYEBYE_CHKCMDTOKEN
        jmp $a7ae

BYEBYE_CHKCMDTOKEN:
        beq BYEBYE_EXIT
        sbc #$80
        bcc BYEBYE_EXECLETCODE
        cmp #$23
        bcc BYEBYE_GOBASICV2CMD
        sec
        sbc #$4c
        bcc BYEBYE_SYNTAXERROR
        asl
        tay
        lda Command_Addr+1,y
        pha
        lda Command_Addr,y
        pha
        jmp bas_CHRGET

BYEBYE_GOBASICV2CMD:
        jmp $a7f7

BYEBYE_SYNTAXERROR:
        jmp $af08

BYEBYE_EXECLETCODE:
        jmp $a9a5

BYEBYE_EXIT:
        rts

// #region Original Executer from Dale
//         jsr bas_CHRGET$
//         cmp #$CC
//         bcc BYERTS
//         cmp #$DF
//         bcs BYERTS
//         JSR BYEGO
//         jmp bas_NewStatement$

// BYEGO
//         sbc #$CB
//         asl
//         tay
//         lda Command_ADDR + 1,y
//         pha
//         lda Command_ADDR,y
//         pha
//         jmp bas_CHRGET$

// BYERTS
//         jsr bas_CHRGOT$
//         jmp bas_GONE$ + 3

// #endregion
