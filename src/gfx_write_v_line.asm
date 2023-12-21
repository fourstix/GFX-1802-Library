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
; Name: gfx_write_v_line
;
; Draw a vertical line starting at position x,y.
;
; Parameters: 
;   r7.1 - origin y 
;   r7.0 - origin x 
;   r9.1 - color 
;   r9.0 - rotation
;   r8.0 - length 
;
; Note: x,y should be a vaild point with a valid length
;
; Registers Used:
;   ra.0 - display width
;   ra.1 - display height                
;
; Return: (None) r8.0 - consumed
;
;-------------------------------------------------------
            proc   gfx_write_v_line

            push   ra               ; save size register
            push   r7               ; save x,y values before rotation

;-------------------------------------------------------            
; May need to clip length (h) to rotated height (rh)
;   if (y + h >= rh), Clip bottom
;       so that h = rh - y;
;-------------------------------------------------------

            call   gfx_disp_size
            glo    r9               ; get rotation value 
            ani    $03              ; rotation has values 0 to 3
            shr                     ; check lsb for upright (0,2) or sideways (1,3)
            lbnf   wvl_uprt         ; DF = 1 means side ways (1 or 3)
            swap   ra               ; swap display width and height, if sideways
wvl_uprt:   ghi    r7               ; get y
            str    r2               ; put y in M(X)
            glo    r8               ; get length (h)
            add                     ; add y + h
            str    r2               ; save sum of y + h in in M(X)
            ghi    ra               ; get rotated height rh
            sd                      ; subtract rotated height from sum of y + h
            lbnf   wvl_okay         ; if y+h less than rotated height, length (h) is okay                      
              
            ghi    r7               ; get y
            str    r2               ; put y in M(X)
            ghi    ra               ; get rotated height (rh)
            sm                      ; subtract y from rotated width => (rh - y)
            plo    r8               ; save (rh - y) as new length (h)              

wvl_okay:   glo    r9               ; check rotation r
            ani    $03              ; rotation only has values 0 to 3
            lbz    wvl_vline        ; r=0, no rotation, just draw vertical line
            smi    1
            lbz    wvl_r90          ; r=1, rotate 90 degrees (counter-clockwise)
            smi    1
            lbz    wvl_r180         ; r=2, rotate 180 degrees (inverted)
            
            ;---- Otherwise r = 3, rotate 270 degrees (counter-clockwise)
            
            ;-------------------------------------------------------            
            ; Rotate x,y 270 degrees:
            ;   x' = y;
            ;   y' = HEIGHT - 1 - x;
            ;-------------------------------------------------------            

wvl_r270:   call  gfx_disp_size     ; get display size
            glo   r7                ; get x value
            str   r2                ; save x in M(X)
            ghi   r7                ; get y
            plo   r7                ; x' = y
            ghi   ra                ; get height
            smi   1                 ; y' = height - 1 - x
            sm                      ; D - M(X) => (height - 1) - x
            phi   r7                ; save y'  
            lbnf  wvl_exit          ; should not be negative

            lbr   wvl_hline         ; draw rotated line as horizontal line     


            
            ;-------------------------------------------------------            
            ; Rotate x,y 90 degrees:
            ;   x' = WIDTH - 1 - y;
            ;   y' = x;
            ;-------------------------------------------------------            
            
wvl_r90:    call  gfx_disp_size     ; get display size
            ghi   r7                ; get y value
            str   r2                ; save y at M(x)
            glo   r7                ; get x value
            phi   r7                ; y' = x
            glo   ra                ; get width
            smi   1                 ; x' = width - 1 - y
            sm                      ; D - M(X) => (width - 1) - y
            plo   r7                ; save x'
            lbnf  wvl_exit          ; should not be negative

            ;----- adjust x' for length (h) so x' -= length
            glo   r8                ; get length (h)
            str   r2                ; save at M(X)
            glo   r7                ; get x'
            sm                      ; subtract length
            plo   r7                ; save as updated x'
            lbnf  wvl_exit          ; should not be negative
              
            lbr   wvl_hline         ; draw rotated line as horizontal line


            ;-------------------------------------------------------            
            ; Rotate x,y 180 degrees:
            ;   x' = WIDTH  - 1 - x;
            ;   y' = HEIGHT - 1 - y;
            ;-------------------------------------------------------            

wvl_r180:   call  gfx_disp_size     ; get display size
            glo   r7                ; get x value
            str   r2                ; put x in M(X)
            glo   ra                ; get width
            smi   1                 ; x' = width - 1 - x
            sm                      ; D - M(X) => (width - 1) - x
            plo   r7                ; save x'
            ghi   r7                ; get y value
            str   r2                ; put y in M(X)
            ghi   ra                ; get height
            smi   1                 ; y' = height - 1 - y
            sm                      ; D - M(X) => (height - 1) - y
            phi   r7                ; save y'
            lbnf  wvl_exit          ; should not be negative

            ;----- adjust y' for length (h) so y' -= length
            glo   r8                ; get length (h)
            str   r2                ; save at M(X)
            ghi   r7                ; get y'
            sm                      ; subtract length
            phi   r7                ; save as updated y'
            lbnf  wvl_exit          ; should not be negative
            
            ;---- draw vertical line after rotation
            
wvl_vline:  clc                     ; clear DF after arithmetic
            call  gfx_disp_v_line   ; draw rotated line as vertical line
            lbr   wvl_exit

wvl_hline:  clc                     ; clear DF after arithmetic
            call  gfx_disp_h_line   ; draw rotated line as horizontal line

wvl_exit:   pop   r7                ; restore registers
            pop   ra
            return

            endp
