;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.include "header.inc"
.include "snes_init.asm"
.include "sample_data.asm"

;----------------------------------------------------------------------------
; Set Accumulator to 16 bit
;----------------------------------------------------------------------------
.MACRO Accu_16bit

  REP #%00100000

.ENDM
;============================================================================

;----------------------------------------------------------------------------
; Set Accumulator to 8 bit
;----------------------------------------------------------------------------
.MACRO Accu_8bit

  SEP #%00100000

.ENDM

;---------------|---------|------------|-------------------------------------
;
; Waits for SPC to finish booting
;
;---------------|---------|------------|-------------------------------------
.bank 0
.section "DSPstuff"
spc_wait_boot:  LDA       #$AA
  wait1:        CMP       $2140
                BNE       wait1

               ;Clear in case it already has $CC in it
               ;(this actually occurred in testing)
               STA        $2140

               LDA        #$BB
  wait2:       CMP        $2141
               BNE        wait2

               RTS
               
;---------------|---------|------------|-------------------------------------
;
; 
;
;---------------|---------|------------|-------------------------------------

ch1_go:  LDA       $00
                XBA
                LDA       $1000
                XBA
    ORA  #$0000
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1001
  XBA
  ORA  #$0001
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1002
  XBA
  ORA  #$0002
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1003
  XBA
  ORA  #$0003
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1004
  XBA
  ORA  #$0004
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1005
  XBA
  ORA  #$0005
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1006
  XBA
  ORA  #$0006
  TAX
  JSR    write_dsp
               RTS

;----------------------------------------------------------------------------
; Write Channel 2 Data
;----------------------------------------------------------------------------
ch2_go:
  LDA  $00
  XBA
  LDA  $1010
  XBA
  ORA  #$0010
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1011
  XBA
  ORA  #$0011
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1012
  XBA
  ORA  #$0012
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1013
  XBA
  ORA  #$0013
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1014
  XBA
  ORA  #$0014
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1015
  XBA
  ORA  #$0015
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1016
  XBA
  ORA  #$0016
  TAX
  JSR    write_dsp
rts

;----------------------------------------------------------------------------
; Write Channel 3 Data
;----------------------------------------------------------------------------
ch3_go:
  LDA  $00
  XBA
  LDA  $1020
  XBA
  ORA  #$0020
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1021
  XBA
  ORA  #$0021
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1022
  XBA
  ORA  #$0022
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1023
  XBA
  ORA  #$0023
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1024
  XBA
  ORA  #$0024
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1025
  XBA
  ORA  #$0025
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1026
  XBA
  ORA  #$0026
  TAX
  JSR    write_dsp

rts

;----------------------------------------------------------------------------
; Write Master Channel Data
;----------------------------------------------------------------------------
master_go:
  LDA  $00
  XBA
  LDA  $1083
  XBA
  ORA  #$005D
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1084
  XBA
  ORA  #$003D
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1085
  XBA
  ORA  #$004D
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1080
  XBA
  ORA  #$006C
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1082
  XBA
  ORA  #$005C
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1081
  XBA
  ORA  #$004C
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1088
  XBA
  ORA  #$002C
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1089
  XBA
  ORA  #$003C
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1086
  XBA
  ORA  #$000C
  TAX
  JSR    write_dsp
  LDA  $00
  XBA
  LDA  $1087
  XBA
  ORA  #$001C
  TAX
  JSR    write_dsp
rts

;----------------------------------------------------------------------------
; Starts upload to SPC addr Y and sets Y to
; 0 for use as index with spc_upload_byte.
; Preserved: X
;----------------------------------------------------------------------------
spc_begin_upload:
  STY    $2142

  ;Send command
  LDA    $2140
  CLC
  ADC    #$22
  BNE    skip		;special case fully verified
  INA
skip:
  STA    $2141
  STA    $2140

  ;Wait for acknowledgement
wait3:
  CMP    $2140
  BNE    wait3

  ;Initialize index
  LDY    #0

  rts

;----------------------------------------------------------------------------
; Uploads byte A to SPC and increments Y. The low byte
; of Y must not changed between calls.
; Preserved: X
;----------------------------------------------------------------------------
spc_upload_byte:
  STA    $2141

  ;Signal that it's ready
  TYA
  STA    $2140
  INY

  ;Wait for acknowledgement
wait4:
  CMP    $2140
  BNE    wait4

  rts

;----------------------------------------------------------------------------
; Starts executing at SPC addr Y
; Preserved: X, Y
;----------------------------------------------------------------------------
spc_execute:
  STY    $2142

  STZ    $2141

  LDA    $2140
  CLC
  ADC    #$22
  STA    $2140

  ;Wait for acknowledgement
wait5:
  CMP    $2140
  BNE    wait5

  rts

;----------------------------------------------------------------------------
; Writes high byte of X to SPC-700 DSP register in low byte of X
;----------------------------------------------------------------------------
write_dsp:
  PHX
  ;Just do a two-byte upload to $00F2-$00F3, so we
  ;set the DSP address, then write the byte into that.
  LDY    #$00F2
  JSR    spc_begin_upload
  PLA
  JSR    spc_upload_byte	;low byte of X to $F2
  PLA
  JSR    spc_upload_byte	;high byte of X to $F3
    
  rts
