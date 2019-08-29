;----------------------------------------------------------------------------
; 
; SNES DRONE Emulation ROM
; dsp_array_values_sim.asm
;
; This file is what the DSP is initialized with. But, this file is also what
; the CPU reads form the MCU.
; Attention: These values are not fetched at initialization! The macros in
; dsp_init.asm define the init values. Though, this array should be consistent with
; the init values... simply for consistency.
; As soon as the MCU is running, these values are swapped with newly generated
; values. But for init, these stay the same.
; Reading of this from ROM should happen right befor the WAI. When these values are read from
; The MCU, the CPU asks for the NMI vector. After that, the MCU is free to do whatever it
; needs to (read and process potentiometer values).
;
; First two empty bytes in the beginning are legacy and unused.
; 
; This data is accessed at address $008000+$004400=$00C400.
; Stored in ROM at offset $4400.
;----------------------------------------------------------------------------
.bank 0
.org 17408
.section "DSP_Value_Sim" force
dsp_value_array:
    .byte $00,$00,$7F,$7F,$00,$01,$00,$FF,$E0,$01,$00,$00,$00,$7F,$7F,$00,$01,$00,$FF,$E0,$02,$00,$00,$00,$7F,$7F,$00,$01,$00,$FF,$E0,$00,$00,$00,$00,$7F,$7F,$00,$01,$00,$FF,$E0,$00,$00,$00,$00,$20,$03,$FC,$02,$00,$00,$7F,$7F,$00,$00
dsp_value_array_end:
.ends
;============================================================================
