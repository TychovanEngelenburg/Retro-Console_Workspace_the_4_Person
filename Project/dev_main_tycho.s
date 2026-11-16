.ifndef MAIN_S
.define MAIN_S

.include "constants.inc"
.include "ppu.s"
.include "sprites.s"


; Cartridge type, based on project PP 
.segment "HEADER"
	INES_MAPPER = 0				; 0 = NROM
	INES_MIRROR = 1				; 0 = horizontal mirroring, 1 = vertical mirroring
	INES_SRAM   = 0				; 1 = battery backed SRAM at $6000-7FFF

  .byte "NES", $1A  ; iNES header identifier
  .byte $02         ; 2x 16KB PRG code
  .byte $01         ; 1x  8KB CHR data
	.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $f) << $4)	; mirroring, sram usage and lower mapper bits
	.byte (INES_MAPPER & %11110000)		; upper mapper bits
	.byte 0, 0, 0, 0, 0, 0, 0, 0	; additional settings which we leave as is
;

; Basically important internal events
.segment "VECTORS"
  .addr nmi     ; When an NMI happens (once per frame if enabled) the label nmi:
  .addr reset   ; When the processor first turns on or is reset, it will jump to the label reset
  .addr 0       ; External interrupt IRQ (unused)
;

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"
  ; =============================
  ; Startup process
  ; =============================
  .proc reset
    sei   ; Disable IRQs
    cld   ; Disable decimal mode

    ldx #$40
    stx APU_FRAME                 ; disable APU frame IRQ

    ; Set stack pointer to its starting value
    ldx #$ff  ; X = 255
    txs       ; Stack pointer = x  

    inx                           ; X = 0
    stx APU_DMC                   ; disable DMC IRQ 

    jsr ppu_off           ; Turn off the PPU       
    jsr ppu_wait_vblank   ; Wait for vblank so nothing ppu related is happening anymore

    ; Clear internal RAM. Takes a while 
    ; TODO: make own process?
    lda #$00 ; A = 0, all memory i nram will be set to this (X is still 0)
    @clear_ram: 
      sta $0000, x    ; zero page
      ; $0100 (stack) skipped for subroutine safety
      sta $0200, x  ; oam buffer
      sta $0300, x  ; general RAM
      sta $0400, x
      sta $0500, x
      sta $0600, x
      sta $0700, x
      inx
      bne @clear_ram  ; if x != 0 continue loop (x wraps as unsigned byte)
    ; End @clear_ram

    jsr ppu_wait_vblank   ; Wait until another vblank for the PPU to be ready
    jsr ppu_hide_sprites
    jsr ppu_load_palette  

   
    lda #0
    sta frameReady  ; Start with no pending frame.

    jsr ppu_enable  ; Turn the PPU back on
    
    jmp MainLoop ; Automatically flows into forever
  .endproc



  ; =============================
  ; Update Loop
  ; =============================  
  .proc MainLoop

