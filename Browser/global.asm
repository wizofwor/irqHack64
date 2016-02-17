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
	ACTIVE_ITEM   = $03 	;Selected row's number
	ACTIVE_ROW 	  = $04 	;Selected row's first color ram address
	RESERVED 	  = $05 	;hi byte for active row's color ram addres

;Starting address of fo data transferred. Menu uses this location to get next / previous
;page of contents from micro.
;DATA_HIGH is not incremented by the loader. Instead ACTUAL_HIGH is used.
;DATA_LOW, DATA_HIGH is also used to launch the loaded program by the loader.
	DATA_LOW 	  = $06 	
	DATA_HIGH 	  = $07
	DATA_LENGHT   = $08 	;Length (page) of data to be transferred
	
;These are set to DATA_LOW and DATA_HIGH respectively before transfer. 
;Loader uses these locations for actual transfer.
	ACTUAL_LOW 	  = $09   
	ACTUAL_HIGH   = $0a

;Nmi handler on cart that does the initial transfer of 4 bytes metadata (data_low, data_high, length, reserved)
;Nmi handler on the cart changes the handler to the fast one upon these 4 bytes finishes transferring.
CARTRIDGENMIHANDLER = $80BB ;$809a	

;Zero page addresses used to address screen
COLLOW	  	= $FB
COLHIGH	  	= $FC

;Zero page addresses used to access file names
NAMELOW	  	= $FD
NAMEHIGH  	= $FE

;Loader on the cartridge rom sets the 6th bit of this location. Which is tested by BIT $64
;command and waiting if overflow flag (which is the 6th bit of this location) is clear.
BITTARGET	= $64

;Next page command
COMMANDNEXTPAGE = $43

;Previous page command
COMMANDPREVPAGE = $41

;Part of the command byte that flags controlling micro that a file/folder is selected.
COMMANDENTERMASK = $01

numberOfItems	= $2CF0
numberOfPages		= $2CF1
PAGEINDEX		= $2CF2
itemList		= $2D00
