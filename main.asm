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
; 7F:4000-7F:4800  Tilemap Buffer
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

                LDA       #%10000000   ;When writing to VRAM, increment address by 1 after writing
                STA       $2115        ;Video Port Control Register

                LDX       #$0C00       ;VRAM_ADDRESS_START
                STX       $2116        ;VRAM Address Registers (LOW and HIGH)

                LDX       #$4000       ;(16 bit) Address of vram data to load
                LDA       #$7F         ;(8 bit) Bank Address of vram data to load
                LDY       #2048        ;Amount of bytes to write per DMA
                ;A=Bank of data
                ;X=Address of data
                ;Y=Amount of data in bytes

                STX       $4302        ;DMA Source Address Registers 16 bit (LOW 2 and MID 3)
                STA       $4304        ;DMA Source Address Registers 8 bit  (HIGH 4)
                STY       $4305        ;DMA Size Registers 16 bit           (LOW 5 and HIGH 6)

                LDA       #$01         ;Value for DMA Control Register (2 registers write once, since addresses in VRAM are words, instead of bytes as in CGRAM)
                STA       $4300        ;DMA Control Register

                LDA       #$18         ;The destination (VRAM Data write) is loaded into A. $2118 is the actual address, but since DMA only affects bus B, which is only 8 bit, 18 is enough.
                                       ;Also, there are actually two bytes to be written in 2118 and 2119 because VRAM has word addresses, but DMA already knows to write words because we said so in the DMA Control Register.
                STA       $4301        ;DMA Destination Register 8 bit

                LDA       #$01         ;Loads the value that is needed to initiate DMA transfer on the first channel.
                STA       $420B        ;DMA Enable Register

                

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
                LoadPalette BG_Palette, 31, 4 ;BG_Palette for BG2
                LoadTiles   Tiles, $0000, 192 ;Tiles is in "tiles.inc", $0000 is the address in
                                              ;VRAM to start writing data, 192 is the amount of data in bytes.

                STZ       $2105        ;Screen mode register (BG mode 1, 8x8 tiles)
                LDA       #$04         ;Value for BG1 Tile Map Location (incremented in $0400 words, so we start at $0400)
                STA       $2107        ;BG1 Tile Map Location (aaaaaass, a is the tile map offset in 0400
                                       ;increments and ss defines the tile map size 00=32x32 01=64x32 10=32x64 11=64x64)

                LDA       #$0C
                STA       $2108

                STZ       $210B        ;BG1 & BG2 Character location: Set BG1's Character VRAM offset to $0000 (word address)
                STZ       $210C        ;BG3 & BG4 Character Location: Set BG3's Character VRAM offset to $0000 (word address)

                ;LDA       #$01         ;Value for Main screen designation Register (enable BG1)
                LDA       #$03
                STA       $212C        ;Main screen designation Register

                ;(video_init.asm)
                LoadTiles   Tilemap, $0400, 2048
                ;LoadTiles   Tilemap, $0C00, 2048
                
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
                ;The routines write values from the DSP buffer in RAM to the DSP registers
                UPDATE_DSP_CH1_REGS    ; launches ch1_go_ram from dsp_ram_routines.asm 
                UPDATE_DSP_CH2_REGS    ; launches ch2_go_ram from dsp_ram_routines.asm 
                UPDATE_DSP_CH3_REGS    ; launches ch3_go_ram from dsp_ram_routines.asm 
                UPDATE_DSP_CH4_REGS    ; launches ch4_go_ram from dsp_ram_routines.asm 
                UPDATE_DSP_MASTER_CH_REGS ; Only Volume is written! Key ON and all else must be done when
                                          ; user needs.

                READ_CONTROLLER_1
                JUMP_INTERFACE
                BUTTON_A_THINGS
                ;Accu_8bit
                
                CURSOR_POS_UPDATE

;---------------|---------|------------|-------------------------------------
; Everything that's coming up, needs the MCU
;---------------|---------|------------|-------------------------------------

                ;Fetches values from MCU and stores them in
                ;the DSP buffer in RAM (00:1000)
                ;(macro dsp_stuff.asm)
                ;Please don't ask me why this is in dsp_stuff.asm
                UPDATE_DSP_RAM_REGS
                ; INSIDE NMI ROUTINE???

                WAI
;---------------|---------|------------|-------------------------------------

                JMP       $2400
.ends
