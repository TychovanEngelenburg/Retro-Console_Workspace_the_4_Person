; Big parts of this code are based on NesHacker's DevEnvironmentDemo code.
; Most comments are redone or added by Tycho van Engelenburg 

; Cartridge type
.segment "HEADER"
  ; .byte "NES", $1A ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring


; Basically important internal events
.segment "VECTORS"
  ; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"


; =============================
; Zero page variables
; =============================

; Rectangle A: top-left X, top-left Y, width, height
rectAX = $00
rectAY = $01
rectAWidth = $02
rectAHeight = $03

; Rectangle B: top-left X, top-left Y, width, height
rectBX = $04
rectBY = $05
rectBWidth = $06
rectBHeight = $07

; Circle A: centre X, centre Y, radius
circleAX = $08
circleAY = $09
circleARadius = $0A

; Circle B: centre X, centre Y, radius
circleBX = $0B
circleBY = $0C
circleBRadius = $0D

; 8 bit multiplication resulting in 16 bit multiplicand
factorA = $0E
factorB = $0F
productLower8 = $10
productHigher8 = $11
multiplicandLower8 = $12
multiplicandHigher8 = $13

; Circle collision preparations
circleDX = $14
circleDY = $15
circleRadiusSum = $16
circleDistanceLow = $17
circleDistanceHigh = $18

; Bits to button order: A   B  Select  Start  Up  Down  Left  Right (carry: held)
buttons     = $19   ; Buttons held this frame
buttons_old = $1A   ; Buttons held the previous frame

color_index = $1B   ; Which color entry is selected

; =============================
; Startup process
; =============================

; TODO: look into how this works exactly
reset:
  sei   ; Disable IRQs
  cld   ; Disable decimal mode
  ldx #$40
  stx $4017   ; disable APU frame IRQ
  ldx #$ff  ; Set up stack
  txs   ;  .
  inx   ; now X = 0
  stx $2000 ; disable NMI
  stx $2001   ; disable rendering
  stx $4010   ; disable DMC IRQs

; Wait for vblank (time in between frames)
vblankwait1: ; Copy ppu status bit 7 (vblank status) to N
  bit $2002
bpl vblankwait1

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
bne clear_memory ; if x != 0 

; Wait for vblank (time in between frames)

; Second wait for vblank (time in between frames)
vblankwait2:
  bit $2002 ; Copy ppu status bit 7 (vblank status) to N
bpl vblankwait2 ; if N > 0

enable_rendering:
  lda #%10000000  ; Enable NMI
  sta $2000

  lda #%00010000  ; Enable Sprites
  sta $2001

; Infinite loop
forever:
  jmp forever


; =============================
; Update loop
; =============================
; NMI is called at the start of every vblank (period in between drawing frames)
nmi:

;Collision subroutines
  CollisionRectangles:
      ; A right edge vs B left edge
      lda rectAX
      clc
      adc rectAWidth
      cmp rectBX
      bcc NoCollision

      ; B right edge vs A left edge
      lda rectBX
      clc
      adc rectBWidth
      cmp rectAX
      bcc NoCollision

      ; A bottom edge vs B top edge
      lda rectAY
      clc
      adc rectAHeight
      cmp rectBY
      bcc NoCollision

      ; B bottom edge vs A top edge
      lda rectBY
      clc
      adc rectBHeight
      cmp rectAY
      bcc NoCollision

      ; Failed all exemption tests meaning they DO COLLIDE
      lda #1
      rts

  CircleCircleCollision:
      ; Find the absolute difference between the centre X positions
      lda circleAX
      cmp circleBX
      bcc CircleX_AIsLeft

      sec
      sbc circleBX
      sta circleDX
      jmp CircleX_Done

  CircleX_AIsLeft:
      lda circleBX
      sec
      sbc circleAX
      sta circleDX

  CircleX_Done:
      ; Find the absolute difference between the centre Y positions
      lda circleAY
      cmp circleBY
      bcc CircleY_AIsAbove

      sec
      sbc circleBY
      sta circleDY
      jmp CircleY_Done

  CircleY_AIsAbove:
      lda circleBY
      sec
      sbc circleAY
      sta circleDY

  CircleY_Done:
      ; Add the radii
      clc
      lda circleARadius
      adc circleBRadius
      sta circleRadiusSum

      ; If either center difference is greater than the radius sum, they can defenitely not touch
      lda circleDX
      cmp circleRadiusSum
      bcc CircleDxAllowed
      beq CircleDxAllowed
      jmp NoCollision

  CircleDxAllowed:
      lda circleDY
      cmp circleRadiusSum
      bcc CircleDyAllowed
      beq CircleDyAllowed
      jmp NoCollision

  CircleDyAllowed:
      ; Calculate dx squared
      lda circleDX
      sta multiplyA
      sta multiplyB
      jsr Multiply8x8

      lda productLow
      sta circleDistanceLow
      lda productHigh
      sta circleDistanceHigh

      ; Calculate dy squared and add it to dx squared
      lda circleDY
      sta multiplyA
      sta multiplyB
      jsr Multiply8x8

      clc
      lda circleDistanceLow
      adc productLow
      sta circleDistanceLow
      lda circleDistanceHigh
      adc productHigh
      sta circleDistanceHigh

      ; Calculate the square of the sum of the radii
      lda circleRadiusSum
      sta multiplyA
      sta multiplyB
      jsr Multiply8x8

      ; Compare dx squared + dy squared against the square of the radius sum.
      lda circleDistanceHigh
      cmp productHigh
      bcc CircleCollision
      bne NoCollision

      lda circleDistanceLow
      cmp productLow
      bcc CircleCollision
      beq CircleCollision
      jmp NoCollision

  CircleCollision:
      lda #1
      rts

  NoCollision:
      lda #0
      rts
