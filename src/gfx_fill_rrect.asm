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
;   then sets pixels to draw a circle.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_fill_rrect
;
; Set pixels in the display buffer to draw a solid 
; rectangle with rounded corners.
;
; Parameters: 
;   r7.1 - origin y 
;   r7.0 - origin x 
;   r8.1 - h 
;   r8.0 - w 
;   ra.0 - corner radius r
;
; Note: Checks origin x,y values, error if out of bounds
;                  
; Return: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    gfx_fill_rrect
            
            ;------ check origin
            call    gfx_check_bounds
            lbdf    frr_skip          ; if out of bounds, don't draw
            
            
            push    ra                ; save registers used
            push    r9
            push    r8
            push    r7
                          
                                  
            call    gfx_adj_bounds    ; adjust w and h, clip if needed
            lbdf    frr_exit          ; if error, exit immediately

            ;-------------------------------------------
            ; Verify that w' >= 2r and h' >= 2r
            ;-------------------------------------------

            glo     ra                ; get corner radius
            shl                       ; multiply by 2 (for 2 corners)
            str     r2                ; save in M(X)
            glo     r8                ; get clipped value w'
            adi      1                ; w = w'+1
            sm                        ; w - 2r < 0, means error
            lbnf    frr_err           ; if 2r > w, exit with error
            
            ghi     r8                ; check height
            adi      1                ; h = h'+1
            sm                        ;  h - 2r < 0, means error
            lbnf    frr_err           ; if 2r > h', exit with error
            
            clc                       ; clear DF after arithmetic
            
            call    gfx_write_oblong  ; draw rounded rectangle
            lbnf    frr_exit          ; if no error, we are done
              
frr_err:    stc                       ; set DF = 1 to indicate error            
                    
frr_exit:   pop     r7                ; restore registers        
            pop     r8
            pop     r9
            pop     ra
frr_skip:   return
            endp
