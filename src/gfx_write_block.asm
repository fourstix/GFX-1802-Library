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
; Name: gfx_write_block
;
; Write pixels for a filled rectangle in the display 
; buffer at position x,y.
;
; Parameters: 
;   r9.1 - color
;   r8.1 - h 
;   r8.0 - w 
;   r7.1 - origin y 
;   r7.0 - origin x 
; Registers Used:
;   ra - origin 
;   rc - counter 
;
; Return: (None) r7, r8, r9 consumed
;-------------------------------------------------------
            proc    gfx_write_block

            push    ra        ; save origin registers
            push    rc        ; save counter register
            
            copy    r7, ra    ; save origin
            load    rc, 0     ; clear rc        
            
            glo     r8        ; get width
            plo     rc        ; put in counter
            inc     rc        ; +1 to always draw first pixel column, even if w = 0
            
            ghi     r8        ; get h for length
            plo     r9        ; set up length of vertical line
            
            ; draw vertical line at x
wb_loop:    call    gfx_disp_v_line   
            lbdf    wb_exit   ; if error, exit immediately
            
            inc     ra        ; increment x for next column
            dec     rc        ; decrement count after drawing line
            
            ghi     r8        ; get h for length
            plo     r9        ; set up length of vertical line
            
            COPY    ra, r7    ; put new origin for next line
            glo     rc        ; check counter
            lbnz    wb_loop   ; keep drawing columns until filled
            
wb_exit:    pop     ra        ; restore registers
            pop     rc
            return 
            endp  