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
