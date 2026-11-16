.ifndef MAIN_S
MAIN_S = 1

; ==========================================
; FILE INCLUDES
; ==========================================

.include "constants.inc"
.include "memory/zeropage.s"

.include "cartridge/header.s"
.include "cartridge/vectors.s"

.include "interrupts/reset.s"
.include "interrupts/nmi.s"

.include "ppu.s"
.include "sprites.s"
.include "input.s"

.include "mathematics/multiply8x8.s"

.include "collision/circle_circle.s"
.include "collision/rectangle_circle.s" ; For now still empty
.include "collision/rectangle_rectangle.s"


; ==========================================
; MAIN GAME LOOP
; ==========================================
.segment "CODE"

    .proc MainLoop
        ; Update game logic
        @wait:
            ; Wait for NMI to signal the next frame.
            lda frameReady
            beq @wait
        ;

        ; Consume the frame signal.
        lda #0
        sta frameReady

        ; Prepare the OAM buffer.
        jsr ppu_clear_oam

        ; Draw sprite 1.
        lda rectAX
        sta spriteX
        lda rectAY
        sta spriteY
        lda #TILE_SQUARE
        sta spriteTile
        lda #(SPRITE_PALETTE_1)
        sta spriteAttr
        jsr ppu_push_sprite


        ; Draw sprite 2.
        lda #160    ; Decimal Xpos
        sta spriteX
        lda #100    ; Decimal Ypos
        sta spriteY
        lda #TILE_CIRCLE
        sta spriteTile ; Decimal Xpos
        lda #(SPRITE_PALETTE_2)
        sta spriteAttr
        jsr ppu_push_sprite


        ; Draw sprite 3.
        lda #140  ; Set X-position
        sta spriteX
        lda #140  ; Set Y-position
        sta spriteY
        lda #TILE_SMILEY ; Set Tile index
        sta spriteTile
        lda #(SPRITE_PALETTE_3) ; Set sprite attributes
        sta spriteAttr
        jsr ppu_push_sprite

        jsr read_input ; read controller input and change sprite position accordingly
        
        jmp MainLoop
    .endproc

; endsegment CODE

.endif ; MAIN_S
