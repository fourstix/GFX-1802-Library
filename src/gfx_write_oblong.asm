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
; Name: gfx_write_oblong
;
; Set pixels for a rectanglar part of a rectangle with
; rounded corners in the display buffer at position x,y
;
; Parameters: 
;   r9.1 - color
;   r9.0 - rotation
;   r8.1 - h 
;   r8.0 - w 
;   r7.1 - origin y 
;   r7.0 - origin x 
;   ra.0 - corner radius r
;
; Registers Used:
;   ra - dimensions
;   rb - origin
;   rc - r and 2r
;   rd - scratch register
;
; Return:
;   DF = 1 if error, 0 if no error (r7 & r9 consumed)
;-------------------------------------------------------
            proc    gfx_write_oblong

            push    rf        ; save delta register
            push    rd        ; save scratch register
            push    rc        ; save radius register
            push    rb        ; save dimension registers
            push    ra        ; save origin register
            
            glo     ra        ; get radius
            plo     rc        ; save in rc.0
            shl               ; multiply by 2
            phi     rc        ; save 2r in rc.1
            
            copy    r7, ra    ; save origin 
            copy    r8, rb    ; save dimensions

            ;--------------------------------------------
            ; Fill rectangle  
            ;--------------------------------------------            
            glo     ra        ; get x0
            str     r2        ; save in M(X)
            glo     rc        ; get r
            add               ; x0+r
            plo     r7        ; x = x0+r
            ;------ y is already y0 in r7.1
            ghi     rc        ; get 2r
            str     r2        ; save in M(X)
            glo     rb        ; get w'
            sm                ; w'-2r
            lbnf    skp_block ; no filled rectangle, if w'-2r < 0 
            plo     r8        ; w = w'-2r
            ;------ h is already h' in r8.1
                        
            call    gfx_write_block  ; draw top line 
            lbdf    wr_done           ; if error, exit immediately

            ;------ draw right side with arcs at x+w'-r, y+r, r, length = h-2r             
skp_block:  glo     ra        ; get x0
            str     r2        ; save x0 in M(X)
            glo     rb        ; get w'
            add               ; x0+w'
            str     r2        ; save x0+w' in M(X)
            glo     rc        ; get r
            sd                ; x0 + w' - r
            plo     r7
            ghi     ra        ; get y0
            str     r2        ; put y0 in M(X)
            glo     rc        ; get r
            add               ; y0 + r
            phi     r7        ; set y = y0+r
            phi     rd        ; save in scratch register            
            glo     rc        ; get r
            plo     r8        ; set radius
            ldi     RIGHT_SIDE
            phi     r8        ; draw right corners and side
            ghi     rc        ; get 2*r
            str     r2        ; put 2*r in M(X)
            ghi     rb        ; get h'
            sm                ; h' - 2r
            phi     rf        ; set delta to h' - 2r
            plo     rd        ; save in scratch register
            clc               ; clear DF after arithmetic
            
            ;--------------------------------------------
            ;  Write right side with corner arcs 
            ;  r7.0 = x = x0+w'-r
            ;  r7.1 = y = y0+r
            ;  r8.0 = r
            ;  r8.1 = corners (Right)
            ;  rf.1 = delta = h'-2r
            ;--------------------------------------------

            call    gfx_write_quads   ; draw right side with arcs
            lbdf    wr_done           ; if error, exit immediately

            ;------ draw left side with arcs at x+r, y+r, r, length = h-2r             
            glo     ra        ; get x0 
            str     r2        ; save x0 in M(X)
            glo     rc        ; get r
            add               ; x0+r
            plo     r7        ; x = x0+r
            ghi     rd        ; get y0+r from scratch register
            phi     r7        ; y = y0+r
            glo     rc        ; get r
            plo     r8        ; set radius to r
            ldi     LEFT_SIDE
            phi     r8        ; draw left corners and side
            glo     rd        ; get length from scratch register
            phi     rf        ; set delta to h' - 2r

            ;--------------------------------------------
            ;  Write left side with corner arcs 
            ;  r7.0 = x = x0+r
            ;  r7.1 = y = y0+r
            ;  r8.0 = r
            ;  r8.1 = corners (Left)
            ;  rf.1 = delta = h'-2r
            ;--------------------------------------------     

            call    gfx_write_quads   ; draw left line
            lbdf    wr_done           ; if error, exit immediately
            
            
            clc               ; clear DF after arithmetic
wr_done:    pop     ra        ; restore registers
            pop     rb
            pop     rc
            pop     rd
            pop     rf
            return 
            endp  
