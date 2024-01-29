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
; Name: gfx_write_arc
;
; Set pixels in the display buffer to write a circle at 
; the origin x0, y0 with a radius r.
;
; Parameters: 
;   r7.1 - origin y 
;   r7.0 - origin x 
;   r8.0 - radius r
;   r8.1 - quads, quadrants to draw
;   r9.1 - color 
;   r9.0 - rotation  
;
; Registers Used:
;   r8.1 - f
;   ra.0 - ddF_x
;   ra.1 - ddF_y
;   rb.0 - origin x
;   rb.1 - origin y
;   rc.0 - x offset
;   rc.1 - y offset
;   rf.0 - quads
;
; Return: 
;   DF = 1 if error, 0 if no error
;   r7, r8 are consumed
;-------------------------------------------------------
            proc    gfx_write_arc
            
            push    rf
            push    rd
            push    rc        ; save registers used
            push    rb
            push    ra

            ;--------------------------------------------
            ;      write pixels to form a circle
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
            ;  rf.0 - quads
            ;--------------------------------------------
            copy    r7, rb    ; save origin in rb

            ghi     r8        ; get quads value
            plo     rf        ; save quads byte in rf.0
          

            ;--------------------------------------------            
            ; Draw pixels at cardinal points at 
            ; north, south, east and west, if arc
            ; spans 2 quadrants (semicircle arc)
            ;--------------------------------------------

            ;-----  write north pixel
chk_n:      glo     rf        ; get quads flag check for north
            ani     NE_QUAD | NW_QUAD   ; check for either bit set
            lbz     chk_s     ; if not, check for next quadrant

            xri     NE_QUAD | NW_QUAD   ; check for both bits  sets
            lbnz    chk_s     ; if not, check for next quadrant

            glo     r8        ; get r
            str     r2        ; save radius in M(X)
            ghi     rb        ; get y0
            sm                ; yp = y0 - r
            phi     r7        ; xp already = x0
            
            ;------ write pixel at (x0, y0-r)
            call    gfx_write_pixel 
            
            ;-----  write south pixel
chk_s:      glo     rf        ; get quads flag check for south
            ani     SE_QUAD | SW_QUAD   ; check for either bit set   
            lbz     chk_e    ; if not, check for east

            xri     SE_QUAD | SW_QUAD   ; check for both bits set   
            lbnz    chk_e    ; if not, check for east

            glo     rb        ; get x0
            plo     r7        ; set xp = x0
            glo     r8        ; get r
            str     r2        ; store radius at M(X)
            ghi     rb        ; get y0
            add               ; yp = y0 + r
            phi     r7   

            ;------ write pixel at (x0, y0+r)
            call    gfx_write_pixel 
            
            ;------ write east pixel
chk_e:      glo     rf        ; get quads flag check for east
            ani     NE_QUAD | SE_QUAD   ; check for either bit set   
            lbz     chk_w    ; if not, check for west

            xri     NE_QUAD | SE_QUAD   ; check for both bits set   
            lbnz    chk_w    ; if not, check for west

            ghi     rb        ; get y0
            phi     r7        ; set yp = y0
            glo     r8        ; get r
            str     r2        ; store radius at M(X)
            glo     rb        ; get x0
            add               ; xp = x0 + r
            plo     r7

            ;------ write pixel at (x0+r, y0)
            call    gfx_write_pixel 
            
            ;------ write west pixel
chk_w:      glo     rf        ; get quads flag check for east
            ani     NW_QUAD | SW_QUAD   ; check for either bit set
            lbz     set_var   ; if not, set up variables to draw rest

            xri     NW_QUAD | SW_QUAD   ; check for both bits set
            lbnz    set_var   ; if not, set up variables to draw rest
            
            ghi     rb        ; get y0
            phi     r7        ; set yp = y0
            glo     r8        ; get r
            str     r2        ; store radius at M(X)
            glo     rb        ; get x0
            sm                ; xp = x0 - r
            plo     r7

            ;------ write pixel at (x0-r, y0)
            call    gfx_write_pixel 
            
            ;--------------------------------------------            
            ; Set up variables to calculate additional 
            ; points.
            ; f = 1 - r
            ; ddF_x = 1;
            ; ddF_y = -2 * r
            ; x offset = 0
            ; y offset = r
            ;--------------------------------------------
