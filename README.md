# GFX-1802-Library
A graphics library written in 1802 Assembler code based on the Adafruit_GFX-Library written by Ladyada Limor Fried.

Introduction
------------
This repository contains 1802 Assembler code for a core graphics library based on Adafruit's [Adafruit_GFX-Library](https://github.com/adafruit/Adafruit-GFX-Library) written by Ladyada Limor Fried. 

Assembler and Linker  
--------------------
These programs were assembled and linked with updated versions of the Asm-02 assembler and Link-02 linker by Mike Riley and updated by Tony Hefner. The updated versions required to assemble and link this code are available at [fourstix/Asm-02](https://github.com/fourstix/Asm-02) and [fourstix/Link-02](https://github.com/fourstic/Link-02).

Supported Displays
------------------
**TBD**

Gfx Display Interface
---------------------

## GFX Display Interface API 
The following methods need to be implemented in a device library that is linked to this library.  These methods are called by the GFX API methods and they encapsulate the device specific details. 

* gfx_disp_size   - return the height and width of the display.
* gfx_disp_clear  - set the memory buffer data to clear all pixels in the display.
* gfx_disp_update - write the memory buffer to the display to update the display.
* gfx_disp_pixel  - set the data in the memory buffer corresponding to a particular x,y co-ordinates in the display.
* gfx_disp_h_line - set the data in the memory buffer for a horizontal line.
* gfx_disp_v_line - set the data in the memory buffer for a vertical line

## API Registers:
* ra.1 = display height 
* ra.0 = display width
* r9.1 = color
* r9.0 = line length  
* r7.1 = origin y (row value, 0 to display height-1)
* r7.0 = origin x (column value, 0 to display width-1)

<table>
<tr><th>Name</th><th colspan="4"></th><th>Returns</th></tr>
<tr><td rowspan="2">gfx_disp_size</th><td rowspan="2" colspan="4">(No Inputs)</td><td>RA.1 = device height</td></tr>
<tr><td>RA.0 = display width</td></tr>
<tr><td>gfx_disp_clear</th><td colspan="4">(No Inputs)</td><td>(None)</td></tr>
<tr><td>gfx_disp_update</th><td colspan="4">(No Inputs)</td><td>(None)</td></tr>
<tr><th>Name</th><th>R7.1</th><th>R7.0</th><th>R9.1</th><th>R9.0</th><th>Returns</th></tr>
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
<tr><th>Name</th><tr><th>R7.1</th><th>R7.0</th><th>R8.1</th><th>R8.0</th><th>R9.1</th><th>R9.0</th><th>Notes</th></tr>
<tr><td>gfx_draw_pixel</td><td>y</td><td>x</td><td colspan="2"> - </td><td>color</td><td> - </td><td>Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_draw_line</td><td>origin y</td><td> origin x</td><td>endpoint y</td><td>endpoint x</td><td>color</td><td> - </td><td>Checks x,y values, returns error (DF = 1) if out of bounds</td></tr>
<tr><td>gfx_draw_rect</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td>color</td><td> - </td><td>Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>gfx_fill_rect</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td>color</td><td> - </td><td>Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>gfx_draw_bitmap</td><td>origin y</td><td> origin x</td><td>height</td><td>width</td><td>color</td><td> - </td><td>Checks origin x,y values, returns error (DF = 1) if out of bounds. The w and h values may be clipped to edge of display.</td></tr>
<tr><td>gfx_draw_char</td><td>origin y</td><td>origin x</td><th colspan="2">-</th><td>color</td><td>character</td><td>Checks origin x,y values, returns error (DF = 1) if out of bounds.</td><tr><tr><td colspan="8">Checks ASCII character value, draws DEL (127) if non-printable.<br> Returns: r7 points to next character position (text wraps).</td></tr>
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
