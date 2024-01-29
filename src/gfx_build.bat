[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_check_bounds.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_adj_bounds.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_check_overlap.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_pixel.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_pixel.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_bitmap.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_bitmap.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_ascii_font.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_char.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_char.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_rect.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_block.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_rect.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_fill_rect.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_h_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_v_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_s_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_steep_flag.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_adj_cursor.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_dimensions.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_triangle.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_fill_triangle.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_wedge.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_math_mul8.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_math_div8.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_circle.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_check_radius.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_arc.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_arc.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_rrect.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_rrect.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_quads.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_disk.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_fill_circle.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_oblong.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_fill_rrect.asm


type gfx_check_bounds.prg gfx_adj_bounds.prg gfx_check_overlap.prg > gfx.lib
type gfx_draw_pixel.prg gfx_write_pixel.prg gfx_write_bitmap.prg >> gfx.lib
type gfx_draw_bitmap.prg gfx_ascii_font.prg gfx_write_char.prg >> gfx.lib
type gfx_draw_char.prg gfx_write_rect.prg gfx_write_block.prg >> gfx.lib
type gfx_draw_rect.prg gfx_fill_rect.prg gfx_write_s_line.prg >> gfx.lib
type gfx_write_h_line.prg gfx_write_v_line.prg gfx_write_line.prg >> gfx.lib
type gfx_steep_flag.prg gfx_draw_line.prg gfx_adj_cursor.prg >> gfx.lib
type gfx_dimensions.prg gfx_draw_triangle.prg gfx_fill_triangle.prg >> gfx.lib
type gfx_write_wedge.prg gfx_math_mul8.prg gfx_math_div8.prg >> gfx.lib
type gfx_write_arc.prg gfx_draw_circle.prg gfx_check_radius.prg >> gfx.lib
type gfx_draw_arc.prg gfx_draw_rrect.prg gfx_write_rrect.prg >> gfx.lib
type gfx_write_quads.prg gfx_write_disk.prg gfx_fill_circle.prg >> gfx.lib
type gfx_write_oblong.prg gfx_fill_rrect.prg >> gfx.lib

copy gfx.lib ..\lib\gfx.lib
