;-------------------------------------------------------------------------------
; Printable Character Constants
;-------------------------------------------------------------------------------

#define C_OFFSET     32
#define C_COUNT      96
#define C_ERROR      95
#define C_WIDTH       6
#define C_HEIGHT      8

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
            
