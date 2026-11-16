; ==========================================
; NON-MASKABLE INTERRUPT
; ==========================================

.segment "CODE"

nmi:
	; Update PPU
	; Read controller
	; Update frame-related data

	RTI
