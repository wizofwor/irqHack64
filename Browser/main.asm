;###############################################################################
; IRQHack64 Cartridge Main Menu - by wizofwor
; November 2015
;###############################################################################
!to "build/menu.prg",cbm

SIMULATION = 1 			;0 to compile for read cartrige
						;1 to compile with simulation routines

!src "standart.asm" 	;standard macros & kernal adresses definition 
!src "global.asm" 		;global labels & zp adresses
;--------------------------------------------------------------------------------

+SET_START $0900

	!src "initialize.asm"

main:
	!src "show_logo.asm"
	!src "controls.asm"
	jsr musicPlay


jmp main

;--------------------------------------------------------------------------------
!src "subroutines.asm"
!src "data.asm"