; ==========================================
; INTERRUPT VECTORS
; ==========================================

; Basically important internal events
.segment "VECTORS"
  .addr nmi     ; When an NMI happens (once per frame if enabled) the label nmi:
  .addr reset   ; When the processor first turns on or is reset, it will jump to the label reset
  .addr 0       ; External interrupt IRQ (unused)
;