 .ifndef RESET_S
 RESET_S = 1

 .include "./constants.inc"

  ; =============================
  ; Startup process
  ; =============================

; .segment "CODE"

.segment "STARTUP"

.segment "CODE"
  .proc reset_handler
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
; endsegment STARTUP

.endif ; RESETS_S