	;+CLEAR_SCREEN

	lda #$00	;Set border
	sta $d020
	lda #$01    ;Set bg#00
	sta $d021
	lda #$03	;Set bg#01
	sta $d022
	lda #$0d	;Set bg#02
	sta $d023

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
	lda second_charset,x
	sta CHARSET2,x
	lda second_charset+$ff,x
	sta CHARSET2+$ff,x
	inx
	cpx #$ff
	bne -

	ldx #$00	
-	lda logo_data,x
	sta SCREEN_RAM,x
	lda color_data,x
	sta COLOR_RAM,x
	inx
	cpx #$c8
	bne -