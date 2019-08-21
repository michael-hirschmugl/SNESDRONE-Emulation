;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro InitDSPch1
                LDA       #$7F         ;Ch1 - Left Channel Volume
                STA       $1000
                LDA       #$7F         ;Ch1 - Right Channel Volume
                STA       $1001
                LDA       #$00         ;Ch1 - Lower 8 bits of Pitch
                STA       $1002
                LDA       #$01         ;Ch1 - Higher 8 bits of Pitch
                STA       $1003
                LDA       #$00         ;Ch1 - Source
                STA       $1004
                LDA       #$FF         ;Ch1 - ADSR1
                STA       $1005
                LDA       #$E0         ;Ch1 - ADSR2
                STA       $1006
                LDA       #$01         ;Ch1 - Key ON
                STA       $1007
                LDA       #$00         ;Ch1 - Pitch Modulation
                STA       $1008
                LDA       #$00         ;Ch1 - Noise Enable
                STA       $1009
                LDA       #$00         ;Ch1 - Echo Enable
                STA       $100A
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro InitDSPch2
                LDA       #$7F         ;Ch2 - Left Channel Volume
                STA       $1010
                LDA       #$7F         ;Ch2 - Right Channel Volume
                STA       $1011
                LDA       #$00         ;Ch2 - Lower 8 bits of Pitch
                STA       $1012
                LDA       #$01         ;Ch2 - Higher 8 bits of Pitch
                STA       $1013
                LDA       #$00         ;Ch2 - Source
                STA       $1014
                LDA       #$FF         ;Ch2 - ADSR1
                STA       $1015
                LDA       #$E0         ;Ch2 - ADSR2
                STA       $1016
                LDA       #$01         ;Ch2 - Key ON
                STA       $1017
                LDA       #$00         ;Ch2 - Pitch Modulation
                STA       $1018
                LDA       #$00         ;Ch2 - Noise Enable
                STA       $1019
                LDA       #$00         ;Ch2 - Echo Enable
                STA       $101A
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro InitDSPch3
                LDA       #$7F         ;Ch3 - Left Channel Volume
                STA       $1020
                LDA       #$7F         ;Ch3 - Right Channel Volume
                STA       $1021
                LDA       #$00         ;Ch3 - Lower 8 bits of Pitch
                STA       $1022
                LDA       #$01         ;Ch3 - Higher 8 bits of Pitch
                STA       $1023
                LDA       #$00         ;Ch3 - Source
                STA       $1024
                LDA       #$FF         ;Ch3 - ADSR1
                STA       $1025
                LDA       #$E0         ;Ch3 - ADSR2
                STA       $1026
                LDA       #$00         ;Ch3 - Key ON
                STA       $1027
                LDA       #$00         ;Ch3 - Pitch Modulation
                STA       $1028
                LDA       #$00         ;Ch3 - Noise Enable
                STA       $1029
                LDA       #$00         ;Ch3 - Echo Enable
                STA       $102A
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro InitDSPch4
                LDA       #$7F         ;Ch4 - Left Channel Volume
                STA       $1030
                LDA       #$7F         ;Ch4 - Right Channel Volume
                STA       $1031
                LDA       #$00         ;Ch4 - Lower 8 bits of Pitch
                STA       $1032
                LDA       #$01         ;Ch4 - Higher 8 bits of Pitch
                STA       $1033
                LDA       #$00         ;Ch4 - Source
                STA       $1034
                LDA       #$FF         ;Ch4 - ADSR1
                STA       $1035
                LDA       #$E0         ;Ch4 - ADSR2
                STA       $1036
                LDA       #$00         ;Ch4 - Key ON
                STA       $1037
                LDA       #$00         ;Ch4 - Pitch Modulation
                STA       $1038
                LDA       #$00         ;Ch4 - Noise Enable
                STA       $1039
                LDA       #$00         ;Ch4 - Echo Enable
                STA       $103A
.endm

;---------------|---------|------------|-------------------------------------
;
;
;
;---------------|---------|------------|-------------------------------------
.macro InitDSPmaster
                LDA       #$20         ;Master - DSP Flags
                STA       $1080
                LDA       #$00
                STA       $1081
                LDA       $1037
                ASL
                ASL
                ASL
                ORA       $1081
                STA       $1081
                LDA       $1027
                ASL
                ASL
                ORA       $1081
                STA       $1081
                LDA       $1017
                ASL
                ORA       $1081
                STA       $1081
                LDA       $1007
                ORA       $1081
                STA       $1081        ;Master - Key On
                EOR       #$FF         ;Master - Key Off
                STA       $1082
                LDA       #$02         ;Master - Offset
                STA       $1083
                LDA       #$00
                STA       $1084
                LDA       $1039
                ASL
                ASL
                ASL
                ORA       $1084
                STA       $1084
                LDA       $1029
                ASL
                ASL
                ORA       $1084
                STA       $1084
                LDA       $1019
                ASL
                ORA       $1084
                STA       $1084
                LDA       $1009
                ORA       $1084
                STA       $1084        ;Master - Noise
                LDA       #$00
                STA       $1085
                LDA       $103A
                ASL
                ASL
                ASL
                ORA       $1085
                STA       $1085
                LDA       $102A
                ASL
                ASL
                ORA       $1085
                STA       $1085
                LDA       $101A
                ASL
                ORA       $1085
                STA       $1085
                LDA       $100A
                ORA       $1085
                STA       $1085        ;Master - Echo
                LDA       #$7F         ;Master - Volume L
                STA       $1086
                LDA       #$7F         ;Master - Volume R
                STA       $1087
                LDA       #$00         ;Master - Echo Vol L
                STA       $1088
                LDA       #$00         ;Master - Echo Vol R
                STA       $1089
.endm