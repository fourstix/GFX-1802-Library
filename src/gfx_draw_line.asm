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
;   then sets pixels to draw a line.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_draw_line
;
; Set pixels in the display buffer to draw a line from 
; the origin x0, y0 to endpoint x1, y1.
;
; Parameters: 
;   r7.1 - origin y 
;   r7.0 - origin x 
;   r8.1 - endpoint y 
;   r8.0 - endpoint x 
;
; Note: Checks x,y values, error if out of bounds
;                  
; Return: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    gfx_draw_line

            call    gfx_check_bounds
            lbdf    dl_exit
 
                         
dl_chk:     push    r7        ; save origin value
            copy    r8, r7    ; copy endpoint for bounds check
            call    gfx_check_bounds
            pop     r7        ; restore origin x,y
            lbdf    dl_exit   ; if out of bounds return error

            push    r9        ; save registers used in gfx_write_line
            push    r8
            push    r7
                      
            call    gfx_write_line
            pop     r7        ; restore registers
            pop     r8
            pop     r9

dl_exit:    return
            
            endp
