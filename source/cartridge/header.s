.ifndef HEADER_S
HEADER_S = 1
; ==========================================
; NES CARTRIDGE HEADER
; Cartridge layout metadata
; ==========================================

; Cartridge type, based on project PP 
.segment "HEADER"
	INES_MAPPER = 0				; 0 = NROM
	INES_MIRROR = 1				; 0 = horizontal mirroring, 1 = vertical mirroring
	INES_SRAM   = 0				; 1 = battery backed SRAM at $6000-7FFF

  .byte "NES", $1A  ; iNES header identifier
  .byte $02         ; 2x 16KB PRG code
  .byte $01         ; 1x  8KB CHR data
	.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $f) << $4)	; mirroring, sram usage and lower mapper bits
	.byte (INES_MAPPER & %11110000)		; upper mapper bits
	.byte 0, 0, 0, 0, 0, 0, 0, 0	; additional settings which we leave as is
;

.endif ; HEADER_S