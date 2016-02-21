;##############################################################################
; IRQHack64 Cartridge Main Menu - by wizofwor
; Menu Controls
;##############################################################################

!zone keyboardScan {
	jsr SCNKEY		; Call kernal's key scan routine
 	jsr GETIN		; Get the pressed key by the kernal routine
 	cmp #$2d 		; IF char is '-'
 	beq .down 		; go down in menu
 	cmp #$2b 		; IF char is '+'
 	beq .up 		; go up in menu
 	cmp #$2e 		; IF char is '>'
 	;beq .nextpage 	; request next page from micro
 	cmp #$2c 		; IF char is '<'
 	;beq .prevpage 	; request previous page from micro
 	cmp #$0d 		; IF char is 'ENTER'
 	beq j1 			; launch selected item
    cmp #$0f 		; IF char is 'F'
    ;beq .simulation ; Display simulation menu
 	jmp .end

j1: jmp enter

.down
	;clear old coloring
	ldy #22
	lda #$0f
-	sta (ACTIVE_ROW),y
	dey
	bne -

	;increment ACTIVE_ITEM
	ldx numberOfItems 	;check if the cursor is
	dex 				;already at end of page
	cpx ACTIVE_ITEM 	
	beq .end
	inc ACTIVE_ITEM

	clc
	lda ACTIVE_ROW
	adc #40
	sta ACTIVE_ROW
	lda ACTIVE_ROW+1
	adc #00
	sta ACTIVE_ROW+1

	jmp .end

.up
	;clear old coloring
	ldy #22
	lda #$0f
-	sta (ACTIVE_ROW),y
	dey
	bne -

	;decrement ACTIVE_ITEM
	lda #00 			;check if the cursor is
	cmp ACTIVE_ITEM 	;already at end of page
	beq .end
	dec ACTIVE_ITEM

	sec
	lda ACTIVE_ROW
	sbc #40
	sta ACTIVE_ROW
	lda ACTIVE_ROW+1
	sbc #00
	sta ACTIVE_ROW+1

	jmp .end 	

.end

}

!zone colorwash {
	ldy #22
	lda #$07
-	sta (ACTIVE_ROW),y
	dey
	bne -
}
