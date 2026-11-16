.ifndef MAIN_S
MAIN_S = 1

; ==========================================
; FILE INCLUDES
; ==========================================

.include "constants.inc"
.include "macros.inc"

.include "memory/zeropage.s"

.include "cartridge/header.s"
.include "cartridge/vectors.s"

.include "interrupts/reset.s"
.include "interrupts/nmi.s"

.include "ppu.s"
.include "sprites.s"
.include "input.s"


; ==========================================
; MAIN GAME LOOP
; ==========================================
.segment "CODE"

    .proc MainLoop
        ; Update game logic
        @wait:
            ; Wait for NMI to signal the next frame.
            lda ppu_frame_ready
            beq @wait
        ;

        ; Consume the frame signal.
        lda #0
        sta ppu_frame_ready

        ; Prepare the OAM buffer.
        jsr ppu_clear_oam

        ; Draw player sprite
        DRAW_SPRITE rectAX, rectAY, #TILE_SQUARE, #(SPRITE_PALETTE_1)

        ; Draw test sprites
        DRAW_SPRITE #160, #100, #TILE_CIRCLE, #(SPRITE_PALETTE_2)
        DRAW_SPRITE #140, #140, #TILE_SMILEY, #(SPRITE_PALETTE_3)

        jsr read_input ; read controller input and change sprite position accordingly
        
        jmp MainLoop
    .endproc

; endsegment CODE

.endif ; MAIN_S