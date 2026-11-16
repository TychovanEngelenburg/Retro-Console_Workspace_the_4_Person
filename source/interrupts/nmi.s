.ifndef NMI_S
NMI_S = 1

.include "./constants.inc"

  ; =============================
  ; NMI (Non Maskable Interrupt)
  ; This is called at the start of vblank
  ; =============================

.segment "CODE"


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
; endsegment CODE

.endif ; NMI_S