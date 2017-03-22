;===============================================================================
; screen.asm
; Screen Initialization Routines
; !NOTE: NON REALATED CODE SHOULD BE MOVED SOMEWHERE 
;===============================================================================
initializeScreen:
; Initial Wait Before Requesting file list
;		Buradaki döngü mantýðý show_logo içine yedirilirse logo'yu da gösterebiliriz açýlýþta.
;		Mantýk olarak ekranda gösterilecek yazý vesaire için bir süre býrakmak için.
;		Arduino da yarým saniye kadar menüyü gönderdikten sonra bekliyor. (Niye koyduðumu hatýrlayamadým þimdi.)
	ldx #WAITCOUNT
	lda #$90		; Raster line to wait. Not a specific one. Just that VIC doesn't have A0 line 
				; which has the 8th bit set to 1. 	
--	cmp $D012
	bne --
	ldy #$00	
-	iny			; Consume current line and a few lines more..
	bne -
	dex			; Decrement wait counter
	bne --
 
; Set Colors

	lda #$00	;Set border
	sta $d020
	lda #$00    	;Set bg#00
	sta $d021
	lda #$03	;Set bg#01
	sta $d022
	lda #$0d	;Set bg#02
	sta $d023

; Copy Character Set Data and set the VIC pointers

	ldx #$00
-	!for n,0,6 {
		lda charset_data+$ff*n,x
		sta CHARSET+$ff*n,x
		}	
	inx
	cpx #$ff
	bne -

	lda #$1b		;set VIC pointers
	sta $d018 		;screen ram is at $0400, charset is at $2800-$2fff

	lda #$08		;switch to hires
	and $d016
	sta $d016

; Copy the Initial Screen Values
	
!zone initialScreenValues {	
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

; Print title
	TITLE_BEGIN = SCREEN_RAM+43

	ldx #00
-	lda title,x
	sta TITLE_BEGIN,x
	inx
	cpx #16
	bne -

; Initialize Music

	lda #$00
	jsr music 		;initilize music

; Set Interrupt Handlers

	sei
	ldy #$7f    	; $7f = %01111111 
    	sty $dc0d   	; Turn off CIAs Timer interrupts 
    	sty $dd0d  	; Turn off CIAs Timer interrupts 
    	lda $dc0d  	; cancel all CIA-IRQs in queue/unprocessed 
    	lda $dd0d   	; cancel all CIA-IRQs in queue/unprocessed 

; Change interrupt routines
	asl $D019
	lda #$00
	sta $D01A

	;cli
	
; Get File List 
	!if SIMULATION = 0 {	
	lda #COMMANDINIT
	sta COMMANDBYTE
	
	JMP enter
	} ELSE {
	jsr printPage
	}

rts	