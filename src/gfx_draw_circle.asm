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
;   then sets pixels to draw a circle.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_draw_circle
;
; Set pixels in the display buffer to draw a circle at 
; the origin x0, y0 with a radius r.
;
; Parameters: 
;   r7.1 - origin y 
;   r7.0 - origin x 
;   r8.0 - radius r
; Registers Used:
;   r8.1 - quadrants to draw
; Note: Checks origin x,y values, error if out of bounds
;                  
; Return: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    gfx_draw_circle
            
            ;------ make sure origin is within display
            call    gfx_check_bounds
            lbdf    dc_exit            
            
            call    gfx_check_radius
            lbdf    dc_exit
            
            push    r9        ; save registers used in gfx_write_circle
            push    r8
            push    r7
                      
            ldi     FULL_CIRCLE
            phi     r8        ; draw all quadrant arcs to make a circle
            call    gfx_write_arc

            pop     r7        ; restore registers
            pop     r8
            pop     r9

dc_exit:    return
            
            endp
