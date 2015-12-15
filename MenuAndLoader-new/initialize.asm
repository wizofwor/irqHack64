;--------------------------------------------------
; SET SCREEN
;--------------------------------------------------
	+CLEAR_SCREEN

	;set colors
	lda #$00	;Set border
	sta $d020
	lda #$01    ;Set bg#00
	sta $d021
	lda #$03	;Set bg#01
	sta $d022
	lda #$0d	;Set bg#02
	sta $d023

	;copy character set data
	ldx #$00
-	lda charset_data,x
	sta CHARSET1,x
	lda charset_data+$ff,x
	sta CHARSET1+$ff,x
	lda charset_data+$1fe,x
	sta CHARSET1+$1fe,x
	lda charset_data+$2fd,x
	sta CHARSET1+$2fd,x
	lda charset_data+$3fc,x
	sta CHARSET1+$3fc,x
	lda second_charset_data,x
	sta CHARSET2,x
	lda second_charset_data+$ff,x
	sta CHARSET2+$ff,x
	inx
	cpx #$ff
	bne -

	;copy initial screen and color ram values
	ldx #$00	
-	lda logo_data,x
	sta SCREEN_RAM,x
	lda color_data,x
	sta COLOR_RAM,x
	inx
	cpx #$f0
	bne -

	ldx #$00
-	lda initialText,x
	sta SCREEN_RAM+$f0,x
	inx
	cpx #15
	bne -

;--------------------------------------------------
; SPRITES
;--------------------------------------------------
	ldx #$00	;set sprite pointers
	lda #$80
-	sta $07f8,x
	inx
	cpx #$08
	bne -

 	ldx #$00 		;set sprite colors
	lda #$0b		
-	sta $d027,x 
 	inx	
 	cpx #$08
	bne -	

	;lda #$FF		;enable all sprites
	;sta $d015

	lda #$FF 		;extend-sprites
	;sta $d017
	sta $d01d

	;lda #15 		;set sprite-x
	;ldx #00
-	;sta $d000,x 
	;inx
	;inx
	;cpx #16
	;bne - 

	lda #128+64 	;Sprite 6 and 7
	sta $d010 		;in 2nd page

	;ldx #$00 		; Set sprite-y
	;ldy #$01
-	;lda spritey,x
	;sta $d000,y 
 	;inx
 	;iny
 	;iny
 	;cpx #$08
 	;bne -

	;initialize parameters
	lda #30
	sta OFFSET

	lda #60
	sta TARGET_RASTER	

;--------------------------------------------------
; INTERRUPTS
;--------------------------------------------------

	sei

	LDY #$7f    			; $7f = %01111111 
    STY $dc0d   			; Turn off CIAs Timer interrupts 
    STY $dd0d  				; Turn off CIAs Timer interrupts 
    LDA $dc0d  				; cancel all CIA-IRQs in queue/unprocessed 
    LDA $dd0d   			; cancel all CIA-IRQs in queue/unprocessed 

    ;Change interrupt routines
	ASL $D019
	LDA #$00
	STA $D01A

	cli
