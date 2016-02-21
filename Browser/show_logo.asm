	;************* first and second row *********

	lda #60 		;wait for raster
-	cmp $d012
	bne -

	lda #%11101110
	sta $d010	;sprite-x in second page

	;set sprite pointers
	ldx #$00
	lda #spriteBase/$40
-	sta $07f8,x
	clc
	adc #$01 
	inx 
	cpx #08
	bne -

	;set spriteX
	ldx #$00
	ldy #$00
-	lda spriteX,x
	sta $d000,y
	sta $d008,y
	iny
	iny
	inx
	cpx #04
	bne -

	lda spriteY+0
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	lda spriteY+1
	sta $d009
	sta $d00b
	sta $d00d
	sta $d00f

	;********* third row *********
	lda #108 		;wait for raster
-	cmp $d012
	bne -

	;set sprite pointers
	ldx #$00
	lda #spriteBase/$40+8
-	sta $07f8,x
	clc
	adc #$01 
	inx 
	cpx #08
	bne -

	;set sprite X
	ldx #$00
	ldy #$00
-	lda spriteX,x
	sta $d000,y
	sta $d008,y
	iny
	iny
	inx
	cpx #04
	bne -

	dec $d000 	;mind the gap
	dec $d000
	dec $d008
	dec $d008

	;set sprite Y
	lda spriteY+2
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	lda spriteY+3
	sta $d009	
	sta $d00b
	sta $d00d
	sta $d00f

	;********* Fifth & eight row *********
	lda #154 		;wait for raster
-	cmp $d012
	bne -

	lda #%1110110
	sta $d010

	ldx #$00
	lda #spriteBase/$40+16
-	sta $07f8,x
	clc
	adc #$01 
	inx 
	cpx #08
	bne -

	;set sprite X
	ldx #$00
	ldy #$00
-	lda spriteX,x
	sta $d000,y
	sta $d006,y
	iny
	iny
	inx
	cpx #03
	bne -

	lda spriteY+4
	sta $d001
	sta $d003
	sta $d005
	lda spriteY+5
	sta $d007
	sta $d009
	sta $d00b
