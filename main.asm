;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.include "header.inc"
.include "snes_init.asm"
.include "video_init.asm"
.include "dsp_init.asm"
.include "sample_data.asm"
.include "dsp_stuff.asm"
.include "misc.asm"
.include "dsp_array_values_sim.asm"

;---------------|---------|------------|-------------------------------------
;
; The VBlank Routine
; This will be placed in RAM at 00:1E00-1FFF
;
;---------------|---------|------------|-------------------------------------
.bank 3
.org 0
.section "VBlank" force
VBlank:         NMIIN                  ;A=8bit, X/Y=16bit
                

                NMIOUT
                RTI
.ends
;---------------|---------|------------|-------------------------------------
; 
; Main Program
; 
;---------------|---------|------------|-------------------------------------
.bank 0
.section "MainCode"

Start:          InitSNES               ;Initialize the SNES.

                LoadPalette BG_Palette, 0, 4  ;BG_Palette is in "palette.inc", 0 is the index of the first color, 4 is the amount of color to write.
                LoadTiles   Tiles, $0000, 192 ;Tiles is in "tiles.inc", $0000 is the address in VRAM to start writing data, 192 is the amount of data in bytes.

                STZ       $2105        ;Screen mode register (BG mode 1, 8x8 tiles)
                LDA       #$04         ;Value for BG1 Tile Map Location (incremented in $0400 words, so we start at $0400)
                STA       $2107        ;BG1 Tile Map Location (aaaaaass, a is the tile map offset in 0400 increments and ss defines the tile map size 00=32x32 01=64x32 10=32x64 11=64x64)

                STZ       $210B        ;BG1 & BG2 Character location: Set BG1's Character VRAM offset to $0000 (word address)
                STZ       $210C        ;BG3 & BG4 Character Location: Set BG3's Character VRAM offset to $0000 (word address)

                LDA       #$01         ;Value for Main screen designation Register (enable BG1)
                STA       $212C        ;Main screen designation Register

                LoadTiles   Tilemap, $0400, 2048
                
                LDA       #$0F
                STA       $2100        ;Turn on screen, full Brightnes

                JSR       spc_wait_boot
                
                ;Upload sample to SPC at $200
                LDY       #$0200
                JSR       spc_begin_upload
  loop:         LDA       sample,y
                JSR       spc_upload_byte
                CPY       #sample_end - sample
                BNE       loop
  
                ;Init DSP register buffer
                InitDSPch1
                InitDSPch2
                InitDSPch3
                InitDSPch4
                InitDSPmaster

                ;Let's load a whole ROM bank into RAM and execute from there... sweet
                ;Only thing is, we cannot overwrite the RAM mirror at 7E, so
                ;let's start at 7F, easy!
                Accu_16bit

                ROM_2_RAM_LOOP

                ROM_2_RAM_VBLANK

                Accu_8bit

                EnableNMI
                NMIIN
                JML       $7F0000
                NMIOUT

.ends

;---------------|---------|------------|-------------------------------------
; 
; Import graphics data
; 
;---------------|---------|------------|-------------------------------------
.bank 1
.org 0
.section "CharacterData"

.include "palette.inc"
.include "tiles.inc"
.include "tilemap.inc"

.ends

;---------------|---------|------------|-------------------------------------
; 
; Loop Routine in RAM
; 
;---------------|---------|------------|-------------------------------------
.bank 2
.org 0
.section "RAM_LOOP" force
test_routine:   ;PER       test_routine
                WAI
                LDA       $00000A
                INA
                STA       $00000A

                UPDATE_DSP_RAM_REGS
   PER       test_routine1
 BRA testy_routy
  test_routine1: NOP
                


                JMP       $0000

testy_routy:
                NOP
                RTS

.ends