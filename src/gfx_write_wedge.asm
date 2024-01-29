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
; Name: gfx_write_wedge
;
; Set pixels in the display buffer to write a solid   
; trianglar wedge with corners at (x0, y0) (x1, y1) 
; and (x2, y2).
;
; Parameters: 
;   r7.1 - y0 
;   r7.0 - x0 
;   r8.1 - y1 
;   r8.0 - x1
;   r9.1 - color 
;   r9.0 - rotation  
;   ra.1 - y2 
;   ra.0 - x2
; 
; Registers Used:
;   rb.0 - a
;   rb.1 - b
;   rc.1 - last value of y
;   rc.0 - current value of y
;   rd   - sa (16-bit)
;   rf   - sb ()
;
; Note: Checks x,y values, error if out of bounds
;                  
; Return: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    gfx_write_wedge

            push    rf        ; save registers used
            push    rd
            push    rc
            push    rb        
            
            ;--------------------------------------------
            ; Make sure y0 <= y1 <= y2 
            ; (sort to fill from top to bottom)
            ;--------------------------------------------
            
            ghi     r7        ; exchange points, if y0 > y1
            str     r2        ; save y0 in M(X)
            ghi     r8        ; get y1
            sm                ; y1 - y0 
            lbdf    y0_ok     ; DF = 1 means y1 >= y0 (okay)
            
            xchg    r7, r8    ; exchange p1 and p0
y0_ok:      ghi     r8        ; exchange points, if y1 > y2            
            str     r2        ; save y1 in M(X)
            ghi     ra        ; get y2
            sm                ; y2 - y1 
            lbdf    y1_ok     ; DF = 1 means y2 >= y1 (okay)
            
            xchg    r8, ra    ; exchange p2 and p1
y1_ok:      ghi     r7        ; exchange points, if y0 > y1, after earlier exchanges
            str     r2        ; save y0 in M(X)
            ghi     r8        ; get y1
            sm                ; y1 - y0 
            lbdf    sort_done ; DF = 1 means y1 >= y0 (exchanges done)
            
            xchg    r7, r8    ; exchange p1 and p0
sort_done:  ghi     r7        ; check for straight line y0 = y1 = y2            
            str     r2        ; save y0 in M(X)
            ghi     ra        ; get y2
            sm                ; y2 - y0
            lbz     ft_h_line ; if zero, all in horizontal line
            
            ghi     r7        ; check for flat-top y0 = y1
            str     r2        ; save y0 in M(X)
            ghi     r8        ; get y1
            sm                ; y1 - y0
            lbz     fill_btm  ; if zero, fill bottom from y1 to y2
            


            ;--------------------------------------------
            ;      fill the top half of triangle
            ;  r7.0 - x0
            ;  r8.1 - dy01
            ;  r8.0 - dx01
            ;  ra.1 - dy02
            ;  ra.0 - dx02
            ;  rb.1 - b
            ;  rb.0 - a
            ;  rc.1 - last y value
            ;  rc.0 - current y
            ;  rd   - sa
            ;  rf   - sb 
            ;--------------------------------------------
            
            push    ra        ; save point registers
            push    r8
            push    r7
            
            ghi     ra        ; get y2
            str     r2        ; save in M(X)
            ghi     r8        ; get y1
            sm                ; y1 - y2
            lbnz    flat_btm   
            ghi     r8        ; get y1
            phi     rc        ; set last y value to include y1
            lbr     fill_top
                          
flat_btm:   ghi     r8        ; get y1
            smi     1         ; 
            phi     rc        ; set last value to y-1
            
fill_top:   ghi     r7        ; set y to start at y0
            plo     rc        ; initial y value for loop
            
            ;------ Calculate dy02 and dx02
            ghi     r7        ; get y0
            str     r2        ; put in M(X)
            ghi     ra        ; get y2
            sm                ; dy02 = y2 - y0
            phi     ra        ; save y02 
            glo     r7        ; get x0
            str     r2        ; put in M(X)
            glo     ra        ; get x2
            sm                ; dx02 = x2 - x0
            plo     ra        ; save x02

            ;------ Calculate dy01 and dx01
            ghi     r7        ; get y0
            str     r2        ; put in M(X)
            ghi     r8        ; get y1
            sm                ; dy01 = y1 - y0
            phi     r8        ; save y01 
            glo     r7        ; get x0
            str     r2        ; put in M(X)
            glo     r8        ; get x1
            sm                ; dx01 = x1 - x0
            plo     r8        ; save x01
            
            ;------ set a,b, sa and sb initially to zero
            ldi     0
            phi     rb        ; b = 0
            plo     rb        ; a = 0
            phi     rd        ; sa = 0
            plo     rd        
            phi     rf        ; sb = 0
            plo     rf
            
