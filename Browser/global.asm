;###############################################################################
;	Global.asm
;###############################################################################

;vic-ii data locations
SCREEN_RAM 	= $0400
COLOR_RAM  	= $d800
CHARSET    	= $2800

;Music
music		= $1000		;Müzik dosyasinin yuklenecegi adres
musicPlay	= music+3	;Müzik player adresi

;Nmi handler on cart that does the initial transfer of 4 bytes metadata (data_low, data_high, length, reserved)
;Nmi handler on the cart changes the handler to the fast one upon these 4 bytes finishes transferring.
CARTRIDGENMIHANDLER = $80BB ;$809a	

;Locations used by kernal to jump to user provided nmi/irq handler respectively
SOFTNMIVECTOR	= $0318
IRQVECTOR	= $0314

ROMNMIHANDLER	= $FE47 ;Kernal NMI handler - used to restore nmi handler on nmi vector.
ROMIRQHANDLER	= $FF48 ;Kernal IRQ handler - not used

numberOfItems	= $2BF0
numberOfPages	= $2BF1
PAGEINDEX	= $2BF2
itemList	= $2C00
MICROLOADSTART	= numberOfItems

;ZERO PAGE ADRESSES
;============================================================================
spAnimationCounter = $10
spColorWashCounter = $11
activeMenuItem  = $12 	;Selected row's number
activeMenuItemAddr = $14 	;Selected row's first color ram address
;           	= $15   ;hi byte for active row's color ram addres
RESERVED 	  	= $05 	;Not used

;temprary variables
var1 			= $18 
var2 			= $19				

;Starting address of fo data transferred. Menu uses this location to get next / previous
;page of contents from micro.
;DATA_HIGH is not incremented by the loader. Instead ACTUAL_HIGH is used.
;DATA_LOW, DATA_HIGH is also used to launch the loaded program by the loader.
DATA_LOW 	= $03 	
DATA_HIGH 	= $04
DATA_LENGTH   	= $05 	;Length (page) of data to be transferred
	
;These are set to DATA_LOW and DATA_HIGH respectively before transfer. 
;Loader uses these locations for actual transfer.
ACTUAL_LOW	= $07   
ACTUAL_HIGH   	= $08

;Zero page addresses used to address screen
;COLLOW	  	= $FB
;COLHIGH	= $FC

;Zero page addresses used to access file names
;NAMELOW	= $FD
;NAMEHIGH  	= $FE


;CONSTANTS
;============================================================================

;Loader on the cartridge rom sets the 6th bit of this location. Which is tested by BIT $64
;command and waiting if overflow flag (which is the 6th bit of this location) is clear.
BITTARGET	= $64
COMMANDINIT	= $45 ;Init command (Micro sends initial state of sd card)
COMMANDNEXTPAGE = $43 ;Next page command
COMMANDPREVPAGE = $41 ;Previous page command
COMMANDENTERMASK= $01 ;Part of the command byte that flags controlling micro that a file/folder is selected.
WAITCOUNT	= 100 ; Frame count to wait between Launching & requesting file list from micro


