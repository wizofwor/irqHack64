;##############################################################################
; IRQHack64 Cartridge Main Menu - by wizofwor
; November 2015
;###############################################################################

!to "build/menu.prg",cbm

!src "standart.asm"
!src "global.asm"

+SET_START $3800

sei

!src "initialize.asm"
!src "loop.asm"

!src "data.asm"