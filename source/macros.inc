; =============================
; Include file with macros (used like C++ preprocessor defines)
; This is mainly used for simplifying usage of interfaces.
;
; Contributors: 
; Tycho van E. 
; =============================

.ifndef MACROS_INC
MACROS_INC = 1



; Drawing

; =============================  
; DRAW_SPRITE(xpos, ypos, tile, attr)
; 
; Set ppu sprite drawing arguments  and push a new sprite for this frame.
;
; Parameters:
;   xpos = Horizontal position the sprite will be drawn at
;   ypos = Vertical position the sprite will be drawn at (%FF = off screen)
;   tile = Index on loaded pattern table. These indexes can be found in constants.s
;   attr = Settings for this sprite. These can be masked using SPRITE masks in constants.s
;           (example attr: #(SPRITE_PALETTE_0 | SPRITE_FLIP_HORIZONTAL).
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


; =============================  
; LOAD_LEVEL(level_addr)
;
; Set ppu sprite drawing arguments 
; and push a new sprite for this frame
;
; level_addr = 16 bit pointer adress to level nametable definition
; =============================  
.macro LOAD_LEVEL level_addr
    lda #<(level_addr)  ; Low byte level address
    sta lvl_selected_addr  
    sta ppu_background_addr
    
    lda #>(level_addr)  ; High byte level address
    sta lvl_selected_addr   + 1
    sta ppu_background_addr + 1

    jsr load_level_nametable    ; Draw the level
.endmacro

.endif ; MACROS_INC