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
; Name: gfx_write_bitmap
;
; Write pixels for an 8x8 bitmap in the display 
; buffer at position x,y. 
;
; Parameters: 
;   rf   - pointer to bitmap
;   r7.1 - origin y  (upper left corner)
;   r7.0 - origin x  (upper left corner)
;   r8.1 - bitmap height h
;   r8.0   bitmap width w
;   r9.1 - color
; Registers Used:
;   rb.0 - i register (inner loop)
;   rb.1 - bitmap data byte for shifting
;   r9.0 - copy of origin x
;   ra.0 - j register (outer loop)
; Return: 
;   DF = 1 if error, 0 if no error (r7 consumed)
;-------------------------------------------------------
            proc    gfx_write_bitmap

            push    rb        ; save registers used
            push    ra        
          
            ;-------------------------------------------------------
            ;     Registers used to draw bitmap
            ;     r7.1  -   y value
            ;     r7.0  -   x value
            ;     r8.1  -   h (bitmap height)
            ;     r8.0  -   w (bitmap width)
            ;     r9.1  -   color
            ;     r9.0  -   x origin value   
            ;     ra.0  -   j value (outer iterator for y)
            ;     ra.1  -   (not used)
            ;     rb.0  -   i value (inner iterator for x)
            ;     rb.1  -   bitmap data byte for shifting
            ;-------------------------------------------------------
                        
            ;-------------------------------------------------------
            ; Algorithm from Adafruit library, optimized for 8x8 
            ; bitmaps
            ;
            ; for (j=8; j>0; j--, y++) {
            ;     b = read_byte(rf++) 
            ;   for (i=8; i>0; i--, x++) {
            ;     b <<= 1, DF = MSB;
            ;     if (DF && x,y on canvas) {
            ;       writePixel(x, y, color);
            ;     } // if  
            ;   } // for i
            ; } // for j
            ;-------------------------------------------------------

            ; save x origin value
            glo     r7
            plo     r9
            
            ;---- set up outer iterator j (count down )
            ghi     r8
            plo     ra

            ;----- outer loop for j iterations from 0 to h     
wbmp_jloop: glo     r8          ; set up x iterator i and bitmap byte
            plo     rb          ; set up inner x iterator i (count up)

            lda     rf          ; get data byte from bitmap
            phi     rb          ; save bitmap byte for shifting

            ;----- inner loop for i iterations from 0 to w
wbmp_iloop: ghi     rb          ; get byte value 
            shl                 ; shift left to move into MSB into DF
            phi     rb          ; save shifted byte
            
            lbnf    wbmp_iend   ; if MSB was zero we are done with this bit
            
            ;---- checks boundaries before writing to canvas
            call    gfx_check_bounds
            lbdf    wbmp_iend   ; don't draw pixel if off canvas
            
            call    gfx_disp_pixel
            
            ;----- end of inner loop
wbmp_iend:  dec     rb          ; increment iterator i (i++)
            
            glo     r7          ; get signed x value
            adi     1           ; add one (x++)
            plo     r7          ; save signed x value
            
            glo     rb          ; get iterator
            lbnz    wbmp_iloop  ; keep going while i < w                 
            
            ;----- end of outer loop
wbmp_jend:  ghi     r7          ; get signed y value
            adi      1          ; add one (y++)
            phi     r7          ; saved signed value
            
            glo     r9          ; get x origin value
            plo     r7          ; set x back to origin for next line
            
            dec     ra          ; count down from h            
            glo     ra          ; check j 
            lbnz    wbmp_jloop  ; keeping going until j = 0
            
            pop     ra          ; restore registers
            pop     rb
            return

            endp
