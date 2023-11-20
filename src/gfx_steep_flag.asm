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
; Name: gfx_steep_flag
;
; Compare absolute values of the x difference and y 
; difference to determine if steeply slanted line. Set
; the steep flag true if steeply slanged, or false
; if not. 
; 
; Parameters: 
;   r7   - origin x,y 
;   r8   - endpoint x,y
;   r9.1 - color
;
; Registers Used:
;   ra   - difference register
;
; Note: A steep line is a line with a larger change in y
; than the change in x.
;                  
; Return: r9.0 - steep flag 
;   steep flag = 1 (true) if steep line
;   steep flag = 0 (false) if not
;-------------------------------------------------------
            proc   gfx_steep_flag
            push   ra       ; save difference register

            glo    r7       ; get origin x value
            str    r2       ; store origin x in M(X)
            glo    r8       ; get endpoint x
            sm              ; subtract origin x in M(X) from endpoint x in D
            plo    ra       ; save x difference in ra.0            
            lbdf   diff_y   ; if positive, calculate y difference

            sdi    0        ; if negative, negate it
            plo    ra       ; put absolute x difference in ra.0

diff_y:     ghi    r7       ; get origin y value
            str    r2       ; store origin y in M(X)
            ghi    r8       ; get endpoint y
            sm              ; subtract origin y in M(X) from endpoint y in D

            phi    ra       ; save y difference in ra.1
            lbdf   st_calc  ; if positive, we can check for steepness

            sdi    0        ; if negative, negate it
            phi    ra       ; put absolute y difference in ra.1

st_calc:    glo    ra       ; get xdiff
            str    r2       ; store in M(X)
            ghi    ra       ; get ydiff
            sm              ; ydiff in D - xdiff in M(X)
            lbdf   is_steep ; if ydiff > xdiff, steep line
            
            ldi    0        ; if ydiff < xdiff, not a steep line
            lskp            ; skip over two bytes that set flag true
            
is_steep:   ldi    $01      ; steep line flag in D
            plo    r9       ; set steep flag in r9.0 for slanted line drawing                                    

            pop    ra       ; retore ra
            return
            
            endp
