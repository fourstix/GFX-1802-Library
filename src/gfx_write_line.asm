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
; Name: gfx_write_line
;
; Write a line in the display buffer from position r7
; to position r8. 
;
; Parameters: r7.1 - origin y 
;             r7.0 - origin x 
;             r8.1 - endpoint y 
;             r8.0 - endpoint x 
;             r9.1 - color
;             r9.0 - rotation
; Registers Used:
;             ra.0 - temp value, steep flag
;                  
; Return: r7, r8, r9 - consumed
;-------------------------------------------------------
            proc    gfx_write_line
            push    ra                ; save temp register
            
            ghi     r7                ; get origin y
            str     r2                ; save at M(X)
            ghi     r8                ; get endpoint y
            sd                        ; check for horizontal line 
            lbnz    wl_vchk           ; if not zero check for vertical line

            glo     r7                ; get origin x
            str     r2                ; save at M(X)
            glo     r8                ; get endpoint x
            sm                        ; length = Endpoint - Origin
            plo     ra                ; put in temp register
            lbdf    wl_horz           ; if positive, we're good to go

            glo     ra                ; get negative length 
            sdi     0                 ; negate it (-D = 0 - D)
            plo     ra                ; put length in temp register
            xchg    r7,r8             ; exchange values so origin is left of endpoint

wl_horz:    glo     ra                ; get length from temp register
            plo     r8                ; set line length
            call    gfx_disp_h_line
            lbr     wl_done

wl_vchk:    glo     r7                ; get origin x
            str     r2                ; save at M(X)
            glo     r8                ; get endpoint x
            sm
            lbnz    wl_slant          ; if not vertical, then slanted
                        
            ghi     r7                ; get origin y
            str     r2                ; save at M(X)
            ghi     r8                ; get endpoint y
            sm                        ; length = endpoint - origin
            plo     ra                ; put in temp register
            lbdf    wl_vert           ; if positive, we're good 

            glo     ra                ; get negative length
            sdi     0                 ; negate length 
            plo     ra                ; put length in temp register
            xchg    r7,r8             ; make sure origin is above endpoint
            
wl_vert:    glo     ra                ; get length from temp register
            plo     r8                ; set line length
            call    gfx_disp_v_line
            lbr     wl_done
            
            ; ra.0 is used as steep flag for drawing a sloping line             
wl_slant:   call    gfx_steep_flag          

            glo     ra                ; check steep flag
            lbz     wl_schk           ; if not steep, jump to check for exchange
            
            ; for steep line, swap x,y bytes for origin and endpoint values
            swap    r7                ; for steep line, swap origin x,y to y,x      
            swap    r8                ; for steep line, swap endpoint x,y to y,x

wl_schk:    glo     r7                ; make sure origin x is left of endpoint x
            str     r2                ; save origin x at M(X)
            glo     r8                ; get endpoint x
            sm                             
            lbdf    wl_slope          ; if positive, the okay (x1 - x0 > 0)

            xchg    r7,r8             ; exchange registers so origin is left of endpoint       
   
wl_slope:   call    gfx_write_s_line  ; draw a sloping line   

wl_done:    pop     ra                ; restore temp register
            clc                       ; make sure DF = 0
            return
            
            endp