.ends

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

                JSR       spc_wait_boot
                
                ;Upload sample to SPC at $200
                LDY       #$0200
                JSR       spc_begin_upload
  loop:         LDA       sample,y
                JSR       spc_upload_byte
                CPY       #sample_end - sample
                BNE       loop
  
                LDA       #$7F		   ;Ch1 - Left Channel Volume
                STA       $1000
                LDA       #$7F			 ; Ch1 - Right Channel Volume
                STA       $1001
                LDA       #$00			; Ch1 - Lower 8 bits of Pitch
                STA       $1002
                LDA       #$01			; Ch1 - Higher 8 bits of Pitch
                STA       $1003
                LDA       #$00			; Ch1 - Source
                STA       $1004
                LDA       #$FF			; Ch1 - ADSR1
                STA       $1005
                LDA       #$E0			; Ch1 - ADSR2
                STA       $1006
                LDA       #$01			; Ch1 - Key ON
                STA       $1007
                LDA       #$00			; Ch1 - Pitch Modulation
                STA       $1008
                LDA       #$00			; Ch1 - Noise Enable
                STA       $1009
                LDA       #$00			; Ch1 - Echo Enable
                STA       $100A
                LDA       #$7F			; Ch2 - Left Channel Volume
                STA       $1010
                LDA  #$7F			; Ch2 - Right Channel Volume
                STA  $1011
                LDA  #$00			; Ch2 - Lower 8 bits of Pitch
                STA  $1012
                LDA  #$01			; Ch2 - Higher 8 bits of Pitch
                STA  $1013
                LDA  #$00			; Ch2 - Source
                STA  $1014
                LDA  #$FF			; Ch2 - ADSR1
                STA  $1015
                LDA  #$E0			; Ch2 - ADSR2
                STA  $1016
                LDA  #$01			; Ch2 - Key ON
                STA  $1017
                LDA  #$00			; Ch2 - Pitch Modulation
                STA  $1018
                LDA  #$00			; Ch2 - Noise Enable
                STA  $1019
                LDA  #$00			; Ch2 - Echo Enable
                STA  $101A
                LDA  #$7F			; Ch3 - Left Channel Volume
                STA  $1020
                LDA  #$7F			; Ch3 - Right Channel Volume
                STA  $1021
                LDA  #$00			; Ch3 - Lower 8 bits of Pitch
                STA  $1022
                LDA  #$01			; Ch3 - Higher 8 bits of Pitch
                STA  $1023
                LDA  #$00			; Ch3 - Source
                STA  $1024
                LDA  #$FF			; Ch3 - ADSR1
                STA  $1025
                LDA  #$E0			; Ch3 - ADSR2
                STA  $1026
                LDA  #$00			; Ch3 - Key ON
                STA  $1027
                LDA  #$00			; Ch3 - Pitch Modulation
                STA  $1028
                LDA  #$00			; Ch3 - Noise Enable
                STA  $1029
                LDA  #$00			; Ch3 - Echo Enable
                STA  $102A
                LDA  #$7F			; Ch4 - Left Channel Volume
                STA  $1030
                LDA  #$7F			; Ch4 - Right Channel Volume
                STA  $1031
                LDA  #$00			; Ch4 - Lower 8 bits of Pitch
                STA  $1032
                LDA  #$01			; Ch4 - Higher 8 bits of Pitch
                STA  $1033
                LDA  #$00			; Ch4 - Source
                STA  $1034
                LDA  #$FF			; Ch4 - ADSR1
                STA  $1035
                LDA  #$E0			; Ch4 - ADSR2
                STA  $1036
                LDA  #$00			; Ch4 - Key ON
                STA  $1037
                LDA  #$00			; Ch4 - Pitch Modulation
                STA  $1038
                LDA  #$00			; Ch4 - Noise Enable
                STA  $1039
                LDA  #$00			; Ch4 - Echo Enable
                STA  $103A
                
                LDA  #$20			; Master - DSP Flags
                STA  $1080
                LDA  #$00
                STA  $1081
                LDA  $1037
                ASL
                ASL
                ASL
                ORA  $1081
                STA  $1081
                LDA  $1027
                ASL
                ASL
                ORA  $1081
                STA  $1081
                LDA  $1017
                ASL
                ORA  $1081
                STA  $1081
                LDA  $1007
                ORA  $1081
                STA  $1081		; Master - Key On
                EOR  #$FF			; Master - Key Off
                STA  $1082
                LDA  #$02			; Master - Offset
                STA  $1083
                LDA  #$00
                STA  $1084
                LDA  $1039
                ASL
                ASL
                ASL
                ORA  $1084
                STA  $1084
                LDA  $1029
                ASL
                ASL
                ORA  $1084
                STA  $1084
                LDA  $1019
                ASL
                ORA  $1084
                STA  $1084
                LDA  $1009
                ORA  $1084
                STA  $1084		; Master - Noise
                LDA  #$00
                STA  $1085
                LDA  $103A
                ASL
                ASL
                ASL
                ORA  $1085
                STA  $1085
                LDA  $102A
                ASL
                ASL
                ORA  $1085
                STA  $1085
                LDA  $101A
                ASL
                ORA  $1085
                STA  $1085
                LDA  $100A
                ORA  $1085
                STA  $1085		; Master - Echo
                LDA  #$7F			; Master - Volume L
                STA  $1086
                LDA  #$7F			; Master - Volume R
                STA  $1087
                LDA  #$00			; Master - Echo Vol L
                STA  $1088
                LDA  #$00			; Master - Echo Vol R
                STA  $1089
                
                jsr ch1_go
                jsr ch2_go
                jsr ch3_go
                
                jsr master_go


                EnableNMI

  Forever:      WAI
  Accu_16bit
  LDA.W #$00FF
  Accu_8bit

    jsr ch1_go
    jsr ch2_go
    jsr ch3_go
                
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
