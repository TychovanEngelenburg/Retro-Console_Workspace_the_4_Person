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



; =============================
; Startup process
; =============================

; =============================
; Game states
; =============================

STATE_TITLE     = 0
STATE_PLAYING   = 1
STATE_DEAD      = 2
STATE_GAME_OVER = 3

; =============================
; Game variables
; =============================

game_state    = $03
current_level = $04
level_start_x = $05
level_start_y = $06
lives         = $07

STARTING_LIVES = 3

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

; =============================
; Game state handling
; =============================

; Check current state
lda game_state

cmp #STATE_TITLE
bne :+
jmp @title_state
:

cmp #STATE_PLAYING
bne :+
jmp @playing_state
:

cmp #STATE_DEAD
bne :+
jmp @dead_state
:

cmp #STATE_GAME_OVER
bne :+
jmp @game_over_state
:

jmp @state_done
; =============================
; TITLE STATE
; =============================

@title_state:

    ; Check if START was newly pressed
    lda buttons_old
    eor #$ff
    and buttons
    and #%00010000
    beq @state_done

    ; Start the game
    lda #0
    sta current_level

    lda #STARTING_LIVES
    sta lives

    jsr LoadLevel

    lda #STATE_PLAYING
    sta game_state

    jmp @state_done
; END @title_state

; =============================
; PLAYING STATE
; =============================

@playing_state:

  ;check if B is pressed (should be the 6th bit in our controller variable)
  lda buttons_old
  eor #$ff
  and buttons
  and #%01000000
  beq @check_next_level

  ;player died
  dec lives 
  lda lives
  beq @go_game_over

  ;lives remain -> enter death state
  lda #STATE_DEAD
  sta game_state
  jmp @state_done

  @go_game_over:
    lda #STATE_GAME_OVER
    sta game_state
    jmp @state_done


  @check_next_level:
    ; A = next level (temporary for now, due to testign purposes)
    lda buttons_old
    eor #$ff
    and buttons
    and #%10000000
    beq @state_done

    inc current_level
    lda current_level
    cmp #3
    bcc @load_next_level
    
    ; after level 3 we go back to 1
    lda #0
    sta current_level

  @load_next_level:
    jsr LoadLevel
    jmp @state_done


; =============================
; DEAD STATE
; =============================

@dead_state:

  ;press Start to retry current level
  lda buttons_old
  eor #$ff
  and buttons
  and #%00010000
  beq @state_done

  ;Reload Current Level
  jsr LoadLevel

  lda #STATE_PLAYING
  sta game_state

  jmp @state_done


; =============================
; GAME OVER STATE
; =============================

@game_over_state:

    ; Press START to begin a new game
    lda buttons_old
    eor #$ff
    and buttons
    and #%00010000
    bne :+
    jmp @state_done
:

    ; Reset level and lives
    lda #0
    sta current_level

    lda #STARTING_LIVES
    sta lives

    jsr LoadLevel

    lda #STATE_PLAYING
    sta game_state

    jmp @state_done

@state_done:
    ; Reset PPU address latch
    lda $2002

    ; Set PPU address to $3F00
    lda #$3f
    sta $2006

    lda #$00
    sta $2006
;END @state_done

; =============================
; DRAW BACKGROUND BASED ON STATE
; =============================

    lda game_state

    cmp #STATE_TITLE
    beq @draw_title

    cmp #STATE_PLAYING
    beq @draw_level

    cmp #STATE_DEAD
    beq @draw_dead

    cmp #STATE_GAME_OVER
    beq @draw_game_over

    ; Fallback color
    lda #$0f
    jmp @write_color


@draw_title:
    lda #$0f          ; Black
    jmp @write_color


@draw_level:
    ldx current_level
    lda level_colors, x
    jmp @write_color


@draw_dead:
    lda #$28          ; Yellow
    jmp @write_color


@draw_game_over:
    lda #$30          ; White


@write_color:
    sta $2007

    ; Reset scrolling
    lda #0
    sta $2005
    sta $2005

    rti


level_colors:
  .byte $2a   ; green for level 1
  .byte $12   ; blue for level 2
  .byte $16   ; red for level 3
level_colors_end:

; =============================
; LEVEL LOADING
; =============================

LoadLevel:
    ldx current_level

    ; Load player starting position
    lda level_start_positions_x, x
    sta level_start_x

    lda level_start_positions_y, x
    sta level_start_y

    rts


; Temporary level data
level_start_positions_x:
    .byte 40, 100, 180

level_start_positions_y:
    .byte 100, 80, 120



.segment "OAM"
	oam: .res $100					; reserve 256 bytes OAM

  .segment "TILES"

  ;if you read this you are gay