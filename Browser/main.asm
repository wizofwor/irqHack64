;===============================================================================
; IRQHack64 Cartridge Main Menu - by wizofwor/i_r_on
; November 2015 - May 2017
;===============================================================================
!to "build/menu.prg",cbm

SIMULATION = 1 		;0 to compile for read cartrige
			;1 to compile with simulation routines

!src "standart.asm" 	;standard macros & kernal adresses definition 
!src "global.asm" 	;global labels & zp adresses

; Main / Start

	+SET_START $0900

; Initialize 

	jsr initializeScreen
	jsr initializeMenu
	jsr initializeLogo

loop:
	jsr updateLogo 		;sprite logo animation
	jsr menuControls
	jsr musicPlay

	jmp loop

; --- Main / End

!src "initialize-screen.asm"
!src "logo.asm"
!src "menuControls.asm"
!src "subroutines.asm"
!src "data.asm"
