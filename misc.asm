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