; ==========================================
; SYSTEM INITIALIZATION
; ==========================================

.segment "CODE"

reset:
	SEI
	CLD

	LDX #$40
	STX $4017

	LDX #$FF
	TXS

	INX
	STX $2000
	STX $2001
	STX $4010

; Wait for vblank
vblankwait1:
	BIT $2002
	BPL vblankwait1

; Clear internal RAM
clear_memory:
	LDA #$00
	STA $0000, X
	STA $0100, X
	STA $0200, X
	STA $0300, X
	STA $0400, X
	STA $0500, X
	STA $0600, X
	STA $0700, X

	INX
	BNE clear_memory

; Wait for vblank again
vblankwait2:
	BIT $2002
	BPL vblankwait2

; Enable NMI
	LDA #%10000000
	STA $2000

; Enable sprites
	LDA #%00010000
	STA $2001

; Enter main loop
	JMP Main
