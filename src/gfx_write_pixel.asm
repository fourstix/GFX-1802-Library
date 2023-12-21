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
; Public routine - This routine validate inputs and 
;   then sets a single pixel.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_write_pixel
;
; Set a pixel in the display buffer at position x,y.
;
; Parameters: 
;   r7.1 - y 
;   r7.0 - x 
;   r9.1 - color
;   r9.0 - rotation
; Registers Used:
;   ra.0 - display width
;   ra.1 - display height
;
; Note: Checks rotation and adjusts x,y values by 
;   rotating the co-ordinates counter-clockwise.
;                  
; Return: DF = 1 if error, 0 if no error
; 
;-------------------------------------------------------
            proc   gfx_write_pixel
            push   ra               ; save size register
            push   r7               ; save x,y values before rotation
            
            glo    r9               ; check rotation
            ani    $03              ; only valid values are 0,1,2,3
            lbz    wp_draw          ; r=0, no rotation. just draw it
            smi    1
            lbz    wp_r90           ; r=1, rotate 90 degrees (ccw)
            smi    1
            lbz    wp_r180          ; r=2, rotate 180 degrees (invert)

            ;---- Otherwise r = 3, rotate 270 degrees (counter-clockwise)
            ;-------------------------------------------------------            
            ; Rotate x,y 270 degrees:
            ;   x' = y;
            ;   y' = HEIGHT - 1 - x;
            ;-------------------------------------------------------            

wp_r270:    call  gfx_disp_size     ; get display size
            glo   r7                ; get x value
            str   r2                ; save x in M(X)
            ghi   r7                ; get y
            plo   r7                ; x' = y
            ghi   ra                ; get height
            smi   1                 ; y' = height - 1 - x
            sm                      ; D - M(X) => (height - 1) - x
            phi   r7                ; save y'  
            lbr   wp_draw           ; rotation done, draw pixel

            ;-------------------------------------------------------            
            ; Rotate x,y 90 degrees:
            ;   x' = WIDTH - 1 - y;
            ;   y' = x;
            ;-------------------------------------------------------            

wp_r90:     call  gfx_disp_size     ; get display size
            ghi   r7                ; get y value
            str   r2                ; save y at M(x)
            glo   r7                ; get x value
            phi   r7                ; y' = x
            glo   ra                ; get width
            smi   1                 ; x' = width - 1 - y
            sm                      ; D - M(X) => (width - 1) - y
            plo   r7                ; save x'
            lbr   wp_draw           ; rotation done, draw pixel

            ;-------------------------------------------------------            
            ; Rotate x,y 180 degrees:
            ;   x' = WIDTH  - 1 - x;
            ;   y' = HEIGHT - 1 - y;
            ;-------------------------------------------------------            

wp_r180:    call  gfx_disp_size     ; get display size
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
            ;---- rotation done, draw pixel    

                    
wp_draw:    clc                     ; clear DF after arithmetic
            call   gfx_disp_pixel   ; write pixel to device buffer
            pop    r7 
            pop    ra 
wp_exit:    return
            
            endp
