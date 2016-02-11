;sprite_data:
;	!bin "resources/skull.bin",3*21

initialText:
!scr " irqhack64 menu"

* = $2140
!bin "resources/sprites.bin",1536

* = music
!bin "resources/First_Dreams.sid",4370,$7c+2

* = $2800
charset_data:
!bin "resources/charset.bin"

;-------------------------------------------------------
; INITIAL SCREEN
;-------------------------------------------------------

filler_bytes:
!by $40,$41,$42,$00
!by $43,$2f,$13,$04,$2d,$03,$01,$12,$04,$2f,$53,$44,$00
!by $45,$49,$4a,$46,$00
!for n,21 {!by $47,$1b,$4b,$48,$00}
!by $50,$51,$52,$00
!by $00

repeat_bytes:
!by $01,$17,$01,$0f
!by $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$0e,$01,$0f
!by $01,$16,$01,$01,$0f
!for n,21 {!by $01,$16,$01,$01,$0f}
!by $01,$17,$01,$0f,$01
!by $00