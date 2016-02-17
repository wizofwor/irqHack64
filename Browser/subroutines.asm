;###############################################################################
; SUBROUTINES
;###############################################################################

!zone printPage { 	
;Prints the initial filenames that's added to the program by the micro.
printPage: 
	ldx numberOfItems
--	ldy #20
	.fetchPointer=*+1
-	lda itemList-1,y
	.fillPointer=*+1
	sta SCREEN_RAM+121,y

	dey
	bne -

	clc
	lda .fetchPointer
	adc #32
	sta .fetchPointer
	lda .fetchPointer+1
	adc #00
	sta .fetchPointer+1

	clc
	lda .fillPointer
	adc #40
	sta .fillPointer
	lda .fillPointer+1
	adc #00
	sta .fillPointer+1

	dex
	bne --

	rts
}
