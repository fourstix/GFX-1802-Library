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
; Name: gfx_adj_cursor
;
; Adjust the cursor position x,y values to point to the
; next character location.  The cursor position will
; wrap to the next line or to the top of the screen if
; the cursor is at the bottom of the display.
;
; Parameters:
;   r7.1 - cursor y  
;   r7.0 - cursor x  
;
; Registers Used:
;   ra.1 - device height
;   ra.0 - device width
;
; Return: 
;   r7 - updated for next cursor position
;-------------------------------------------------------
            proc    gfx_adj_cursor
            push    ra
            call    gfx_disp_size
              
            glo     ra          ; get display width
            smi     C_WIDTH     ; Cursor X = WIDTH - C_WIDTH
            str     r2          ; save Cursor X in M(X)

            glo     r7          ; get the current x position 
            sd                  ; check for past last column in row
                                ; M(X) - D => Cursor_X - x
            
            lbdf    ac_line     ; if Cursor_X - x >= 0, we are okay 
  
            ldi      0          ; set cursor to beginning of next line
            plo     r7          ; save new x location
            
            ghi     r7          ; adjust y position
            adi     C_HEIGHT    ; advance to next line
            phi     r7          ; save new line y location            

ac_line:    ghi     ra          ; get display height
            smi     C_HEIGHT    ; Cursor_Y = HEIGHT - C_HEIGHT
            str     r2          ; save CURSOR_Y in M(X)
              
            ghi     r7          ; get the current y position 
            sd                  ; check for past last line 
                                ; M(X)-D => CURSOR_Y - y

            lbdf    ac_done     ; if CURSOR_Y - y >= 0, we are okay
             
            ldi      0          ; set y to top row
            phi     r7          

ac_done:    pop     ra
            clc                 ; clear error flag
            return        
       
            endp
