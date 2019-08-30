;----------------------------------------------------------------------------
; 
; SNES DRONE Emulation ROM
; dsp_stuff.asm
;
; ROUTINE spc_wait_boot
; ROUTINE spc_begin_upload
; ROUTINE spc_upload_byte
; ROUTINE write_dsp
; ROUTINE master_go
; MACRO UPDATE_DSP_RAM_REGS
;
; All these routines are executed from ROM and stored at
; offset $1000 ($9000).
;
; Author: Michael Hirschmugl
;
;----------------------------------------------------------------------------
.bank 0
.org 4096
.section "DSPstuff" force
.include "sample_data.asm"
;---------------|---------|------------|-------------------------------------
;
; Waits for SPC to finish booting
;
;---------------|---------|------------|-------------------------------------
spc_wait_boot:  LDA       #$AA
  wait1:        CMP       $2140
                BNE       wait1

                LDA       #$BB
  wait2:        CMP       $2141
                BNE       wait2

                RTS

;---------------|---------|------------|-------------------------------------
;
; Starts upload to SPC
;
;---------------|---------|------------|-------------------------------------
spc_begin_upload:
                STY       $2142

                ;Send command
                LDA       $2140
                CLC
                ADC       #$22
                BNE       skip         ;special case fully verified
                INA
  skip:         STA       $2141
                STA       $2140

                ;Wait for acknowledgement
  wait3:        CMP       $2140
                BNE       wait3

                ;Initialize index
                LDY       #0
                RTS

;---------------|---------|------------|-------------------------------------
;
; Uploads byte A to SPC and increments Y.
;
;---------------|---------|------------|-------------------------------------
spc_upload_byte:
                STA       $2141

                ;Signal that it's ready
                ;Write 0 for first write
                TYA
                STA       $2140
                INY

                ;Wait for acknowledgement (same value as written)
  wait4:        CMP       $2140
                BNE       wait4
                RTS

;---------------|---------|------------|-------------------------------------
;
; Writes X to SPC-700 DSP register
;
;---------------|---------|------------|-------------------------------------
write_dsp:      PHX
                ;Just do a two-byte upload to $00F2-$00F3, so we
                ;set the DSP address, then write the byte into that.
                LDY       #$00F2
                JSR       spc_begin_upload
                PLA
                JSR       spc_upload_byte ;low byte of X to $F2
                PLA
                JSR       spc_upload_byte ;high byte of X to $F3
                RTS

;---------------|---------|------------|-------------------------------------
;
; Write Master Channel Data
; Reads values from DSP register buffer in RAM and copies them to the DSP
; registers.
; This is used for initialization.
;
; https://wiki.superfamicom.org/spc700-reference#toc-47
;
;---------------|---------|------------|-------------------------------------
master_go:      LDA       $00
                XBA
                LDA       $1083        ; Master Offset
                XBA
                ORA       #$005D       ; Offset of source directory (DIR*100h = memory offset)
                TAX
                JSR       write_dsp

                LDA       $00
                XBA
                LDA       $1084        ; Master Noise
                XBA
                ORA       #$003D       ; Noise enable
                TAX
                JSR       write_dsp

                LDA       $00
                XBA
                LDA       $1085        ; Master Echo
                XBA
                ORA       #$004D       ; Echo enable
                TAX
                JSR       write_dsp

                LDA       $00
                XBA
                LDA       $1080        ; Master DSP Flags
                XBA
                ORA       #$006C       ; DSP Flags. (used for MUTE,ECHO,RESET,NOISE CLOCK)
                TAX
                JSR       write_dsp
                    ;RESET: Soft reset. Writing a '1' here will set all voices in a state of 
                    ;"Key-On suspension" (???). MUTE is also set. A soft-reset gets triggered upon power-on.
                    ;MUTE: Mutes all channel output.
                    ;ECEN: ~Echo enable. A '0' here enables echo data to be written into external memory
                    ;(the memory your program/data is in!). Be careful when enabling it, it's quite easy to
                    ;crash your program with the echo hardware!
                    ;NOISE CLOCK: Designates the frequency for the white noise.

                LDA       $00
                XBA
                LDA       $1082        ; Master Key OFF
                XBA
                ORA       #$005C       ; Key Off (1 bit for each voice)
                TAX
                JSR       write_dsp

                LDA       $00
                XBA
                LDA       $1081        ; Master Key ON
                XBA
                ORA       #$004C       ; Key On (1 bit for each voice)
                TAX
                JSR       write_dsp

                LDA       $00
                XBA
                LDA       $1088        ; Master Echo Volume Left
                XBA
                ORA       #$002C       ; Echo Volume (left output)
                TAX
                JSR       write_dsp

                LDA       $00
                XBA
                LDA       $1089        ; Master Echo Volume Right
                XBA
                ORA       #$003C       ; Echo Volume (right output)
                TAX
                JSR       write_dsp

                LDA       $00
                XBA
                LDA       $1086        ; Master Main Volume Left
                XBA
                ORA       #$000C       ; Main Volume (left output)
                TAX
                JSR       write_dsp

                LDA       $00
                XBA
                LDA       $1087         ; Master Main Volume Right
                XBA
                ORA       #$001C        ; Main Volume (right output)
                TAX
                JSR       write_dsp
                RTS

.ends

;---------------|---------|------------|-------------------------------------
;
; This macro fetched DSP values from the MCU (ROM) and stores them in 
; the DSP register buffer at $00:1000 in RAM.
;
; values fetched from MCU:
; ch1 vol L
; ch1 vol R
; ch1 LO 8bit PITCH
; ch1 HI 8bit PITCH
; ch2 vol L
; ch2 vol R
; ch2 LO 8bit PITCH
; ch2 HI 8bit PITCH
; ch3 vol L
; ch3 vol R
; ch3 LO 8bit PITCH
; ch3 HI 8bit PITCH
; ch4 vol L
; ch4 vol R
; ch4 LO 8bit PITCH
; ch4 HI 8bit PITCH
; Master Volume Left
; Master Volume Right
;
;---------------|---------|------------|-------------------------------------
.macro  UPDATE_DSP_RAM_REGS
                LDX       #2

                LDY       #0
  DSP_ARRAY_I1: LDA       $00C400,X
                STA       $1000,Y
                INX
                INY
                TXA
                CMP       #5           ; For now, only fetch values for volume and frequency
                BNE       DSP_ARRAY_I1

                LDX       #12
                LDY       #0
  DSP_ARRAY_I2: LDA       $00C400,X
                STA       $100F,Y
                INX
                INY
                TXA
                CMP       #15
                BNE       DSP_ARRAY_I2

                LDX       #23
                LDY       #0
  DSP_ARRAY_I3: LDA       $00C400,X
                STA       $101F,Y
                INX
                INY
                TXA
                CMP       #26
                BNE       DSP_ARRAY_I3

                LDX       #34
                LDY       #0
  DSP_ARRAY_I4: LDA       $00C400,X
                STA       $102F,Y
                INX
                INY
                TXA
                CMP       #37
                BNE       DSP_ARRAY_I4

                ;LDX       #45
                ;LDY       #0
                LDX       #52
                LDY       #7

;This is for the whole Master section
;But in this configuration, it's only for volume
  DSP_ARRAY_I5: LDA       $00C400,X
                STA       $107F,Y
                INX
                INY
                TXA
                CMP       #54
                BNE       DSP_ARRAY_I5
.endm