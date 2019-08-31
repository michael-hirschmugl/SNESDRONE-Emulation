;----------------------------------------------------------------------------
; 
; SNES DRONE Emulation ROM
; sample_data.asm
; Author: Michael Hirschmugl
;
; Stored in DSP RAM with a routine in main.asm
;
;----------------------------------------------------------------------------
sample:
;.org $200
    ;directory:
    .word $0206      ; start
    .word $0206      ; loop
    .word $0218

    ;sample:
    ;sample_loop:
    .byte $B0,$78,$78,$78,$78,$78,$78,$78,$78
    .byte $B3,$78,$78,$78,$78,$78,$78,$78,$78
sample_end:
;============================================================================
