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
; Name: gfx_write_s_line
;
; Draw a sloping line starting at position x,y.
;
; Parameters: r7.1 - origin y 
;             r7.0 - origin x 
;             r8.1 - endpoint y 
;             r8.0 - endpoint x 
;             r9.1 - color
;             r9.0 - steep flag (transposed x,y values)
;
; Note: Uses Bresenham's algorithm to draw line.
; https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
;
; Since display co-ordinates each fit in one byte. This
; routine uses byte arithmetic to calculate pixel x,y values.
;                  
; Return: (None) r7, r8, r9 - consumed
;-------------------------------------------------------
            proc   gfx_write_s_line
            push   ra       ; save x,y register 
            push   rb       ; save dx, dy register
            push   rc       ; save error, Ystep register       

;-------------------------------------------------------------------------------
;  The following values are used in Bresenham's algorithm 
;-------------------------------------------------------------------------------
;  ra.0  => calculated x
;  ra.1  => calculated y
;  rb.0  => dx  (x1 - x0), signed
;  rb.1  => dy  abs(y1 - y0)
;  rc.0  => error 
;  rc.1  => y_step (+1 or -1)
;  r9.1  => color
;  r9.0  => steep flag (calculate with transposed x,y)
;  r8.0  => endpoint x1, endpoint y1
;  r7    => pixel (x,y) to be drawn (either ra, or ra transposed for steep line)
;------------------------------------------------------------------------------- 
; This algorithm allows lines to be drawn using signed byte arithmetic. Some
; values were set up by the caller before this algorithm is called to 
; simplify calculations. 
;------------------------------------------------------------------------------- 
; A steep line is a line whose y difference is larger than its x difference.
; For a steep line, r7 and r8, are already transposed by the caller. If needed,
; r7 and r8 were exchanged by the caller so that r7 is left of r8, making the 
; difference dx = x1 - x0 always positive.
;------------------------------------------------------------------------------- 
; The logic below sets up the remaining values used by algorithm.
;------------------------------------------------------------------------------- 

            copy   r7, ra     ; copy origin to x,y
            glo    ra         ; dx = x1 - x0
            str    r2         ; x0 in M(X)
            glo    r8         ; get endpoint x1
            sm                ; dx = x1 in D minus x0 in M(X)
            plo    rb         ; save dx (always positive)              
            ghi    ra         ; dy = abs(y1 - y0)
            str    r2         ; y0 in M(X)
            ghi    r8         ; endpoint y1 in D  
            sm                ; dy = y1 in D minus y0 in M(X)
            phi    rb         ; save dy in rb
            lbdf   dy_pos     ; if positive no need to adjust

            ghi    rb         ; if dy is negative
            sdi    0          ; negate it
            phi    rb         ; save abs(dy) in rb
            ldi    $FF        ; set y step = -1 (signed byte value)
            phi    rc         ; save step in rc.1
            lbr    calc_err

dy_pos:     ldi    $01        ; set y step = +1
            phi    rc
calc_err:   glo    rb         ; get dx
            shr               ; divide by 2 (shift right)
            plo    rc         ; save as error value

;------------------------------------------------------------------------------- 
; Calculate and draw x,y values, for x = x0; x < x1; x++ Since we know the 
; endpoint is at pixel (x1,y1), we just draw it instead of calculating it.  
; For a steep line, the transposed x,y values must be transposed back to their 
; original positions to draw the pixel correctly on the display.
;------------------------------------------------------------------------------- 
           
sl_loop:    glo    r8         ; for x <= x1; x++    
            str    r2         ; store x1 in M(X)
            glo    ra         ; get x
            sm                ; x - x1, DF =0, until x >= x1
            lbdf   sl_done    ; if x1 >= x1, we are done
            
            glo    r9         ; check steep flag
            lbnz   sl_steep1  ; if steep, transpose x,y and draw
            copy   ra, r7     ; copy current x,y to pixel x,y

            call   gfx_disp_pixel
            lbr    sl_cont    ; continue    

sl_steep1:  glo    ra         ; transpose x and y for pixel
            phi    r7         ; put x in pixel y
            ghi    ra         ; put y in pixel x
            plo    r7         ; draw transposed pixel

            call   gfx_disp_pixel 
            
sl_cont:    ghi    rb         ; get dy
            str    r2         ; save in M(X)
            glo    rc         ; get error
            sm                ; err = err - dy
            plo    rc         ;  save updated err
            lbdf   sl_adjx    ; if positive don't adjust y

            ghi    rc         ; get y step value (+1 or -1 signed byte)
            str    r2         ; save step in M(X)
            ghi    ra         ; get current y
            add               ; adjust y by step value (one step up or down) 
            phi    ra         ; save updated y
            glo    rb         ; get dx
            str    r2         ; save dx in M(X)
            glo    rc         ; get error value
            add               ; add dx to error value
            plo    rc         ; save updated error for next calculation
            
sl_adjx:    inc    ra         ; next x
            lbr    sl_loop    ; keep going while x < x1

;------------------------------------------------------------------------------- 
; Draw the endpoint to finish line 
;------------------------------------------------------------------------------ 
            
sl_done:    glo    r9         ; check steep flag
            lbnz   sl_steep2  ; if steep, transpose x,y and draw

            copy   ra, r7     ; copy current x,y to pixel x,y
            lbr    sl_end     ; draw endpoint last
            
sl_steep2:  glo    r8         ; transpose x and y for pixel
            phi    r7         ; put x in pixel y
            ghi    r8         ; put y in pixel x
            plo    r7         ; draw transposed pixel 
                                 
sl_end:     call   gfx_disp_pixel 

            pop    ra
            pop    rb
            pop    rc
            
            return
            endp
            
