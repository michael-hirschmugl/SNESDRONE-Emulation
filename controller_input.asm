.ENUM $0F00
Joy1Raw     DW      ; Holder of RAW joypad data from register (from last frame)

Joy1Press   DW      ; Contains only pressed buttons (not held down)

Joy1Held    DW      ; Contains only buttons that are Held

.ENDE

; Joypad defines
; $4218
.EQU Button_A		$80
.EQU Button_X		$40
.EQU Button_L		$20
.EQU Button_R		$10
; $4219
.EQU Button_B		$80
.EQU Button_Y		$40
.EQU Button_Select	$20
.EQU Button_Start	$10
.EQU Button_Up		$08
.EQU Button_Down	$04
.EQU Button_Left	$02
.EQU Button_Right	$01

;---------------|---------|------------|-------------------------------------
;
; 
; 
;
;---------------|---------|------------|-------------------------------------
.bank 0
.org 14336
.section "Controller_Input_Routines" force

Joypad_Ready:   LDA       $4212
                AND       #$01
                BNE       Joypad_Ready
                Accu_16bit
                LDX       Joy1Raw
                LDA       $4218
                STA       Joy1Raw
                TXA
                EOR       Joy1Raw
                AND       Joy1Raw
                STA       Joy1Press
                TXA
                AND       Joy1Raw
                STA       Joy1Held
                Accu_8bit
  Skip_Joypad:  RTS
.ends

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro  READ_CONTROLLER_1
                PER       ret30
                BRL       Joypad_Ready
                ret30:     NOP
.endm