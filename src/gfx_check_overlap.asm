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
; Name: gfx_check_overlap
;
; Check to see if a bitmap at origin x,y 
; overlaps the canvas
;
; Parameters: 
;   r7.1 - y origin (upper left corner)
;   r7.0 - x origin (upper left corner)
;   r8.1 - h bitmap height
;   r8.0 - w bitmap width
;
; Registers Used:
;   ra.1 - device height
;   ra.0 - device width
;
; Note: Values x and y are signed byte values. In 
;   the logic below negative values are treated like
;   large positive numbers and subtraction yields an
;   absolute value.
;             
; Return: DF = 1 if outside (nothing to draw)
;         DF = 0 if inside (bitmap overlaps canvas)
;-------------------------------------------------------
            proc    gfx_check_overlap
            push    ra                ; save size register
            call    gfx_disp_size     ; ra.1 = height, ra.0 = width
            
            ; check left corners first
            glo     r7                ; check x value
            str     r2                ; save in M(X)
            glo     ra                ; get device width
            sd                        ; M(X) - D => x0 - width
            lbdf    chk_right         ; if x0 out of range, check right corners
            
            ; check upper left corner
            ghi     r7                ; check y value at upper left corner
            str     r2                ; save in M(X)
            ghi     ra                ; get device height
            sd                        ; any absolute value under height is inside
            lbnf    xy_in             ; if in bounds, exit with DF = 0
            
            ; check lower left corner
            ghi     r7                ; check y value at lower left corner
            str     r2                ; save y0 in M(X)
            ghi     r8                ; get bitmap height
            add                       ; y = y0 + h (signed addition)
            str     r2                ; save in M(X)
            ghi     ra                ; get device height
            sd                        ; any absolute value under height is inside
            lbnf    xy_in             ; if in bounds, exit with DF = 0
            
chk_right:  glo     r7                ; check right corners
            str     r2                ; save x0 in M(X)
            glo     r8                ; get bitmap width
            add                       ; x = x0 + width (signed addition)               
            str     r2                ; save in M(X)
            glo     ra                ; get device width
            sd                        ; any absolute value under width is inside
            lbdf    xy_out            ; if outside, exit with DF = 1
            
            ; check upper right corner
            ghi     r7                ; check y value at upper right corner
            str     r2                ; save in M(X)
            ghi     ra                ; get device height
            sd                        ; any absolute value under height is inside
            lbnf    xy_in             ; if in bounds, exit with DF = 0
            
            ; check lower right corner
            ghi     r7                ; check y value at lower left corner
            str     r2                ; save y0 in M(X)
            ghi     r8                ; get bitmap height
            add                       ; y = y0 + h (signed addition)
            str     r2                ; save in M(X)
            ghi     ra                ; get device height
            sd                        ; any absolute value under height is inside
            lbnf    xy_in             ; if in bounds, exit with DF = 0
            

xy_out:     stc                       ; DF = 1 (nothing to draw)
            lbr    done               ; and exit            
xy_in:      clc                       ; DF = 0 (draw bitmap)
done:       pop    ra                 ; restore size register
            return
            endp
