;----------------------------------------------------------------------------
; 
; SNES DRONE Emulation ROM
; palette.inc
; Author: Michael Hirschmugl
;
; Just a 4-color palette. Stored in CGRAM by LoadPalette in main.asm.
; Routine is stored in video_init.asm.
;
;----------------------------------------------------------------------------
BG_Palette:
    .db $00, $00, $FF, $01, $FF, $FF, $01, $FF
Title_Palette:
    .db $00, $00, $10, $40, $00, $50, $00, $00