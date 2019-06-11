;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.include "header.inc"
.include "snes_init.asm"

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.bank 0
.section "DMAPaletteandVRAM"
DMAPalette:     STX       $4302        ;DMA Source Address Registers 16 bit (LOW 2 and MID 3)
                STA       $4304        ;DMA Source Address Registers 8 bit  (HIGH 4)
                STY       $4305        ;DMA Size Registers 16 bit           (LOW 5 and HIGH 6)

                STZ       $4300        ;DMA Control Register (store zeros for normal mode)

                LDA       #$22         ;The destination (CGRAM Data write) is loaded into A. $2122 is the actual address, but since DMA only affects bus B, which is only 8 bit, 22 is enough.
                STA       $4301        ;DMA Destination Register 8 bit

                LDA       #$01         ;Loads the value that is needed to initiate DMA transfer on the first channel.
                STA       $420B        ;DMA Enable Register

                RTS

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
DMAVramTiles:   STX       $4302        ;DMA Source Address Registers 16 bit (LOW 2 and MID 3)
                STA       $4304        ;DMA Source Address Registers 8 bit  (HIGH 4)
                STY       $4305        ;DMA Size Registers 16 bit           (LOW 5 and HIGH 6)

                LDA       #$01         ;Value for DMA Control Register (2 registers write once, since addresses in VRAM are words, instead of bytes as in CGRAM)
                STA       $4300        ;DMA Control Register

                LDA       #$18         ;The destination (VRAM Data write) is loaded into A. $2118 is the actual address, but since DMA only affects bus B, which is only 8 bit, 18 is enough.
                                       ;Also, there are actually two bytes to be written in 2118 and 2119 because VRAM has word addresses, but DMA already knows to write words because we said so in the DMA Control Register.
                STA       $4301        ;DMA Destination Register 8 bit

                LDA       #$01         ;Loads the value that is needed to initiate DMA transfer on the first channel.
                STA       $420B        ;DMA Enable Register

                RTS
.ends

;---------------|---------|------------|-------------------------------------
;
;
; example: LoadPalette DATA_24BIT_ADDRESS, START_COLOR, NUMBER_OF_COLORS
;---------------|---------|------------|-------------------------------------
.macro  LoadPalette
                LDA       #\2          ;START_COLOR
                STA       $2121        ;CGRAM Address Register

                LDX       #\1          ;(16 bit) Address of palette data
                LDA       #:\1         ;(8 bit) Bank Address of palette data
                LDY       #(\3 * 2)    ;16 bits per color (0BBBBBGG GGGRRRRR)
                ;A=Bank of data
                ;X=Address of data
                ;Y=Amount of data in bytes
                JSR       DMAPalette
.endm

;---------------|---------|------------|-------------------------------------
;
;
; example: LoadTiles DATA_24BIT_ADDRESS, VRAM_ADDRESS_START, NUMBER_OF_BYTES
;---------------|---------|------------|-------------------------------------
.macro  LoadTiles
                LDA       #%10000000   ;When writing to VRAM, increment address after writing by 1
                STA       $2115        ;Video Port Control Register

                LDX       #\2          ;VRAM_ADDRESS_START
                STX       $2116        ;VRAM Address Registers (LOW and HIGH)

                LDX       #\1          ;(16 bit) Address of vram data to load
                LDA       #:\1         ;(8 bit) Bank Address of vram data to load
                LDY       #\3          ;Amount of bytes to write per DMA
                ;A=Bank of data
                ;X=Address of data
                ;Y=Amount of data in bytes

                JSR       DMAVramTiles
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro  EnableNMI
                LDA       #%10000000   ;If set, NMI will fire just after the start of V-Blank.
                STA       $4200        ;NMITIMEN - Interrupt Enable Flags
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro  NMIIN
                REP       #$30         ;A/mem=16 bits, X/Y=16 bits (to push all 16 bits)
                PHB                    ;Push Data Bank Register (holds current bank for memory transfer)
                PHA                    ;Push Accumulator
                PHX                    ;Push Index Register X
                PHY                    ;Push Index Register Y
                PHD                    ;Push Direct Page Ragister (holds memory bank address for direct page addressing modes)

                SEP       #$20         ;A/mem=8 bit
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro  NMIOUT
                LDA       $4210        ;Clear NMI flag (set at the start of V-Blank, needs to be read during V-Blank)
                REP       #$30         ;A/Mem=16 bits, X/Y=16 bits 
    
                PLD
                PLY
                PLX
                PLA
                PLB

                SEP       #$20
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.bank 0
.section "VBlank"
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
                SEP       #$20         ;A=8bit, X/Y=16bit
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




                EnableNMI

  Forever:      WAI
                
                JMP       Forever
.ends

;---------------|---------|------------|-------------------------------------
; 
; Import graphics data
; 
;---------------|---------|------------|-------------------------------------
.bank 1 slot 0
.org 0
.section "CharacterData"

.include "palette.inc"
.include "tiles.inc"
.include "tilemap.inc"

.ends