; End Collision logic

; Begin Mathematics logic
  Multiply8x8:
	; Copy factorB into multiplicand lower 8 to be iterated and added to final product
      lda factorB
      sta multiplicandLower8
      lda #0
      sta multiplicandHigher8

      ; Clear the 16-bit final product
      sta productLower8
      sta productHigher8

      ldx #8                  ; Process all 8 bits of factorA

  MultiplyLoop:
      lsr factorA          	; Shift next bit into carry
      bcc MultiplySkipAdd     ; If bit is 0, skip addition

      clc
      lda productLower8
      adc multiplicandLower8
      sta productLower8

      lda productHigher8
      adc multiplicandHigher8
      sta productHigher8

  MultiplySkipAdd:
      asl multiplicandLower8    ; Shift working value left by one bit
      rol multiplicandHigher8   ; Carry moves into higher byte

      dex
      bne MultiplyLoop
      rts


; Input Detection
  ; Move the last parsed buttons to old
  lda buttons 
  sta buttons_old 
  
  ; Ready input detection
  lda #1
  sta $4016     ; strobe on: the controller captures the button states
  sta buttons   ; Reset buttons to %00000001

  lsr a       ; Shift A right, its value is now %00000000
  sta $4016   ; Strobe off, buttons can now be read sequentially

  @read_input:
    lda $4016         ; next button arrives in bit 0
    lsr a             ; shift bit 0 to carry
    rol buttons       ; shift carry into buttons
    bcc @read_input   ; if carry == 0

  ; Check if A was pressed this frame specifically
  lda buttons_old
  eor #$ff        ; Invert: 1 = not held last frame
  and buttons     ; Keep only buttons that are held
  and #%10000000  ; Keep only bit 7 (A button)
  beq @no_a       ; if a == 0


; Input handling
  ; On A down:
  inc color_index   ; Select next colour

  lda color_index
  cmp #6  
  bcc @store  ; If color_index < 6

  lda #0  ; Reset color index to 0
  @store:
    sta color_index

@no_a:


; Drawing: write the chosen colour to $3F00 (the universal background colour)
  lda $2002   ; Reading this resets the PPU address latch

  ; store PPU adress -> $3F00 (start of palette RAM)
  lda #$3f
  sta $2006   ; Write high byte PPU adress
  lda #$00
  sta $2006   ; Write low byte PPU adress 

  ; Get color from list
  ldx color_index     
  lda colors, x   ; select color in list
  sta $2007       ; Write it to $3F00 

  lda #0      ; Reset A
  sta $2005   ; Reset scrolling X
  sta $2005   ; Reset scrolling
  rti


colors:
  .byte $2a   ; green
  .byte $16   ; red
  .byte $12   ; blue
  .byte $28   ; yellow
  .byte $30   ; white
  .byte $0f   ; black
colors_end:

.segment "OAM"
	oam: .res $100					; reserve 256 bytes OAM

  .segment "TILES"
