; ==========================================
; ZERO PAGE ($00 - $FF)
; Create variables and assign location in zero page
; ==========================================

; Collision detection
rectAX			= $00
rectAY			= $01
rectAWidth		= $02
rectAHeight		= $03

rectBX			= $04
rectBY			= $05
rectBWidth		= $06
rectBHeight		= $07

circleAX		= $08
circleAY		= $09
circleARadius		= $0A

circleBX		= $0B
circleBY		= $0C
circleBRadius	= $0D

; Multiplication
factorA			= $0E
factorB			= $0F
productLower8		= $10
productHigher8		= $11
multiplicandLower8	= $12
multiplicandHigher8	= $13

; Circle collision
circleDX		= $14
circleDY		= $15
circleRadiusSum		= $16
circleDistanceLow	= $17
circleDistanceHigh	= $18

; Controller
buttons			= $19
buttons_old		= $1A

; Graphics
color_index		= $1B
