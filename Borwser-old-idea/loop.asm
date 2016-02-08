mainLoop:
	;inc $d020
	jsr musicPlay 	;play music
	;dec $d020

	inc $07f8 		;set sprite pointers to
 	inc $07f9 		;null data
 	inc $07fa
 	inc $07fb
 	inc $07fc
 	inc $07fd
 	inc $07fe
 	inc $07ff

	;-----------------------------------------------------------
	; Part 1 - logo
	;-----------------------------------------------------------
 	lda #55 ;wait for raster
-	cmp $d012
	bne -

	lda #$01
	sta $d021

	lda #$1b		;set VIC pointers
	sta $d018 		;screen ram is at $0400, charset is at $2800-$2fff

	lda #$18 		;switch to multicolor
	ora $d016
	sta $d016


	;-----------------------------------------------------------
	; Part 2 - menu
	;-----------------------------------------------------------
	lda #98 ;wait for raster
- 	cmp $d012
 	bne -

 	ldy #08 	;loose time to hide 
- 	dey 		;flickering
 	bne -

 	dec $07f8 	;set sprite pointers
 	dec $07f9 	;to filled data
 	dec $07fa
 	dec $07fb
 	dec $07fc
 	dec $07fd
 	dec $07fe
 	dec $07ff

 	lda #$0c
 	sta $d021

	lda #$1d	;set VIC pointers
	sta $d018 	;screen ram is at $0400, charset is at $3000-$27ff

	lda #$08	;switch to hires
	and $d016
	sta $d016

	;----------/ Sprite multiplexer /---------------------------
	lda #0
	sta COUNTER
	;*** Shift sprites vertically ***
    ldx #00 			; X = spriteNum
    
- 	sec					; decrease
	lda spritex,x 		; sprite-x
	sbc #01 			; by 1
	sta spritex,x

	bcs + 				;if carry is set change the page		
	lda $d010 			
	eor bitTable,x
	sta $d010

	lda bitTable,x 		;if sprite is not in page 2
	bit $d010 			;skip to +
	beq +
	lda #$f7 			;if sprite in page 2 
	sta spritex,x 		;set sprite-x to $f7
+	
	;if sprite-x is between 80-200 in page to, make it = 80  
	lda bitTable,x 		;if sprite is not in page 2
	bit $d010 			;skip to +
	beq +

	lda spritex,x 		;if x-pos<80 		
	cmp #80 			;skip to +
	bcc +
	cmp #200 			;if x-pos>200
	bcs + 				;skip to +

	lda #80 			;x-pos = 80
	sta spritex,x
+
	inx 				;repeat the loop
    cpx #8 				;for 8 sprites
 	bne -

	;*** Update Sprite-x ***
 	ldx #00
 	ldy #00
- 	lda spritex,x
 	sta $d000,y
 	inx
 	iny
 	iny
 	cpx #08
 	bne -

	;*** Copy sprites for repeating rows ***

raster_loop:
	ldx COUNTER 		;read target raster
	lda rowTable,x 		;from table
	clc 				;and add offset
 	adc OFFSET
 	sta TARGET_RASTER

 	lda TARGET_RASTER 	;wait for target raster
- 	cmp $d012
 	bne -

 	;inc $d020

 	lda spritey,x 		;load sprite-y from table
 	clc 				;and add offset
 	adc OFFSET 		

 	ldy #00 			;update sprite-y
- 	sta $d001,y
 	iny
 	iny
 	cpy #16
 	bne -	

    inc COUNTER 		;increase counter
    lda COUNTER 		;then loop
    cmp #5
    bne raster_loop

    ;*** update sprites for top row ***
 	lda spritey+5 		;load sprite-y from table
 	clc 				;and add offset
 	adc OFFSET

 	ldy #00 			;update sprite-y
- 	sta $d001,y
 	iny
 	iny
 	cpy #16
 	bne -	

    ;*** update vertical offset ***
    dec OFFSET
    bne +
    lda #30
    sta OFFSET
+
	;***End of effect loop***    
    lda #0
    sta $d020

	jmp mainLoop

rowTable: 	!by 110,140,170,200,230 			;Raster rows for sprite effect
spritey: 	!by 115,145,175,205,235,85 			
spritex:	!by 0,48,96,144,194,242,32,80
bitTable:	!by 1,2,4,8,16,32,64,128