set_var:    ldi      0
            plo     rc        ; set x = 0
            glo     r8        ; get radius r
            phi     rc        ; set y = r
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

            ;------ draw SE Quardrant
            glo     rf        ; get quads flag
            ani     SE_QUAD   ; check for NE quadrant
            lbz     chk_se    ; if not, check for next quadrant

            ;--------------------------------------------
            ; Set up x0+x and y0+y values in r7 
            ;--------------------------------------------            
            glo     rc        ; get x
            str     r2        ; save x in M(X)
            glo     rb        ; get x0
            add               
            plo     r7        ; xp = x0+x
            ghi     rc        ; get y
            str     r2        ; save y in M(X)  
            ghi     rb        ; get y0
            add 
            phi     r7        ; yp = y0+y
            call    gfx_write_pixel
                          
            ;--------------------------------------------
            ; Set up x0+y and y0+x values in r7 
            ;--------------------------------------------            
            ghi     rc        ; get y
            str     r2        ; save y in M(X)
            glo     rb        ; get x0
            add               
            plo     r7        ; xp = x0+y
            glo     rc        ; get x
            str     r2        ; save x in M(X)  
            ghi     rb        ; get y0
            add 
            phi     r7        ; yp = y0+x
            call    gfx_write_pixel              
            
            
            ;------ draw NE Quardrant
chk_se:     glo     rf        ; get quads flag
            ani     NE_QUAD   ; check for NE quadrant
            lbz     chk_nw    ; if not, check for next quadrant
            
            ;--------------------------------------------
            ; Set up x0+x and y0-y values in r7 
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
            call    gfx_write_pixel
            
            ;--------------------------------------------
            ; Set up x0+y and y0-x values in r7 
            ;--------------------------------------------            
            ghi     rc        ; get y
            str     r2        ; save y in M(X)
            glo     rb        ; get x0
            add               
            plo     r7        ; xp = x0+y
            glo     rc        ; get x
            str     r2        ; save x in M(X)  
            ghi     rb        ; get y0
            sm 
            phi     r7        ; yp = y0-x
            call    gfx_write_pixel              
            
            ;------ draw SW Quardrant
chk_nw:     glo     rf        ; get quads flag
            ani     SW_QUAD   ; check for SE quadrant
            lbz     chk_sw    ; if not, check for next quadrant
              
            ;--------------------------------------------
            ; Set up x0-x and y0+y values in r7 
            ;--------------------------------------------            
            glo     rc        ; get x
            str     r2        ; save x in M(X)
            glo     rb        ; get x0
            sm               
            plo     r7        ; xp = x0-x
            ghi     rc        ; get y
            str     r2        ; save y in M(X)  
            ghi     rb        ; get y0
            add 
            phi     r7        ; yp = y0+y
            call    gfx_write_pixel

            ;--------------------------------------------
            ; Set up x0-y and y0+x values in r7 
            ;--------------------------------------------            
            ghi     rc        ; get y
            str     r2        ; save y in M(X)
            glo     rb        ; get x0
            sm               
            plo     r7        ; xp = x0-y
            glo     rc        ; get x
            str     r2        ; save x in M(X)  
            ghi     rb        ; get y0
            add 
            phi     r7        ; yp = y0+x
            call    gfx_write_pixel              

            ;------ draw NW Quardrant
chk_sw:     glo     rf        ; get quads flag
            ani     NW_QUAD   ; check for NW quadrant
            lbz     chk_done    ; if not, we're done

            ;--------------------------------------------
            ; Set up x0-x and y0-y values in r7 
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
            phi     r7        ; yp = y0+y
            call    gfx_write_pixel
       
            ;--------------------------------------------
            ; Set up x0-y and y0-x values in r7 
            ;--------------------------------------------            
            ghi     rc        ; get y
            str     r2        ; save y in M(X)
            glo     rb        ; get x0
            sm               
            plo     r7        ; xp = x0-y
            glo     rc        ; get x
            str     r2        ; save x in M(X)  
            ghi     rb        ; get y0
            sm 
            phi     r7        ; yp = y0-x
            call    gfx_write_pixel                          
             
chk_done:   lbr     p_loop    ; continue drawing pixels while x < y
            
wc_exit:    pop     ra        ; restore registers
            pop     rb
            pop     rc
            pop     rd
            pop     rf
                        
            clc               ; clear DF after arithmetic
            return
            
            endp
