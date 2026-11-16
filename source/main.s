; ==========================================
; FILE INCLUDES
; ==========================================

.include "cartridge/header.s"
.include "memory/zeropage.s"

.include "cartridge/vectors.s"

.include "system/reset.s"
.include "system/nmi.s"

.include "collision/rectangle_rectangle.s"
.include "collision/circle_circle.s"
.include "collision/circle_rectangle.s"


; ==========================================
; MAIN GAME LOOP
; ==========================================

.segment "CODE"

Main:
	; Update game logic

	JMP Main
