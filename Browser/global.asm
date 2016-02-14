;--------------------------------------------------------------
;	Global.asm
;--------------------------------------------------------------

	;vic-ii data locations
	SCREEN_RAM = $0400
	COLOR_RAM  = $d800
	CHARSET    = $2800
	CHARSET2   = $3000

	;Music
	music		= $1000		;Müzik dosyasinin yuklenecegi adres
	musicPlay	= music+3	;Müzik player adresi

	;zp adresses
	SPRITE_STATE  = $02
	ACTIVE_ITEM   = $03
	HIGHLIGHT_LO = $04
	HIGHLIGHT_HI = $05


