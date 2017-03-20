;###############################################################################
; show_logo.asm
; display sprite logo
;###############################################################################
!zone show_logo {
updateLogo:	
;increment animation counter
	inc spAnimationCounter
	lda spAnimationCounter
	cmp #64
	bne +
	lda #00
	sta spAnimationCounter
+	
	ldx spAnimationCounter

;color wash effect
	inc spColorWashCounter
	lda spColorWashCounter
	cmp #128
	bne +
	lda #00
	sta spColorWashCounter
+	
	ldx spColorWashCounter
	lda spColorOffset,x
	tax

	lda spColor1,x 	;set sprite multicolor 1
	sta $d025	

	lda spColor2,x 	;set sprite multicolor 2
	sta $d026

	ldy #$08	;set sprite colors
	lda spColor3,x
-	sta $d026,y
	dey
	bne -

; Move Sprites
	lda #60 	;wait for raster
-	cmp $d012
	bne -

	;set spriteX
	lda #$19
	jsr .setSpriteX

	;set sprite Y
	lda spriteY+0
	ldy spriteY+1
	jsr .setSpriteY

.end
	rts  ;skip subroutines

;=========================================================================
; Subroutines 
;=========================================================================
.setSpriteX
	sta $d000
	sta $d002
	sta $d004
	rts

	ldx #$00
	ldy #$00
-	clc
	lda spriteX,x
	adc var1 
	sta $d000,y
	sta $d008,y
	iny
	iny
	inx
	cpx #04
	bne -
	rts

.setSpriteY	
	lda spriteY,x
	sta $d001
	sec
	sbc #23
	lda spriteY,x
	sbc #23
	sta $d003
	sbc #23
	sta $d005
	rts

.setSpritePointers
	ldx #$00
	;lda #spriteBase/$40
-	sta $07f8,x
	clc
	adc #$01 
	inx 
	cpx #03
	bne -	
	rts

}

;=========================================================================
; Data Part 
;=========================================================================

spriteX:
!by 232,0,24,48

;spriteY:
;!by 65,86,112,132,160,181

spriteY:
!for i,0,64 {
!by int(sin((float(i))/64*3.14*2)*126.5+126.5)
}

spColorOffset:
!by 3,2,2,2,1,1,1,1,0,0,0,0,0,0,0,0
!by 0,0,0,0,0,0,0,0,0,1,1,1,1,2,2,2
!by 3,3,3,4,4,4,4,5,5,5,5,5,5,5,5,5
!by 5,5,5,5,5,5,5,5,4,4,4,4,3,3,3,3
!fill 65,0

spColor1: !by 1,1,15,12,11,0
spColor2: !by 6,6,6,11,11,0
spColor3: !by 14,14,4,12,11,0