logo_data:
	!bin "resources/logo.iscr" 

charset_data:
	!bin "resources/logo.imap"

color_data:
	!bin "resources/logo.col"

second_charset_data:
	!bin "resources/jetset.char",,1

sprite_data:
	!bin "resources/skull.bin",3*21

initialText:
	!scr " irqhack64 menu"

* = $2000
	!bin "resources/skull.bin"

end