.ifndef MAIN_S
MAIN_S = 1

.include "cartridge/header.s"
.include "cartridge/vectors.s"

.include "interrupts/reset.s"
.include "interrupts/nmi.s"


.include "constants.inc"
.include "ppu.s"
.include "sprites.s"

.segment "CODE"

  ; =============================
  ; Update Loop
  ; =============================  
  .proc MainLoop
    @wait:
      ; Wait for NMI to signal the next frame
      lda frameReady
      beq @wait
    ;
    ; Reset next frame flag
    lda #0
    sta frameReady

    ; Prepare the OAM buffer
    jsr ppu_clear_sprites

    ; Draw sprite 1.
    lda #120
    sta spriteX
    lda #100
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

    jmp @wait

  .endproc  ; MainLoop 

; endsegment CODE

.endif ; MAIN_S