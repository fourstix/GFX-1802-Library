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
; Name: gfx_write_quads
;
; Set pixels in the display buffer to write solid  
; quadrants of a circle with origin at x0, y0 and a 
; radius r.
;
; Parameters: 
;   r7.1 - origin y 
;   r7.0 - origin x 
;   r8.0 - radius r
;   r8.1 - corners, quadrants to fill
;   r9.1 - color 
;   r9.0 - rotation  
;   rf.1 - delta
;
; Registers Used:
;   r8.1 - f
;   ra.0 - ddF_x
;   ra.1 - ddF_y
;   rb.0 - origin x
;   rb.1 - origin y
;   rc.0 - x offset
;   rc.1 - y offset
;   rd.0 - px
;   rd.1 - py
;   rf.0 - quads
;
; Return: 
;   DF = 1 if error, 0 if no error
;   r7, r8 are consumed
;-------------------------------------------------------
            proc    gfx_write_quads
            
            push    rf
            push    rd
            push    rc        ; save registers used
            push    rb
            push    ra

            ;--------------------------------------------
            ;  write pixels to form a filled quadrant
            ;  r7.0 - xp (pixel x)
            ;  r7.1 - yp (pixel y)
            ;  r8.1 - f
            ;  r8.0 - radius r
            ;  ra.1 - ddF_y
            ;  ra.0 - ddF_x
            ;  rb.1 - origin x0
            ;  rb.0 - origin y0
            ;  rc.0 - x offset
            ;  rc.1 - y offset
            ;  rd.0 - px
            ;  rd.1 - py
            ;  rf.0 - quads
            ;  rf.1 - delta
            ;--------------------------------------------
            copy    r7, rb    ; save origin in rb

            ghi     r8        ; get quads value
            plo     rf        ; save quads byte in rf.0
          
            
            ;--------------------------------------------            
            ; Set up variables to calculate additional 
            ; points.
            ; f = 1 - r
            ; ddF_x = 1;
            ; ddF_y = -2 * r
            ; x offset = 0
            ; y offset = r
            ; px = x
            ; py = y
            ;--------------------------------------------
set_var:    ldi      0
            plo     rc        ; set x = 0
            plo     rd        ; set px = x
            glo     r8        ; get radius r
            phi     rc        ; set y = r
            phi     rd        ; set py = y
            shl               ; multiply r by 2
            sdi     0         ; negate it, so -2 * r
            phi     ra        ; ddF_y = -2*r
            glo     r8        ; get radius 
            str     r2        ; save in M(X)
            ldi     1          
            plo     ra        ; ddF_x = 1
            sm                ; f = 1-r
            phi     r8        ; f is a negative number (1-r)
            
p_loop:     ghi     rc        ; get y 
            str     r2        ; save y in M(X)
            glo     rc        ; get x
            sm                ; check x - y < 0
            lbdf    wc_exit   ; when x >= y, we are done
            
            ghi     r8        ; check f
            ani     $80       ; mask off all but sign bit (msb)
            lbnz    f_neg     ; if negative, no need to adjust
            
            ghi     rc        ; get y offset
            smi     1         ; decrement
            phi     rc        ; save y = y-1
            
            ghi     ra        ; get ddF_y
            adi      2        ; ddF_y = ddF_y + 2;
            phi     ra        ; save updated ddF_y
            str     r2        ; save ddF_y in M(X)
            ghi     r8        ; get f
            add               ; f = f+ddF_y
            phi     r8        ; save updated f    
            
