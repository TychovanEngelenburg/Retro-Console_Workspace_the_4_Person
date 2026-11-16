.ifndef CONSTANTS_INC ; Include guard
CONSTANTS_INC = 1

; =============================
; PPU Registers
; =============================
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007

OAMDMA    = $4014



; =============================
; PPUCTRL Masks
; =============================
PPUCTRL_NAMETABLE_1         = %00000001
PPUCTRL_NAMETABLE_2         = %00000010
PPUCTRL_VRAM_INCREMENT_32   = %00000100
PPUCTRL_SPRITE_PATTERN_HIGH = %00001000
PPUCTRL_BG_PATTERN_HIGH     = %00010000
PPUCTRL_SPRITE_SIZE_8X16    = %00100000
; PPUCTRL_MASTER_SLAVE      = %01000000 DO NOT USE. This is broken.
PPUCTRL_NMI_ENABLED         = %10000000



; =============================
; PPUMASK Masks
; =============================
PPUMASK_GRAYSCALE         = %00000001
PPUMASK_SHOW_BG_LEFT      = %00000010
PPUMASK_SHOW_SPRITES_LEFT = %00000100
PPUMASK_SHOW_BACKGROUND   = %00001000
PPUMASK_SHOW_SPRITES      = %00010000
PPUMASK_EMPHASIZE_RED     = %00100000
PPUMASK_EMPHASIZE_GREEN   = %01000000
PPUMASK_EMPHASIZE_BLUE    = %10000000



; =============================
; PPUSTATUS Masks
; =============================
PPUSTATUS_VBLANK       = %10000000
PPUSTATUS_SPRITE_ZERO  = %01000000
PPUSTATUS_SPRITE_OVERFLOW = %00100000



; =============================
; APU / Controller
; =============================
APU_DMC     = $4010
APUSTATUS   = $4015
APU_FRAME   = $4017

CONTROLLER1 = $4016
CONTROLLER2 = $4017
; CONTROLLER3 = $4016   ; Only relevant for FourScore
; CONTROLLER4 = $4017   ; Only relevant for FourScore



; =============================
; Screen Dimensions
; =============================
SCREEN_WIDTH  = 256
SCREEN_HEIGHT = 240



; =============================
; Tile IDs
; =============================
TILE_EMPTY  = 0
TILE_SQUARE = 1
TILE_CIRCLE = 2
TILE_SMILEY = 3



; =============================
; Sprite / OAM
; =============================
OAM_SPRITE_SIZE = 4
OAM_MAX_SPRITES = 64

OAM_Y          = 0
OAM_TILE       = 1
OAM_ATTRIBUTES = 2
OAM_X          = 3



; =============================
; Sprite Attribute Masks
; =============================
SPRITE_FLIP_VERTICAL   = %10000000
SPRITE_FLIP_HORIZONTAL = %01000000
SPRITE_PRIORITY_BG     = %00100000

SPRITE_PALETTE_0       = %00000000
SPRITE_PALETTE_1       = %00000001
SPRITE_PALETTE_2       = %00000010
SPRITE_PALETTE_3       = %00000011



; =============================
; Controller Button Masks
; =============================
BUTTON_A      = %00000001
BUTTON_B      = %00000010
BUTTON_SELECT = %00000100
BUTTON_START  = %00001000
BUTTON_UP     = %00010000
BUTTON_DOWN   = %00100000
BUTTON_LEFT   = %01000000
BUTTON_RIGHT  = %10000000

.endif ; CONSTANTS_INC