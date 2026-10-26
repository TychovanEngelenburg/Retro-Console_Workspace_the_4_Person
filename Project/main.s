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

; Bits to button order: A   B  Select  Start  Up  Down  Left  Right (carry: held)
buttons     = $00   ; Buttons held this frame
buttons_old = $01   ; Buttons held the previous frame

color_index = $02   ; Which color entry is selected

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

  ;if you read this you are gay