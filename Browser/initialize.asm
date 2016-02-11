;--------------------------------------------------
; SET SCREEN
;--------------------------------------------------
	;+CLEAR_SCREEN

	;set colors
	lda #$00	;Set border
	sta $d020
	lda #$00    ;Set bg#00
	sta $d021
	lda #$03	;Set bg#01
	sta $d022
	lda #$0d	;Set bg#02
	sta $d023

	;copy character set data
	ldx #$00
-	lda charset_data,x
	sta CHARSET,x
	lda charset_data+$ff,x
	sta CHARSET+$ff,x
	lda charset_data+$1fe,x
	sta CHARSET+$1fe,x
	lda charset_data+$2fd,x
	sta CHARSET+$2fd,x
	lda charset_data+$3fc,x
	sta CHARSET+$3fc,x
	inx
	cpx #$ff
	bne -

	lda #$1b		;set VIC pointers
	sta $d018 		;screen ram is at $0400, charset is at $2800-$2fff

	lda #$08	;switch to hires
	and $d016
	sta $d016

	;copy initial screen values
!zone memCopy {		
.fetchNewData:
	fetchPointer1=*+1 	;mark self modiying address
	lda filler_bytes 	;read char value into A
	fetchPointer2=*+1 
	ldx repeat_bytes 	;read repeat value into x
	beq .end 			;finish copying if x=0

	inc fetchPointer1
	bne *+5
	inc fetchPointer1+1
	inc fetchPointer2
	bne *+5
	inc fetchPointer2+1

	fillPointer=*+1
-	sta SCREEN_RAM
	inc fillPointer
	bne *+5
	inc fillPointer+1

	dex
	bne -

	jmp .fetchNewData
.end	
}

	;copy initial color ram values
	ldx #22
-	lda #$05
	sta COLOR_RAM,x
	lda #$0d
	sta COLOR_RAM+40,x
	sta COLOR_RAM+40*24,x
	lda #$0f
	!for num,22 {sta COLOR_RAM+40*(num+1),x} 
	dex
	bne -


	;ldx #$00
-	;lda initialText,x
	;sta SCREEN_RAM+$f0,x
	;inx
	;cpx #15
	;bne -
;--------------------------------------------------
; SPRITES
;--------------------------------------------------	
	lda #$ff	
	sta $d015	;enable all sprites
	sta $d01c	;enable multicolor for all

	lda #$00	;undo sprite extend
	sta $d017
	sta $d01d

	lda #$01 	;set sprite multicolor 1
	sta $d025	

	lda #$03 	;set sprite multicolor 2
	sta $d026

	ldx #$08	;set sprite colors
	lda #$0d
-	sta $d026,x
	dex
	bne -

;--------------------------------------------------
; MUSIC
;--------------------------------------------------	
	lda #$00
	jsr music 		;initilize music
;--------------------------------------------------
; INTERRUPTS
;--------------------------------------------------

	sei

	LDY #$7f    	; $7f = %01111111 
    STY $dc0d   	; Turn off CIAs Timer interrupts 
    STY $dd0d  		; Turn off CIAs Timer interrupts 
    LDA $dc0d  		; cancel all CIA-IRQs in queue/unprocessed 
    LDA $dd0d   	; cancel all CIA-IRQs in queue/unprocessed 

    ;Change interrupt routines
	ASL $D019
	LDA #$00
	STA $D01A

	;cli
