loop:
	;---------------/ part 1 -----------------------
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

	;---------------/ part 2 -----------------------
	lda #98 ;wait for raster
- 	cmp $d012
 	bne -

 	ldy #08 	;loose time to hide 
- 	dey 		;flickering
 	bne -

 	lda #$06
 	sta $d021

	lda #$1d	;set VIC pointers
	sta $d018 	;screen ram is at $0400, charset is at $3000-$27ff

	lda #$08	;switch to hires
	and $d016
	sta $d016






	
	jmp loop	