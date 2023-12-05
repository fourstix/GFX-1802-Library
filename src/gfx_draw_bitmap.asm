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
;   and clips the bitmap to the edges of the display.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_draw_bitmap
;
; Set pixels in the display buffer to draw a bitmap 
; with its upper left corner at the position x,y.
;  
; Pixels corresponding to 1 values in the bitmap data 
; are set.  Pixels corresponding to 0 values in the 
; bitmap data are unchanged.
;
; Parameters: 
;   r7.1 - origin y (signed value)
;   r7.0 - origin x (signed value) 
;   r8.1 - h bitmap height
;   r8.0 - w bitmap width
;   r9.1 - color
;   rf   - pointer to bitmap
;
; Note: Checks to see if any possible overlap with the
;   display before drawing bitmap.
;                  
; Return: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    gfx_draw_bitmap

            call    gfx_check_overlap
            lbnf    dbmp_ok           ; if overlap, continue
            clc                       ; otherwise clear error
            return                    ; and return
            
dbmp_ok:    push    rf                ; save registers used
            push    r9
            push    r8                
            push    r7

            call    gfx_write_bitmap  ; draw new bitmap

db_err:     pop     r7                ; restore registers        
            pop     r8
            pop     r9
            pop     rf        

db_exit:    return
            endp
