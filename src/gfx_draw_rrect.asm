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
#include    ../include/bios.inc
#include    ../include/kernel.inc
#include    ../include/ops.inc
#include    ../include/gfx_display.inc 
#include    ../include/gfx_def.inc  
 

;-------------------------------------------------------
; Public routine - This routine validate inputs and
;   then sets pixels to draw a circle.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_draw_rrect
;
; Set pixels in the display buffer to draw a rectangle
; with rounded corners.
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
            proc    gfx_draw_rrect
                        
            ;------ check origin
            call    gfx_check_bounds
            lbdf    drr_skip          ; if out of bounds, don't draw
            
            
            push    ra                ; save registers used
            push    r9
            push    r8
            push    r7
                          
                                  
            call    gfx_adj_bounds    ; adjust w and h, clip if needed
            lbdf    drr_exit          ; if error, exit immediately

            ;-------------------------------------------
            ; Verify that w' >= 2r and h' >= 2r
            ;-------------------------------------------

            glo     ra                ; get corner radius
            shl                       ; multiply by 2 (for 2 corners)
            str     r2                ; save in M(X)
            glo     r8                ; get clipped value w'
            adi     1                 ; add one for original width
            sm                        ; (w' + 1) - 2r < 0, error
            lbnf    drr_err           ; if 2r > w'+1, exit with error
            
            ghi     r8                ; get height
            adi     1                 ; add one so DF = 1 indicates error
            sm                        ;  (h' + 1) - 2r < 0, error
            lbnf    drr_err           ; if 2r > h'+1, exit with error
                      
            call    gfx_write_rrect   ; draw rounded rectangle
            lbr     drr_exit

drr_err:    stc                       ; if h or w is < 2r, exit with error
                    
drr_exit:   pop     r7                ; restore registers        
            pop     r8
            pop     r9
            pop     ra
drr_skip:   return
            endp
