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


;-----------------------------------
; Constants for drawing Arcs
;-----------------------------------
#define NW_QUAD       $01
#define NE_QUAD       $02
#define SE_QUAD       $04
#define SW_QUAD       $08
#define FULL_CIRCLE   $0F 

;-----------------------------------
; Constants for filling Circles
;-----------------------------------
#define RIGHT_SIDE    $01
#define LEFT_SIDE     $02
#define BOTH_SIDES    $03    

;-----------------------------------
; Public Text constants
;-----------------------------------
#define GFX_TXT_NORMAL    $01
#define GFX_TXT_INVERSE   $00
#define GFX_TXT_OVERLAY   $80


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
            extrn   gfx_fill_rect
            extrn   gfx_write_wedge
            extrn   gfx_math_mul8
            extrn   gfx_math_div8
            extrn   gfx_write_circle
            extrn   gfx_dimensions
            extrn   gfx_check_radius  
            extrn   gfx_write_arc
            extrn   gfx_write_disk
            extrn   gfx_write_quads
            extrn   gfx_write_rrect          
            extrn   gfx_write_oblong          
            extrn   gfx_debug
