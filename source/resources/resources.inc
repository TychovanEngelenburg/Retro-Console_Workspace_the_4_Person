; =============================
; This is a simple data script which loads and holds external resource files.
;
; Contributors: 
; Tycho van E. 
; =============================

.ifndef RESOURCES_INC ; Include guard
RESOURCES_INC = 1



.segment "RODATA"

  ; Nametables
  level1: 
    .incbin "levels/level1.nam"       
  ;


  ; Palettes
  .export palette_data
  palette_data:
    ; Background palettes
    .incbin "palettes/BackgroundPalette.pal"

    ; Sprite palettes
    .byte $0f, $28, $16, $0f
    .byte $0f, $16, $11, $0f
    .byte $0f, $12, $1a, $0f
    .byte $0f, $38, $15, $0f
  ;

; endsegment RODATA

.segment "TILES"
  
  ; Tiles
  .incbin "tilesheets/PatternTable.chr"

; endsegment TILES

.endif ; RESOURCES_INC