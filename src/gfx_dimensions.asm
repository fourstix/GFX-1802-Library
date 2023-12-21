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
; Name: gfx_dimensions
;
; Get the maximum values for x and y.
;
; Parameters: 
;   r9.0 - rotation
;
; Returns:
;   RA.1 = Ymax
;   RA.0 = Xmax
;-------------------------------------------------------
            proc    gfx_dimensions

            call    gfx_disp_size   ; ra.1 = height, ra.0 = width
            
            glo     r9              ; check rotation
            ani     $03             ; rotation has values 0 to 3
            shr                     ; lsb indicates portrait or landscape mode 
            lbnf    gd_adj          ; r=0 or r=2 is landscape, no need to swap h and w 
            swap    ra              ; r=1 or r=3 is portrait, swap h and w values            
gd_adj:     ghi     ra              ; Ymax = h - 1
            smi     1
            phi     ra              ; ra.1 = Ymax
            glo     ra              ; Xmax = w - 1
            smi     1
            plo     ra              ; ra.0 = Xmax
            clc                     ; clear DF after arithmetic
            return
            endp
