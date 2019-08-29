;---------------|---------|------------|-------------------------------------
;
; SNES DRONE Emulation ROM
; video_init.asm
; Author: Michael Hirschmugl
;
; MACRO LoadPalette
; MACRO LoadTiles
; ROUTINE DMAPalette
; ROUTINE DMAVramTiles
;
; All of this is used in the main programm.
; Stored and executed in ROM at offset $0C00.
;
;---------------|---------|------------|-------------------------------------

.bank 0
.org 3072
.section "DMAPaletteandVRAM" force
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
                LDA       #%10000000   ;When writing to VRAM, increment address by 1 after writing
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
; DMAs Palette data into CGRAM
; X: DMA Source Address Registers 16 bit
; A: DMA Source Address Registers 8 bit
; Y: DMA Size Registers 16 bit
;
;---------------|---------|------------|-------------------------------------
DMAPalette:     STX       $4302        ;DMA Source Address Registers 16 bit (LOW 2 and MID 3)
                STA       $4304        ;DMA Source Address Registers 8 bit  (HIGH 4)
                STY       $4305        ;DMA Size Registers 16 bit           (LOW 5 and HIGH 6)

                STZ       $4300        ;DMA Control Register (store zeros for normal mode)

                LDA       #$22         ;The destination (CGRAM Data write) is loaded into A. $2122 is the actual address, but since DMA only affects bus B, which is only 8 bit, 22 is enough.
                STA       $4301        ;DMA Destination Register 8 bit

                LDA       #$01         ;Loads the value that is needed to initiate DMA transfer into the first channel.
                STA       $420B        ;DMA Enable Register

                RTS

;---------------|---------|------------|-------------------------------------
; DMAs Characters (Tiles) data into VRAM
; X: DMA Source Address Registers 16 bit
; A: DMA Source Address Registers 8 bit
; Y: DMA Size Registers 16 bit
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