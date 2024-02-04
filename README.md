# GFX-1802-Library
A graphics library written in 1802 Assembler code based on the Adafruit_GFX-Library written by Ladyada Limor Fried.

Introduction
------------
This repository contains 1802 Assembler code for a common graphics library based on Adafruit's [Adafruit_GFX-Library](https://github.com/adafruit/Adafruit-GFX-Library) written by Ladyada Limor Fried. 

Assembler and Linker  
--------------------
These programs were assembled and linked with updated versions of the Asm-02 assembler and Link-02 linker by Mike Riley and updated by Tony Hefner. The updated versions required to assemble and link this code are available at [fourstix/Asm-02](https://github.com/fourstix/Asm-02) and [fourstix/Link-02](https://github.com/fourstix/Link-02).

Supported Displays
------------------
* [Adafruit 8x8 BiColor LED Matrix](https://github.com/fourstix/Elfos-I2C-Libraries/tree/main#example-program-7)
* [SH1106 OLED display](https://github.com/fourstix/Elfos-SPI-OLED-Drivers#sh1106-display-pinout)
* [SSD1306 OLED display](https://github.com/fourstix/Elfos-SPI-OLED-Drivers#ssd1306-display-pinout)
* [SSD1309 OLED display](https://github.com/fourstix/Elfos-SPI-OLED-Drivers#ssd1309-display-pinout)

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
* r8.0 = line length  
* r7.1 = origin y (row value, 0 to display height-1)
* r7.0 = origin x (column value, 0 to display width-1)

<table>
<tr><th>Name</th><th>R7.1</th><th>R7.0</th><th>R8.0</th><th>R9.1</th><th>Returns</th></tr>
<tr><td rowspan="2">gfx_disp_size</th><td rowspan="2" colspan="4">(No Inputs)</td><td>RA.1 = display height</td></tr>
<tr><td>RA.0 = display width</td></tr>
<tr><td>gfx_disp_clear</th><td colspan="4">(No Inputs)</td><td>DF = 1, if error</td></tr>
<tr><td>gfx_disp_pixel</td><td>y</td><td>x</td><td> - </td><td>color</td><td>DF = 1, if error</td></tr>
<tr><td>gfx_disp_h_line</td><td>origin y</td><td>origin x</td><td>length</td><td>color</td><td>DF = 1, if error</td></tr>
<tr><td>gfx_disp_v_line</td><td>origin y</td><td>origin x</td><td>length</td><td>color</td><td>DF = 1, if error</td></tr>
</table>

Graphics Library API
---------------------

## Public API List
The methods validate inputs and check boundaries before updating the display buffer.

* gfx_draw_pixel    - set a pixel at a particular x,y co-ordinates.
* gfx_draw_line     - set pixels to form a line from x0,y0 to x1,y1
* gfx_draw_rect     - set pixels to form a rectangle with its upper left corner at x0,y0 with width w and height h.
* gfx_fill_rect     - set pixels to form a filled rectangle with its upper left corner at x0,y0 with width w and height h.
* gfx_draw_bitmap   - set pixels to draw a bitmap of width w and height h with its upper left corner at x0,y0.
* gfx_draw_char     - draw a character, which may be scaled by size s, at x0,y0
* gfx_check_bounds  - validate that x,y co-ordinates are within the display height and width.
* gfx_adj_bounds    - adjust the x,y co-ordinates to remain within the display height and width.
* gfx_check_overlap - validate that x,y co-ordinates and height and width are within the display height and width.
* gfx_adj_cursor    - adjust the x,y co-ordinates, if needed, so the next character is drawn entirely within the display height and width.
* gfx_dimensions    - get the maximum x,y values for the rotated display
* gfx_draw_triangle - set pixels to form a triangle
* grx_fill_triangle - set pixels to form a solid triangle
* gfx_draw_circle   - set pixels to form a circle at the origin x0, y0 with a radius r
* gfx_fill_circle   - set pixels to fill a solid circle at the origin x0, y0 with a radius r
* gfx_draw_arc      - draw quadrants of a circular arc at the origin x0, y0 with a radius r

## API Registers:
* r7.1 = origin y0 (row value, 0 to device height-1)
* r7.0 = origin x0 (column value, 0 to device width-1)
* r8.1 = endpoint y1, height, character size
* r8.0 = endpoint x1, width, ASCII character, radius
* r9.1 = color
* r9.0 = rotation  
* ra.1 = endpoint y2
* ra.0 = endpoint x2, corner radius

<table>
<tr><th>Name</th><th>R7.1</th><th>R7.0</th><th>R8.1</th><th>R8.0</th><th>RA.1</th><th>RA.0</th></tr>
<tr><th colspan="7"> All functions: R9.1 = color, R9.0 = rotation </th></tr>
<tr><td>gfx_draw_pixel</td><td>y</td><td>x</td><td> - </td><td> - </td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_draw_line</td><td>origin y0</td><td> origin x0</td><td>endpoint y1</td><td>endpoint x1</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_draw_rect</td><td>origin y0</td><td> origin x0</td><td>height</td><td>width</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>gfx_fill_rect</td><td>origin y0</td><td> origin x0</td><td>height</td><td>width</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>gfx_draw_bitmap</td><td>origin y0</td><td> origin x0</td><td>height</td><td>width</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>gfx_draw_char</td><td>origin y0</td><td>origin x0</td><td>size</td><td>character</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks origin x,y values, returns error (DF = 1) if out of bounds. Checks ASCII character value, draws DEL (127) if non-printable.<br> Returns: r7 points to next character position.</td></tr>
<tr><td>gfx_check_bounds</td><td>origin y0</td><td> origin x0</td><td> - </td><td> - </td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_adj_bounds</td><td>origin y0</td><td> origin x0</td><td>height</td><td>width</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks origin x, y, width and height values. The values may be clipped to the edges of display. Returns error (DF = 1) if clipping fails.</td></tr>
<tr><td>gfx_check_overlap</td><td>origin y0</td><td> origin x0</td><td>height</td><td>width</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks origin x,y values, height and width to determine if a graphic overlaps the display, returns error (DF = 1) if no overlap.</td></tr>
<tr><td>gfx_adj_cursor</td><td>origin y0</td><td> origin x0</td><td>height</td><td>width</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks origin x,y values to validate a character can be drawn on the display. The x and y values may be adjusted so the cursor wraps to the next character position.</td></tr>
<tr><td>gfx_dimensions</td><td> - </td><td> - </td><td> - </td><td> - </td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Get the maximum  x,y values for the rotated display. Returns RA.1 = Ymax (h' - 1) and RA.0 = Xmax (w' - 1)</td></tr>
<tr><td>gfx_draw_triangle</td><td>origin y0</td><td> origin x0</td><td>endpoint y1</td><td>endpoint x1</td><td>endpoint y2</td><td>endpoint x2</td></tr>
<tr><td colspan="7">Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_fill_triangle</td><td>origin y0</td><td> origin x0</td><td>endpoint y1</td><td>endpoint x1</td><td>endpoint y2</td><td>endpoint x2</td></tr>
<tr><td colspan="7">Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_check_radius</td><td>origin y0</td><td> origin x0</td><td> - </td><td>radius</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks x,y and r values of a circle, returns error (DF = 1) if the circle defined is out of bounds</td></tr>
<tr><td>gfx_draw_circle</td><td>origin y0</td><td> origin x0</td><td> - </td><td>radius r</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks x,y and r values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_fill_circle</td><td>origin y0</td><td> origin x0</td><td> - </td><td>radius r</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks x,y and r values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_draw_arc</td><td>origin y0</td><td> origin x0</td><td>quadrants</td><td>radius r</td><td> - </td><td> - </td></tr>
<tr><td colspan="7">Checks x,y and r values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_draw_rrect</td><td>origin y0</td><td> origin x0</td><td>height</td><td>width</td><td> - </td><td>corner radius</td></tr>
<tr><td colspan="7">Checks origin x,y and r values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>gfx_fill_rrect</td><td>origin y0</td><td> origin x0</td><td>height</td><td>width</td><td> - </td><td>corner radius</td></tr>
<tr><td colspan="7">Checks origin x,y and r values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
</table>

## Private API List
The methods write directly to the display buffer. They may not validate inputs or check boundaries.  They may consume registers and are meant to be called by one of the public API methods rather than called directly.

* gfx_write_pixel   - write data for a pixel at a particular x,y co-ordinates
* gfx_write_line    - write data to form a line from x0,y0 to x1,y1
* gfx_steep_flag    - set a flag if a line from x0,y0 to x1,y1 is steeply slanted.
* gfx_write_h_line  - write data to form a horizontal line at y0 from x0 to x1
* gfx_write_v_line  - write data to form a vertical line at x0 from y0 to y1
* gfx_write_s_line  - write data to form a slanted line from x0,y0 to x1,y1
* gfx_write_rect    - write data to form a rectangle with its upper left corner at x0,y0 with width w and height h.
* gfx_write_block   - write data to form a filled rectangle with its upper left corner at x0,y0 with width w and height h.
* gfx_write_bitmap  - write data for a bitmap of width w and height h with its upper left corner at x0,y0.
* gfx_ascii_font    - ASCII character bitmap patterns
* gfx_write_char    - write data for an ASCII character, which may be scaled by size s, at x0,y0
* gfx_write_wedge   - write data to form a filled triangle with endpoints at x0,y0 at x1,y1 and at x2,y2.
* gfx_write_arc     - write data to form quarter-circle arcs of a circle of radius r at origin x0,y0.
* gfx_write_quads   - write data to form solid quadrants of a circle of radius r at origin x0,y0.
* gfx_write_disk    - write data to form a solid circle of radius r at origin x0,y0.
* gfx_write_rrect   - write data to form a rectangle with its upper left corner at x0,y0 with width w and height h and rounded corners of radius r.
* gfx_write_oblong  - write data to form a filled rectangle with its upper left corner at x0,y0 with width w and height h and rounded corners of radius r.

## API Registers:
* r7.1 = origin y0 (row value, 0 to device height-1)
* r7.0 = origin x0 (column value, 0 to device width-1)
* r8.1 = endpoint y1, height or character size
* r8.0 = endpoint x1, width or ASCII character 
* r9.1 = color
* r9.0 = rotation
* ra.1 = endpoint y2
* ra.0 = steep flag, endpoint x2 or corner radius  

## GFX API That Call GFX Interface Methods ##
Public GFX API may call private GFX API methods which, in turn, call one or more of the GFX Interface methods. The table below lists the GFX API methods and the GFX Interface methods they call.

<table>
<tr><th>GFX API</th><th>GFX Interface Methods Called</th></tr>
<tr><td>gfx_check_bounds</td><td rowspan="5">gfx_disp_size</td></tr>
<tr><td>gfx_adj_bounds</td></tr>
<tr><td>gfx_check_overlap</td>
<tr><td>gfx_adj_cursor</td></tr>
<tr><td>gfx_dimensions</td></tr>
<tr><td>gfx_write_pixel</td><td rowspan="4">gfx_disp_pixel</td></tr>
<tr><td>gfx_write_bitmap</td></tr>
<tr><td>gfx_write_char</td></tr>
<tr><td>gfx_write_s_line</td></tr>
<tr><td>gfx_write_block</td><td rowspan="4">gfx_disp_h_line<br /> gfx_disp_v_line</td></tr>
<tr><td>gfx_write_rect</td></tr>
<tr><td>gfx_write_h_line</td></tr>
<tr><td>gfx_write_v_line</td></tr>
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
