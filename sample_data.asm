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
    .word $0210      ; start
    .word $0210      ; loop
    .word $0222
    .word $0222
    .word $0234
    .word $0234
    .word $0246
    .word $0246

    ;sample:
    ;sample_loop:
    ; ??? Hz Sine Wave
    .byte $B0,$78,$78,$78,$78,$78,$78,$78,$78
    .byte $B3,$78,$78,$78,$78,$78,$78,$78,$78

    ;  1000 Hz Square Wave:
    .byte $B0,$77,$77,$77,$77,$77,$77,$77,$77
    .byte $B3,$99,$99,$99,$99,$99,$99,$99,$99

    ;  1000 Hz Triangle Wave:
    .byte $B0,$01,$23,$45,$67,$76,$54,$32,$10
    .byte $B3,$FE,$DC,$BA,$98,$89,$AB,$CD,$EF

    ;  1000 Hz Sawtooth Wave:
    .byte $B0,$00,$11,$22,$33,$44,$55,$66,$77
    .byte $B3,$88,$99,$AA,$BB,$CC,$DD,$EE,$FF
sample_end:
;============================================================================
