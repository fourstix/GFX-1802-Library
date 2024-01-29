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
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------


;-------------------------------------------------------
; Name: gfx_write_disk
;
; Set pixels in the display buffer to write a solid  
; circle at the origin x0, y0 with a radius r.
;
; Parameters: 
;   r7.1 - origin y 
;   r7.0 - origin x 
;   r8.0 - radius r
;   r9.1 - color 
;   r9.0 - rotation  
;
; Registers Used:
;   rf.1 - delta
;   r8.1 - corners
;
; Return: 
;   DF = 1 if error, 0 if no error
;   r7, r8 are consumed
;-------------------------------------------------------
            proc    gfx_write_disk
            
            push    rf        ; save registers used

            ;--------------------------------------------
            ; Draw vertical midline
            ; from x0, y0-r of length 2r
            ;--------------------------------------------
            push    r8        ; save registers to draw line
            push    r7
            
            ;------ x = x0, so r7.0 is already set 
            glo     r8        ; get r
            str     r2        ; save in M(X)
            ghi     r7        ; get y0
            sm                ; y0 - r
            phi     r7        ; set y = y0 - r
            glo     r8        ; get r
            shl               ; multiple by 2
            plo     r8        ; set length to 2r
            
            ;------ draw line at center
            call    gfx_write_v_line    
            
            pop     r7        ; restore registers
            pop     r8
            
            ;--------------------------------------------
            ;  Write quads to form a circle
            ;  r7.0 = x0
            ;  r7.1 = y0
            ;  r8.0 = r
            ;  r8.1 = corners = 3, both left and right
            ;  rf.1 = delta = 0
            ;--------------------------------------------
            
            ldi     0          
            phi     rf        ; set delta = 0
            ldi     BOTH_SIDES          
            phi     r8        ; set corners to draw all quads
            
            call    gfx_write_quads
            
wc_exit:    pop     rf        ; restore registers
                        
            clc               ; clear DF after arithmetic
            return
            
            endp
