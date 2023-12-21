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
            
