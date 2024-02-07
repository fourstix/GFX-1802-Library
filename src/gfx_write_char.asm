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
;   r8.1 - character scale factor
;   r8.0 - character to write
;
; Registers Used:
;   rf   - pointer to char bitmap (five data bytes)
;   rc.1 - shifted data byte
;   rc.0 - outer byte counter, temp offset
;   ra.1 - scale flag (0 or 1)
;   ra.0 - scale value (2 to 8) 
;   rb.0 - inner bit counter, index register
;   rb.1 - origin y value, index register
;
; Return: (None) - r8, r9 consumed
;-------------------------------------------------------
            proc    gfx_write_char
            
            push    rf        ; save font character pointer
            push    rc        ; save counter
            push    rb        ; save scratch register
            push    ra        ; save scale register
            
            ;---- set rf to base of font table
            load    rf, gfx_ascii_font
            
            ;---- set up default values for no scale
            load    ra, $0001   ; scale flag false, delta value of 1               
            
            ghi     r8          ; get character scale value
            lbz     no_scale

            plo     ra          ; save character scale value in ra.0
            ldi     $01 
            phi     ra          ; set scale flag in ra.1 to true
              
            ;---- set up scratch register as index register
no_scale:   ldi      0          ; clear high byte of index
            phi     rb        
                
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

set_offset: plo     rb          ; put offset into index register
            plo     rc          ; save temp char offset for add
  
            ;---- each character is 5 bytes so multply offset by 5 (4+1)
            SHL16   rb          ; shift index twice to multiply by 4
            SHL16   rb          ; rb = 4*offset
            glo     rc          ; get offset value
            str     r2          ; put offset in M(X) for add
            glo     rb          ; get index register lo byte
            add                 ; add offset to lo byte
            plo     rb          ; save lo byte
            ghi     rb          ; 4*offset + offset = 5*offset
            adci     0          ; update hi byte with carry flag
            phi     rb          ; rb = 5 * offset
            
            ADD16   rf, rb      ; rf now points to character data in table
                                            
            ;---- set up byte counter            
            ldi      5          ; 5 bytes in font table for character
            plo     rc          ; set up outer counter in rc.0

            ghi     r7          ; save copy of y origin
            phi     rb  
            
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
            plo     rb          ; 8 bits per font byte
            
            ;---- inner loop to shift font byte
shft_bits:  glo     rb          ; check shift value count
            lbz     shft_done
            
            ghi     rc          ; get data byte
            shr                 ; shift lsb into DF
            phi     rc          ; save shifted font data byte
            lbnf    wc_cont     ; if bit is zero, don't draw anything
            
            call    gfx_check_bounds
            lbdf    wc_cont     ; if out of bounds, don't draw it
            
            ghi     ra          ; check char scale flag
            lbz     thin_char
                            
            glo     ra          ; draw square instead of single pixel
            plo     r8          ; w = scale value
            phi     r8          ; h = scale value
                        
            call    gfx_fill_rect   

            lbr     wc_cont     ; continue
            
            ;---- bytes represent font columns (vertical font data)
thin_char:  call   gfx_write_pixel              
              
wc_cont:    dec     rb          ; count down
            ghi     r7          ; increment y value for next bit
            str     r2          ; save in M(X)
            glo     ra          ; get scale value to add
            add
            phi     r7          ; save updated y 
            lbr     shft_bits   ; keep going until done

            
            ;---- inner loop done                        
shft_done:  ghi     rb          ; reset y back to origin for next byte
            phi     r7          ; reset pixel y value
            
            glo     r7          ; increment x value for next byte
            str     r2          ; save in M(X)
            glo     ra          ; get scale value to add
            add            
            plo     r7          ; update x value for next byte 
            
            ;---- outer loop counter
            dec     rc          ; count down character bytes
            lbr     shft_font   ; keep going until all 5 bytes done
                        
char_done:  pop     ra          ; restore registers
            pop     rb
            pop     rc
            pop     rf
            clc                 ; clear DF because of arithmetic
            return

            endp
