;--------------------------------------------------
; SET SCREEN
;--------------------------------------------------
	+CLEAR_SCREEN

	;set colors
	lda #$0d	;Set border
	sta $d020
	lda #$00    ;Set bg#00
	sta $d021
	lda #$03	;Set bg#01
	sta $d022
	lda #$0d	;Set bg#02
	sta $d023

	;copy character set data
	;ldx #$00
-	;lda charset_data,x
	;sta CHARSET1,x
	;lda charset_data+$ff,x
	;sta CHARSET1+$ff,x
	;lda charset_data+$1fe,x
	;sta CHARSET1+$1fe,x
	;lda charset_data+$2fd,x
	;sta CHARSET1+$2fd,x
	;lda charset_data+$3fc,x
	;sta CHARSET1+$3fc,x
	;lda second_charset_data,x
	;sta CHARSET2,x
	;lda second_charset_data+$ff,x
	;sta CHARSET2+$ff,x
	;inx
	;cpx #$ff
	;bne -

	;copy initial screen and color ram values
	;ldx #$00	
-	;lda logo_data,x
	;sta SCREEN_RAM,x
	;lda color_data,x
	;sta COLOR_RAM,x
	;inx
	;cpx #$f0
	;bne -

	ldx #$00
-	lda initialText,x
	sta SCREEN_RAM+$f0,x
	inx
	cpx #15
	bne -
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
