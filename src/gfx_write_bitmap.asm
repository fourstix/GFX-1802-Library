;-------------------------------------------------------------------------------
; This library contains routines to support a graphics library 
; written in 1802 Assembler code based on the Adafruit_GFX-Library
; written by Ladyada Limor Fried.
;
;
; Copyright 2023 by Gaston Williams
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
; Write pixels for a filled rectangle in the display 
; buffer at position x,y.
;
; Parameters: 
;   rf   - pointer to bitmap
;   r7.1 - origin y  (upper left corner)
;   r7.0 - origin x  (upper left corner)
;   r8.1 - h 
;   r8.0 - w 
;   r9.1 - color
;
; Return: (None) r7, r8, r9 consumed
;-------------------------------------------------------
            proc    gfx_write_bitmap

            push    rf        ; save bitmap pointer  
            push    rc        ; save i register, x origin
            push    rb        ; save j register, x origin
            push    ra        ; save bit register,  y value
          
            ;-------------------------------------------------------
            ;     Registers used to draw bitmap
            ;     r8.1  -   h (height of bitmap)
            ;     r8.0  -   w (width of bitmap)
            ;     r9.1  -   color
            ;     r9.0  -   rotation
            ;     ra.1  -   bitmap byte (b value for shifting)
            ;     ra.0  -   y value 
            ;     rc.0  -   inner iterator for x (i value)
            ;     rc.1  -   x origin value
            ;     rb.0  -   outer iterator for y (j value)  
            ;     rb.1  -   bitmap width in bytes
            ;-------------------------------------------------------
            
            ;----- set up registers 
            glo     r7        ; set up x origin value
            phi     rc
            ghi     r7        ; set up origin y value
            plo     ra        

            ;---- set up outer iterator j (count ddown )
            ghi     r8        ; get h value
            plo     rb        ; save as iterator j (count down)
            
            ;----- set up x iterator i and clear bitmap byte
            ldi     0         ; clear values
            plo     rc        ; set up inner x iterator i (count up)
            phi     ra        ; clear out bitmap byte for shifting
            
            ; calculate bitmap byte width
            glo     r8        ; get width of bitmap
            adi     07        ; add 7 to so byte width always >= 1
            shr               ; divide by 8 for int(w+7)
            shr               ; three shifts right => divde by 8  
            shr               ; D = byte width of byte map
            phi     rb        ; set byte width                        

            ;-------------------------------------------------------
            ; Algorithm from Adafruit library:
            ;
            ; for (j=0; j<h; j++, y++) {
            ;   for (i=0; i<w; i++) {
            ;     if (i & 7) b <<= 1;
            ;     else b = read_byte(rf + i / 8]) 
            ;
            ;     if (b & $80)
            ;       writePixel(x + i, y, color);
            ;     } // for i
            ;   rf += byteWidth   // rf = rf + j * byteWidth
            ; } // for j
            ;-------------------------------------------------------

            ;----- outer loop for j iterations from 0 to h     
wbmp_jloop:                     ; redundant labels for readability            
            ;----- inner loop for i iterations from 0 to w
wbmp_iloop: glo     rc          ; get the i value
            ani     07          ; and i with 7
            lbz     wbmp_getb   ; if 0 or on byte boundary, get byte     
            ghi     ra          ; get byte value for shifting
            shl                 ; shift left to move next bit into MSB
            phi     ra          ; save shifted byte
            lbr     wbmp_chkb   ; check the byte
            
            ;----- read a new byte from the bitmap data
wbmp_getb:  push    rf          ; save current byte row pointer
            glo     rc          ; get x iterator i
            shr                 ; convert x to byte offset
            shr                 ; 3 right shifts => divide by 8
            shr                 ; D = the byte offset int(i/8)
            str     r2          ; put byte offset in M(X)
            glo     rf          ; get byte row pointer
            add                 ; add offset to lower byte
            plo     rf          ; save byte ptr
            ghi     rf          ; adjust hi byte of pointer for carry
            adci    0           ; add DF into hi byte
            phi     rf          ; rf now points to rf + j*byteWidth + int(i/8)
            ldn     rf          ; get bitmap byte
            phi     ra          ; save bitmap byte for shifting
            pop     rf          ; restore byte pointer back to row
            
            ;----- check bit in bitmap and draw pixel if required
wbmp_chkb:  ghi     ra          ; get bitmap byte
            ani     $80         ; check MSB
            lbz     wbmp_iend   ; if MSB is zero we are done with this bit

            push    r8          ; save h and w since r8 is consumed
            glo     ra          ; get current y value
            phi     r7          ; save as y value as pixel y
            ghi     rc          ; get x origin value
            str     r2          ; save x origin in M(X)
            glo     rc          ; get i offset
            add                 ; add offset to origin to get pixel x
            plo     r7          ; r7 now points to pixel to write
            
            ;---- checks boundaries before writing to canvas
            call    gfx_check_bounds
            lbdf    wbmp_skp    ; don't draw pixel if off canvas

            call    gfx_write_pixel
wbmp_skp:   pop     r8          ; restore h,w
            
            ;----- end of inner loop
wbmp_iend:  inc     rc          ; increment iterator i
            glo     rc          ; get iterator
            str     r2          ; save i in M(X)
            glo     r8          ; get w
            sm                  ; D = w - i
            lbnz    wbmp_iloop  ; keep going until i = w                 
            
            ;----- end of outer loop
wbmp_jend:  inc     ra          ; point y to next row

            ghi     rb          ; get byte width of bitmap pointer
            str     r2          ; save in M(X) for addition
            glo     rf          ; get bitmap pointer   
            add                 ; add byte width to bitmap pointer
            plo     rf          ; save in ptr
            ghi     rf          ; adjust hi byte for possible carry out
            adci    0           ; add DF to high byte
            phi     rf          ; rf now points to next line of bytes in bitmap
            
            ;----- reset iterator i and clear bitmap byte
            ldi     0         ; set up iterator values i and j
            plo     rc        ; set up inner x iterator (i)
            phi     ra        ; clear out bitmap byte for shifting

            dec     rb          ; count down from h 
            glo     rb          ; check j 
            lbnz    wbmp_jloop  ; keeping going until j = h
            
            pop     ra          ; restore registers
            pop     rb
            pop     rc
            pop     rf
            return
            endp
