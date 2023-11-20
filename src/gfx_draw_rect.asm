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
; Public routine - This routine validates the origin
;   and clips the rectangle to the display edges.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_draw_rect
;
; Set pixels in the display buffer to create a 
; rectangle with its upper left corner at position x,y
; and sides of width w and height h.
;
; Parameters: 
;   r9.1 - color
;   r8.1 - h 
;   r8.0 - w 
;   r7.1 - origin y 
;   r7.0 - origin x 
;
; Note: Checks origin x,y values, error if out of bounds
; and the w, h values may be clipped to edge of display.
;                  
; Return: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    gfx_draw_rect
            call    gfx_check_bounds
            lbdf    dr_skip           ; if out of bounds, don't draw
            
            push    r9                ; save registers used
            push    r8
            push    r7
            call    gfx_adj_bounds    ; adjust w and h, clip if needed
            lbdf    dr_exit           ; if error, exit immediately
            
            call    gfx_write_rect    ; draw rectangle
                    
dr_exit:    pop     r7                ; restore registers        
            pop     r8
            pop     r9
dr_skip:    return
            endp
