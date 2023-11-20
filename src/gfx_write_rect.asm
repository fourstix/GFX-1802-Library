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
; Name: gfx_write_rect
;
; Set pixels for a rectangle in the display buffer at 
; position x,y.
;
; Parameters: 
;   r9.1 - color
;   r8.1 - h 
;   r8.0 - w 
;   r7.1 - origin y 
;   r7.0 - origin x 
;
; Registers Used:
;   rb - origin
;   ra - dimensions
;
; Return:
;   DF = 1 if error, 0 if no error (r7 & r9 consumed)
;-------------------------------------------------------
            proc    gfx_write_rect

            push    rb        ; save dimension registers
            push    ra        ; save origin register
            
            copy    r7, ra    ; save origin 
            copy    r8, rb    ; save dimensions
            
            glo     r8        ; get w for length
            plo     r9        ; set up length of horizontal line

            call    gfx_disp_h_line  ; draw top line 
            lbdf    wr_done          ; if error, exit immediately

            copy    ra, r7    ; restore origin
            copy    rb, r8    ; restore w and h values
            ghi     r8        ; get h for length
            plo     r9        ; set up length of vertical line

            call    gfx_disp_v_line ; draw left line
            lbdf    wr_done         ; if error, exit immediately
            
            copy    rb, r8    ; restore h and w values
            glo     ra        ; get origin x
            plo     r7        ; restore origin x
            ghi     ra        ; get origin y
            str     r2        ; put y0 in M(X)
            ghi     r8        ; get h
            add               ; D = y0 + h
            phi     r7        ; set new origin at lower left corner
            glo     r8        ; get w for length
            plo     r9        ; set length for horizontal line

            call    gfx_disp_h_line ; draw bottom line
            lbdf    wr_done         ; if error, exit immediately
            
            copy    rb, r8    ; restore w and h values
            ghi     ra        ; get origin y
            phi     r7        ; restore origin y
            glo     ra        ; get origin x
            str     r2        ; put x0 in M(X)
            glo     r8        ; get w
            add               ; D = x0 + w
            plo     r7        ; set origin to upper right corner
            ghi     r8        ; get h for length
            plo     r9        ; set length for vertical line

            call    gfx_disp_v_line   ; draw right line
            
wr_done:    pop     ra         ; restore registers
            pop     rb
            return 
            endp  
