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
