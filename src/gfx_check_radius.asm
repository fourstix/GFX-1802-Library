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
; Name: gfx_check_radius
;
; Check that the circle falls within the boundaries of
; the display.
;
; Parameters:
;   r7.0 - origin X0
;   r7.1 - origin y0 
;   r8.0 - radius r
;   r8.1 - quadrants
;   r9.0 - rotation
;
; Registers Used:
;   ra.1 - device Ymax
;   ra.0 - device Xmax
;
; Return: 
;   DF = 1 if error, ie
;     x0 + r > Xmax, x0 - r < 0 or  
;     y0 + r > Ymax, y0 - r < 0
;     
;   DF = 0 if no error, ie
;     x0 + r <= Xmax, x0 - r >= 0 and  
;     y0 + r <= Ymax, y0 - r >= 0
;-------------------------------------------------------
            proc    gfx_check_radius 
            push    ra                ; save size register
            
            call    gfx_dimensions    ; ra.1 = Ymax, ra.0 = Xmax

            push    r7                ; save origin before bounds check     
            
            ;------- check origin minus radius
            glo     r8                ; get radius
            str     r2                ; save in M(X)
            glo     r7                ; get origin x0
            sm                        ; x1 = x0 - r
            plo     r7                ; save x1 for bounds check
            ghi     r7                ; get origin y0
            sm                        ; y1 = y0 - r
            phi     r7                ; save y1 for bounds check
            
            call    gfx_check_bounds  ; check (x1,y1) within bounds
            
            pop     r7                ; restore origin

            lbdf    r_done            ; if out of bounds, we are done

            push    r7                ; save origin before bounds check     
                        
            ;------ check origin plus radius
            glo     r8                ; get radius
            str     r2                ; save in M(X)
            glo     r7                ; get origin x0
            add                       ; x2 = x0 + r
            plo     r7                ; save x2 for bounds check
            ghi     r7                ; get origin y0
            add                       ; y2 = y0 + r
            phi     r7                ; save y2 for bounds check
            
            call    gfx_check_bounds  ; check (x1,y1) within bounds
            
            pop     r7                ; restore origin

r_done:     pop     ra                ; restore size register
            return

            endp
