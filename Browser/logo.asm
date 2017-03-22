;===============================================================================
; logo.asm
; display sprite logo
;===============================================================================
!zone {	
initializeLogo:
	; Set Sprites
	lda #%00000111	
	sta $d015		;enable Sprite0,1,2
	sta $d01c		;enable multicolor for all

	lda #$00		;undo sprite extend
	sta $d017
	sta $d01d

	lda #$01 		;set sprite multicolor 1
	sta $d025	

	lda #$06 		;set sprite multicolor 2
	sta $d026

	ldx #$03		;set sprite colors
	lda #$0e
-	sta $d026,x
	dex
	bne -

	lda #%00000000 		;set Sprite-x
	sta $d010		
	lda #$1b
	sta $d000
	sta $d002
	sta $d004

	lda #$00
	sta spAnimationCounter

	lda #spriteBase/$40 	;set sprite pointers
	sta $07f8
	lda #spriteBase/$40+1
	sta $07f9
	lda #spriteBase/$40+2
	sta $07fa

	rts
;===============================================================================
updateLogo:	

; Increment animation counter
	inc spAnimationCounter
	lda spAnimationCounter
	cmp #64
	bne +
	lda #00
	sta spAnimationCounter
+	
	ldx spAnimationCounter

.moveSprites:
	lda #60 	;wait for raster
-	cmp $d012
	bne -

	; set sprite Y
	lda spriteY+0
	ldy spriteY+1
	jsr .setSpriteY

; Color wash effect
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



.end
	rts


;=========================================================================
; Subroutines 

.setSpriteY	
	lda spriteY,x
	sta $d001
	sec
	sbc #21
	sta $d003
	sec
	sbc #22
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

spriteY:
!for i,0,64 {
!by int(sin((float(i))/64*3.14*2)*5+110)
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