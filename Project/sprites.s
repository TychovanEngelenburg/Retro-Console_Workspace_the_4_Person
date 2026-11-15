.ifndef SPRITES_S ; Include guard
SPRITES_S = 1

.segment "RODATA"

.export palette_data

palette_data:
    ; Background palettes
    .byte $0f, $00, $10, $30
    .byte $0f, $00, $10, $30
    .byte $0f, $00, $10, $30
    .byte $0f, $00, $10, $30

    ; Sprite palettes
    .byte $0f, $28, $16, $0f
    .byte $0f, $21, $11, $0f
    .byte $0f, $2a, $1a, $0f
    .byte $0f, $25, $15, $0f


.segment "TILES"
; .incbin "FileName.chr"        ; Leftover from investigating PP.char file. Can be used later to define char table.



; tile 0: blank
  .res 16, $00

; tile 1: Square
  .res 8, $ff
  .res 8, $00

; tile 3: Circle
  .byte %00111100
  .byte %01111110
  .byte %11111111
  .byte %11111111
  .byte %11111111
  .byte %11111111
  .byte %01111110
  .byte %00111100

  .res 8, $00


; tile 3: smiley
  .byte %00111100
  .byte %01111110
  .byte %11111111
  .byte %11111111
  .byte %11111111
  .byte %11111111
  .byte %01111110
  .byte %00111100

  .byte %00000000
  .byte %00000000
  .byte %01100110
  .byte %01100110
  .byte %00000000
  .byte %01000010
  .byte %00111100
  .byte %00000000

.endif ; INCLUDE GUARDS