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
; Name: gfx_math_div8
;
; Divide a 16-bit signed value by a signed byte value 
; and return the result as a 16 bit value in RF.
;
; Parameters:
;   rf - signed 16-bit dividend
;   rd.0 - signed byte divisor
;
; Registers Used:
;   rf   - f_div16 remainder (ignored)
;   rd.1 - sign extension for divisor
;   rb.0 - sign flag for result
;   rb   - f_div16 16-bit quotient
;   r9   - used by f_div16  
;   r8   - used by f_div16
;
; Returns: 
;   DF = 1 if error, 0 if no error
;   rf = signed 16 bit quotient for rf / rd.0
;   rd = remainder
;
; Note: 
;   Calls f_div16 with two positive 16-bit values set equal
;   to the absolute values of the dividend and divisor.  
;   The 16-bit quotient in rb is then sign adjusted for 
;   the result and copied into rf.  
;-------------------------------------------------------
            proc    gfx_math_div8
            push    rb              ; save registers used by f_div16
            push    r9
            push    r8
            
            ldi      0
            plo     rb              ; set signed result flag for positive initially
            ghi     rf              ; get dividend from rf.1
            shl                     ; check for negative (shift msb to df)
            lbnf    pos1            ; df = 0, means positive

            glo     rb              ; negative value 
            xri     $ff             ; toggle signed result flag
            plo     rb
            glo     rf              ; negate dividend
            sdi     0               ; 0 - D => -D = |D|
            plo     rf              ; save absolute value in rf.0
            ghi     rf              ; negate upper byte with borrow
            sdbi    0
            phi     rf              ; rf has absolute value of dividend
pos1:       glo     rd              ; get divisor in rd.0             
            shl                     ; check for negative (shift msb to df)
            lbnf    pos2            ; df = 0, means positive

            glo     rb              ; negative value  
            xri     $ff             ; toggle signed result flag
            plo     rb
            glo     rd              ; negate byte
            sdi     0               ; 0 - D => -D = |D|
            plo     rd              ; save absolute value in rd.0
pos2:       ldi     0               ; set high byte of absolute value of divisor
            phi     rd
            glo     rb              ; get sign result flag
            stxd                    ; save sign flag on stack for later
            
            call    f_div16         ; call bios 16 bit multiply routine
            copy    rf, rd          ; copy remainder into rd
            copy    rb, rf          ; copy 16-bit result into rf (ignore rc)
            irx                     ; get sign byte from stack 
            ldx                     ; check sign byte and adjust result
            lbz    dv_done          ; if positive then we are done
            glo    rf               ; negate the result
            sdi    0                ; negate lower byte
            plo    rf
            ghi    rf               ; negate upper byte with borrow
            sdbi   0        
            phi    rf               ; rf = signed 16-bit quotient
            
dv_done:    clc                     ; clear df (after math)
            pop     r8              ; restore registers
            pop     r9
            pop     rb                  
            return
            endp
