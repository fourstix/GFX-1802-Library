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
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------
;-------------------------------------------------------
; Name: gfx_check_bounds
;
; Check to see if signed byte values for a point x,y 
; are inside of the display boundaries.
;
; Parameters: 
;   r7.1 - y (display line, 0 to 7)
;   r7.0 - x (pixel offset, 0 to 7)
;
; Registers Used:
;   ra.1 - device height
;   ra.0 - device width
;
; Note: Values x and y are signed byte values
;             
; Return: DF = 1 if error
;              ie x >= width or x < 0 or y >= height or y < 0 
;         DF = 0 if no error
;              ie 0 <= x < width and 0 <= y < height
;-------------------------------------------------------
            proc    gfx_check_bounds            
            push    ra                ; save size register
            call    gfx_disp_size     ; ra.1 = height, ra.0 = width

            ghi     r7                ; check y value
            str     r2                ; save in M(X)
            ghi     ra                ; get device height
            sd                        ; y0 >= height is an error
            lbdf    xy_done           ; if out of bounds, exit immediately
            
            glo     r7                ; check x value
            str     r2                ; save in M(X)
            glo     ra                ; get device width
            sd                        ; x0 >= width is an error
  
xy_done:    pop     ra                ; restore size register
            return

            endp
