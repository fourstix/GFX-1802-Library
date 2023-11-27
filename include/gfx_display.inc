;-------------------------------------------------------------------------------
; The following methods need to be implemented in any device library that uses 
; methods in the Gfx library.  These methods are called by the GFX API methods 
; and they encapsulate the device specific display details. These routines 
; were written in 1802 Assembler code based on the Adafruit_GFX-Library
; written by Ladyada Limor Fried.
;
; Based on code from Adafruit_GFX library
; Written by Limor Fried/Ladyada for Adafruit Industries  
; Copyright 2012 by Adafruit Industries
; Please see https://learn.adafruit.com/adafruit-gfx-graphics-library for more info
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; GFX Display interface
;-------------------------------------------------------------------------------
            extrn   gfx_disp_size
            extrn   gfx_disp_clear
            extrn   gfx_disp_pixel      
            extrn   gfx_disp_h_line 
            extrn   gfx_disp_v_line 
