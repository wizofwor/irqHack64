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

	!src "initialize-screen.asm"
	jsr initializeLogo

loop:
	jsr updateLogo 		;sprite logo animation
	!src "menuControls.asm"
	jsr musicPlay

	jmp loop

; --- Main / End

!src "logo.asm"
!src "subroutines.asm"
!src "data.asm"