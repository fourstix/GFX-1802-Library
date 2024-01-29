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
;   then sets pixels to fill a triangle.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_fill_triangle
;
; Set pixels in the display buffer to draw a solid   
; triangle with corners at (x0, y0) (x1, y1) and (x2, y2).
;
; Parameters: 
;   r7.1 - y0 
;   r7.0 - x0 
;   r8.1 - y1 
;   r8.0 - x1
;   r9.1 - color 
;   r9.0 - rotation  
;   ra.1 - y2 
;   ra.0 - x2
; 
; Note: Checks x,y values, error if out of bounds
;                  
; Return: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    gfx_fill_triangle

            ;-------------------------------------------      
            ; Make sure corners are in bounds
            ;-------------------------------------------
            
            ;------ check corner 0 in r7
            call    gfx_check_bounds
            lbdf    ft_exit

            ;------ check corner 1 in r8                         
            push    r7        ; save corner 0 value
            copy    r8, r7    ; copy corner 1 for bounds check
            call    gfx_check_bounds
            pop     r7        ; restore corner 0 x,y
            lbdf    ft_exit   ; if out of bounds return error
            
            ;------ check corner 2 in ra                          
            push    r7        ; save corner 0 value
            copy    ra, r7    ; copy corner 2 for bounds check
            call    gfx_check_bounds
            pop     r7        ; restore corner 0 x,y
            lbdf    ft_exit   ; if out of bounds return error

            push    ra        ; save parameter registers
            push    r9        
            push    r8
            push    r7
            
            call   gfx_write_wedge
                    
            pop     r7        ; restore parameter registers
            pop     r8
            pop     r9
            pop     ra
            
ft_exit:    return
            
            endp
