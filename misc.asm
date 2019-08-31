;---------------|---------|------------|-------------------------------------
;
; SNES DRONE Emulation ROM
; misc.asm
; Author: Michael Hirschmugl
;
; MACRO Accu_16Bit
; MACRO Accu_8Bit
; MACRO EnableNMI
; MACRO NMIIN
; MACRO NMIOUT
; MACRO ROM_2_RAM_LOOP
; MACRO ROM_2_RAM_VBLANK
; MACRO ROM_2_RAM_INTERFACE
; MACRO ZERO_HI_ACC
; MACRO EnableNMIandAutoJoypad
;
;---------------|---------|------------|-------------------------------------

;---------------|---------|------------|-------------------------------------
;
; Set Accumulator to 16 bit
;
;---------------|---------|------------|-------------------------------------
.macro Accu_16bit
                REP       #%00100000
.endm

;---------------|---------|------------|-------------------------------------
;
; Set Accumulator to 8 bit
;
;---------------|---------|------------|-------------------------------------
.macro Accu_8bit
                SEP       #%00100000
.endm

;---------------|---------|------------|-------------------------------------
;
; Enable NMI Interrupts
;
;---------------|---------|------------|-------------------------------------
.macro  EnableNMI
                LDA       #%10000000   ;If set, NMI will fire just after the start of V-Blank.
                STA       $4200        ;NMITIMEN - Interrupt Enable Flags
.endm

;---------------|---------|------------|-------------------------------------
;
; Enter NMI interrupt and save all registers
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
; Exit NMI interrupt and pull all registers
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
; Copies the main loops to RAM
; Source: ROM at 00A400 (002400) (offset of section "RAM_LOOP" in main.asm, but also
; the follwing sections "DSP_RAM_Routines" (dsp_ram_routines.asm) and "Controller_Read_Routines"
; (controller_input.asm)).
; Destination: 7F:2400 (same offset as ROM)
;
;---------------|---------|------------|-------------------------------------
.macro  ROM_2_RAM_LOOP
                LDX       #0
  LOOP_2_RAM_LOOP:
                LDA       $00A400,X
                STA       $7F2400,X
                INX
                TXA
                CMP       #$1800
                BNE       LOOP_2_RAM_LOOP
.endm

;---------------|---------|------------|-------------------------------------
;
; Copies the VBlank routine from ROM to RAM
; Source: 00A400 (002000)
; Destination: 001E00 (specified as NMI vector in header.inc, but also
; this address is manually stored again at address 004FEA and 004FEB, because
; the firmware will look there for the vector).
;
;---------------|---------|------------|-------------------------------------
.macro  ROM_2_RAM_VBLANK
                LDX       #0
  VBLA_2_RAM_LOOP:
                LDA       $00A000,X
                STA       $001E00,X
                INX
                TXA
                CMP       #$0100
                BNE       VBLA_2_RAM_LOOP
.endm

;---------------|---------|------------|-------------------------------------
;
; Copies the map an d behaviour of the GUI into RAM to make it
; modifiable by the software.
;
;---------------|---------|------------|-------------------------------------
.macro  ROM_2_RAM_INTERFACE
                LDX       #0
  INFC_2_RAM_LOOP:
                LDA       $00C800,X
                STA       $7F1000,X
                INX
                TXA
                CMP       #$01C2
                BNE       INFC_2_RAM_LOOP
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro  ZERO_HI_ACC
                LDA       $00
                XBA
.endm

;---------------|---------|------------|-------------------------------------
;
; Enables not only NMI, but also automatic reading of Joypad inputs.
;
;---------------|---------|------------|-------------------------------------
.macro  EnableNMIandAutoJoypad
                LDA       #%10000001
                STA       $4200        ;NMITIMEN - Interrupt Enable Flags
.endm

;---------------|---------|------------|-------------------------------------
;
; Reads frequency values from RAM and writes them to the tilemap
;
;---------------|---------|------------|-------------------------------------
.macro  UPDATE_FREQUENCY_GUI
                LDA       $001003
                LSR
                LSR
                LSR
                LSR
                INA
                STA       $7F4282
                LDA       $001003
                AND       #$0F
                INA
                STA       $7F4284

                LDA       $001002
                LSR
                LSR
                LSR
                LSR
                INA
                STA       $7F4286
                LDA       $001002
                AND       #$0F
                INA
                STA       $7F4288

                LDA       $001013
                LSR
                LSR
                LSR
                LSR
                INA
                STA       $7F4292
                LDA       $001013
                AND       #$0F
                INA
                STA       $7F4294

                LDA       $001012
                LSR
                LSR
                LSR
                LSR
                INA
                STA       $7F4296
                LDA       $001012
                AND       #$0F
                INA
                STA       $7F4298

                LDA       $001023
                LSR
                LSR
                LSR
                LSR
                INA
                STA       $7F42A2
                LDA       $001023
                AND       #$0F
                INA
                STA       $7F42A4

                LDA       $001022
                LSR
                LSR
                LSR
                LSR
                INA
                STA       $7F42A6
                LDA       $001022
                AND       #$0F
                INA
                STA       $7F42A8

                LDA       $001033
                LSR
                LSR
                LSR
                LSR
                INA
                STA       $7F42B2
                LDA       $001033
                AND       #$0F
                INA
                STA       $7F42B4

                LDA       $001032
                LSR
                LSR
                LSR
                LSR
                INA
                STA       $7F42B6
                LDA       $001032
                AND       #$0F
                INA
                STA       $7F42B8
.endm