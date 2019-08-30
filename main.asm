;---------------|---------|------------|-------------------------------------
;
; SNES DRONE Emulation ROM
; This ROM is best run on BSNES. I don't know if any other emulator can even
; run it properly.
; Author: Michael Hirschmugl
;
; RAM map:
; 00:1DFF          Stack Pointer
; 00:1E00-00:1FFF  VBlank Routine
; 7F:2400-7F:3300  Main Loops
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
; It is running nothing at the moment, but it will run the 
; update for the screen (mostly update tilemaps).
;
;---------------|---------|------------|-------------------------------------
.bank 0
.org 8192
.section "VBlank" force
VBlank:         NMIIN                  ;Saves all registers
                                       ;A=8bit, X/Y=16bit
                

                NMIOUT
                RTI
.ends
;---------------|---------|------------|-------------------------------------
; 
; Main Program
;
; 1. Initialize SNES
; 2. Load Palette from section "CharacterData" (ROM: $000800) stores it in CGRAM
; 3. Load Characters (Tiles) from section "CharacterData" (ROM: $000800) stores it in VRAM
; 4. Init Backgrounds and Screen (Tilemap location and character location)
; 5. Load Tilemap from section "CharacterData" (ROM: $000800) stores it in VRAM
;    The tilemap is stored with the same routine as the character data, but tilemap
;    has an offset of $400.
; 6. Turn ON screen
; 7. Wait for SPC-700 to finish booting.
; 8. Upload audio samples from 
; 
;---------------|---------|------------|-------------------------------------
.bank 0
.org 2048
.section "MainCode" force

Start:          InitSNES               ;Initialize the SNES. (snes_init.asm)

                ;(video_init.asm)
                LoadPalette BG_Palette, 0, 4  ;BG_Palette is in "palette.inc", 0 is the index of the 
                                              ;first color, 4 is the amount of color to write.
                LoadTiles   Tiles, $0000, 192 ;Tiles is in "tiles.inc", $0000 is the address in
                                              ;VRAM to start writing data, 192 is the amount of data in bytes.

                STZ       $2105        ;Screen mode register (BG mode 1, 8x8 tiles)
                LDA       #$04         ;Value for BG1 Tile Map Location (incremented in $0400 words, so we start at $0400)
                STA       $2107        ;BG1 Tile Map Location (aaaaaass, a is the tile map offset in 0400
                                       ;increments and ss defines the tile map size 00=32x32 01=64x32 10=32x64 11=64x64)

                STZ       $210B        ;BG1 & BG2 Character location: Set BG1's Character VRAM offset to $0000 (word address)
                STZ       $210C        ;BG3 & BG4 Character Location: Set BG3's Character VRAM offset to $0000 (word address)

                LDA       #$01         ;Value for Main screen designation Register (enable BG1)
                STA       $212C        ;Main screen designation Register

                ;(video_init.asm)
                LoadTiles   Tilemap, $0400, 2048
                
                LDA       #$0F
                STA       $2100        ;Turn on screen, full Brightnes

                ;Wait for the SPC-700 to finish booting
                ;(dsp_stuff.asm)
                JSR       spc_wait_boot
                
                ;Upload sample to SPC at $200
                ;(dsp_stuff.asm)
                LDY       #$0200
                JSR       spc_begin_upload
  loop:         LDA       sample,y
                JSR       spc_upload_byte
                CPY       #sample_end - sample
                BNE       loop
  
                ;Init DSP register buffer
                ;These macros specify the init values for the registers.
                ;(macros dsp_init.asm)
                InitDSPch1
                InitDSPch2
                InitDSPch3
                InitDSPch4
                InitDSPmaster

                ;Let's load all routines into RAM that need to be executed from there.
                ;Only thing is, we should not overwrite the RAM mirror at 7E, so
                ;let's start at 7F, easy!
                ;(macros misc.asm)
                ;"LOOP" cover sections "RAM_LOOP", "DSP_RAM_ROUTINES" and "Controller_Read_Routines".
                ;       goes to RAM: 7F:2400
                ;"VBLANK" is the NMI routine, which is copied into the first page of RAM, right
                ;after the Stack Pointer
                ;       goes to RAM: 00:1E00
                ;"INTERFACE" is the map for the GUI
                ;       goes to RAM: 7F:1000
                Accu_16bit
                ROM_2_RAM_LOOP
                ROM_2_RAM_VBLANK
                ROM_2_RAM_INTERFACE
                Accu_8bit

                ;Writes all values from the master dsp register buffer in RAM to the
                ;registers in the DSP.
                ;(dsp_stuff.asm)
                JSR       master_go

                STZ       $4016        ;Write a byte of nothing to $4016 (old style joypad register)
                EnableNMIandAutoJoypad
                NMIIN
                JML       $7F2400      ;Jump into main Loop in RAM

.ends

;---------------|---------|------------|-------------------------------------
; 
; Import graphics data
; Written to VRAM and CGRAM by routines in video_init.asm
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
                

                ;These are macros that launch routines stored in RAM (by branching there)
                ;The routines write values from the DSP buffer in RAM to the DSP registers.
                UPDATE_DSP_CH1_REGS    ; launches ch1_go_ram from dsp_ram_routines.asm 
                UPDATE_DSP_CH2_REGS    ; launches ch2_go_ram from dsp_ram_routines.asm 
                UPDATE_DSP_CH3_REGS    ; launches ch3_go_ram from dsp_ram_routines.asm 
                UPDATE_DSP_CH4_REGS    ; launches ch4_go_ram from dsp_ram_routines.asm 
                UPDATE_DSP_MASTER_CH_REGS ; Only Volume is written! Key ON and all else must be done when
                                          ; user needs.

                READ_CONTROLLER_1
                JUMP_INTERFACE

                ;Fetches values from MCU and stores them in
                ;the DSP buffer in RAM (00:1000)
                ;(macro dsp_stuff.asm)
                ;Please don't ask me why this is in dsp_stuff.asm
                UPDATE_DSP_RAM_REGS
                ; INSIDE NMI ROUTINE???

                WAI

                JMP       $2400
.ends
