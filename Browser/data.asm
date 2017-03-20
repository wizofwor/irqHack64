;-------------------------------------------------------
; INITIAL SCREEN
;-------------------------------------------------------

repeat_bytes:
!by $02,$01,$17,$01,$0d
!by $02,$01,$17,$01,$0d
!by $02,$01,$16,$01,$01,$0d
!for n,1,21 {!by $02,$01,$16,$01,$01,$0d}
!by $02,$01,$17,$01,$0F
!by $00

char_bytes:
!by $00,$40,$41,$42,$00
!by $00,$43,$53,$44,$00
!by $00,$45,$49,$4a,$46,$00
!for n,1,21 {!by $00,$47,$20,$4b,$48,$00}
!by $00,$50,$51,$52,$00

color_bytes:
!by $00,$01,$0d,$01,$00
!by $00,$0d,$05,$0d,$00
!by $00,$0d,$0f,$0b,$0d,$00
!for n,1,21 {!by $00,$0d,$0f,$0b,$0d,$00}
!by $00,$05,$0d,$0d,$00,$00

* = $3000 ;walkaround for is segment override problem 



;-------------------------------------------------------
; Test Data
;-------------------------------------------------------

title:
!scr "/micro sd       "
;text:
;!scr " menu item 12345"

;lookup:
;!by 4,44,84,214

menuState:
!by 0			; Menu state (0 = Launched, 1 = Got list from micro)


;-------------------------------------------------------
; Fixed Adress Data
;-------------------------------------------------------
* = $2140
spriteBase:
!bin "resources/sprites2.bin",192

* = music
!bin "resources/Jamaica_10_intro.sid",3167-($7c+2),$7c+2

* = $2800
charset_data:
!bin "resources/charset.bin",1000
FINAL:

* = $2BEF
!by $EA