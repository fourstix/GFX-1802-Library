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
;   then sets pixels to draw a triangle.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_draw_triangle
;
; Write lines in the display buffer to draw a triangle  
; with corners at (x0, y0) (x1, y1) and (x2, y2).
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
            proc    gfx_draw_triangle
            
            ;-------------------------------------------      
            ; Make sure corners are in bounds
            ;-------------------------------------------
            
            ;------ check corner 0
            call    gfx_check_bounds
            lbdf    dt_exit

            ;------ check corner 1                          
            push    r7        ; save corner 0 value
            copy    r8, r7    ; copy corner 1 for bounds check
            call    gfx_check_bounds
            pop     r7        ; restore corner 0 x,y
            lbdf    dt_exit   ; if out of bounds return error
            
            ;------ check corner 2                          
            push    r7        ; save corner 0 value
            copy    ra, r7    ; copy corner 2 for bounds check
            call    gfx_check_bounds
            pop     r7        ; restore origin x,y
            lbdf    dt_exit   ; if out of bounds return error


            push    ra        ; save registers used in gfx_write_line
            push    r9        
            push    r8
            push    r7
            
            ;-------------------------------------------
            ; Draw line from p1 to p2
            ;-------------------------------------------            
            call    gfx_write_line
            pop     r7        ; restore registers
            pop     r8
            pop     r9
            pop     ra

            ;-------------------------------------------
            ; Draw line from p2 to p3
            ;-------------------------------------------
            push    ra        ; save registers used in gfx_write_line
            push    r9        
            push    r8
            push    r7
            
            copy    r8, r7    ; copy p2 to origin
            copy    ra, r8;   ; copy p3 to endpoint
            call    gfx_write_line
            
            pop     r7        ; restore registers
            pop     r8
            pop     r9
            pop     ra
            
            ;-------------------------------------------
            ; Draw line from p1 to p3
            ;-------------------------------------------
            push    ra        ; save registers used in gfx_write_line
            push    r9        
            push    r8
            push    r7
            
            copy    ra, r8    ; copy p3 as endpoint
            call    gfx_write_line
            
            pop     r7        ; restore registers
            pop     r8
            pop     r9
            pop     ra

dt_exit:    return
            
            endp
