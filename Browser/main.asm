;###############################################################################
; IRQHack64 Cartridge Main Menu - by wizofwor/i_r_on
; November 2015 - February 2016
;###############################################################################

!to "build/menu.prg",cbm

!src "standart.asm"
!src "global.asm"

!src "simulationData.asm"

+SET_START $0900

!src "initialize.asm"

main:
	!src "show_logo.asm"
	!src "controls.asm"
	jsr musicPlay

jmp main

!src "subroutines.asm"
!src "data.asm"