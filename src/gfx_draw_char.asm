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
; Name: gfx_draw_char
;
; Set pixels in the display buffer to draw a character 
;
; Parameters: 
;   r7.1 - origin y 
;   r7.0 - origin x 
;   r9.1 - color
;   r9.0 - rotation 
;   r8.1 - character scaling (0,1 or 2-8)
;   r8.0 - ASCII character to draw 
;
; Note: Checks to see if any possible overlap with the
;   display before drawing bitmap.
;                  
; Return: DF = 1 if error, 0 if no error
;         R7 = next character location
;-------------------------------------------------------
            proc    gfx_draw_char
                                            
            push    r9                ; save registers used           
            push    r8
            
            ghi     r8                ; check scaling factor
            lbz     scale_ok          ; s=0 means no scaling
            smi     1                 ; check for s=1, also no scaling
            lbz     fix_scale
            sdi     7                 ; 2 to 8 is valid 
            lbdf    scale_ok          ; 7 - (s-1) >= 0 means okay

fix_scale:  ldi     0                 ; set r8.1 for no scale (s=0)
            phi     r8
scale_ok:   call    gfx_write_char    ; write character at origin

            pop     r8                ; restore registers
            pop     r9

            return

            endp
