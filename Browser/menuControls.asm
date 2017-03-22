;===============================================================================
; MENU CONTROLS
; 
;===============================================================================
!zone {
.KEY_MINUS = $2d ; -
.KEY_PLUS  = $2b ; +
.KEY_GREAT = $2e ; >
.KEY_LESS  = $2c ; <
.KEY_ENTER = $0d

;===============================================================================
initializeMenu:

	lda #00
	sta activeMenuItem
	lda #<COLOR_RAM+122
	sta activeMenuItemAddr
	lda #>COLOR_RAM+122
	sta activeMenuItemAddr+1

	rts

;===============================================================================
menuControls:
.keyboardScan:
	jsr SCNKEY		; Call kernal's key scan routine
 	jsr GETIN		; Get the pressed key by the kernal routine
 	cmp #.KEY_MINUS 		
 	beq .down 		; go down in menu
 	cmp #.KEY_PLUS 		; IF char is '+'
 	beq .up 		; go up in menu
 	cmp #.KEY_GREAT 	; IF char is '>'
 	beq .nextPage 		; request next page from micro
 	cmp #.KEY_LESS		; IF char is '<'
 	beq .prevPage 		; request previous page from micro
 	cmp #.KEY_ENTER		; IF char is 'ENTER'
 	beq j1 			; launch selected item
    cmp #$0f 		; IF char is 'F'
    ;beq .simulation ; Display simulation menu
 	jmp .end

.nextPage:
	ldx PAGEINDEX
	cpx numberOfPages	  	
	bcc .execNext	;BLT
	jmp .end
	
.execNext:
	inc PAGEINDEX
	ldx #COMMANDNEXTPAGE
	stx COMMANDBYTE
	jmp j1
	
.prevPage
	ldx PAGEINDEX
	bne .execPrev
	jmp .end
	
.execPrev
	dec PAGEINDEX
	ldx #COMMANDPREVPAGE
	stx COMMANDBYTE	
	
j1: jmp enter

.down
	;clear old coloring
	ldy #22
	lda #$0f
-	sta (activeMenuItemAddr),y
	dey
	bne -

	;increment ACTIVE_ITEM
	ldx numberOfItems 	;check if the cursor is
	dex 				;already at end of page
	cpx activeMenuItem 	
	beq .end
	inc activeMenuItem

	clc
	lda activeMenuItemAddr
	adc #40
	sta activeMenuItemAddr
	lda activeMenuItemAddr+1
	adc #00
	sta activeMenuItemAddr+1

	jmp .end

.up
	;clear old coloring
	ldy #22
	lda #$0f
-	sta (activeMenuItemAddr),y
	dey
	bne -

	;decrement ACTIVE_ITEM
	lda #00 			;check if the cursor is
	cmp activeMenuItem 	;already at end of page
	beq .end
	dec activeMenuItem

	sec
	lda activeMenuItemAddr
	sbc #40
	sta activeMenuItemAddr
	lda activeMenuItemAddr+1
	sbc #00
	sta activeMenuItemAddr+1

	jmp .end 	
.end

}

!zone colorwash {
	ldy #22
	lda #$01
-	sta (activeMenuItemAddr),y
	dey
	bne -
}

rts