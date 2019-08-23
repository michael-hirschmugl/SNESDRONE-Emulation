.bank 0
.section "DSPstuff"
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
.ends