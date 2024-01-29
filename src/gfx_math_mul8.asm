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
; Name: gfx_math_mul8
;
; Multiply two signed byte values and return the 
; signed product as a 16 bit value in RF.
;
; Parameters:
;   rf.0 - signed byte multiplicand
;   rd.0 - signed byte multiplier
;
; Registers Used:
;   rf.1 - sign extension for multiplicand
;   rd.1 - sign extension for multiplier
;   rc.0 - sign flag for result
;   rc   - f_mult16 32-bit result high word (ignored)
;   rb   - f_mult16 32-bit result low word (16-bit product)
;
; Returns: 
;   DF = 1 if error, 0 if no error
;   rf = signed 16 bit product for rd.0 * rf.0
;   rd is consumed
;
; Note: 
;   Calls f_mul16 with two positive 16-bit values set equal
;   to the absolute values of the 8-bit values.  The 16-bit 
;   product of two bytes in rb is then sign adjusted for 
;   the result. The high word of the 32-bit result in rc is 
;   not significant and is ignored.  
;-------------------------------------------------------
            proc    gfx_math_mul8
            push    rb              ; save register used
            
            ldi      0
            plo     rb              ; set signed result flag for positive initially
            glo     rf              ; get multiplicand from rf.0
            shl                     ; check for negative (shift msb to df)
            lbnf    pos1            ; df = 0, means positive

            glo     rb              ; negative value 
            xri     $ff             ; toggle signed result flag
            plo     rb
            glo     rf              ; negate byte
            sdi     0               ; 0 - D => -D = |D|
            plo     rf              ; save absolute value in rf.0
            
pos1:       glo     rd              ; get multiplier in rd.0             
            shl                     ; check for negative (shift msb to df)
            lbnf    pos2            ; df = 0, means positive

            glo     rb              ; negative value  
            xri     $ff             ; toggle signed result flag
            plo     rb
            glo     rd              ; negate byte
            sdi     0               ; 0 - D => -D = |D|
            plo     rd              ; save absolute value in rd.0
            
pos2:       ldi     0               ; set high byte of absolute values 
            phi     rf
            phi     rd
            glo     rb              ; get sign flag
            stxd                    ; save sign flag on stack for later
            
            call    f_mul16         ; call bios 16 bit multiply routine
            copy    rb, rf          ; copy 16-bit result into rf (ignore rc)
            irx                     ; get sign byte from stack 
            ldx                     ; check sign byte and adjust result
            lbz    m8_done          ; if positive then we are done

            glo    rf               ; negate the result
            sdi    0                ; negate lower byte
            plo    rf
            ghi    rf               ; borrow into upper byte
            sdbi   0        
            phi    rf               ; rf = signed 16-bit result
            

m8_done:    clc                     ; clear df (after math)
            pop     rb              ; restore product register
            return
            endp
