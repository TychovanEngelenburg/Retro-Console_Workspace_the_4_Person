; ==========================================
; NES CARTRIDGE HEADER
; Cartridge layout metadata
; ==========================================

.segment "HEADER"

; Identification
.byte $4E, $45, $53, $1A

; ROM sizes
.byte $02               ; 2x 16KB PRG-ROM
.byte #01               ; 1x 8KB CHR-ROM

; Mapper
.byte $01, $00        ; Mapper 0, vertical mirroring

; Reserved
.res $08, $00
