;-------------------------------------------------------------------------------
; Printable Character Constants
;-------------------------------------------------------------------------------

#define C_OFFSET     32
#define C_COUNT      96
#define C_ERROR      95
#define C_WIDTH       6
#define C_HEIGHT      8

;-------------------------------------------------------------------------------
; Rotation constants
;-------------------------------------------------------------------------------
#define ROTATE_0      0
#define ROTATE_90     1
#define ROTATE_180    2
#define ROTATE_270    3
#define ROTATE_360    0
#define ROTATE_NONE   0

;-----------------------------------
; Constants for drawing Arcs
;-----------------------------------
#define NW_QUAD       $01
#define NE_QUAD       $02
#define SE_QUAD       $04
#define SW_QUAD       $08

;-------------------------------------------------------------------------------
; Public GFX Library Routines
;-------------------------------------------------------------------------------

            extrn   gfx_draw_pixel
            extrn   gfx_draw_bitmap
            extrn   gfx_draw_char
            extrn   gfx_draw_rect
            extrn   gfx_fill_rect
            extrn   gfx_draw_line
            extrn   gfx_check_bounds
            extrn   gfx_adj_bounds
            extrn   gfx_adj_cursor
            extrn   gfx_dimensions
            extrn   gfx_draw_triangle
            extrn   gfx_fill_triangle
            extrn   gfx_draw_circle
            extrn   gfx_draw_arc
            extrn   gfx_draw_rrect
            extrn   gfx_fill_circle
            extrn   gfx_fill_rrect  
