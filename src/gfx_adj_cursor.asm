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
;   r8.1 - character scaling (0,1 for none, or 2-8)
;
; Registers Used:
;   ra.1 - device height
;   ra.0 - device width
;   rb.1 - scale count
;   rb.0 - loop counter
;
; Return: 
;   r7 - updated for next cursor position
;-------------------------------------------------------
            proc    gfx_adj_cursor
            push    rb                ; save loop register
            push    ra                ; save size register

            ldi     1                 ; set loop value for no scale
            phi     rb
            
            ghi     r8                ; check scaling factor
            lbz     no_scale          ; s=0 means no scaling
            smi     1                 ; check for s=1, also no scaling
            lbz     no_scale
            smi     8                 ; only 2 to 8 is valid 
            lbdf    no_scale          ; ignore anything over 8
            ghi     r8                ; 2 to 8 is fine,
            phi     rb                ; so save it as the loop value

no_scale:   call    gfx_disp_size

            glo     r9          ; get rotation value (r)
            ani    $03          ; rotation has values 0 to 3
            shr                 ; check lsb for sideways (r=1 or r=3)
            lbnf    upright     ; DF = 0, means upright (r=0 or r=2)
            swap    ra          ; if sideways, swap width and height
              
upright:    ghi     rb          ; get scale value
            plo     rb          ; set up loop counter
            
w_loop:     glo     ra          ; get current Cursor_X
            smi     C_WIDTH     ; Cursor_X = WIDTH - s*(C_WIDTH)
            plo     ra          ; save Cursor X in ra.0
            dec     rb          ; decrement scale counter
            glo     rb          ; check counter
            lbnz    w_loop      ; subtract C_WIDTH s times for scaled character
            
            glo     ra          ; get Cursor_X
            str     r2          ; save Cursor_X in M(X)
              
            glo     r7          ; get the current x position 
            sd                  ; check for past last column in row
                                ; M(X) - D => Cursor_X - x
            lbdf    ac_line     ; if Cursor_X - x >= 0, we are okay 
  
            ldi      0          ; set cursor to beginning of next line
            plo     r7          ; save new x location
            
            ghi     rb          ; get scale count
            plo     rb          ; set up loop counter
            
            ghi     r7          ; adjust y position
            str     r2          ; store initial y value in M(X)
            
h_loop:     ldx                 ; get current y value from M(X)
            adi     C_HEIGHT    ; advance to next line (D = y + s*C_HEIGHT)
            str     r2          ; store current y value in M(X)
            dec     rb          ; add C_HEIGHT s times to y
            glo     rb          ; check scale counter
            lbnz    h_loop      ; keep going to add s * C_HEIGHT to y
            
            ldx                 ; get updated y from M(X)
            phi     r7          ; save new line y location            

ac_line:    ghi     rb          ; get scale count
            plo     rb          ; set up loop counter
            
h_loop2:    ghi     ra          ; get current Cursor_Y            
            smi     C_HEIGHT    ; Cursor_Y = HEIGHT - (C_HEIGHT * s)
            phi     ra          ; save current Cursor_Y in ra.1
            dec     rb          ; subtract C_HEIGHT s times from height
            glo     rb          ; check the scale counter
            lbnz    h_loop2
            
            ghi     ra          ; get Cursor_Y
            str     r2          ; save CURSOR_Y in M(X)
              
            ghi     r7          ; get the current y position 
            sd                  ; check for past last line 
                                ; M(X)-D => CURSOR_Y - y

            lbdf    ac_done     ; if CURSOR_Y - y >= 0, we are okay
             
            ldi      0          ; set y to top row
            phi     r7          

ac_done:    pop     ra
            pop     rb
            clc                 ; clear error flag after arithmetic
            return        
       
            endp