f_neg:      inc     rc        ; x++
            glo     ra        ; get ddF_x
            adi      2        ; ddF_x = ddF_x + 2;
            plo     ra        ; save updated ddF_x
            str     r2        ; save ddF_x in M(X)
            ghi     r8        ; get f
            add               ; f = f+ddF_y
            phi     r8        ; save updated f    


            ;--------------------------------------------
            ; Verify that x < (y+1) to avoid double
            ; drawing certain lines.
            ;--------------------------------------------
               
            ghi     rc        ; get y
            adi      1        ; y+1 
            str     r2        ; save y+1 in M(X)
            glo     rc        ; get x
            sm                ; check x - y+1 < 0
            lbdf    wq_skp1   ; when x >= y+1, skip first corners
                        
            ;------ draw right corners
            push    r8        ; save register for f and radius
            glo     rf        ; get corners value
            ani      1        ; check for first quad
            lbz     wq_qd2    ; if not q1 draw quad2
            
            ;--------------------------------------------
            ; Set up x0+x and y0-y values in r7 
            ; Set up length in r8.0
            ;--------------------------------------------            
            glo     rc        ; get x
            str     r2        ; save x in M(X)
            glo     rb        ; get x0
            add               
            plo     r7        ; xp = x0+x
            ghi     rc        ; get y
            str     r2        ; save y in M(X)  
            ghi     rb        ; get y0
            sm 
            phi     r7        ; yp = y0-y
            ghi     rc        ; get y
            shl               ; multiply by 2
            str     r2        ; save y*2 in M(X)
            ghi     rf        ; get delta
            add               ; length = 2y+delta
            plo     r8        ; set length for vertical line
            call    gfx_write_v_line

            ;------ draw left corners
wq_qd2:     glo     rf        ; get corners value
            ani      2        ; check for second quad            
            lbz     wq_done1  ; if not q2 we are done
            ;--------------------------------------------
            ; Set up x0-x and y0-y values in r7
            ; Set length in r8.0 
            ;--------------------------------------------            
            glo     rc        ; get x
            str     r2        ; save x in M(X)
            glo     rb        ; get x0
            sm               
            plo     r7        ; xp = x0-x
            ghi     rc        ; get y
            str     r2        ; save y in M(X)  
            ghi     rb        ; get y0
            sm 
            phi     r7        ; yp = y0-y
            ghi     rc        ; get y
            shl               ; multiply by 2
            str     r2        ; save y*2 in M(X)
            ghi     rf        ; get delta
            add               ; length = 2y+delta
            plo     r8        ; set length for vertical line            
            call    gfx_write_v_line
wq_done1:   pop     r8        ; restore f and radius              
          
wq_skp1:    ghi     rc        ; get y
            str     r2        ; save y in M(X)
            ghi     rd        ; get py
            sm                ; py - y
            lbz     wq_skp2
            
            ;------ draw right corners
            push    r8        ; save register for f and radius
            glo     rf        ; get corners value
            ani      1        ; check for first quad
            lbz     wq_qd3    ; if not q1 draw quad2
            
            ;--------------------------------------------
            ; Set up x0+py and y0-px values in r7 
            ; Set up length in r8.0
            ;--------------------------------------------            
            ghi     rd        ; get py
            str     r2        ; save py in M(X)
            glo     rb        ; get x0
            add               
            plo     r7        ; xp = x0+py
            glo     rd        ; get px
            str     r2        ; save px in M(X)  
            ghi     rb        ; get y0
            sm 
            phi     r7        ; yp = y0-px
            glo     rd        ; get px
            shl               ; multiply by 2
            str     r2        ; save px*2 in M(X)
            ghi     rf        ; get delta
            add               ; length = 2*px+delta
            plo     r8        ; set length for vertical line
            call    gfx_write_v_line

            ;------ draw left corners
wq_qd3:     glo     rf        ; get corners value
            ani      2        ; check for second quad            
            lbz     wq_done2  ; if not q2 we are done
            ;--------------------------------------------
            ; Set up x0-py and y0-px values in r7
            ; Set length in r8.0 
            ;--------------------------------------------            
            ghi     rd        ; get py
            str     r2        ; save py in M(X)
            glo     rb        ; get x0
            sm               
            plo     r7        ; xp = x0-py
            glo     rd        ; get px
            str     r2        ; save px in M(X)  
            ghi     rb        ; get y0
            sm 
            phi     r7        ; yp = y0-px
            glo     rd        ; get px
            shl               ; multiply by 2
            str     r2        ; save px*2 in M(X)
            ghi     rf        ; get delta
            add               ; length = 2*px+delta
            plo     r8        ; set length for vertical line            
            call    gfx_write_v_line

wq_done2:   pop     r8        ; restore f and radius              
            ghi     rc        ; get y
            phi     rd        ; set py = y
wq_skp2:    glo     rc        ; get x
            plo     rd        ; set px = x
             
chk_done:   lbr     p_loop    ; continue drawing pixels while x < y
            
wc_exit:    pop     ra        ; restore registers
            pop     rb
            pop     rc
            pop     rd
            pop     rf
                        
            clc               ; clear DF after arithmetic
            return
            
            endp
