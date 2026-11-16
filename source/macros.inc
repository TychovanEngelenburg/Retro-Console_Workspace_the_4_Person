.ifndef MACROS_INC
MACROS_INC = 1

; =============================  
; Set ppu sprite drawing arguments 
; and push a new sprite for this frame
; =============================  
.macro DRAW_SPRITE xpos, ypos, tile, attr
    lda xpos
    sta ppu_sprite_x

    lda tile
    sta ppu_sprite_tile
    
    lda attr
    sta ppu_sprite_attr
    
    lda ypos
    sta ppu_sprite_y

    jsr ppu_push_sprite
.endmacro

.endif