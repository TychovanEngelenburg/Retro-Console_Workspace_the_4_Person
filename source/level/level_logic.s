; =============================
; Script that handles logic relating to the level
;
; Contributors: 
; Tycho van E. 
; =============================

.ifndef LEVEL_LOGIC_S
LEVEL_LOGIC_S = 1



.segment "ZEROPAGE"
    lvl_selected_addr: .res 2     ; 16 bit pointer to level definition 

    lvl_world_x: .res 1     ; World position input
    lvl_world_y: .res 1     ; World position input
    lvl_tile_x:  .res 1     ; Output for world_to_tile.    Input for get_selected_attributes
    lvl_tile_y:  .res 1     ; Output for world_to_tile.    Input for get_selected_attributes

    lvl_tile_offset_out: .res 2    ; Tile index based on selected x and y. Output from get_tile_offset

    lvl_tile_pointer:    .res 2    ; Internal pointer to selected address + offset
    lvl_tile_attr_out:   .res 1    ; Output from get_selected_attributes

; endsegment ZEROPAGE



.segment "CODE"
    ; =============================
    ; First get tile offset, then write related attributes into output.
    ; 
    ; Example of how you could this:
    ;   LDA lvl_attributes_out
    ;   AND #TILE_WALL
    ;   BEQ handle_wall_hit 
    ; =============================
    .proc get_selected_attributes
        jsr get_tile_offset

        clc 

        ; Add offset to address, low byte
        lda lvl_selected_addr
        adc lvl_tile_offset_out
        sta lvl_tile_pointer

        ; Add offset to address, high byte
        lda lvl_selected_addr    + 1
        adc lvl_tile_offset_out  + 1
        sta lvl_tile_pointer     + 1
        
        ; Get tile attributes
        ldy #$00 ; Add empty Y to tile pointer, indirect accessing requires Y register use 
        lda (lvl_tile_pointer), Y
        sta lvl_tile_attr_out

        rts
    .endproc ; get_selected_attributes



    ; =============================
    ; Get tile offset based on grid x and y pos,
    ; write it into output.
    ; =============================
    .proc  get_tile_offset
        ; Add y pos selected tile * 32 (Y * SCREEN_TILE_WIDTH) 
        lda lvl_tile_y  ; Set low byte to y pos
        sta lvl_tile_offset_out 

        lda #$00            ; clear high byte
        sta lvl_tile_offset_out + 1

        ; Shift lvl_tile_offset left 5x, this multiplies by 32 (SCREEN_TILE_WIDTH)
        .repeat 5
            ASL lvl_tile_offset_out         ; Shift low byte left 
            ROL lvl_tile_offset_out + 1     ; Rotate overflow carry frol low byte into high
        .endrepeat
 
        clc         ; Make sure theres no carry

        lda lvl_tile_offset_out
        adc lvl_tile_x  ; Add x pos selected tile to low byte
        sta lvl_tile_offset_out
        
        lda lvl_tile_offset_out + 1     ; Add any carry to the high byte
        adc #$00
        sta lvl_tile_offset_out + 1

        rts
    .endproc


    ; =============================
    ; Convert world_x and world_y to grid tile positions
    ; Store these in tile_x and tile_y
    ; When out of bounds tiles wrap around to the other side of the screen
    ; =============================
    .proc world_to_tile
        lda lvl_world_x
        lsr     ; /= 2
        lsr     ; /= 2
        lsr     ; /= 2
        and #(SCREEN_TILE_WIDTH - 1) ; functions as x = x % 32 
        sta lvl_tile_x


        ; Convert world Y position to tile Y position
        lda lvl_world_y
        lsr     ; /= 2
        lsr     ; /= 2
        lsr     ; /= 2

        ; wrap y to 30 
        @wrap_check_y:
        cmp SCREEN_TILE_HEIGHT
        bcc @valid_y ; if y < tile height

        ; else
        SEC
        SBC SCREEN_TILE_HEIGHT  ; y -= tile height
        jmp @wrap_check_y       ; repeat check until no longer out of set bounds
        
        @valid_y:

        sta lvl_tile_y

        rts
    .endproc ; world_to_tile
; endsegment CODE


.endif ; LEVEL_LOGIC_S