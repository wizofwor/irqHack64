mainLoop:
	;inc $d020
	jsr musicPlay 	;play music
	;dec $d020

	;-----------------------------------------------------------
	; Part 1 - logo
	;-----------------------------------------------------------
 	lda #65 ;wait for raster
-	cmp $d012
	bne -

	lda #66
-	cmp $d012
	bne -

	lda #$00
	sta $d021

	lda #$1b		;set VIC pointers
	sta $d018 		;screen ram is at $0400, charset is at $2800-$2fff

	lda #$18 		;switch to multicolor
	ora $d016
	sta $d016

	lda #$01
	sta $d021


	;-----------------------------------------------------------
	; Part 2 - menu
	;-----------------------------------------------------------
	lda #98 ;wait for raster
- 	cmp $d012
 	bne -

 	ldy #08 	;loose time to hide 
- 	dey 		;flickering
 	bne -

	lda #$1d	;set VIC pointers
	sta $d018 	;screen ram is at $0400, charset is at $3000-$27ff

	lda #$08	;switch to hires
	and $d016
	sta $d016


+

	jmp mainLoop