@wait:
    ; Wait for NMI to signal the next frame.
    lda frameReady
    beq @wait

    ; Consume the frame signal.
    lda #0
    sta frameReady

    ; Prepare the OAM buffer.
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



  ; =============================
  ; Draw loop
  ; =============================
  ; NMI is called at the start of every vblank (period in between drawing frames)
  .proc nmi
    pha  ; Push current A, X and Y to stack to preserve them
    txa
    pha
    tya
    pha

    jsr ppu_oam_dma  ; Copy sprite buffer to PPU.

    lda #1
    sta frameReady  ; Tell main new frame ready

    pla
    tay
    pla
    tax
    pla   ; Return previous A from stack 
    rti
  .endproc



  ; =============================
  ; Collision detection subroutines
  ; Todo: move somewhere else maybe?
  ; =============================
  ; CollisionRectangles:
  ;     ; A right edge vs B left edge
  ;     lda rectAX
  ;     clc
  ;     adc rectAWidth
  ;     cmp rectBX
  ;     bcc NoCollision

  ;     ; B right edge vs A left edge
  ;     lda rectBX
  ;     clc
  ;     adc rectBWidth
  ;     cmp rectAX
  ;     bcc NoCollision

  ;     ; A bottom edge vs B top edge
  ;     lda rectAY
  ;     clc
  ;     adc rectAHeight
  ;     cmp rectBY
  ;     bcc NoCollision

  ;     ; B bottom edge vs A top edge
  ;     lda rectBY
  ;     clc
  ;     adc rectBHeight
  ;     cmp rectAY
  ;     bcc NoCollision

  ;     ; Failed all exemption tests meaning they DO COLLIDE
  ;     lda #1
  ;     rts

  ; CircleCircleCollision:
  ;     ; Find the absolute difference between the centre X positions
  ;     lda circleAX
  ;     cmp circleBX
  ;     bcc CircleX_AIsLeft

  ;     sec
  ;     sbc circleBX
  ;     sta circleDX
  ;     jmp CircleX_Done

  ; CircleX_AIsLeft:
  ;     lda circleBX
  ;     sec
  ;     sbc circleAX
  ;     sta circleDX

  ; CircleX_Done:
  ;     ; Find the absolute difference between the centre Y positions
  ;     lda circleAY
  ;     cmp circleBY
  ;     bcc CircleY_AIsAbove

  ;     sec
  ;     sbc circleBY
  ;     sta circleDY
  ;     jmp CircleY_Done

  ; CircleY_AIsAbove:
  ;     lda circleBY
  ;     sec
  ;     sbc circleAY
  ;     sta circleDY

  ; CircleY_Done:
  ;     ; Add the radii
  ;     clc
  ;     lda circleARadius
  ;     adc circleBRadius
  ;     sta circleRadiusSum

  ;     ; If either center difference is greater than the radius sum, they can defenitely not touch
  ;     lda circleDX
  ;     cmp circleRadiusSum
  ;     bcc CircleDxAllowed
  ;     beq CircleDxAllowed
  ;     jmp NoCollision

  ; CircleDxAllowed:
  ;     lda circleDY
  ;     cmp circleRadiusSum
  ;     bcc CircleDyAllowed
  ;     beq CircleDyAllowed
  ;     jmp NoCollision

  ; CircleDyAllowed:
  ;     ; Calculate dx squared
  ;     lda circleDX
  ;     sta multiplyA
  ;     sta multiplyB
  ;     jsr Multiply8x8

  ;     lda productLow
  ;     sta circleDistanceLow
  ;     lda productHigh
  ;     sta circleDistanceHigh

  ;     ; Calculate dy squared and add it to dx squared
  ;     lda circleDY
  ;     sta multiplyA
  ;     sta multiplyB
  ;     jsr Multiply8x8

  ;     clc
  ;     lda circleDistanceLow
  ;     adc productLow
  ;     sta circleDistanceLow
  ;     lda circleDistanceHigh
  ;     adc productHigh
  ;     sta circleDistanceHigh

  ;     ; Calculate the square of the sum of the radii
  ;     lda circleRadiusSum
  ;     sta multiplyA
  ;     sta multiplyB
  ;     jsr Multiply8x8

  ;     ; Compare dx squared + dy squared against the square of the radius sum.
  ;     lda circleDistanceHigh
  ;     cmp productHigh
  ;     bcc CircleCollision
  ;     bne NoCollision

  ;     lda circleDistanceLow
  ;     cmp productLow
  ;     bcc CircleCollision
  ;     beq CircleCollision
  ;     jmp NoCollision

  ; CircleCollision:
  ;     lda #1
  ;     rts

  ; NoCollision:
  ;     lda #0
  ;     rts
  ; ; End Collision logic

  ; ; Begin Mathematics logic
  ; Multiply8x8:
  ; ; Copy factorB into multiplicand lower 8 to be iterated and added to final product
  ;     lda factorB
  ;     sta multiplicandLower8
  ;     lda #0
  ;     sta multiplicandHigher8

  ;     ; Clear the 16-bit final product
  ;     sta productLower8
  ;     sta productHigher8

  ;     ldx #8                  ; Process all 8 bits of factorA

  ; MultiplyLoop:
  ;     lsr factorA          	; Shift next bit into carry
  ;     bcc MultiplySkipAdd     ; If bit is 0, skip addition

  ;     clc
  ;     lda productLower8
  ;     adc multiplicandLower8
  ;     sta productLower8

  ;     lda productHigher8
  ;     adc multiplicandHigher8
  ;     sta productHigher8

  ; MultiplySkipAdd:
  ;     asl multiplicandLower8    ; Shift working value left by one bit
  ;     rol multiplicandHigher8   ; Carry moves into higher byte

  ;     dex
  ;     bne MultiplyLoop
  ;     rts

  .endif ; MAIN_S