fill_lp:    push    rf        ; save sa and sb
            push    rd        ; before arithmetic
            
            copy    rd, rf    ; set dividend to sa            
            ldi     0
            phi     rd
            ghi     r8        ; get dy01 as divisor
            plo     rd
            
            ;-----  divide sa by dy01
            call    gfx_math_div8
            
            glo     r7        ; get x0
            str     r2        ; save in M(X)
            glo     rf        ; get quotient
            add               ; a = x0 + sa/dy01
            plo     rb        ; save a
              
            pop     rd        ; restore sa and sb
            pop     rf
            
            push    rf        ; save sa and sb on stack
            push    rd
            
            ;-----  rf is aleady set to sb
            ldi     0
            phi     rd
            ghi     ra        ; get dy02 as divisor
            plo     rd
            
            ;-----  divide sb by dy02
            call    gfx_math_div8
            
            glo     r7        ; get x0
            str     r2        ; save in M(X)
            glo     rf        
            add               ; b = x0 + sb/dy02
            phi     rb        ; save b
              
            pop     rd        ; restore sa and sb
            pop     rf
            
            push    r8        ; save point registers
            push    r7 
            
            glo     rb        ; check for a > b
            str     r2        ; save a in M(X)
            ghi     rb        ; get b
            sm                ; b - a
            lbdf    lng_ok    ; if b > a, length is okay
            
            sdi     0         ; invert the difference
            plo     r8        ; set length
            ghi     rb        ; get b
            plo     r7        ; set x = b
            lbr     set_y
              
lng_ok:     plo     r8        ; set length
            glo     rb        ; get a
            plo     r7        ; set x = a
set_y:      glo     rc        ; get current y
            phi     r7        ; set y 
            
            ;-----  draw a horizontal line
            call    gfx_write_h_line
            
            pop     r7        ; restore point registers
            pop     r8

            ;-----  adjust sa, sa += dx01            
            push    r8        ; save d01 register
            sext    r8        ; extend dx01 for sign
            ADD16   rd, r8    ; add sign extended dx01 to sa
            pop     r8        ; restore d01 register

            ;-----  adjust sb, sb += dx02
            push    ra        ; save d02 register
            sext    ra        ; adjust dx02 for sign
            ADD16   rf, ra    ; add sign extended dx02 to sb
            pop     ra        ; restore d02 register


            inc     rc        ; advance y

            ghi     rc        ; check for last y
            str     r2
            glo     rc        ; get y value  
            sd                ; last - y >= 0, DF = 1
            lbdf    fill_lp   ; if y > last, we are done
                        
            pop     r7        ; restore point registers
            pop     r8
            pop     ra

            ;-----  check for flat bottom, y1 = y2
            ghi     ra        ; get y2
            str     r2        ; save in M(X)
            ghi     r8        ; get y1
            sm                ; y1 - y2
            lbz    ww_exit   ; if flat bottom, we are done   

            ;--------------------------------------------
            ;      fill the bottom half of triangle
            ;  r7.0 - x0
            ;  r7.1 - x1
            ;  r8.1 - dy12
            ;  r8.0 - dx12
            ;  ra.1 - dy02
            ;  ra.0 - dx02
            ;  rb.1 - b
            ;  rb.0 - a
            ;  rc.1 - last y value (y2)
            ;  rc.0 - current y value, initially y1
            ;  rd   - sa
            ;  rf   - sb 
            ;--------------------------------------------

fill_btm:   ghi     r8        ; get y1
            plo     rc        ; save as current y
            ghi     ra        ; get y2  
            phi     rc        ; set as last y


            ;------ Calculate dy01 for initial sb
            ghi     r7        ; get y0
            str     r2        ; put in M(X)
            ghi     r8        ; get y1
            sm                ; dy01 = y1 - y0
            plo     rd        ; save y01 as multiplier for sb 

            ;------ Calculate dy12 and dx12
            ghi     r8        ; get y1
            str     r2        ; put in M(X)
            ghi     ra        ; get y2
            sm                ; dy12 = y2 - y1
            phi     r8        ; save y12 
            glo     r8        ; get x1
            plo     re        ; save x1 in Elf/OS scratch register
            str     r2        ; put in M(X)
            glo     ra        ; get x2
            sm                ; dx12 = x2 - x1
            plo     r8        ; save dx12            

            ;------ Calculate dy02 and dx02
            ghi     r7        ; get y0
            str     r2        ; put in M(X)
            ghi     ra        ; get y2
            sm                ; dy02 = y2 - y0
            phi     ra        ; save y02 
            glo     r7        ; get x0
            str     r2        ; put in M(X)
            glo     ra        ; get x2
            sm                ; dx02 = x2 - x0
            plo     ra        ; save dx02
            
            ;------ Store x1 in r7.1 for sa calculations
            glo     re
            phi     r7

            ;------ Calculate initial sb value
            glo     ra        ; get dx02
            plo     rf        ; set as multiplicand
            
            ;------ sb = dx02 * dy01 
            call    gfx_math_mul8

            ldi     0         
            plo     rd        ; set sa = 0
            phi     rd
            plo     rb        ; set a = 0
            phi     rb        ; set b = 0
            
