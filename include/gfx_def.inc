;-------------------------------------------------------------------------------
; This library contains routines to support a graphics library 
; written in 1802 Assembler code based on the Adafruit_GFX-Library
; written by Ladyada Limor Fried.
;
; Based on code from Adafruit_GFX library
; Written by Limor Fried/Ladyada for Adafruit Industries  
; Copyright 2012 by Adafruit Industries
; Please see https://learn.adafruit.com/adafruit-gfx-graphics-library for more info
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Character constants
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
; Graphics routines used by other GFX library routines
;-------------------------------------------------------------------------------
            extrn   gfx_check_bounds  
            extrn   gfx_adj_bounds  
            extrn   gfx_write_pixel      
            extrn   gfx_write_bitmap      
            extrn   gfx_check_overlap  
            extrn   gfx_ascii_font  
            extrn   gfx_write_char      
            extrn   gfx_write_rect
            extrn   gfx_write_block  
            extrn   gfx_write_h_line 
            extrn   gfx_write_v_line 
            extrn   gfx_write_s_line 
            extrn   gfx_steep_flag 
            extrn   gfx_write_line 
            extrn   gfx_check_cursor
            extrn   gfx_adj_cursor
