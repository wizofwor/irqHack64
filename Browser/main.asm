;##############################################################################
; IRQHack64 Cartridge Main Menu - by wizofwor
; November 2015
;###############################################################################

!to "build/menu.prg",cbm

!src "standart.asm"
!src "global.asm"

+SET_START $0900

!src "initialize.asm"

main:
	!src "show_logo.asm"
	!src "controls.asm"

jmp main

!src "data.asm"