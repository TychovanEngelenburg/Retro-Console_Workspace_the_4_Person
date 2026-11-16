.ifndef PPU_S ; Include guard
PPU_S = 1

.include "constants.inc"

.segment "ZEROPAGE"
; =============================
; Sprite drawing variables
; =============================

ppu_sprite_x:    .res 1 
ppu_sprite_y:    .res 1
ppu_sprite_tile: .res 1
; spriteAttr = 
    ; Bit 7: Vertical flip.
    ; Bit 6: Horizontal flip.
    ; Bit 5: Priority (0: foreground, 1: background).
    ; Bit 2 - 4: Do not use! Set to 0.
    ; Bit 0 - 1: 2-bit pallette Select.
ppu_sprite_attr :   .res 1

ppu_sprite_offset : .res 1
ppu_sprite_count:   .res 1



; =============================
; Runtime flags
; =============================
ppu_frame_ready: .res 1


; =============================
; OAM
; =============================
.segment "OAM"
    .export oam
    oam: .res $100  ; sprite buffer, copied to the PPU by ppu_oam_dma
; End segment OAM



; =============================
; CODE
; =============================
.segment "CODE"
    ; Turn off NMI and rendering.
    .proc ppu_disable
        lda #0
        sta PPUCTRL   ; NMI off
        sta PPUMASK   ; rendering off
        rts
    .endproc    ; ppu_off

    .proc ppu_clear_nametable
        bit PPUSTATUS       ; Reset PPU address latch

        lda #$20
        sta PPUADDR     ; Write high byte of address ($2000)
        lda #$00
        sta PPUADDR     ; Write low byte of address ($2000)

        ldx #$04    ; Loop 4 times 256 bytes = 1024 bytes
        
        ldy #$00
        lda #$00    
        @ClearLoop:
            sta PPUDATA     ; Write value to VRAM
            
            dey
            bne @ClearLoop
            
            dex
            bne @ClearLoop
        ;

        rts
    .endproc ; ppu_clear_nametable



    .proc ppu_wait_vblank
        bit PPUSTATUS         ; Copy bit 7 (vblank flag) into N
        bpl ppu_wait_vblank   ; if N != 0 go to ppu_wait_vblank
        rts
    .endproc    ; ppu_wait_vblank



    ; Copy 32 bytes of palette_data to $3F00. Rendering must be off
    .proc ppu_load_palette
        bit PPUSTATUS     ; Reset the PPU address latch

        ; store PPU adress -> $3F00 (start of palette RAM)
        lda #$3f
        sta PPUADDR   ; Write high byte PPU adress
        lda #$00
        sta PPUADDR   ; Write low byte PPU adress
        
        ldx #0    ; X = 0 
        @loop:
        ; Write pallate data at index x to PPUdata
        lda palette_data, x
        sta PPUDATA
        
        inx           ; index x++
        cpx #32    
        bne @loop     ; if x != 32 repeat loop
        rts           ; else return
    .endproc    ; ppu_load_palette



    ; Turn on NMI and sprite rendering
    .proc ppu_enable
        bit PPUSTATUS     ; Reset the address latch

        ; Set scrolling
        lda #0
        sta PPUSCROLL     ; Reset scroll X to 0
        sta PPUSCROLL     ; Reset scroll Y to 0

        ; Load PPUCTL masks from constants.s into PPUMASK
        lda #(PPUCTRL_NMI_ENABLED)
        sta PPUCTRL

        ; Load PPUMASK masks from constants.s into PPUMASK
        lda #(PPUMASK_SHOW_SPRITES | PPUMASK_SHOW_BACKGROUND)
        sta PPUMASK
        rts
    .endproc    ; ppu_enable



    ; Move all 64 sprites in the oam buffer below the visible screen
    .proc ppu_clear_oam
        lda #$0  ; A = 255
        ldx #0    ; X = 0
        @hide:
            sta oam, x    ; Sets byte x of OAM to 255

            inx
            bne @hide     ; if x != 0 loop (x wraps as unsigned byte)
        ;

        jsr ppu_clear_sprite_index

        rts
    .endproc    ; ppu_hide_sprites



    ; Clears the old sprites and resets the next free slot.
    .proc ppu_clear_sprite_index
        lda #0              ; A = 0
        sta ppu_sprite_offset    ; Reset sprite offset
        sta ppu_sprite_count     ; Reset sprite count

        rts
    .endproc



    ; Copy OAM buffer to PPU. 
    ; Call at the start of nmi
    .proc ppu_oam_dma
        lda #$00      ; Set OAMADDR to 0   
        sta OAMADDR   

        lda #>oam  ; Set OAMDMA to high byte OAM 
        sta OAMDMA

        rts
    .endproc    ; ppu_oam_dma

    
    
    ; Draw one sprite based on variables:
    ; spriteX     = horizontal position
    ; spriteY     = vertical position
    ; spriteTile  = tile index
    ; spriteAttr  = palette and sprite attributes
    ; Each call automatically adcances to the next available OAM slot
    .proc ppu_push_sprite
        lda ppu_sprite_count 
        cmp #OAM_MAX_SPRITES
        beq @done   ; if spritecount > 64 (max available in oam) do not execute

        ldx ppu_sprite_offset    ; Get the next OAM slot

        ; Write Y position
        ; The way OAM works y needs to be subtracted 1
        lda ppu_sprite_y     ; Load sprite y
        sec             ; Set carry so no borrow possible
        sbc #1          ; Move sprite up 1
        sta oam + OAM_Y, x      ; Write byte to current sprite

        ; Write tile index.
        lda ppu_sprite_tile
        sta oam + OAM_TILE, x

        ; Write attributes.
        lda ppu_sprite_attr
        sta oam + OAM_ATTRIBUTES, x

        ; Write X position
        lda ppu_sprite_x
        sta oam + OAM_X, x        

        ; Advance to the next slot.
        lda ppu_sprite_offset   ; Get sprite memory offset
        clc                     ; Clear any previously set carry
        adc #OAM_SPRITE_SIZE    ; Sprite offset += 4
        sta ppu_sprite_offset   ; Store new offset

        inc ppu_sprite_count    ; Add newly drawn sprite to count

        @done:
        rts
    .endproc    ; Push sprite
; End segment CODE

.endif ; PPU_S