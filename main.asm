;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.include "header.inc"
.include "snes_init.asm"
.include "video_init.asm"
.include "dsp_init.asm"
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

                JSR       ch1_go
                JSR       ch2_go
                JSR       ch3_go
                
                JSR       master_go

                EnableNMI
                NMIIN
                JML       $7F0000
                NMIOUT

;---------------|---------|------------|-------------------------------------
;
; 
;
;---------------|---------|------------|-------------------------------------
ch1_go:         LDA       $00
                XBA
                LDA       $1000
                XBA
                ORA       #$0000
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1001
                XBA
                ORA       #$0001
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1002
                XBA
                ORA       #$0002
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1003
                XBA
                ORA       #$0003
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1004
                XBA
                ORA       #$0004
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1005
                XBA
                ORA       #$0005
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1006 
                XBA
                ORA       #$0006
                TAX
                JSR       write_dsp
                RTS

;---------------|---------|------------|-------------------------------------
;
; Write Channel 2 Data
;
;---------------|---------|------------|-------------------------------------
ch2_go:         LDA       $00
                XBA
                LDA       $1010
                XBA
                ORA       #$0010
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1011
                XBA
                ORA       #$0011
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1012
                XBA
                ORA       #$0012
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1013
                XBA
                ORA       #$0013
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1014
                XBA
                ORA       #$0014
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1015
                XBA
                ORA       #$0015
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1016
                XBA
                ORA       #$0016
                TAX
                JSR       write_dsp
                RTS

;---------------|---------|------------|-------------------------------------
;
; Write Channel 3 Data
;
;---------------|---------|------------|-------------------------------------
ch3_go:         RTS

;---------------|---------|------------|-------------------------------------
;
; Write Master Channel Data
;
;---------------|---------|------------|-------------------------------------
master_go:      LDA       $00
                XBA
                LDA       $1083
                XBA
                ORA       #$005D
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1084
                XBA
                ORA       #$003D
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1085
                XBA
                ORA       #$004D
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1080
                XBA
                ORA       #$006C
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1082
                XBA
                ORA       #$005C
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1081
                XBA
                ORA       #$004C
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1088
                XBA
                ORA       #$002C
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1089
                XBA
                ORA       #$003C
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1086
                XBA
                ORA       #$000C
                TAX
                JSR       write_dsp
                LDA       $00
                XBA
                LDA       $1087
                XBA
                ORA       #$001C
                TAX
                JSR       write_dsp
                RTS

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
; This will be placed in RAM at 7F:0000-7F:FFFF
; Whole ROM bank 2 takes up this space in RAM
; 
;---------------|---------|------------|-------------------------------------
.bank 2
.org 0
.section "RAM_LOOP" force
RAM_LOOP:       WAI
                LDA       $00000A
                INA
                STA       $00000A

                UPDATE_DSP_RAM_REGS

                JMP       $0000
.ends