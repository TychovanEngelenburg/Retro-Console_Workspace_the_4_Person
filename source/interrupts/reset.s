; =============================
; This script handles the startup process.
; So setup before the game and clearing/getting memory ready.
;
; Contributors: 
; Tycho van E.
; =============================

.ifndef RESET_S
RESET_S = 1

.include "./macros.inc"
.include "./resources/resources.inc"

.include "./constants.inc"
.include "./level/level_logic.s"



.segment "STARTUP"
  ; Unused, but needs to be defined for the build to be successful.
; endsegment STARTUP



.segment "CODE"

  .proc reset_handler
    sei   ; Disable IRQs
    cld   ; Disable decimal mode

    ldx #$40
    stx APU_FRAME                 ; disable APU frame IRQ

    ; Set stack pointer to its starting value
    ldx #$ff  ; X = 255
    txs       ; Stack pointer = x  

    inx           ; X = 0
    stx APU_DMC   ; disable DMC IRQ 

    jsr ppu_disable       ; Turn off the PPU       
    jsr ppu_wait_vblank   ; Wait for vblank so nothing ppu related is happening anymore

    ; Clear internal RAM. Takes a while 
    ; TODO: make own process?
    @clear_ram: 
      lda #$00      ; A = 0, all memory i nram will be set to this (X is still 0)
      sta $0000, x  ; zero page
      sta $0100, x  ; stack
      sta $0200, x  ; oam buffer (cleared properly later)
      sta $0300, x  ; general RAM
      sta $0400, x
      sta $0500, x
      sta $0600, x
      sta $0700, x

      inx
      bne @clear_ram  ; if x != 0 continue loop (x wraps as unsigned byte)
    ; End @clear_ram

    jsr ppu_wait_vblank   ; Wait until another vblank for the PPU to be ready

    ; Sprite and oam clearing
    jsr ppu_clear_oam
    jsr ppu_load_palette  
    jsr ppu_oam_dma

    ; Background and nametable clearing
    jsr ppu_clear_nametable
   
    lda #0
    sta ppu_frame_ready  ; Start with no pending frame.

    LOAD_LEVEL level1

    jsr ppu_enable  ; Turn the PPU back on
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; TODO: MOVE ELSEWHERE
    ; initial player position
    lda #100
    sta rectAX
    sta rectAY
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    jmp MainLoop ; Automatically flows into forever
  .endproc

; endsegment CODE

.endif ; RESETS_S