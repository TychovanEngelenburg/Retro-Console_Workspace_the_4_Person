.ifndef INPUT_S ; Include guard
INPUT_S = 1

.segment "CODE"
    .proc read_input
        ; Input Detection
        ; Move the last parsed buttons to old
        lda buttons 
        sta buttons_old 
        
        ; Ready input detection
        lda #1
        sta CONTROLLER1     ; strobe on: the controller captures the button states
        sta buttons   ; Reset buttons to %00000001

        lsr a       ; Shift A right, its value is now %00000000
        sta CONTROLLER1   ; Strobe off, buttons can now be read sequentially

        @read_input:
            lda CONTROLLER1         ; next button arrives in bit 0
            lsr a             ; shift bit 0 to carry
            rol buttons       ; shift carry into buttons
            bcc @read_input   ; if carry == 0

        ; Check if A was pressed this frame specifically
        lda buttons
        and #BUTTON_LEFT
        beq LEFT_NOT_PRESSED   ; if left == 0
            lda rectAX ; get the current X position
            ; cmp #0 ; bounding check with the screen on the left
            ; beq LEFT_NOT_PRESSED ; if on the left of the screen, skip to the next input check
            sec ; set the carry flag, for substraction
            sbc #1 ; move 1 to the left
            ; Here wall check
            sta rectAX ; store the new position


        LEFT_NOT_PRESSED:
            lda buttons
            and #BUTTON_RIGHT
            beq RIGHT_NOT_PRESSED
                lda rectAX ; get current x position
                ; cmp #SCREEN_WIDTH ; check if position is at the right screen boundary
                ; beq RIGHT_NOT_PRESSED ; if its against the wall, skip to the next input
                clc ; clear carry for addition
                adc #1 ; add one to the accumulator
                ; Here wall check
                sta rectAX ; store the new position
        
        RIGHT_NOT_PRESSED:
            lda buttons
            and #BUTTON_UP
            beq UP_NOT_PRESSED
                lda rectAY ; get current y position
                ; cmp #0 ; check if position is at the top of the screen
                ; beq UP_NOT_PRESSED ; move on if it is at the top of the screen
                sec ; set carry flag for substraction
                sbc #1 ; move 1 up
                ; Here wall check
                sta rectAY ; store the new position

        UP_NOT_PRESSED:
            lda buttons
            ; eor #$ff        ; Invert: 1 = not held last frame
            ; and buttons     ; Keep only buttons that are held
            and #BUTTON_DOWN
            beq RETURN
                lda rectAY ; get current y position
                ; cmp #SCREEN_HEIGHT ; check if position is at the bottom of the screen
                ; beq RETURN ; continue with the main loop if it is
                clc ; clear the carry flag for addition
                adc #1 ; add 1 to the accumulator
                ; Here wall check
                sta rectAY ; store the new position

        RETURN:
            rts
    .endproc
; End segment CODE
.endif ; INPUT_S