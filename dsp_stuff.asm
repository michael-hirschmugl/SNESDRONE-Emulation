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
;
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
                CMP       #12
                BNE       DSP_ARRAY_I1
                LDY       #0
  DSP_ARRAY_I2: LDA       $00C400,X
                STA       $100F,Y
                INX
                INY
                TXA
                CMP       #23
                BNE       DSP_ARRAY_I2
                LDY       #0
  DSP_ARRAY_I3: LDA       $00C400,X
                STA       $101F,Y
                INX
                INY
                TXA
                CMP       #34
                BNE       DSP_ARRAY_I3
                LDY       #0
  DSP_ARRAY_I4: LDA       $00C400,X
                STA       $102F,Y
                INX
                INY
                TXA
                CMP       #45
                BNE       DSP_ARRAY_I4
                LDY       #0
  DSP_ARRAY_I5: LDA       $00C400,X
                STA       $107F,Y
                INX
                INY
                TXA
                CMP       #55
                BNE       DSP_ARRAY_I5
.endm