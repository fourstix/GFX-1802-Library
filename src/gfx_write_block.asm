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
; Name: gfx_write_block
;
; Write pixels for a filled rectangle in the display 
; buffer at position x,y.
;
; Parameters: 
;   r9.1 - color
;   r9.0 - rotation
;   r8.1 - h 
;   r8.0 - w 
;   r7.1 - origin y 
;   r7.0 - origin x 
; Registers Used:
;   ra - origin 
;   rb - counter 
;
; Return: (None) r7, r8, r9 consumed
;-------------------------------------------------------
            proc    gfx_write_block

            push    rb        ; save counter register
            push    ra        ; save origin registers
            
            copy    r7, ra    ; save origin
            load    rb, 0     ; clear rb        
            
            glo     r8        ; get width
            plo     rb        ; put in counter
            inc     rb        ; +1 to always draw first pixel column, even if w = 0
            
            ghi     r8        ; get h for length
            plo     r8        ; set up length of vertical line

            ; draw vertical line at x
wb_loop:    call    gfx_write_v_line   
            lbdf    wb_exit   ; if error, exit immediately
            
            inc     ra        ; increment x for next column
            dec     rb        ; decrement count after drawing line
            
            ghi     r8        ; get h for length
            plo     r8        ; set up length of vertical line
            
            copy    ra, r7    ; put new origin for next line
            
            glo     rb        ; check counter
            lbnz    wb_loop   ; keep drawing columns until filled
            
wb_exit:    pop     ra        ; restore registers
            pop     rb
            return 
            endp  
