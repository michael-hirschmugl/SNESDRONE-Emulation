.bank 0
.section "DSPRAMroutines"
;---------------|---------|------------|-------------------------------------
;
; Starts upload to SPC
;
;---------------|---------|------------|-------------------------------------
spc_begin_upload_ram:
                STY       $2142

                ;Send command
                LDA       $2140
                CLC
                ADC       #$22
                BNE       skip_ram     ;special case fully verified
                INA
  skip_ram:     STA       $2141
                STA       $2140

                ;Wait for acknowledgement
  wait3_ram:    CMP       $2140
                BNE       wait3_ram

                ;Initialize index
                LDY       #0
                RTS

;---------------|---------|------------|-------------------------------------
;
; Uploads byte A to SPC and increments Y.
;
;---------------|---------|------------|-------------------------------------
spc_upload_byte_ram:
                STA       $2141

                ;Signal that it's ready
                ;Write 0 for first write
                TYA
                STA       $2140
                INY

                ;Wait for acknowledgement (same value as written)
  wait4_ram:    CMP       $2140
                BNE       wait4_ram
                RTS

;---------------|---------|------------|-------------------------------------
;
; Writes X to SPC-700 DSP register
;
;---------------|---------|------------|-------------------------------------
write_dsp_ram:  PHX
                ;Just do a two-byte upload to $00F2-$00F3, so we
                ;set the DSP address, then write the byte into that.
                LDY       #$00F2
                JSR       spc_begin_upload_ram
                PLA
                JSR       spc_upload_byte_ram ;low byte of X to $F2
                PLA
                JSR       spc_upload_byte_ram ;high byte of X to $F3
                RTS

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
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1001
                XBA
                ORA       #$0001
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1002
                XBA
                ORA       #$0002
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1003
                XBA
                ORA       #$0003
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1004
                XBA
                ORA       #$0004
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1005
                XBA
                ORA       #$0005
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1006 
                XBA
                ORA       #$0006
                TAX
                JSR       write_dsp_ram
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
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1011
                XBA
                ORA       #$0011
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1012
                XBA
                ORA       #$0012
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1013
                XBA
                ORA       #$0013
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1014
                XBA
                ORA       #$0014
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1015
                XBA
                ORA       #$0015
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1016
                XBA
                ORA       #$0016
                TAX
                JSR       write_dsp_ram
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
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1084
                XBA
                ORA       #$003D
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1085
                XBA
                ORA       #$004D
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1080
                XBA
                ORA       #$006C
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1082
                XBA
                ORA       #$005C
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1081
                XBA
                ORA       #$004C
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1088
                XBA
                ORA       #$002C
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1089
                XBA
                ORA       #$003C
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1086
                XBA
                ORA       #$000C
                TAX
                JSR       write_dsp_ram
                LDA       $00
                XBA
                LDA       $1087
                XBA
                ORA       #$001C
                TAX
                JSR       write_dsp_ram
                RTS
.ends