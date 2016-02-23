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

	lda #$08		;switch to hires
	and $d016
	sta $d016

	
!zone memCopy {		;copy initial screen values
.fetchNewData:
	;***read***
	.fetchPointer1=*+1 	;read repeat value 
	ldx repeat_bytes 	;x=repeat value
	beq .end 			;finish copying if x=0

	.fetchPointer2=*+1 	
	lda char_bytes 		;A=char value
	.fetchPointer3=*+1 
	ldy color_bytes 	;Y=color value

	;***copy***
	.charFillPointer=*+1
-	sta SCREEN_RAM
	.colorFillPointer=*+1
	sty COLOR_RAM
	+inc16 .charFillPointer
	+inc16 .colorFillPointer

	dex
	bne -

	;***increment pointers***
	+inc16 .fetchPointer1
	+inc16 .fetchPointer2
	+inc16 .fetchPointer3

	jmp .fetchNewData
.end	
; Deðiþtirilen operand'larýn tekrar init edilmesi, 
; gerek var mý bilemediðim için comment'ledim - nejat
;	lda #<repeat_bytes
;	sta .fetchPointer1
;	lda #>repeat_bytes
;	sta .fetchPointer1+1
	
;	lda #<char_bytes
;	sta .fetchPointer2
;	lda #>char_bytes
;	sta .fetchPointer2+1
	
;	lda #<color_bytes
;	sta .fetchPointer3
;	lda #>color_bytes
;	sta .fetchPointer3+1	
	
;	lda #<SCREEN_RAM
;	sta .charFillPointer
;	lda #>SCREEN_RAM
;	sta .charFillPointer+1	
	
;	lda #<COLOR_RAM
;	sta .colorFillPointer
;	lda #>COLOR_RAM
;	sta .colorFillPointer+1	
}
	;***Print title
	ldx #00
-	lda title,x
	sta SCREEN_RAM+41,x
	inx
	cpx #16
	bne -

	;***Print initial filenames
	;jsr printPage

	;***initialize color wash effect for active menu item
	lda #00
	sta ACTIVE_ITEM
	lda #<COLOR_RAM+120
	sta ACTIVE_ROW
	lda #>COLOR_RAM+120
	sta ACTIVE_ROW+1


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

	lda #$06 	;set sprite multicolor 2
	sta $d026

	ldx #$08	;set sprite colors
	lda #$0e
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
	
	
	
;--------------------------------------------------
; INITIAL WAIT BEFORE REQUESTING FILE LIST
;--------------------------------------------------
	;Buradaki döngü mantýðý show_logo içine yedirilirse logo'yu da gösterebiliriz açýlýþta.
	;Mantýk olarak ekranda gösterilecek yazý vesaire için bir süre býrakmak için.
	;Arduino da yarým saniye kadar menüyü gönderdikten sonra bekliyor. (Niye koyduðumu hatýrlayamadým þimdi.)
	LDX #WAITCOUNT
	LDA #$90		; Raster line to wait. Not a specific one. Just that VIC doesn't have A0 line 
					; which has the 8th bit set to 1. 
--	
	CMP $D012
	BNE --
	LDY #$00
-	
	INY				; Consume current line and a few lines more..
	BNE -
	DEX				; Decrement wait counter
	BNE --
	
	LDA #COMMANDINIT
	STA COMMANDBYTE
	JMP enter
