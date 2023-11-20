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
; Name: gfx_adj_bounds
;
; Adjust the values h,w so that they represent pixel 
; drawing lengths h' = h-1, w' = w-1 and the origin plus 
; h',w' are inside the display boundaries.
;
; Parameters:
;   r7.1 - y0 signed byte
;   r7.0 - x0 signed byte
;   r8.1 - h  
;   r8.0 - w
;
; Registers Used:
;   ra.1 - device height
;   ra.0 - device width
;
; Returns: DF = 1 if error, 0 if no error
;   r8.1 - h' = h-1, adjusted so that 0 <= y0 + h' <= height 
;   r8.0 - w' = w-1, adjusted so that 0 <= x0 + w' <= width
;
; Note: Values x and y are unsigned byte values. The
;   dimension values inclusive of the origin, and 
;   are converted to lengths that exclude the origin 
;   so that h' = h-1 and w' = w-1.
;-------------------------------------------------------
            proc    gfx_adj_bounds
            push    ra                ; save size register
            call    gfx_disp_size     ; ra.1 = device height, ra.0 = device width
            
            ghi     r8                ; check h first
            lbz     bad_clip          ; height should not be 0
            str     r2                ; save h in M(X)
            ghi     ra                ; get device height
            sm                        ; device height - h
            lbnf    bad_clip          ; h must be 1 to device height
            ghi     r8                ; get h
            smi      1                ; adjust h by 1 for length h'
            phi     r8                ; save adjusted h' value
            ghi     r7  
            str     r2                ; put origin y value in M(X)
            ghi     r8                ; get adjusted height
            add                       ; D = y0 + h'
            str     r2                ; put adjusted height in M(X)
            ghi     ra                ; get device height
            sm                        ; >= device height is too big
            lbdf    check_w           ; if y0 + h' < device height, h' is okay
            adi     $01               ; add one to difference to adjust overage
            str     r2                ; save overage in M(X)
            ghi     r8                ; get adjusted height h'
            sm                        ; subtract overage
            phi     r8                ; adjust h'
            lbnf    bad_clip          ; h' should not be negative
              
check_w:    glo     r8                ; check w
            lbz     bad_clip          ; w should not be zero 

            str     r2                ; save w in M(X)
            glo     ra                ; get device width
            sm                        ; device width - w
            lbnf    bad_clip          ; w must be 1 to device width

            glo     r8                ; get w
            smi     1                 ; subtract 1 for length w'
            plo     r8                ; save adjusted w' value
            glo     r7                ; get origin x value
            str     r2                ; put origin y value in M(X)
            glo     r8                ; get adjusted width w'
            add                       ; D = x0 + w'
            str     r2                ; put adjusted width in M(X)
            glo     ra                ; check with device width
            sm                        ; >= device width is too big
            lbdf    clip_done         ; if x0 + w' < width, w' is okay
            adi     $01               ; add one to difference to adjust overage
            str     r2                ; save overage in M(X)
            glo     r8                ; get w'  
            sm                        ; subtract overage
            plo     r8
            lbdf    clip_done         ; w' should be positve        

bad_clip:   stc                       ; otherwise, exit with error
            lbr     clip_exit

clip_done:  clc                       ; clear df (no error)
clip_exit:  pop     ra                ; restore size register
            return
            endp
