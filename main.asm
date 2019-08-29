;---------------|---------|------------|-------------------------------------
;
;
; RAM map:
; 00:1DFF          Stack Pointer
; 00:1E00-00:1FFF  VBlank Routine
; 7F:2400-7F:3300  Main Loop
; 00:1000-00:108F  DSP Register Buffer
; 00:0F00          Controller Input Buffer (max. 0100h 256 bytes)
; 7F:1000-7F:11C2  Interface Data
;
;---------------|---------|------------|-------------------------------------
.include "header.inc"
.include "snes_init.asm"
.include "video_init.asm"
.include "dsp_init.asm"
.include "dsp_stuff.asm"
.include "dsp_ram_routines.asm"
.include "misc.asm"
.include "dsp_array_values_sim.asm"
.include "controller_input.asm"
.include "interface_data.asm"

;---------------|---------|------------|-------------------------------------
;
; The VBlank Routine
; This will be placed in RAM at 00:1E00-1FFF (after Stack Pointer)
;
;---------------|---------|------------|-------------------------------------
.bank 0
.org 8192
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
.org 2048
.section "MainCode" force

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
                ROM_2_RAM_INTERFACE

                Accu_8bit

                JSR       master_go

  ;loop_di_loop: JMP       loop_di_loop

                ;EnableNMI
                STZ       $4016        ;Write a byte of nothing to $4016 (old style joypad register)
                EnableNMIandAutoJoypad
                NMIIN
                JML       $7F2400
                ;NMIOUT

.ends

;---------------|---------|------------|-------------------------------------
; 
; Import graphics data
; 
;---------------|---------|------------|-------------------------------------
.bank 0
.org 5120
.section "CharacterData" force

.include "palette.inc"
.include "tiles.inc"
.include "tilemap.inc"

.ends

;---------------|---------|------------|-------------------------------------
; 
; Loop Routine in RAM
; This will be placed in RAM at 7F:2400-7F:3300
; 
;---------------|---------|------------|-------------------------------------
.bank 0
.org 9216
.section "RAM_LOOP" force
RAM_LOOP:       
                
                UPDATE_DSP_RAM_REGS

                UPDATE_DSP_CH1_REGS
                UPDATE_DSP_CH2_REGS
                UPDATE_DSP_CH3_REGS
                UPDATE_DSP_CH4_REGS
                UPDATE_DSP_MASTER_CH_REGS

                READ_CONTROLLER_1

                WAI

                JMP       $2400
.ends
