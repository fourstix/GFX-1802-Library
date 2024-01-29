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
#include    ../include/bios.inc
#include    ../include/kernel.inc
#include    ../include/ops.inc
#include    ../include/gfx_display.inc  
#include    ../include/gfx_def.inc  

;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: gfx_write_rrect
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
;   ra - origin
;   rb - dimensions
;
; Return:
;   DF = 1 if error, 0 if no error (r7 & r9 consumed)
;-------------------------------------------------------
            proc    gfx_write_rrect

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
            ; Draw lines  
            ;--------------------------------------------            
            ; draw top line at x+r, y, length = w - 2r
            glo     rc        ; get r
            str     r2        ; save in M(X)
            glo     ra        ; get x0
            add               ; x0+r
            plo     r7        ; x = x0+r
            plo     rd        ; save in scratch register for bottom line
            ghi     ra        ; get y0
            phi     r7        ; y = y0
            ghi     rc        ; get 2r
            str     r2        ; save in M(X)
            glo     rb        ; get w'
            sm                ; w'- 2r
            lbnf    drw_sides ; if -1, skip top and bottom lines
            phi     rd        ; save length in scratch register
            plo     r8        ; length = w'-2r
            clc               ; clear DF flag after arithmetic      
              
            call    gfx_write_h_line  ; draw top line 
            lbdf    wr_done           ; if error, exit immediately

            ;----- draw bottom line at x+r, y+h', length = w-2r
            glo     rd        ; get x0+r from scratch register
            plo     r7
            ghi     rb        ; get h'
            str     r2        ; save in M(X)
            ghi     ra        ; get y
            add               ; y0+h'
            phi     r7        ; y = y0+h'
            ghi     rd        ; get length from scratch register
            plo     r8
            clc               ; clear DF flag after arithmetic      
            
            call    gfx_write_h_line  ; draw bottom line
            lbdf    wr_done           ; if error, exit immediately

            ;------ draw left line at x, y+r, length = h-2r             
drw_sides:  clc               ; clear DF in case of skip top and bottom lines
            glo     ra        ; get x0 
            plo     r7        ; x = x0
            glo     rc        ; get r
            str     r2        ; save in M(X)
            ghi     ra        ; get y0
            add               ; y0+r
            phi     r7        ; y = y0+r
            plo     rd        ; save in scratch register for right line 
            ghi     rc        ; get 2r
            str     r2        ; save in M(X)
            ghi     rb        ; get h'
            sm                ; length = h'-2r
            lbnf    corners   ; if < 0, skip left and right lines
            plo     r8  
            phi     rd        ; save length in scratch register
            clc               ; clear DF flag after arithmetic      

            call    gfx_write_v_line  ; draw left line
            lbdf    wr_done           ; if error, exit immediately
            
            ;------ draw right line at x+w-1, y+r, length = h-2r
            glo     rb        ; get w
            str     r2        ; save in M(X)  
            glo     ra        ; get x0
            add               ; x0+w'
            plo     r7        ; x = x0+w'
            glo     rd        ; get y0+r from scratch register
            phi     r7        ; y = y0+r
            ghi     rd        ; get length from scratch register
            plo     r8        ; length = h'-2r
            clc               ; clear DF flag after arithmetic      
            
            call    gfx_write_v_line   ; draw right line
            lbdf    wr_done           ; if error, exit immediately
            
            ;--------------------------------------------
            ; Draw corners  
            ;--------------------------------------------
corners:    clc               ; clear DF in case skipped left and right lines
            glo     rc        ; get r
            str     r2        ; save in M(X)
            glo     ra        ; get x0
            add               ; x0+r
            plo     r7        ; x = x0+r
            ghi     ra        ; get y0
            add               ; y0+r
            phi     r7        ; y = y0+r
            glo     rc        ; radius = r
            plo     r8        ; set radius for corner
            ldi     NW_QUAD   ; draw upper left quadrant
            phi     r8        ; as arc for rounded corner

            ;--------------------------------------------
            ; Draw upper left corner arc  
            ;--------------------------------------------
             
            call    gfx_write_arc

            glo     rb        ; get w'
            str     r2        ; save in M(X)
            glo     ra        ; get x0
            add               ; x = x0+w'
            str     r2        ; put x0+w' in M(X)
            glo     rc        ; get r
            sd                ; x0+w'-r
            plo     r7        ; x = x0+w'-r
            glo     rc        ; get r
            str     r2        ; put r in M(X)
            ghi     ra        ; get y0
            add               ; y0+r
            phi     r7        ; y = y0+r
            glo     rc        ; radius = r
            plo     r8        ; set radius for corner
            ldi     NE_QUAD   ; draw upper right quadrant
            phi     r8        ; as arc for rounded corner

            ;--------------------------------------------
            ; Draw upper right corner arc  
            ;--------------------------------------------

            call    gfx_write_arc

            glo     rb        ; get w'
            str     r2        ; save in M(X)
            glo     ra        ; get x0
            add               ; x0+w'
            str     r2        ; put x0+w' in M(X)
            glo     rc        ; get r
            sd                ; x0+w'-r
            plo     r7        ; x = x0+w'-r

            ghi     rb        ; get h'
            str     r2        ; save in M(X)
            ghi     ra        ; get y0
            add               ; y0+h'
            str     r2        ; put y0+h' in M(X)
            glo     rc        ; get r
            sd                ; y0+h'-r
            phi     r7        ; y = y0+h-r
            glo     rc        ; radius = r
            plo     r8        ; set radius for corner
            ldi     SE_QUAD   ; draw lower right quadrant
            phi     r8        ; as arc for rounded corner
            
            ;--------------------------------------------
            ; Draw lower right corner arc  
            ;--------------------------------------------

            call    gfx_write_arc

            glo     rc        ; get r
            str     r2        ; save in M(X)
            glo     ra        ; get x0
            add               ; x0+r
            plo     r7        ; x = x0+r 

            ghi     rb        ; get h'
            str     r2        ; save in M(X)
            ghi     ra        ; get y0
            add               ; y0+h
            str     r2        ; put y0+h' in M(X)
            glo     rc        ; get r
            sd                ; y0+h-r
            phi     r7        ; y = y0+h'-r
            glo     rc        ; radius = r
            plo     r8        ; set radius for corner
            ldi     SW_QUAD   ; draw lower left quadrant
            phi     r8        ; as arc for rounded corner

            ;--------------------------------------------
            ; Draw lower left corner arc  
            ;--------------------------------------------
               
            call    gfx_write_arc
            
            clc               ; cleaer DF after arithmetic
wr_done:    pop     ra        ; restore registers
            pop     rb
            pop     rc
            pop     rd
            return 
            endp  
