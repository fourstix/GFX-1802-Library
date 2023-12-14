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
; Name: gfx_write_char
;
; Write pixels for a character in the display buffer 
; at position x,y.
;
; Parameters: 
;   rf   - pointer to display buffer.
;   r7.1 - origin y  (signed byte)
;   r7.0 - origin x  (signed byte)
;   r9.1 - color
;   r9.0 - rotation
;   r8.0 - character to write
;
; Registers Used:
;   rf   - pointer to char bitmap (five data bytes)
;   rc.1 - shifted data byte
;   rc.0 - outer byte counter, temp offset 
;   r8.0 - inner bit counter, index register
;   r8.1 - origin y value, index register
;
; Return: (None) - r8, r9 consumed
;-------------------------------------------------------
            proc    gfx_write_char
            
            push    rf        ; save font character pointer
            push    rc        ; save counter
            
            ;---- set rf to base of font table
            load    rf, gfx_ascii_font   
            
            ;---- set up scratch register as index register
            ldi      0          ; clear high byte of index
            phi     r8        
                
            ;---- convert character to offset 
            glo     r8          ; get character
            ani     $80         ; check for non-ascii
            lbz     char_ok

            ldi     C_ERROR     ; show DEL for all non-ascii chars
            lbr     set_offset  ; set offset to DEL value
            
char_ok:    glo     r8          
            smi     C_OFFSET    ; convert to offset value
            lbdf    set_offset  ; printable character 
            
            ldi     0           ; print space for all control characters                

set_offset: plo     r8          ; put offset into index register
            plo     rc          ; save temp char offset for add
  
            ;---- each character is 5 bytes so multply offset by 5 (4+1)
            SHL16   r8          ; shift index twice to multiply by 4
            SHL16   r8          ; r8 = 4*offset
            glo     rc          ; get offset value
            str     r2          ; put offset in M(X) for add
            glo     r8          ; get index register lo byte
            add                 ; add offset to lo byte
            plo     r8          ; save lo byte
            ghi     r8          ; 4*offset + offset = 5*offset
            adci     0          ; update hi byte with carry flag
            phi     r8          ; r8 = 5 * offset
            
            ADD16   rf, r8      ; rf now points to character data in table
                                            
            ;---- set up byte counter            
            ldi      5          ; 5 bytes in font table for character
            plo     rc          ; set up outer counter in rc.0

            ghi     r7          ; save copy of y origin
            phi     r8  
            
            ;-------------------------------------------------------------------
            ; Each font consists of five data bytes which represent bits
            ; in a 5x7 character bitmap.  Each byte represents one column
            ; of vertical font bitmap data. Character bitmaps are printed
            ; with one column spacing to yield 6x8 pixel characters.
            ;-------------------------------------------------------------------
            
shft_font:  glo     rc          ; check outer counter
            lbz     char_done   ; done, when all char bytes are set

            lda     rf          ; get next character data byte
            phi     rc          ; save data byte for shifting

                        
            ldi      8          ; set up inner bit counter
            plo     r8          ; 8 bits per font byte
            
            ;---- inner loop to shift font byte
shft_bits:  glo     r8          ; check shift value count
            lbz     shft_done
            
            ghi     rc          ; get data byte
            shr                 ; shift lsb into DF
            phi     rc          ; save shifted font data byte
            lbnf    no_draw     ; if bit is zero, don't draw anything
            
            call    gfx_check_bounds
            lbdf    no_draw     ; if out of bounds, don't draw it
  
            ;---- bytes represent font columns (vertical font data)
            call    gfx_disp_pixel
              
no_draw:    dec     r8          ; count down
            ghi     r7          ; increment y value for next bit
            adi      1          ; signed byte add
            phi     r7          ; save updated y 
            lbr     shft_bits   ; keep going until done

            
            ;---- inner loop done                        
shft_done:  ghi     r8          ; reset y back to origin for next byte
            phi     r7          ; reset pixel y value
            
            glo     r7          ; increment x value for next byte
            adi      1          ; signed byte add
            plo     r7          ; update pixel x value for next byte 
            
            ;---- outer loop counter
            dec     rc          ; count down character bytes
            lbr     shft_font   ; keep going until all 5 bytes done
                        
char_done:  pop     rc          ; restore registers
            pop     rf
            clc                 ; clear DF because of arithmetic
            return

            endp
