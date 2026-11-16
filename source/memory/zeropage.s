.ifndef ZEROPAGE_S
ZEROPAGE_S = 1

.segment "ZEROPAGE"

; ==========================================
; ZERO PAGE ($00 - $FF)
; Create variables and assign location in zero page
; ==========================================

; Collision detection
rectAX:			.res 1
rectAY:			.res 1
rectAWidth:		.res 1
rectAHeight:		.res 1

rectBX:			.res 1
rectBY:			.res 1
rectBWidth:		.res 1
rectBHeight:		.res 1

circleAX:		.res 1
circleAY:		.res 1
circleARadius:		.res 1

circleBX:		.res 1
circleBY:		.res 1
circleBRadius:	.res 1

; Multiplication
factorA:			.res 1
factorB:			.res 1
productLower8:		.res 1
productHigher8:		.res 1
multiplicandLower8:	.res 1
multiplicandHigher8:	.res 1

; Circle collision
circleDX:		.res 1
circleDY:		.res 1
circleRadiusSum:		.res 1
circleDistanceLow:	.res 1
circleDistanceHigh:	.res 1

; Controller
buttons:			.res 1
buttons_old:		.res 1

; Graphics
color_index:		.res 1

.endif ; ZEROPAGE_S