fill_lp2:   push    rf        ; save sa and sb
            push    rd        ; before arithmetic
            
            copy    rd, rf    ; set dividend to sa            
            ldi     0
            phi     rd
            ghi     r8        ; get dy12 as divisor
            plo     rd
            
            ;-----  divide sa by dy12
            call    gfx_math_div8
            
            ghi     r7        ; get x1
            str     r2        ; save in M(X)
            glo     rf        ; get quotient
            add               ; a = x1 + sa/dy12
            plo     rb        ; save a
              
            pop     rd        ; restore sa and sb
            pop     rf
             
            push    rf        ; save sa and sb on stack
            push    rd
            
            ;-----  rf is aleady set to sb
            ldi     0
            phi     rd
            ghi     ra        ; get dy02 as divisor
            plo     rd
            
            ;-----  divide sb by dy02
            call    gfx_math_div8
            
            glo     r7        ; get x0
            str     r2        ; save in M(X)
            glo     rf        
            add               ; b = x0 + sb/dy02
            phi     rb        ; save b
              
            pop     rd        ; restore sa and sb
            pop     rf

            push    r8        ; save point registers
            push    r7 
            
            glo     rb        ; check for a > b
            str     r2        ; save a in M(X)
            ghi     rb        ; get b
            sm                ; b - a
            lbdf    lng2_ok   ; if b > a, length is okay

            sdi     0         ; invert the difference
            plo     r8        ; set length
            ghi     rb        ; get b
            plo     r7        ; set x = b
            lbr     set_y2
              
lng2_ok:    plo     r8        ; set length
            glo     rb        ; get a
            plo     r7        ; set x = a
set_y2:     glo     rc        ; get current y
            phi     r7        ; set y 
            
            ;-----  draw a horizontal line
            call    gfx_write_h_line
            
            pop     r7        ; restore point registers
            pop     r8

            ;-----  adjust sa, sa += dx12            
            push    r8        ; save d12 register
            sext    r8        ; extend dx12 for sign
            ADD16   rd, r8    ; add sign extended dx12 to sa
            pop     r8        ; restore d12 register

            ;-----  adjust sb, sb += dx02
            push    ra        ; save d02 register
            sext    ra        ; adjust dx02 for sign
            ADD16   rf, ra    ; add sign extended dx02 to sb
            pop     ra        ; restore d02 register

            inc     rc        ; advance y

            ghi     rc        ; check for last y
            str     r2
            glo     rc        ; get y value  
            sd                ; last - y >= 0, DF = 1
            lbdf    fill_lp2   ; if y > last, we are done
              
            lbr     ww_exit 
            
ft_h_line:  glo     r7        ; set a and b to x0
            plo     rb        ; a = x0
            phi     rb        ; b = x0
            glo     rb        ; get a
            str     r2        ; save a in M(X)
            glo     r8        ; get x1
            sm                ; check x1 - a
            lbdf    a_ok1     ; df =1 means x1 - a >= 0, x1 > a

            glo     r8        ; if x1 < a
            plo     rb        ; then a = x1
            lbr     b_ok1     ; if x1 < a, no need to check for x1 > b

a_ok1:      glo     r8        ; get x1
            str     r2        ; save x1 in M(X)
            ghi     rb        ; check if x1 > b
            sm                ; b - x1
            lbdf    b_ok1     ; df = 1, means b - x1 >= 0, b > x1

            glo     r8        ; if x1 > b
            phi     rb        ; b = x1
b_ok1:      glo     rb        ; get a 
            str     r2        ; save a in M(X)
            glo     ra        ; get x2
            sm                ; check x2 - a
            lbdf    a_ok2     ; df = 1 means x2 - a >= 0, x2 > a

            glo     ra        ; if x2 < a
            plo     rb        ; then a = x2
            lbr     b_ok2     ; if x2 < a, no need to check x2 > b

a_ok2:      glo     ra        ; get x2
            str     r2        ; save x2 in M(X)
            ghi     rb        ; check if x2 > b
            sm                ; b - x2
            lbdf    b_ok2     ; df = 1 means b - x2 >= 0, b > x2

            glo     ra        ; if x2 > b
            phi     rb        ; b = x2        
                  
            ;----  set up to draw horizontal line y0 is already set
b_ok2:      glo    rb         ; get a (minimum x)
            plo    r7         ; set x0 to minimum
            str    r2         ; save a in M(X)
            ghi    rb         ; get b (maximum x)
            sm                ; D = b -a (length)
            plo    r8         ; set length
            call   gfx_write_h_line
                    
ww_exit:    pop     rb        ; restore registers
            pop     rc
            pop     rd
            pop     rf
            
            clc               ; clear error
            return
            
            endp
