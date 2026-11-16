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

NoCollision:
    lda #0
    rts
