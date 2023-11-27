# GFX-1802-Library
A graphics library written in 1802 Assembler code based on the Adafruit_GFX-Library written by Ladyada Limor Fried.

Introduction
------------
This repository contains 1802 Assembler code for a core graphics library based on Adafruit's [Adafruit_GFX-Library](https://github.com/adafruit/Adafruit-GFX-Library) written by Ladyada Limor Fried. 

Assembler and Linker  
--------------------
These programs were assembled and linked with updated versions of the Asm-02 assembler and Link-02 linker by Mike Riley and updated by Tony Hefner. The updated versions required to assemble and link this code are available at [fourstix/Asm-02](https://github.com/fourstix/Asm-02) and [fourstix/Link-02](https://github.com/fourstix/Link-02).

Supported Displays
------------------
* [Adafruit 8x8 BiColor LED Matrix](https://github.com/fourstix/Elfos-I2C-Libraries/tree/main#gfx-1802-library)

GFX Display Interface
---------------------
The following methods need to be implemented in a device library that is linked to this library.  These methods are called by the GFX API methods and they encapsulate the device specific details. 

* gfx_disp_size   - return the height and width of the display.
* gfx_disp_clear  - set the memory buffer data to clear all pixels.
* gfx_disp_pixel  - set the data in the memory buffer corresponding to a particular x,y co-ordinates in the display.
* gfx_disp_h_line - set the data in the memory buffer for a horizontal line.
* gfx_disp_v_line - set the data in the memory buffer for a vertical line

## Interface Registers:
* ra.1 = display height 
* ra.0 = display width
* r9.1 = color
* r9.0 = line length  
* r7.1 = origin y (row value, 0 to display height-1)
* r7.0 = origin x (column value, 0 to display width-1)

<table>
<tr><th>Name</th><th>R7.1</th><th>R7.0</th><th>R9.1</th><th>R9.0</th><th>Returns</th></tr>
<tr><td rowspan="2">gfx_disp_size</th><td rowspan="2" colspan="4">(No Inputs)</td><td>RA.1 = device height</td></tr>
<tr><td>RA.0 = display width</td></tr>
<tr><td>gfx_disp_clear</th><td colspan="4">(No Inputs)</td><td>DF = 1, if error</td></tr>
<tr><td>gfx_disp_pixel</td><td>y</td><td>x</td><td>color</td><td> - </td><td>DF = 1, if error</td></tr>
<tr><td>gfx_disp_h_line</td><td>origin y</td><td>origin x</td><td>color</td><td>length</td><td>DF = 1, if error</td></tr>
<tr><td>gfx_disp_v_line</td><td>origin y</td><td>origin x</td><td>color</td><td>length</td><td>DF = 1, if error</td></tr>
</table>

Graphics Library API
---------------------

## Public API List
The methods validate inputs and check boundaries before updating the display buffer.

* gfx_draw_pixel   - set a pixel at a particular x,y co-ordinates.
* gfx_draw_line    - set pixels to form a line from x0,y0 to x1,y1
* gfx_draw_rect    - set pixels to form a rectangle with its upper left corner at x0,y0 with width w and height h.
* gfx_fill_rect    - set pixels to form a filled rectangle with its upper left corner at x0,y0 with width w and height h.
* gfx_draw_bitmap  - set pixels to draw a bitmap of width w and height h with its upper left corner at x0,y0.
* gfx_draw_char    - draw a character at x0,y0

## API Registers:
* r7.1 = origin y (row value, 0 to device height-1)
* r7.0 = origin x (column value, 0 to device width-1)
* r8.1 = endpoint y, or height
* r8.0 = endpoint x, or width
* r9.1 = color
* r9.0 = ASCII character  

<table>
<tr><th>Name</th><th>R7.1</th><th>R7.0</th><th>R8.1</th><th>R8.0</th><th>R9.1</th><th>R9.0</th></tr>
<tr><th colspan="7">Notes</th></tr>
<tr><td>gfx_draw_pixel</td><td>y</td><td>x</td><td> - </td><td> - </td><td>color</td><td> - </td></tr>
<tr><td colspan="7">Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_draw_line</td><td>origin y</td><td> origin x</td><td>endpoint y</td><td>endpoint x</td><td>color</td><td> - </td></tr>
<tr><td colspan="7">Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_draw_rect</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td>color</td><td> - </td></tr>
<tr><td colspan="7">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>gfx_fill_rect</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td>color</td><td> - </td></tr>
<tr><td colspan="7">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>gfx_draw_bitmap</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td>color</td><td> - </td></tr>
<tr><td colspan="7">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>gfx_draw_char</td><td>origin y</td><td>origin x</td><td> - </td><td> - </td><td>color</td><td>character</td></tr>
<tr><td colspan="7">Checks origin x,y values, returns error (DF = 1) if out of bounds. Checks ASCII character value, draws DEL (127) if non-printable.<br> Returns: r7 points to next character position.</td></tr>
</table>


## Private API List
The methods write directly to the display buffer. They may not validate inputs or check boundaries.  They may consume registers and are meant to be called by one of the public API methods rather than called directly.

* gfx_check_bounds  - validate that x,y co-ordinates are within the display height and width.
* gfx_adj_bounds    - adjust the x,y co-ordinates to remain within the display height and width.
* gfx_check_overlap - validate that x,y co-ordinates and height and width are within the display height and width.
* gfx_write_pixel   - write data for a pixel at a particular x,y co-ordinates
* gfx_write_line    - write data to form a line from x0,y0 to x1,y1
* gfx_steep_flag    - set a flag if a line from x0,y0 to x1,y1 is steeply slanted.
* gfx_write_s_line  - write data to form a slanted line from x0,y0 to x1,y1
* gfx_write_rect    - write data to form a rectangle with its upper left corner at x0,y0 with width w and height h.
* gfx_write_block   - write data to form a filled rectangle with its upper left corner at x0,y0 with width w and height h.
* gfx_write_bitmap  - write data for a bitmap of width w and height h with its upper left corner at x0,y0.
* gfx_ascii_font    - ASCII character bitmap patterns
* gfx_write_char    - write data for an ASCII character at x0,y0

## API Registers:
* r7.1 = origin y (row value, 0 to device height-1)
* r7.0 = origin x (column value, 0 to device width-1)
* r8.1 = endpoint y, or height
* r8.0 = endpoint x, or width
* r9.1 = color
* r9.0 = ASCII character or steep flag  

## Notes: ##
Public Gfx API call one or more private Gfx API which, in turn, call one or more of the Gfx Interface methods. The table below lists the Private API and the Gfx Interface methods they call.

<table>
<tr><th>Private API</th><th>Gfx Interface Methods Called</th></tr>
<tr><td>gfx_check_bounds</td><td rowspan="3">gfx_disp_size</td></tr>
<tr><td>gfx_adj_bounds</td></tr>
<tr><td>gfx_check_overlap</td>
<tr><td>gfx_write_pixel</td><td rowspan="4">gfx_disp_pixel</td></tr>
<tr><td>gfx_write_bitmap</td></tr>
<tr><td>gfx_write_char</td></tr>
<tr><td>gfx_write_s_line</td></tr>
<tr><td>gfx_write_block</td><td>gfx_disp_v_line</td></tr>
<tr><td rowspan="2">gfx_write_rect</td><td>gfx_disp_h_line</td></tr>
<tr><td>gfx_disp_v_line</td></tr>
<tr><td rowspan="2">gfx_write_line</td><td>gfx_disp_h_line</td></tr>
<tr><td>gfx_disp_v_line</td></tr>
<tr><td>gfx_steep_flag</td><td rowspan="2">(None)</td></tr>
<tr><td>gfx_ascii_font</td></tr>
</table>

Repository Contents
-------------------
* **/src/**  -- Source files for the GFX 1802 Graphics library.
  * *.asm - Assembly source files for library functions.
  * gfx_build.bat - Windows batch file to assemble and create the gfx graphics library. Replace [Your_Path] with the correct path information for your system. 
  * clean.bat - Windows batch file to delete the gfx library and its associated files.    
* **/lib/**  -- Library file for the GFX 1802 graphics routines.
  * gfx.lib - Assembled Graphics 1802 library. The source files for library functions are in the */src/* directory.
* **/include/**  -- Include files for the GFX 1802 Graphics library.  
  * gfx_lib.inc - External definitions for the Graphics 1802 Library public API.
  * gfx_display.inc - GFX Display interface definitions required to support the GFX 1802 graphics library functions in a device library.
  * gfx_def.inc - Definitions for internal API methods used by other GFX functions.
  * ops.inc - Opcode definitions for Asm/02.
  
License Information
-------------------

This code is public domain under the MIT License, but please buy me a beverage
if you use this and we meet someday (Beerware).

References to any products, programs or services do not imply
that they will be available in all countries in which their respective owner operates.

Adafruit, the Adafruit logo, and other Adafruit products and services are
trademarks of the Adafruit Industries, in the United States, other countries or both. 

Any company, product, or services names may be trademarks or services marks of others.

All libraries used in this code are copyright their respective authors.

This code is based on code written by Tony Hefner and assembled with the Asm/02 assembler and Link/02 linker written by Mike Riley.

Elf/OS  
Copyright (c) 2004-2023 by Mike Riley

Asm/02 1802 Assembler  
Copyright (c) 2004-2023 by Mike Riley

Link/02 1802 Linker  
Copyright (c) 2004-2023 by Mike Riley

The Adafruit_GFX Library  
Copyright (c) 2012-2023 by Adafruit Industries   
Written by Limor Fried/Ladyada for Adafruit Industries. 

The 1802/Mini SPI Adapter Board   
Copyright (c) 2022-2023 by Tony Hefner

The 1802/Mini PIO Parallel Expansion Board   
Copyright (c) 2022-2023 by Tony Hefner

The 1802/Mini I2C Adapter Board   
Copyright (c) 2022-2023 by Tony Hefner

The 1802-Mini Microcomputer Hardware   
Copyright (c) 2020-2023 by David Madole

Many thanks to the original authors for making their designs and code available as open source.
 
This code, firmware, and software is released under the [MIT License](http://opensource.org/licenses/MIT).

The MIT License (MIT)

Copyright (c) 2023 by Gaston Williams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.**
