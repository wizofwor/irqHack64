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
	COUNTER = $02
	TARGET_RASTER = $03
	OFFSET = $04

