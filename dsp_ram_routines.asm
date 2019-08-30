;----------------------------------------------------------------------------
; 
; SNES DRONE Emulation ROM
; dsp_ram_routines.asm
; Author: Michael Hirschmugl
;
; ROUTINE ch1_go_ram
; ROUTINE ch2_go_ram
; ROUTINE ch3_go_ram
; ROUTINE ch4_go_ram
; ROUTINE master_go_ram
; ROUTINE write_dsp_ram
; MACRO UPDATE_DSP_CH1_REGS
; MACRO UPDATE_DSP_CH2_REGS
; MACRO UPDATE_DSP_CH3_REGS
; MACRO UPDATE_DSP_CH4_REGS
; MACRO UPDATE_DSP_MASTER_CH_REGS
;
; These routines copy the values that are buffered in RAM (00:1000) to the DSP
; registers. Essentially, the master_go_ram does the same as master_go in
; dsp_stuff.asm, but not quite (TBD).
;
; The macros are simply used to launch the routines, because they are copied to RAM
; with the macro ROM_2_RAM_LOOP in misc.asm.
; It's important that these routines are stored at offset $2800 in ROM bank 0, because they
; need to have the same offset to the main routines (in RAM) after being copied to RAM.
;
; Stored in ROM at offset $2800.
;----------------------------------------------------------------------------

.bank 0
.org 10240
.section "DSP_RAM_routines" force
;---------------|---------|------------|-------------------------------------
;
; Write Channel 1 data to DSP registers
; 
;
;---------------|---------|------------|-------------------------------------
ch1_go_ram:     LDA       $00
                XBA
                LDA       $1000
                XBA
                ORA       #$0000
                TAX
                PER       ret5
                BRL       write_dsp_ram
                ret5:     NOP
                LDA       $00
                XBA
                LDA       $1001
                XBA
                ORA       #$0001
                TAX
                PER       ret6
                BRL       write_dsp_ram
                ret6:     NOP
                LDA       $00
                XBA
                LDA       $1002
                XBA
                ORA       #$0002
                TAX
                PER       ret7
                BRL       write_dsp_ram
                ret7:     NOP
                LDA       $00
                XBA
                LDA       $1003
                XBA
                ORA       #$0003
                TAX
                PER       ret8
                BRL       write_dsp_ram
                ret8:     NOP
                LDA       $00
                XBA
                LDA       $1004
                XBA
                ORA       #$0004
                TAX
                PER       ret9
                BRL       write_dsp_ram
                ret9:     NOP
                LDA       $00
                XBA
                LDA       $1005
                XBA
                ORA       #$0005
                TAX
                PER       ret10
                BRL       write_dsp_ram
                ret10:     NOP
                LDA       $00
                XBA
                LDA       $1006 
                XBA
                ORA       #$0006
                TAX
                PER       ret11
                BRL       write_dsp_ram
                ret11:     NOP
                RTS

;---------------|---------|------------|-------------------------------------
;
; Write Channel 2 Data
;
;---------------|---------|------------|-------------------------------------
ch2_go_ram:     LDA       $00
                XBA
                LDA       $1010
                XBA
                ORA       #$0010
                TAX
                PER       ret12
                BRL       write_dsp_ram
                ret12:     NOP
                LDA       $00
                XBA
                LDA       $1011
                XBA
                ORA       #$0011
                TAX
                PER       ret13
                BRL       write_dsp_ram
                ret13:     NOP
                LDA       $00
                XBA
                LDA       $1012
                XBA
                ORA       #$0012
                TAX
                PER       ret14
                BRL       write_dsp_ram
                ret14:     NOP
                LDA       $00
                XBA
                LDA       $1013
                XBA
                ORA       #$0013
                TAX
                PER       ret15
                BRL       write_dsp_ram
                ret15:     NOP
                LDA       $00
                XBA
                LDA       $1014
                XBA
                ORA       #$0014
                TAX
                PER       ret16
                BRL       write_dsp_ram
                ret16:     NOP
                LDA       $00
                XBA
                LDA       $1015
                XBA
                ORA       #$0015
                TAX
                PER       ret17
                BRL       write_dsp_ram
                ret17:     NOP
                LDA       $00
                XBA
                LDA       $1016
                XBA
                ORA       #$0016
                TAX
                PER       ret18
                BRL       write_dsp_ram
                ret18:     NOP
                RTS

;---------------|---------|------------|-------------------------------------
;
; Write Channel 3 Data
;
;---------------|---------|------------|-------------------------------------
ch3_go_ram:     RTS

;---------------|---------|------------|-------------------------------------
;
; Write Channel 4 Data
;
;---------------|---------|------------|-------------------------------------
ch4_go_ram:     RTS

;---------------|---------|------------|-------------------------------------
;
; Write Master Channel Data
;
;---------------|---------|------------|-------------------------------------
master_go_ram:  
                ;LDA       $00
                ;XBA
                ;LDA       $001007        ;CH1 Key ON?
                ;ORA       $001017        ;CH2 Key ON?
                ;ORA       $001027        ;CH3 Key ON?
                ;ORA       $001037        ;CH4 Key ON?
                ;STA       $001081        ;Store at Key ON Master Buffer

                ;LDA       $00
                ;XBA
                ;LDA       $1007        ;CH1 Key ON?
                ;EOR       #1
                ;ORA       $1017        ;CH2 Key ON?
                ;EOR       #2
                ;ORA       $1027        ;CH3 Key ON?
                ;EOR       #4
                ;ORA       $1037        ;CH4 Key ON?
                ;EOR       #8
                ;STA       $1082        ;Store at Key OFF Master Buffer
                
                LDA       $00
                XBA
                LDA       $1086
                XBA
                ORA       #$000C        ; Master Volume Left
                TAX
                PER       ret27
                BRL       write_dsp_ram
                ret27:     NOP
                LDA       $00
                XBA
                LDA       $1087
                XBA
                ORA       #$001C        ; Master Volume Right
                TAX
                PER       ret28
                BRL       write_dsp_ram
                ret28:     NOP
                RTS

;---------------|---------|------------|-------------------------------------
;
; Writes X to SPC-700 DSP register
; This is a copy of a routine in dsp_stuff.asm (altered for usage from RAM)
;
;---------------|---------|------------|-------------------------------------
write_dsp_ram:  PHX
                ;Just do a two-byte upload to $00F2-$00F3, so we
                ;set the DSP address, then write the byte into that.
                LDY       #$00F2
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
                PLA
                STA       $2141

                ;Signal that it's ready
                ;Write 0 for first write
                TYA
                STA       $2140
                INY

                ;Wait for acknowledgement (same value as written)
  wait4_ram:    CMP       $2140
                BNE       wait4_ram
                PLA
                STA       $2141

                ;Signal that it's ready
                ;Write 0 for first write
                TYA
                STA       $2140
                INY

                ;Wait for acknowledgement (same value as written)
  wait5_ram:    CMP       $2140
                BNE       wait5_ram
                RTS
.ends

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro  UPDATE_DSP_CH1_REGS
                PER       ret0
                BRL       ch1_go_ram
                ret0:     NOP
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro  UPDATE_DSP_CH2_REGS
                PER       ret1
                BRL       ch2_go_ram
                ret1:     NOP
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro  UPDATE_DSP_CH3_REGS
                PER       ret2
                BRL       ch3_go_ram
                ret2:     NOP
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro  UPDATE_DSP_CH4_REGS
                PER       ret3
                BRL       ch4_go_ram
                ret3:     NOP
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro  UPDATE_DSP_MASTER_CH_REGS
                PER       ret4
                BRL       master_go_ram
                ret4:     NOP
.endm