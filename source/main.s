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


; ==========================================
; MAIN GAME LOOP
; ==========================================

.segment "CODE"

.proc MainLoop
	; initial player position
    lda #100
    sta rectAX
    sta rectAY
	; Update game logic
	wait:
      ; Wait for NMI to signal the next frame.
      lda frameReady
      beq wait
    ;

    ; Consume the frame signal.
    lda #0
    sta frameReady

    ; Prepare the OAM buffer.
    jsr ppu_clear_sprites

    ; Draw sprite 1.
    lda rectAX
    sta spriteX
    
    lda rectAY
    sta spriteY

    lda #TILE_SQUARE
    sta spriteTile

    lda #(SPRITE_PALETTE_1)
    sta spriteAttr
    jsr ppu_draw_sprite


    ; Draw sprite 2.
    lda #160    ; Decimal Xpos
    sta spriteX

    lda #100    ; Decimal Ypos
    sta spriteY

    lda #TILE_CIRCLE
    sta spriteTile ; Decimal Xpos

    lda #(SPRITE_PALETTE_2)
    sta spriteAttr
    jsr ppu_draw_sprite


    ; Draw sprite 3.
    lda #140  ; Set X-position
    sta spriteX
    
    lda #140  ; Set Y-position
    sta spriteY

    lda #TILE_SMILEY ; Set Tile index
    sta spriteTile

    lda #(SPRITE_PALETTE_3) ; Set sprite attributes
    sta spriteAttr
    jsr ppu_draw_sprite

	jsr read_input ; read controller input and change sprite position accordingly
    jmp wait

	JMP MainLoop
.endproc