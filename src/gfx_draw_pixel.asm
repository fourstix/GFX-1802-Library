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

#include    ../include/ops.inc
#include    ../include/gfx_display.inc
#include    ../include/gfx_def.inc  


;-------------------------------------------------------
; Public routine - This routine validate inputs and 
;   then sets a single pixel.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_draw_pixel
;
; Set a pixel in the display buffer at position x,y.
;
; Parameters: 
;   r7.1 - y 
;   r7.0 - x 
;   r9.1 - color
;   r9.0 - rotation  
;
; Note: 
;   Checks x,y values, doesn't draw if out of bounds
;                  
; Return: 
;   DF = 1 if error, 0 if no error
; 
;-------------------------------------------------------
            proc   gfx_draw_pixel
            
            call   gfx_check_bounds
            lbdf   dp_exit    ; exit immediately if out of bounds

            call   gfx_write_pixel  
dp_exit:    return
            
            endp
